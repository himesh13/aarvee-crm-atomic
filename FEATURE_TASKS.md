# Feature Tasks for GitHub Project

This document outlines all the feature tasks extracted from the business requirements, organized for GitHub Project creation.

## Epic 1: Core Lead Management System

### Task 1.1: Basic Lead Capture Form
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Create web-based form for initial lead capture with the following fields:
- Customer name input field
- Contact number input field
- Product dropdown with dynamic option management
- Loan amount required field
- Location input with auto-search functionality
- Lead referred by field
- Short description textarea (500 words limit)

**Acceptance Criteria**:
- Form validates all required fields
- Product dropdown allows adding new products
- Location auto-search is functional
- Form data is saved to database

---

### Task 1.2: Auto-Generated Lead Number
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Implement auto-generation of unique Lead No/File No for each new lead.

**Acceptance Criteria**:
- Lead number is automatically generated on lead creation
- Numbers are sequential and unique
- Format is configurable

---

### Task 1.3: Lead Assignment System
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Create lead assignment functionality with dropdown for assigning leads to team members.

**Acceptance Criteria**:
- Dropdown populated with active team members
- Ability to add new team members dynamically
- Assignment is tracked in database

---

### Task 1.4: Lead Status Management
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Implement lead status tracking with predefined statuses: New, In talk, Logged in, Sanctioned, Disbursed, Dead, Recycled.

**Acceptance Criteria**:
- Status dropdown with all required options
- Ability to add new status options dynamically
- Status history tracking
- Visual indicators for different statuses

---

### Task 1.5: Business Details Section
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Create comprehensive business details form section including:
- Type of employment dropdown
- Type of industry dropdown
- Lead ownership/accountability
- Type of business dropdown
- Constitution dropdown
- Years in business/job/practice
- Monthly net salary
- Other info textarea (150 words)

**Acceptance Criteria**:
- All fields save correctly
- Dropdowns support dynamic options
- Validation on numeric fields

---

### Task 1.6: Existing Loan Details Module
**Labels**: `enhancement`, `phase-1`, `priority-high`
**Description**: Create module to track existing loan obligations with:
- Name of financer (dropdown)
- Type of loan
- Tenure (3 digits max)
- Paid EMI (3 digits max)
- EMI amount
- Auto-calculated remaining tenure

**Acceptance Criteria**:
- Remaining tenure calculates automatically
- All fields validate correctly
- Multiple existing loans can be added

---

### Task 1.7: Notes and Updates System
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Implement notes, reminders, and updates functionality with:
- Unlimited note entries per lead
- Auto-timestamp for each entry
- Auto-capture of username who created/updated
- Rich text editing capability

**Acceptance Criteria**:
- Notes are timestamped automatically
- User attribution is automatic
- Notes display chronologically
- Edit and delete functionality

---

### Task 1.8: File Upload Management
**Labels**: `enhancement`, `phase-1`, `priority-critical`
**Description**: Create file upload system with:
- Unlimited file uploads per lead
- File caption/description field
- Auto-timestamp
- Auto-capture of uploader username

**Acceptance Criteria**:
- Multiple file upload supported
- File size limits enforced
- Supported file types configured
- Files are securely stored
- Download functionality works

---

## Epic 2: Property & Asset Management

### Task 2.1: Property Details Module - Core
**Labels**: `enhancement`, `phase-2`, `priority-high`
**Description**: Create property details module (visible only for Home Loan, Loan Against Property, Working Capital, Overdraft, Project Finance, SME Loans) with core fields:
- Property type dropdown (expandable)
- New purchase or owned checkbox
- Builder purchase or resale option
- Ready possession or under construction
- Classification of property dropdown

**Acceptance Criteria**:
- Module shows/hides based on loan type
- All fields save correctly
- Conditional fields work properly

---

### Task 2.2: Property Details Module - Measurements
**Labels**: `enhancement`, `phase-2`, `priority-high`
**Description**: Add property measurement and value fields:
- Property value (numeric)
- Sale deed value (numeric, for new purchase)
- Area of property with unit dropdown (Sq. Yd., Sq. Mt., Sq. Ft.)
- Age of property (3 digits max)
- Property address (50 words)
- Other info (200 words)

**Acceptance Criteria**:
- Numeric validation on all value fields
- Unit conversion option available
- Address field has character limit

---

### Task 2.3: Multiple Properties Support
**Labels**: `enhancement`, `phase-2`, `priority-high`
**Description**: Enable adding multiple properties within the same lead.

**Acceptance Criteria**:
- "Add Property" button functional
- Each property can be edited independently
- Properties can be deleted
- Property list displays clearly

---

### Task 2.4: Auto Loan Module
**Labels**: `enhancement`, `phase-2`, `priority-medium`
**Description**: Create auto loan specific fields:
- Brand input
- Model input
- Sub-model input
- Manufacturing year (4 digits max)
- Insurance validity date picker

**Acceptance Criteria**:
- Fields appear for auto loan type only
- Year validation (4 digits)
- Date picker for insurance validity

---

### Task 2.5: Machinery Loan Module
**Labels**: `enhancement`, `phase-2`, `priority-medium`
**Description**: Create machinery loan specific fields:
- Brand input
- Model input
- Purchase/invoice value
- Manufacturing/purchase year
- Description (150 words)

**Acceptance Criteria**:
- Fields appear for machinery loan type only
- Description has character limit
- Numeric validation on value fields

---

## Epic 3: Company & Individual Management

### Task 3.1: Company Details Core Fields
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Create company details module with core fields:
- Applicant/Co-applicant/Guarantor role dropdown
- Company name
- PAN number
- Registration number with type dropdown
- Date of incorporation

**Acceptance Criteria**:
- Multiple companies can be added to one lead
- Role selection works correctly
- PAN validation implemented

---

### Task 3.2: Company Contact Information
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Add company contact fields:
- Contact numbers with editable labels (Mobile, Work, Office, WhatsApp, Custom)
- Email ID
- Website URL

**Acceptance Criteria**:
- Multiple contact numbers supported
- Email validation
- URL validation for website

---

### Task 3.3: Company Address Management
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Implement company address functionality:
- Office address
- Factory address
- "Same as office" checkbox for factory address
- Business premises dropdown (Rented/Owned)
- Years at office/factory (3 digits)

**Acceptance Criteria**:
- "Same as" checkbox auto-fills factory address
- Address fields support multi-line input

---

### Task 3.4: Individual Details Core
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Create individual details module with core fields:
- Applicant/Co-applicant/Guarantor role dropdown
- Full name
- Date of birth date picker
- Marital status dropdown
- Gender selection

**Acceptance Criteria**:
- Multiple individuals can be added to one lead
- Age calculation from DOB
- Role selection works correctly

---

### Task 3.5: Individual Contact & Identity
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Add individual contact and identity fields:
- Multiple contact numbers with labels
- Email ID
- Mother's maiden name
- PAN number
- Aadhar number
- Education field

**Acceptance Criteria**:
- PAN validation
- Aadhar validation (12 digits)
- Multiple contact numbers supported

---

### Task 3.6: Individual Address Management
**Labels**: `enhancement`, `phase-3`, `priority-high`
**Description**: Implement individual address functionality:
- Residence address
- Permanent address
- "Same as residence" checkbox
- Address ownership (Rented/Owned)
- Years at residence (3 digits)

**Acceptance Criteria**:
- "Same as" checkbox auto-fills permanent address
- Ownership tracking works

---

### Task 3.7: References Management
**Labels**: `enhancement`, `phase-3`, `priority-medium`
**Description**: Create references module:
- Reference name
- Firm name
- Address
- Mobile number
- Relationship dropdown (Buyer, Supplier, Friend, Relative, etc.)

**Acceptance Criteria**:
- Unlimited references can be added
- All fields save correctly
- References can be edited/deleted

---

## Epic 4: Disbursement & Financial Tracking

### Task 4.1: Disbursement Details Core
**Labels**: `enhancement`, `phase-4`, `priority-high`
**Description**: Create disbursement details form with core fields:
- Name of financer dropdown
- Type of loan
- Loan account number
- Loan amount
- ROI with percentage indicator
- Tenure (3 digits)

**Acceptance Criteria**:
- All fields validate correctly
- ROI displays percentage symbol
- Tenure is numeric only

---

### Task 4.2: Disbursement Financial Details
**Labels**: `enhancement`, `phase-4`, `priority-high`
**Description**: Add financial tracking fields:
- Processing fees
- EMI amount
- Pre-EMI amount
- First EMI date picker
- Last EMI date picker

**Acceptance Criteria**:
- Date pickers work correctly
- Date validation (first EMI before last EMI)
- Numeric validation on amounts

---

### Task 4.3: Disbursement Insurance & Expenses
**Labels**: `enhancement`, `phase-4`, `priority-high`
**Description**: Add insurance and expense tracking:
- Loan cover insurance
- Property insurance
- Registered mortgage (Yes/No with conditional expense field)
- Other expenses
- Disbursement payment details

**Acceptance Criteria**:
- Conditional fields show/hide correctly
- All expenses tracked properly

---

### Task 4.4: Disbursement Document Management
**Labels**: `enhancement`, `phase-4`, `priority-high`
**Description**: Create document upload system for disbursement with categories:
- Sanction letter
- Repayment schedule
- Cheque copy
- Statement of Account (SOA)
- Cheque deposit slip
- Agreement copy
- Other (with custom caption)

**Acceptance Criteria**:
- Unlimited documents can be uploaded
- Document categories work correctly
- Custom caption for "Other" category
- Download functionality

---

## Epic 5: Configuration & Master Data

### Task 5.1: Product and Policy Management
**Labels**: `enhancement`, `phase-5`, `priority-medium`
**Description**: Create product and policy configuration module:
- Name of financer
- Policy text editor (2000 words capacity)
- Add unlimited product/policy entries

**Acceptance Criteria**:
- Rich text editor for policy details
- Character limit enforced (2000 words)
- CRUD operations work

---

### Task 5.2: DSA Code Management
**Labels**: `enhancement`, `phase-5`, `priority-medium`
**Description**: Create DSA code tracking module:
- Name of financer
- Registered firm name
- DSA code
- Add unlimited DSA code entries

**Acceptance Criteria**:
- All fields save correctly
- CRUD operations work

---

### Task 5.3: ROI Updates Management
**Labels**: `enhancement`, `phase-5`, `priority-medium`
**Description**: Create ROI tracking module:
- Name of financer
- Latest ROI
- File upload capability
- Text box for manual entry

**Acceptance Criteria**:
- File upload and text entry both supported
- Unlimited ROI updates can be added
- Date tracking for updates

---

## Epic 6: Human Resources

### Task 6.1: Employee Management Core
**Labels**: `enhancement`, `phase-6`, `priority-low`
**Description**: Create employee management module with core fields:
- Employee name
- Multiple contact numbers
- Email ID
- Address
- Qualification

**Acceptance Criteria**:
- Unlimited employees can be added
- All fields validate correctly

---

### Task 6.2: Employee Financial Details
**Labels**: `enhancement`, `phase-6`, `priority-low`
**Description**: Add employee financial tracking:
- Salary information
- Bank name
- Account number
- Bank branch
- IFSC code

**Acceptance Criteria**:
- IFSC code validation
- Account number validation
- Salary tracking works

---

## Epic 7: Advanced Features & Automation

### Task 7.1: Dead Lead Restore
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Implement functionality to restore dead leads at any time.

**Acceptance Criteria**:
- Dead leads can be viewed in a separate list
- Restore button brings lead back to active status
- Status history is maintained

---

### Task 7.2: Lead to Contact Conversion
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Enable converting leads to contacts when deals close.

**Acceptance Criteria**:
- Convert button available on leads
- All lead data transfers to contact
- Original lead is archived

---

### Task 7.3: Duplicate Lead Creation
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Allow creating duplicate leads for returning clients with new lead numbers.

**Acceptance Criteria**:
- "Duplicate" button copies all relevant data
- New unique lead number is generated
- Original lead remains unchanged

---

### Task 7.4: Login Details Export to PDF/Word
**Labels**: `enhancement`, `phase-7`, `priority-medium`
**Description**: Create login details export functionality with:
- Export to Word or PDF format
- Customizable based on applicant type
- Company letterhead formatting
- Relevant details selection

**Acceptance Criteria**:
- Export generates properly formatted document
- Letterhead displays correctly
- All selected details are included

---

### Task 7.5: Direct Document Sharing
**Labels**: `enhancement`, `phase-7`, `priority-medium`
**Description**: Implement direct document sharing capability.

**Acceptance Criteria**:
- Share button generates shareable link
- Access control options available
- Sharing log is maintained

---

### Task 7.6: Lead/Contact Print Functionality
**Labels**: `enhancement`, `phase-7`, `priority-medium`
**Description**: Add print functionality for full lead or contact details.

**Acceptance Criteria**:
- Print view is properly formatted
- All relevant details are included
- Print layout is printer-friendly

---

### Task 7.7: Notification System
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Implement comprehensive notification system:
- Notifications for all users on updates
- Auto-generated timestamp
- Username tracking for updates
- In-app notification display

**Acceptance Criteria**:
- Notifications appear in real-time
- Users can mark notifications as read
- Notification history is maintained

---

### Task 7.8: Birthday Reminders
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Create birthday reminder system for contacts.

**Acceptance Criteria**:
- Birthday reminders appear on dashboard
- Notifications sent on birthday
- Option to send birthday greetings

---

### Task 7.9: Loan Top-up Reminders
**Labels**: `enhancement`, `phase-7`, `priority-high`
**Description**: Implement 12-month reminder system for loan top-up opportunities.

**Acceptance Criteria**:
- Reminders trigger 12 months after disbursement
- Notifications sent to assigned team member
- Reminder history tracked

---

### Task 7.10: Auto-Save Functionality
**Labels**: `enhancement`, `phase-7`, `priority-critical`
**Description**: Implement auto-save to prevent data loss during updates.

**Acceptance Criteria**:
- Form data auto-saves every 30 seconds
- Recovery on page reload
- Visual indication of save status
- Works offline with sync on reconnection

---

## Epic 8: Integration & Enhancement

### Task 8.1: Advanced Search & Filter
**Labels**: `enhancement`, `phase-8`, `priority-medium`
**Description**: Enhance search and filter capabilities:
- Location-based search with auto-complete
- Multi-field filtering
- Quick search across entities
- Saved filter presets

**Acceptance Criteria**:
- Search returns relevant results
- Filters can be combined
- Filter presets can be saved
- Search performance is optimized

---

### Task 8.2: Reporting Dashboard
**Labels**: `enhancement`, `phase-8`, `priority-low`
**Description**: Create reporting and analytics dashboard with:
- Lead status reports
- Disbursement tracking reports
- Employee performance metrics
- Revenue analytics

**Acceptance Criteria**:
- Reports generate correctly
- Data visualization is clear
- Export to Excel/PDF available
- Date range filtering works

---

### Task 8.3: Mobile Responsiveness
**Labels**: `enhancement`, `phase-8`, `priority-medium`
**Description**: Ensure mobile-friendly interface across all modules.

**Acceptance Criteria**:
- All forms work on mobile devices
- Touch-friendly interface
- Responsive layout
- Mobile-optimized workflows

---

### Task 8.4: Audit Trail System
**Labels**: `enhancement`, `phase-8`, `priority-medium`
**Description**: Implement comprehensive audit trail for all changes.

**Acceptance Criteria**:
- All changes logged with timestamp and user
- Audit log is searchable
- Changes can be reviewed
- Export audit log capability

---

## Epic 9: Integration Tasks

### Task 9.1: Email Integration
**Labels**: `enhancement`, `integration`, `priority-medium`
**Description**: Integrate email capabilities for sending notifications and documents.

**Acceptance Criteria**:
- Email templates configured
- Send email from within CRM
- Email history tracked

---

### Task 9.2: SMS Integration
**Labels**: `enhancement`, `integration`, `priority-low`
**Description**: Integrate SMS gateway for notifications and reminders.

**Acceptance Criteria**:
- SMS can be sent from CRM
- SMS templates configured
- SMS history tracked

---

### Task 9.3: WhatsApp Integration
**Labels**: `enhancement`, `integration`, `priority-low`
**Description**: Integrate WhatsApp Business API for communication.

**Acceptance Criteria**:
- WhatsApp messages can be sent
- Message templates configured
- Message history tracked

---

## Total Task Count: 50+ Feature Tasks

This breakdown provides a comprehensive list of all features that can be created as GitHub issues and organized in a project board.
