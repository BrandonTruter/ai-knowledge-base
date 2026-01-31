# nCino Solution Baseline Menu

## Introduction

This document provides comprehensive guidance for deploying nCino solution baselines. It explains available solution configurations, their dependencies, and deployment procedures for both internal and external environments.

### Purpose

- Serve as a definitive guide for solution deployment
- Document dependencies between solution components
- Provide clear deployment sequences and instructions
- Differentiate between internal and external deployment artifacts

### Understanding Manifest Files

- **Manifest Files**: Individual JSON files defining specific component deployments
- **MoM (Manifest of Manifests) Files**: Collection of manifests with defined dependencies and deployment order
- **Internal vs External MoM Files**:
  - **Internal**: For development, QA, and demo environments; includes additional tooling and capabilities
  - **External**: For customer deployments; contains only essential components

## Master Dependency Map

The following dependency map shows the relationships between all solution baselines:

```
Foundation
├── Commercial Lending
│   ├── Credit Analysis
│   └── Small Business Lending
├── Customer Portal
│   └── Person Account
├── Customer Onboarding
│   └── Consumer
│       ├── Consumer Deposits
│       │   ├── Consumer Deposits In-Branch
│       │   └── Consumer Deposits Online
│       │       └── Matrix Manager
│       └── Consumer Lending
│           ├── Consumer Lending In-Branch
│           ├── Consumer Lending Online
│           └── Credit Underwriting
│               └── Consumer Omnichannel
│                   └── Electronic Disclosures
├── EMEA Foundation
│   ├── EMEA Commercial Lending
│   └── EMEA Mortgage Lending
└── APAC Mortgage Lending
```

Note: EMEA and APAC solutions are independent and do not depend on the foundation components.

## Solutions

### Foundation

**Description**: Core nCino platform components that serve as the base for most other solutions.

#### External Deployment

##### Available MoM Files

- [foundation-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/foundation/environments/foundation-MoM.json)

##### Dependency Map

```
foundation-MoM.json
└── foundation
    └── foundation-users
        └── matrix-manager
            └── person-account-foundation
```

##### Deployment Sequence

1. foundation
2. foundation-users
3. matrix-manager
4. person-account-foundation

##### Record Configuration

Record Configuration Deployed: Yes

### Commercial Lending

#### Internal Deployment

##### Available MoM Files

- [commercial-lending-full-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/commercial-lending/environments/internal/commercial-lending-full-MoM.json)
- [commercial-lending-online-full-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/commercial-lending/environments/internal/commercial-lending-online-full-MoM.json)

##### Dependency Map

```
commercial-lending-full-MoM.json
└── purgeRBC
    └── aws-qa-named-credential
        └── foundation-metadata
            └── foundation-user
                └── matrix-manager
                    └── commercial-metadata
                        └── credit-analysis
                            └── commercial-records
                                └── commercial-features
                                    └── admin-persona
```

##### Deployment Sequence

1. purgeRBC
2. aws-qa-named-credential
3. foundation-metadata
4. foundation-user
5. matrix-manager
6. commercial-metadata
7. credit-analysis
8. commercial-records
9. commercial-features
10. admin-persona

##### Feature Enablement

- Administration
- Amortization_Calculator
- Analytics
- Bank_Operating_System
- Bulk_Credit_Actions
- Collateral
- Commercial_Workspace
- Connections
- Construction_Loan_Administration
- Counter_Party_Report
- Covenant_Servicing
- Covenants
- Credit_Memo
- Credit_Reporting
- Customer_Information_Maintenance
- Deal_Management
- Deal_Proposal
- Deposit_Account_Opening
- DocuSign
- Document_Manager
- Dodd_Frank_1071
- Enhanced_Credit_Memo
- Entity_Involvement
- FSC
- Fee_Management
- Force_Framework
- Form_Generation
- Loan_Origination
- Loan_Team
- Memo
- Offers
- Onboarding
- Orchestration_Framework
- Platform
- Policy_Exceptions
- Product_Package
- Questionnaire
- Risk_Grade
- Risk_Rating_Selector
- Smart_Checklist
- Snapshot
- Third_Party_Management
- Total_Exposure
- Treasury_Maintenance
- Treasury_Management
- UI_Framework
- Web_Messaging
- nCinoUI

##### Record Configuration

Record Configuration Deployed: Yes

#### External Deployment

##### Available MoM Files

- [commercial-lending-full-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/commercial-lending/environments/external/commercial-lending-full-MoM.json)
- [commercial-lending-online-full-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/commercial-lending/environments/external/commercial-lending-online-full-MoM.json)

##### Dependency Map

```
commercial-lending-full-MoM.json
└── purgeRBC
    └── foundation-metadata
        └── foundation-user
            └── matrix-manager
                └── commercial-metadata
                    └── credit-analysis
                        └── commercial-records
                            └── commercial-features
```

##### Deployment Sequence

1. purgeRBC
2. foundation-metadata
3. foundation-user
4. matrix-manager
5. commercial-metadata
6. credit-analysis
7. commercial-records
8. commercial-features

##### Feature Enablement

- Administration
- Amortization_Calculator
- Analytics
- Bank_Operating_System
- Bulk_Credit_Actions
- Collateral
- Commercial_Workspace
- Connections
- Construction_Loan_Administration
- Counter_Party_Report
- Covenant_Servicing
- Covenants
- Credit_Memo
- Credit_Reporting
- Customer_Information_Maintenance
- Deal_Management
- Deal_Proposal
- Deposit_Account_Opening
- DocuSign
- Document_Manager
- Dodd_Frank_1071
- Enhanced_Credit_Memo
- Entity_Involvement
- FSC
- Fee_Management
- Force_Framework
- Form_Generation
- Loan_Origination
- Loan_Team
- Memo
- Offers
- Onboarding
- Orchestration_Framework
- Platform
- Policy_Exceptions
- Product_Package
- Questionnaire
- Risk_Grade
- Risk_Rating_Selector
- Smart_Checklist
- Snapshot
- Third_Party_Management
- Total_Exposure
- Treasury_Maintenance
- Treasury_Management
- UI_Framework
- Web_Messaging
- nCinoUI

##### Record Configuration

Record Configuration Deployed: Yes

### Small Business Lending

#### Internal Deployment

##### Available MoM Files

- [small-business-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/small-business-lending/environments/internal/small-business-lending-MoM.json)

##### Dependency Map

```
small-business-lending-MoM.json
└── foundation
    └── commercial-lending
        └── customer-portal
            └── small-business-lending
```

##### Deployment Sequence

1. foundation
2. commercial-lending
3. customer-portal
4. small-business-lending

#### External Deployment

##### Available MoM Files

- [small-business-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/small-business-lending/environments/external/small-business-lending-MoM.json)

##### Dependency Map

```
small-business-lending-MoM.json
└── foundation
    └── commercial-lending
        └── small-business-lending
```

##### Deployment Sequence

1. foundation
2. commercial-lending
3. small-business-lending

### Consumer

#### Internal Deployment

##### Available MoM Files

- [consumer-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer/environments/internal/consumer-MoM.json)

##### Dependency Map

```
consumer-MoM.json
└── aws-qa-named-credential
    └── foundation
        ├── foundation-users
        ├── matrix-manager
        └── customer-onboarding
            └── consumer
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. foundation-users
4. matrix-manager
5. customer-onboarding
6. consumer

#### External Deployment

##### Available MoM Files

- [consumer-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer/environments/external/consumer-MoM.json)

##### Dependency Map

```
consumer-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer

### Consumer Deposits

#### Internal Deployment

##### Available MoM Files

- [consumer-deposits-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits/environments/internal/consumer-deposits-MoM.json)

##### Dependency Map

```
consumer-deposits-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── foundation-users
            └── matrix-manager
                └── customer-onboarding
                    └── consumer
                        └── consumer-deposits
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. foundation-users
4. matrix-manager
5. customer-onboarding
6. consumer
7. consumer-deposits

#### External Deployment

##### Available MoM Files

- [consumer-deposits-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits/environments/external/consumer-deposits-MoM.json)

##### Dependency Map

```
consumer-deposits-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-deposits
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-deposits

### Consumer Deposits In-Branch

#### Internal Deployment

##### Available MoM Files

- [consumer-deposits-in-branch-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits-in-branch/environments/internal/consumer-deposits-in-branch-MoM.json)

##### Dependency Map

```
consumer-deposits-in-branch-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── customer-onboarding
            └── consumer
                └── consumer-deposits
                    └── consumer-deposits-in-branch
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. customer-onboarding
4. consumer
5. consumer-deposits
6. consumer-deposits-in-branch

#### External Deployment

##### Available MoM Files

- [consumer-deposits-in-branch-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits-in-branch/environments/external/consumer-deposits-in-branch-MoM.json)

##### Dependency Map

```
consumer-deposits-in-branch-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-deposits
                └── consumer-deposits-in-branch
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-deposits
5. consumer-deposits-in-branch

### Consumer Deposits Online

#### Internal Deployment

##### Available MoM Files

- [consumer-deposits-online-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits-online/environments/internal/consumer-deposits-online-MoM.json)

##### Dependency Map

```
consumer-deposits-online-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── customer-onboarding
            └── consumer
                └── consumer-deposits
                    └── matrix-manager
                        └── consumer-deposits-online
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. customer-onboarding
4. consumer
5. consumer-deposits
6. matrix-manager
7. consumer-deposits-online

#### External Deployment

##### Available MoM Files

- [consumer-deposits-online-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-deposits-online/environments/external/consumer-deposits-online-MoM.json)

##### Dependency Map

```
consumer-deposits-online-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-deposits
                └── matrix-manager
                    └── consumer-deposits-online
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-deposits
5. matrix-manager
6. consumer-deposits-online

### Consumer Lending

#### Internal Deployment

##### Available MoM Files

- [consumer-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending/environments/internal/consumer-lending-MoM.json)

##### Dependency Map

```
consumer-lending-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── customer-onboarding
            └── consumer
                └── consumer-lending
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. customer-onboarding
4. consumer
5. consumer-lending

#### External Deployment

##### Available MoM Files

- [consumer-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending/environments/external/consumer-lending-MoM.json)

##### Dependency Map

```
consumer-lending-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-lending
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-lending

### Consumer Lending In-Branch

#### Internal Deployment

##### Available MoM Files

- [consumer-lending-in-branch-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending-in-branch/environments/internal/consumer-lending-in-branch-MoM.json)

##### Dependency Map

```
consumer-lending-in-branch-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── customer-onboarding
            └── consumer
                └── consumer-lending
                    └── consumer-lending-in-branch
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. customer-onboarding
4. consumer
5. consumer-lending
6. consumer-lending-in-branch

#### External Deployment

##### Available MoM Files

- [consumer-lending-in-branch-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending-in-branch/environments/external/consumer-lending-in-branch-MoM.json)

##### Dependency Map

```
consumer-lending-in-branch-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-lending
                └── consumer-lending-in-branch
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-lending
5. consumer-lending-in-branch

### Consumer Lending Online

#### Internal Deployment

##### Available MoM Files

- [consumer-lending-online-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending-online/environments/internal/consumer-lending-online-MoM.json)

##### Dependency Map

```
consumer-lending-online-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── customer-onboarding
            └── consumer
                └── consumer-lending
                    └── credit-underwriting
                        └── consumer-lending-online
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. customer-onboarding
4. consumer
5. consumer-lending
6. credit-underwriting
7. consumer-lending-online

#### External Deployment

##### Available MoM Files

- [consumer-lending-online-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/consumer-lending-online/environments/external/consumer-lending-online-MoM.json)

##### Dependency Map

```
consumer-lending-online-MoM.json
└── foundation
    └── customer-onboarding
        └── consumer
            └── consumer-lending
                └── credit-underwriting
                    └── consumer-lending-online
```

##### Deployment Sequence

1. foundation
2. customer-onboarding
3. consumer
4. consumer-lending
5. credit-underwriting
6. consumer-lending-online

### Customer Portal

#### Internal Deployment

##### Available MoM Files

- [customer-portal-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/customer-portal/environments/internal/customer-portal-MoM.json)

##### Dependency Map

```
customer-portal-MoM.json
└── foundation
    └── customer-portal-user
        └── customer-portal
            └── customer-portal-post-install-scripts
```

##### Deployment Sequence

1. foundation
2. customer-portal-user
3. customer-portal
4. customer-portal-post-install-scripts

##### Record Configuration

Record Configuration Deployed: Yes

#### External Deployment

##### Available MoM Files

- [customer-portal-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/customer-portal/environments/external/customer-portal-MoM.json)

##### Dependency Map

```
customer-portal-MoM.json
└── foundation
    └── customer-portal-user
        └── customer-portal
            └── customer-portal-post-install-scripts
```

##### Deployment Sequence

1. foundation
2. customer-portal-user
3. customer-portal
4. customer-portal-post-install-scripts

##### Record Configuration

Record Configuration Deployed: Yes

### EMEA Foundation

#### Available MoM Files

- [emea-foundation-manifest.json](https://github.com/ncino/solution-baseline/blob/release/src/emea/emea-foundation/emea-foundation-manifest.json)

Note: EMEA Foundation is independent and does not depend on standard Foundation.

### EMEA Commercial Lending

#### Available MoM Files

- [emea-commercial-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/emea/emea-commercial-lending/emea-commercial-lending-MoM.json)
- [emea-commercial-lending-MoM-full.json](https://github.com/ncino/solution-baseline/blob/release/src/emea/emea-commercial-lending/emea-commercial-lending-MoM-full.json)
- [emea-commercial-lending-MoM-SmartChecklist.json](https://github.com/ncino/solution-baseline/blob/release/src/emea/emea-commercial-lending/emea-commercial-lending-MoM-SmartChecklist.json)

##### Dependency Map

```
emea-commercial-lending-MoM.json
└── emea-foundation
    └── emea-commercial-lending
```

##### Deployment Sequence

1. emea-foundation
2. emea-commercial-lending

##### Record Configuration

Record Configuration Deployed: Yes

### EMEA Mortgage Lending

#### Available MoM Files

- [emea-mortgage-lending-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/emea/emea-mortgage-lending/emea-mortgage-lending-MoM.json)

##### Dependency Map

```
emea-mortgage-lending-MoM.json
└── emea-foundation
    └── emea-commercial-lending
        └── emea-mortgage-lending
```

##### Deployment Sequence

1. emea-foundation
2. emea-commercial-lending
3. emea-mortgage-lending

### APAC Mortgage Lending

#### Available Files

- [apac-mortgage-lending-manifest.json](https://github.com/ncino/solution-baseline/blob/release/src/apac/apac-mortgage-lending/apac-mortgage-lending-manifest.json)

Note: APAC solutions are independent and do not depend on the components in the foundation directory.

## Modules

### Credit Analysis

#### External Deployment

##### Available MoM Files

- [credit-analysis-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/modules/credit-analysis/credit-analysis-MoM.json)

##### Dependency Map

```
credit-analysis-MoM.json
└── spreads
    └── cre-analysis
        └── pro-forma
```

##### Deployment Sequence

1. spreads
2. cre-analysis
3. credit-analysis

##### Feature Enablement

- Spreads
- Credit_Analysis
- Formula_Creator
- Formula_Details

##### Record Configuration

Record Configuration Deployed: Yes

### Credit Underwriting

#### External Deployment

##### Available MoM Files

- [credit-underwriting-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/modules/credit-underwriting/credit-underwriting-MoM.json)

##### Dependency Map

```
credit-underwriting-MoM.json
└── aws-qa-named-credential
    └── foundation
        └── consumer
            └── consumer-lending
                └── consumer-lending-in-branch
                    └── credit-underwriting
```

##### Deployment Sequence

1. aws-qa-named-credential
2. foundation
3. consumer
4. consumer-lending
5. consumer-lending-in-branch
6. credit-underwriting

##### Feature Enablement

- Credit_Underwriting
- Retail_Lending
- Retail_Underwriting
- Retail_Pricing

##### Record Configuration

Record Configuration Deployed: Yes

### Consumer Omnichannel

#### External Deployment

##### Available MoM Files

- [consumer-omnichannel-MoM.json](https://github.com/ncino/solution-baseline/blob/release/src/modules/consumer-omnichannel/consumer-omnichannel-MoM.json)

##### Dependency Map

```
consumer-omnichannel-MoM.json
└── foundation
    └── consumer
        └── consumer-lending
            └── credit-underwriting
                └── consumer-omnichannel
```

##### Deployment Sequence

1. foundation
2. consumer
3. consumer-lending
4. credit-underwriting
5. consumer-omnichannel

##### Feature Enablement

- Income_Enhancements
- Relationship_Management_Rest

##### Record Configuration

Record Configuration Deployed: Yes

### Matrix Manager

#### External Deployment

##### Available MoM Files

- [matrix-manager-manifest.json](https://github.com/ncino/solution-baseline/blob/release/src/modules/matrix-manager/matrix-manager-manifest.json)

##### Deployment Sequence

1. foundation
2. matrix-manager

##### Feature Enablement

- Matrix_Builder
- Matrix_Manager

### Electronic Disclosures

#### External Deployment

##### Available MoM Files

- [electronic-disclosures-manifest.json](https://github.com/ncino/solution-baseline/blob/release/src/modules/electronic-disclosures/electronic-disclosures-manifest.json)

##### Deployment Sequence

1. foundation
2. electronic-disclosures

##### Feature Enablement

- Electronic_Disclosures

##### Record Configuration

Record Configuration Deployed: Yes

## Pre-deployment Requirements

Before deploying any solution baseline, ensure that:

1. The target environment meets the minimum package version requirements
2. All prerequisite solutions in the dependency tree are deployed
3. Proper permissions are in place for the deployment user
4. A backup of the environment has been created (for production deployments)

## Post-deployment Verification

After deploying a solution baseline, perform these verification steps:

1. Verify feature enablement settings
2. Validate user permissions
3. Perform basic functionality tests
4. Check for any post-deployment error logs
5. Run any required post-deployment scripts

For more information about contributing to the solution baseline repository, see the [Contributing Guide](../CONTRIBUTING.md).

For a high-level overview of the solution baseline repository, see the [README](../README.md).
