# Aarvee CRM - Product Roadmap

This roadmap outlines the planned features and enhancements for the Aarvee CRM system based on the business requirements. Features are organized into phases for systematic development.

## Phase 1: Core Lead Management System (Foundation)

### 1.1 Basic Lead Capture Form (LEVEL-1)
- **Priority**: Critical
- **Description**: Web-based form for initial lead capture
- **Features**:
  - Customer name input
  - Contact number input
  - Product dropdown (with ability to add more options dynamically)
  - Loan amount required input
  - Location input with auto-search functionality
  - Lead referred by input
  - Short description text area (500 words capacity)

### 1.2 Lead Management System (LEVEL-2)
- **Priority**: Critical
- **Description**: Advanced lead tracking and assignment
- **Features**:
  - Auto-generated Lead No/File No
  - Lead assignment dropdown (with dynamic option adding)
  - Lead status tracking: New, In talk, Logged in, Sanctioned, Disbursed, Dead, Recycled
  - Business details section:
    - Type of employment (Salaried, Self Employed, Self Employed Professional)
    - Type of industry dropdown
    - Lead ownership/accountability
    - Type of business dropdown
    - Constitution dropdown
    - Years in business/job/practice
    - Monthly net salary
    - Other info (150 words)

### 1.3 Existing Loan Details Module
- **Priority**: High
- **Description**: Track customer's existing loan obligations
- **Features**:
  - Name of financer dropdown (dynamic)
  - Type of loan
  - Tenure input (3 digits max)
  - Paid EMI (3 digits max)
  - EMI amount
  - Auto-calculated remaining tenure (tenure - paid EMI)

### 1.4 Notes, Reminders & File Management
- **Priority**: Critical
- **Description**: Document and communication tracking
- **Features**:
  - Notes section with unlimited entries
  - Reminders functionality
  - Updates tracking
  - File upload capability (unlimited files)
  - File caption/description for each upload
  - Auto-timestamp (date, time)
  - Auto-capture updated by username

## Phase 2: Property & Asset Management

### 2.1 Property Details Module
- **Priority**: High
- **Description**: Comprehensive property information for relevant loan types
- **Scope**: Only for Home Loan, Loan Against Property, Working Capital, Overdraft, Project Finance, SME Loans
- **Features**:
  - Multiple property support (unlimited)
  - Property type dropdown (Residence, Commercial, Industrial Shed, Residential/Commercial/Industrial Open Plot, School/College, Hospital, Hostel, Waterpark, Restaurant, Hotel, Banquet Hall, etc.)
  - New purchase or owned checkbox
  - Builder purchase or resale option (for new purchase)
  - Ready possession or under construction (for new purchase)
  - Classification of property dropdown (Flat, Tenement, Office, Shop, N.A.)
  - Property value (numeric)
  - Sale deed value (numeric, for new purchase)
  - Area of property with unit dropdown (Sq. Yd., Sq. Mt., Sq. Ft.)
  - Age of property (3 digits max)
  - Property address (50 words)
  - Other info (200 words)

### 2.2 Auto Loan Module
- **Priority**: Medium
- **Description**: Vehicle-specific information capture
- **Features**:
  - Brand input
  - Model input
  - Sub-model input
  - Manufacturing year (4 digits max)
  - Insurance validity date

### 2.3 Machinery Loan Module
- **Priority**: Medium
- **Description**: Equipment financing details
- **Features**:
  - Brand input
  - Model input
  - Purchase/invoice value
  - Manufacturing/purchase year
  - Description (150 words)

## Phase 3: Company & Individual Management (LEVEL-3)

### 3.1 Company Details Management
- **Priority**: High
- **Description**: Business entity information tracking
- **Features**:
  - Multiple company support (unlimited)
  - Applicant/Co-applicant/Guarantor role selection
  - Company name
  - PAN number
  - Registration number with type dropdown (S.T., C.S.T., G.S.T., etc.)
  - Contact numbers with labels (Mobile, Work, Office, WhatsApp, Custom)
  - Date of incorporation
  - Email ID
  - Website
  - Office address
  - Factory address (with "same as office" option)
  - Business premises type (Rented/Owned)
  - Years at office/factory (3 digits)
  - Login code used dropdown
  - Other info (150 words)

### 3.2 Individual Details Management
- **Priority**: High
- **Description**: Personal information for applicants and guarantors
- **Features**:
  - Multiple individuals support (unlimited)
  - Applicant/Co-applicant/Guarantor role selection
  - Full name
  - Multiple contact numbers with labels
  - Email ID
  - Date of birth
  - Marital status dropdown (Single, Married, Widow)
  - Gender
  - Residence address
  - Permanent address (with "same as residence" option)
  - Address ownership (Rented/Owned)
  - Mother's maiden name
  - PAN number
  - Aadhar number
  - Education
  - Business details (if other than applicant)
  - Years at residence (3 digits)

### 3.3 References Management
- **Priority**: Medium
- **Description**: Contact references tracking
- **Features**:
  - Unlimited reference entries
  - Reference name
  - Firm name
  - Address
  - Mobile number
  - Relationship dropdown (Buyer, Supplier, Friend, Relative, etc.)

## Phase 4: Disbursement & Financial Tracking

### 4.1 Disbursement Details
- **Priority**: High
- **Description**: Loan completion and disbursement tracking
- **Features**:
  - Name of financer dropdown
  - Type of loan
  - Loan account number
  - Loan amount
  - ROI (with percentage indicator)
  - Tenure (3 digits)
  - Processing fees
  - EMI amount
  - Pre-EMI amount
  - First EMI date picker
  - Last EMI date picker
  - Loan cover insurance
  - Property insurance
  - Registered mortgage (Yes/No with expense field)
  - Other expenses
  - Disbursement payment details

### 4.2 Document Management for Disbursement
- **Priority**: High
- **Description**: Critical financial documents storage
- **Features**:
  - Unlimited document uploads
  - Document categories:
    - Sanction letter
    - Repayment schedule
    - Cheque copy
    - Statement of Account (SOA)
    - Cheque deposit slip
    - Agreement copy
    - Other (with custom caption)

## Phase 5: Configuration & Master Data Management

### 5.1 Product and Policy Management
- **Priority**: Medium
- **Description**: Financial product configuration
- **Features**:
  - Unlimited product/policy entries
  - Name of financer
  - Policy text editor (2000 words capacity)

### 5.2 DSA Code Management
- **Priority**: Medium
- **Description**: Direct Selling Agent code tracking
- **Features**:
  - Unlimited DSA code entries
  - Name of financer
  - Registered firm name
  - DSA code

### 5.3 ROI Updates Management
- **Priority**: Medium
- **Description**: Rate of interest tracking
- **Features**:
  - Unlimited ROI update entries
  - Name of financer
  - Latest ROI with file upload and text box

## Phase 6: Human Resources Management

### 6.1 Employee Management
- **Priority**: Low
- **Description**: Internal staff management
- **Features**:
  - Unlimited employee entries
  - Employee name
  - Multiple contact numbers
  - Email ID
  - Address
  - Salary information
  - Bank details:
    - Bank name
    - Account number
    - Bank branch
    - IFSC code
  - Qualification

## Phase 7: Advanced Features & Automation

### 7.1 Lead Lifecycle Management
- **Priority**: High
- **Description**: Advanced lead handling features
- **Features**:
  - Dead lead restore functionality
  - Lead to contact conversion
  - Duplicate lead creation with new lead number (for returning clients)

### 7.2 Login Details Export
- **Priority**: Medium
- **Description**: Document generation for clients
- **Features**:
  - Login details button
  - Export to Word or PDF
  - Customizable content based on applicant type
  - Includes relevant details:
    - Applicant details (firm or individual)
    - Registration/PAN/Aadhar numbers
    - Contact information
    - Property details (for relevant loan types)
    - Formatted on company letterhead

### 7.3 Document Sharing
- **Priority**: Medium
- **Description**: Easy document distribution
- **Features**:
  - Direct document sharing option
  - Full lead/contact print functionality

### 7.4 Notification System
- **Priority**: High
- **Description**: Real-time updates and communication
- **Features**:
  - Notifications for all login IDs on updates
  - Auto-generated date and timestamp for updates
  - Username tracking for who made updates
  - Birthday reminders
  - 12-month reminder for loan top-up opportunities

### 7.5 Auto-Save Functionality
- **Priority**: Critical
- **Description**: Data loss prevention
- **Features**:
  - Auto-save during updates
  - Protection against power/connection loss
  - Recovery of last saved state

## Phase 8: Integration & Enhancement

### 8.1 Search & Filter Enhancements
- **Priority**: Medium
- **Description**: Improved data discovery
- **Features**:
  - Location-based search with auto-complete
  - Advanced filtering options
  - Quick search across all entities

### 8.2 Reporting & Analytics
- **Priority**: Low
- **Description**: Business intelligence features
- **Features**:
  - Lead status reports
  - Disbursement tracking reports
  - Employee performance tracking
  - Revenue analytics

### 8.3 Mobile Responsiveness
- **Priority**: Medium
- **Description**: Mobile-friendly interface
- **Features**:
  - Responsive design for all forms
  - Mobile-optimized workflows
  - Touch-friendly interfaces

## Implementation Notes

### Technical Considerations
1. All dropdown fields should support dynamic addition of new options
2. All multi-entry sections (properties, companies, individuals, etc.) support zero to unlimited entries
3. Auto-save functionality should be implemented across all forms
4. All timestamps should be auto-generated
5. User tracking should be automatic for all updates
6. File upload should support multiple file types with size limits

### Priority Legend
- **Critical**: Essential for MVP launch
- **High**: Important for full functionality
- **Medium**: Valuable enhancements
- **Low**: Nice-to-have features

### Development Approach
1. Start with Phase 1 (Core Lead Management) as the foundation
2. Build Phase 2-3 to complete the data model
3. Implement Phase 4 for financial tracking
4. Add Phase 5-6 for configuration and HR
5. Enhance with Phase 7-8 for advanced features

## Timeline Estimate

- **Phase 1**: 4-6 weeks (Foundation)
- **Phase 2**: 3-4 weeks (Asset Management)
- **Phase 3**: 4-5 weeks (Entity Management)
- **Phase 4**: 3-4 weeks (Financial Tracking)
- **Phase 5**: 2-3 weeks (Configuration)
- **Phase 6**: 1-2 weeks (HR Management)
- **Phase 7**: 4-5 weeks (Advanced Features)
- **Phase 8**: 3-4 weeks (Enhancements)

**Total Estimated Timeline**: 24-33 weeks (6-8 months)

---

*This roadmap is a living document and will be updated as features are completed and new requirements emerge.*
