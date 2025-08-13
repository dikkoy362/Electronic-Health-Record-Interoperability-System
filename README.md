# Electronic Health Record Interoperability System

A blockchain-based Electronic Health Record (EHR) system built on Stacks that enables secure, patient-controlled sharing of medical data between healthcare providers while maintaining HIPAA compliance and privacy.

## Overview

This system addresses critical healthcare challenges:
- **Secure Data Sharing**: Enables authorized sharing of patient records between providers
- **Patient Control**: Gives patients full control over their medical data access
- **Reduced Medical Errors**: Eliminates duplicate tests and provides complete medical history
- **Emergency Access**: Supports instant record access during medical emergencies
- **HIPAA Compliance**: Maintains strict privacy and security standards

## System Architecture

The system consists of five interconnected smart contracts:

### 1. Patient Registry (\`patient-registry.clar\`)
- Manages patient identities and basic demographic information
- Handles patient registration and profile updates
- Maintains patient-to-wallet address mappings

### 2. Medical Records (\`medical-records.clar\`)
- Stores encrypted medical records and metadata
- Manages record creation, updates, and retrieval
- Implements record versioning and audit trails

### 3. Provider Registry (\`provider-registry.clar\`)
- Manages healthcare provider identities and credentials
- Handles provider registration and verification
- Maintains provider specialties and contact information

### 4. Access Control (\`access-control.clar\`)
- Manages patient consent and access permissions
- Handles authorization for record sharing
- Implements time-based and scope-limited access

### 5. Emergency Access (\`emergency-access.clar\`)
- Provides emergency access to critical medical information
- Implements break-glass access for life-threatening situations
- Maintains audit logs for emergency access events

## Key Features

### Patient-Controlled Access
- Patients grant and revoke access permissions
- Granular control over what data is shared
- Time-limited access grants
- Real-time permission management

### Provider Verification
- Healthcare provider credential verification
- License validation and specialty tracking
- Secure provider-to-provider communication

### Emergency Protocols
- Immediate access to critical medical information
- Emergency contact notifications
- Audit trail for all emergency access events

### Privacy & Security
- End-to-end encryption of medical data
- Zero-knowledge proofs for sensitive information
- Immutable audit trails
- HIPAA-compliant data handling

## Data Flow

1. **Patient Registration**: Patients register with demographic information
2. **Provider Registration**: Healthcare providers register with credentials
3. **Record Creation**: Providers create encrypted medical records
4. **Access Grant**: Patients grant specific providers access to records
5. **Record Sharing**: Authorized providers access patient records
6. **Emergency Access**: Emergency protocols provide immediate access when needed

## Security Model

- **Encryption**: All medical data is encrypted before storage
- **Access Control**: Multi-layered permission system
- **Audit Trails**: Complete logging of all access events
- **Emergency Override**: Secure break-glass access for emergencies
- **Data Integrity**: Blockchain ensures tamper-proof records

## Compliance

The system is designed to meet:
- HIPAA Privacy and Security Rules
- State medical privacy regulations
- Healthcare interoperability standards
- Blockchain security best practices

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd ehr-interoperability

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts (testnet)
clarinet deploy --testnet
\`\`\`

### Usage

1. **Register as Patient**:
   \`\`\`clarity
   (contract-call? .patient-registry register-patient "John Doe" u30 "Male")
   \`\`\`

2. **Register as Provider**:
   \`\`\`clarity
   (contract-call? .provider-registry register-provider "Dr. Smith" "Cardiology" "12345")
   \`\`\`

3. **Create Medical Record**:
   \`\`\`clarity
   (contract-call? .medical-records create-record patient-principal "encrypted-data" "Diagnosis")
   \`\`\`

4. **Grant Access**:
   \`\`\`clarity
   (contract-call? .access-control grant-access provider-principal u86400)
   \`\`\`

## Testing

The system includes comprehensive tests covering:
- Contract functionality
- Access control mechanisms
- Emergency access scenarios
- Data integrity validation
- Error handling

Run tests with:
\`\`\`bash
npm test
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This system is for educational and development purposes. Consult with healthcare compliance experts before deploying in production environments.
