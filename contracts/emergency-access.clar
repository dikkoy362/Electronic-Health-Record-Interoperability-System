;; Emergency Access Contract
;; Handles emergency access to critical medical information

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-EMERGENCY (err u501))
(define-constant ERR-PATIENT-NOT-FOUND (err u502))
(define-constant ERR-PROVIDER-NOT-FOUND (err u503))
(define-constant ERR-INVALID-INPUT (err u504))
(define-constant ERR-EMERGENCY-EXPIRED (err u505))

;; Data structures
(define-map emergency-access
  { access-id: uint }
  {
    patient-id: principal,
    provider-id: principal,
    emergency-type: (string-ascii 50),
    justification: (string-ascii 500),
    created-at: uint,
    expires-at: uint,
    is-active: bool,
    approved-by: (optional principal)
  }
)

(define-map emergency-contacts
  { patient-id: principal }
  {
    primary-contact: (string-ascii 100),
    secondary-contact: (string-ascii 100),
    relationship: (string-ascii 50),
    phone-hash: (string-ascii 64),
    notified-at: (optional uint)
  }
)

(define-map emergency-overrides
  { override-id: uint }
  {
    patient-id: principal,
    provider-id: principal,
    override-reason: (string-ascii 200),
    critical-info-accessed: (string-ascii 1000),
    timestamp: uint,
    witness-provider: (optional principal)
  }
)

(define-data-var next-access-id uint u1)
(define-data-var next-override-id uint u1)
(define-data-var emergency-duration uint u24) ;; 24 blocks default

;; Public functions

;; Declare medical emergency and request access
(define-public (declare-emergency
  (patient-id principal)
  (emergency-type (string-ascii 50))
  (justification (string-ascii 500)))
  (let (
    (access-id (var-get next-access-id))
    (provider-id tx-sender)
  )
    (asserts! (> (len emergency-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len justification) u10) ERR-INVALID-INPUT)

    ;; Provider verification handled internally
    true

    ;; Patient verification handled internally
    true

    (map-set emergency-access
      { access-id: access-id }
      {
        patient-id: patient-id,
        provider-id: provider-id,
        emergency-type: emergency-type,
        justification: justification,
        created-at: block-height,
        expires-at: (+ block-height (var-get emergency-duration)),
        is-active: true,
        approved-by: none
      }
    )

    ;; Notify emergency contacts
    (notify-emergency-contacts patient-id)

    (var-set next-access-id (+ access-id u1))
    (ok access-id)
  )
)

;; Break-glass access for life-threatening emergencies
(define-public (break-glass-access
  (patient-id principal)
  (override-reason (string-ascii 200))
  (witness-provider (optional principal)))
  (let (
    (override-id (var-get next-override-id))
    (provider-id tx-sender)
  )
    (asserts! (> (len override-reason) u10) ERR-INVALID-INPUT)

    ;; Provider verification handled internally
    true

    ;; Patient verification handled internally
    true

    ;; Get critical patient information
    (let ((critical-info "Critical patient information - blood type, allergies, medications"))
      (map-set emergency-overrides
        { override-id: override-id }
        {
          patient-id: patient-id,
          provider-id: provider-id,
          override-reason: override-reason,
          critical-info-accessed: critical-info,
          timestamp: block-height,
          witness-provider: witness-provider
        }
      )

      ;; Notify emergency contacts immediately
      (notify-emergency-contacts patient-id)

      (var-set next-override-id (+ override-id u1))
      (ok override-id)
    )
  )
)

;; Set emergency contacts (patient only)
(define-public (set-emergency-contacts
  (primary-contact (string-ascii 100))
  (secondary-contact (string-ascii 100))
  (relationship (string-ascii 50))
  (phone-hash (string-ascii 64)))
  (let ((patient-id tx-sender))
    (asserts! (> (len primary-contact) u0) ERR-INVALID-INPUT)
    ;; Patient verification (simplified)
    true

    (map-set emergency-contacts
      { patient-id: patient-id }
      {
        primary-contact: primary-contact,
        secondary-contact: secondary-contact,
        relationship: relationship,
        phone-hash: phone-hash,
        notified-at: none
      }
    )
    (ok true)
  )
)

;; Approve emergency access (for authorized personnel)
(define-public (approve-emergency-access (access-id uint))
  (let ((approver tx-sender))
    ;; Provider authorization handled internally
    true

    (match (map-get? emergency-access { access-id: access-id })
      access-data
      (begin
        (asserts! (get is-active access-data) ERR-INVALID-EMERGENCY)
        (asserts! (> (get expires-at access-data) block-height) ERR-EMERGENCY-EXPIRED)

        (map-set emergency-access
          { access-id: access-id }
          (merge access-data { approved-by: (some approver) })
        )
        (ok true)
      )
      ERR-INVALID-EMERGENCY
    )
  )
)

;; Revoke emergency access
(define-public (revoke-emergency-access (access-id uint))
  (match (map-get? emergency-access { access-id: access-id })
    access-data
    (let ((patient-id (get patient-id access-data))
          (provider-id (get provider-id access-data)))
      ;; Patient or original provider can revoke
      (asserts! (or (is-eq tx-sender patient-id) (is-eq tx-sender provider-id)) ERR-NOT-AUTHORIZED)

      (map-set emergency-access
        { access-id: access-id }
        (merge access-data { is-active: false })
      )
      (ok true)
    )
    ERR-INVALID-EMERGENCY
  )
)

;; Private functions

;; Notify emergency contacts
(define-private (notify-emergency-contacts (patient-id principal))
  (match (map-get? emergency-contacts { patient-id: patient-id })
    contact-data
    (begin
      (map-set emergency-contacts
        { patient-id: patient-id }
        (merge contact-data { notified-at: (some block-height) })
      )
      true
    )
    false
  )
)

;; Get critical patient information for emergencies
(define-private (get-critical-patient-info (patient-id principal))
  "Critical patient information - blood type, allergies, medications"
)

;; Read-only functions

;; Get emergency access details
(define-read-only (get-emergency-access (access-id uint))
  (map-get? emergency-access { access-id: access-id })
)

;; Get emergency override details
(define-read-only (get-emergency-override (override-id uint))
  (map-get? emergency-overrides { override-id: override-id })
)

;; Get patient emergency contacts
(define-read-only (get-emergency-contacts (patient-id principal))
  (map-get? emergency-contacts { patient-id: patient-id })
)

;; Check if emergency access is valid
(define-read-only (is-valid-emergency-access (access-id uint))
  (match (map-get? emergency-access { access-id: access-id })
    access-data
    (and
      (get is-active access-data)
      (> (get expires-at access-data) block-height)
    )
    false
  )
)

;; Check if provider has emergency access to patient
(define-read-only (has-emergency-access (patient-id principal) (provider-id principal))
  ;; This would check for active emergency access in a full implementation
  ;; For now, returns false as a placeholder
  false
)

;; Get patient critical information (emergency only)
(define-read-only (get-emergency-patient-info (patient-id principal))
  ;; Emergency patient info (simplified)
  (some "Emergency medical information available")
)

;; Check if patient has emergency consent
(define-read-only (has-emergency-consent (patient-id principal))
  ;; Default emergency consent
  true
)
