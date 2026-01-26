#!/bin/bash

# GitHub Project Creation Script for Aarvee CRM Features
# This script creates a GitHub project and populates it with feature tasks

set -e

REPO_OWNER="himesh13"
REPO_NAME="aarvee-crm-atomic"
PROJECT_TITLE="Aarvee CRM Feature Roadmap"
PROJECT_DESCRIPTION="Comprehensive roadmap for Aarvee CRM features based on business requirements"

echo "=========================================="
echo "Aarvee CRM - GitHub Project Setup"
echo "=========================================="
echo ""

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is authenticated"
echo ""

# Create the project
echo "📋 Creating GitHub Project: $PROJECT_TITLE"
PROJECT_NUMBER=$(gh project create \
    --owner "$REPO_OWNER" \
    --title "$PROJECT_TITLE" \
    --format json | jq -r '.number')

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to create project"
    exit 1
fi

echo "✅ Project created with number: $PROJECT_NUMBER"
echo ""

# Function to create an issue and add it to the project
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"
    
    echo "Creating issue: $title"
    
    # Create the issue
    ISSUE_URL=$(gh issue create \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --title "$title" \
        --body "$body" \
        --label "$labels" \
        2>&1)
    
    if [[ $ISSUE_URL == *"https://github.com"* ]]; then
        echo "  ✅ Issue created: $ISSUE_URL"
        
        # Extract issue number from URL
        ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oP '\d+$')
        
        # Add issue to project
        gh project item-add "$PROJECT_NUMBER" \
            --owner "$REPO_OWNER" \
            --url "$ISSUE_URL" 2>/dev/null || echo "  ⚠️  Could not add to project"
    else
        echo "  ❌ Failed to create issue: $ISSUE_URL"
    fi
    
    sleep 1  # Rate limiting
}

# Create labels if they don't exist
echo "🏷️  Creating labels..."
gh label create "phase-1" --color "0e8a16" --description "Phase 1: Foundation" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-2" --color "1d76db" --description "Phase 2: Asset Management" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-3" --color "5319e7" --description "Phase 3: Entity Management" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-4" --color "fbca04" --description "Phase 4: Financial Tracking" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-5" --color "d93f0b" --description "Phase 5: Configuration" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-6" --color "c5def5" --description "Phase 6: HR Management" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-7" --color "f9d0c4" --description "Phase 7: Advanced Features" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "phase-8" --color "bfdadc" --description "Phase 8: Enhancement" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "priority-critical" --color "b60205" --description "Critical priority" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "priority-high" --color "d93f0b" --description "High priority" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "priority-medium" --color "fbca04" --description "Medium priority" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "priority-low" --color "0e8a16" --description "Low priority" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true
gh label create "integration" --color "c2e0c6" --description "Integration feature" --repo "$REPO_OWNER/$REPO_NAME" 2>/dev/null || true

echo "✅ Labels created"
echo ""

# Epic 1: Core Lead Management System
echo "=========================================="
echo "Creating Epic 1: Core Lead Management"
echo "=========================================="

create_issue \
    "[Epic] Core Lead Management System" \
    "## Overview
This epic covers the foundational lead management features for the CRM system.

## Features Included
- Basic lead capture form
- Auto-generated lead numbers
- Lead assignment system
- Lead status management
- Business details section
- Existing loan tracking
- Notes and file management

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown.

## Acceptance Criteria
- All basic lead information can be captured
- Lead workflow is functional from creation to assignment
- Notes and files can be attached to leads" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Basic Lead Capture Form" \
    "## Description
Create web-based form for initial lead capture with the following fields:
- Customer name input field
- Contact number input field
- Product dropdown with dynamic option management
- Loan amount required field
- Location input with auto-search functionality
- Lead referred by field
- Short description textarea (500 words limit)

## Acceptance Criteria
- [ ] Form validates all required fields
- [ ] Product dropdown allows adding new products
- [ ] Location auto-search is functional
- [ ] Form data is saved to database

## Related Epic
Part of Epic: Core Lead Management System" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Auto-Generated Lead Number System" \
    "## Description
Implement auto-generation of unique Lead No/File No for each new lead.

## Acceptance Criteria
- [ ] Lead number is automatically generated on lead creation
- [ ] Numbers are sequential and unique
- [ ] Format is configurable (e.g., LEAD-YYYY-XXXXX)

## Technical Notes
- Consider using database sequences for uniqueness
- Implement proper error handling for concurrent creation" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Lead Assignment System" \
    "## Description
Create lead assignment functionality with dropdown for assigning leads to team members.

## Acceptance Criteria
- [ ] Dropdown populated with active team members
- [ ] Ability to add new team members dynamically
- [ ] Assignment is tracked in database
- [ ] Assignment history is maintained

## Related Features
- Should integrate with employee management" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Lead Status Management" \
    "## Description
Implement lead status tracking with predefined statuses: New, In talk, Logged in, Sanctioned, Disbursed, Dead, Recycled.

## Acceptance Criteria
- [ ] Status dropdown with all required options
- [ ] Ability to add new status options dynamically
- [ ] Status history tracking
- [ ] Visual indicators for different statuses
- [ ] Status-based filtering in lead list

## UI Requirements
- Use color coding for different statuses
- Display status prominently in lead cards" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Business Details Section" \
    "## Description
Create comprehensive business details form section including:
- Type of employment dropdown (Salaried, Self Employed, Self Employed Professional)
- Type of industry dropdown
- Lead ownership/accountability
- Type of business dropdown
- Constitution dropdown
- Years in business/job/practice
- Monthly net salary
- Other info textarea (150 words)

## Acceptance Criteria
- [ ] All fields save correctly
- [ ] Dropdowns support dynamic options
- [ ] Validation on numeric fields
- [ ] Character limits enforced" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "Existing Loan Details Module" \
    "## Description
Create module to track existing loan obligations with:
- Name of financer (dropdown)
- Type of loan
- Tenure (3 digits max)
- Paid EMI (3 digits max)
- EMI amount
- Auto-calculated remaining tenure (tenure - paid EMI)

## Acceptance Criteria
- [ ] Remaining tenure calculates automatically
- [ ] All fields validate correctly
- [ ] Multiple existing loans can be added
- [ ] Loan details can be edited/deleted

## Technical Notes
- Implement calculation trigger for remaining tenure
- Validate that paid EMI doesn't exceed tenure" \
    "enhancement,phase-1,priority-high"

create_issue \
    "Notes and Updates System" \
    "## Description
Implement notes, reminders, and updates functionality with:
- Unlimited note entries per lead
- Auto-timestamp for each entry
- Auto-capture of username who created/updated
- Rich text editing capability

## Acceptance Criteria
- [ ] Notes are timestamped automatically
- [ ] User attribution is automatic
- [ ] Notes display chronologically
- [ ] Edit and delete functionality
- [ ] Search within notes

## UI Requirements
- Timeline view for notes
- Highlight recent updates" \
    "enhancement,phase-1,priority-critical"

create_issue \
    "File Upload Management System" \
    "## Description
Create file upload system with:
- Unlimited file uploads per lead
- File caption/description field
- Auto-timestamp
- Auto-capture of uploader username

## Acceptance Criteria
- [ ] Multiple file upload supported (drag & drop)
- [ ] File size limits enforced (e.g., 10MB per file)
- [ ] Supported file types configured (PDF, DOC, DOCX, XLS, XLSX, JPG, PNG)
- [ ] Files are securely stored
- [ ] Download functionality works
- [ ] File preview for images/PDFs

## Security Requirements
- Scan uploaded files for viruses
- Validate file types server-side
- Implement access control" \
    "enhancement,phase-1,priority-critical"

# Epic 2: Property & Asset Management
echo ""
echo "=========================================="
echo "Creating Epic 2: Property & Asset Management"
echo "=========================================="

create_issue \
    "[Epic] Property & Asset Management" \
    "## Overview
This epic covers property and asset-specific information capture for different loan types.

## Features Included
- Property details module (for relevant loan types)
- Multiple properties support
- Auto loan specific fields
- Machinery loan specific fields

## Loan Types Covered
- Home Loan
- Loan Against Property
- Working Capital
- Overdraft
- Project Finance
- SME Loans
- Auto Loan
- Machinery Loan

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-2,priority-high"

create_issue \
    "Property Details Module - Core Fields" \
    "## Description
Create property details module (visible only for Home Loan, Loan Against Property, Working Capital, Overdraft, Project Finance, SME Loans) with core fields:
- Property type dropdown (expandable)
- New purchase or owned checkbox
- Builder purchase or resale option
- Ready possession or under construction
- Classification of property dropdown (Flat, Tenement, Office, Shop, N.A.)

## Acceptance Criteria
- [ ] Module shows/hides based on loan type
- [ ] All fields save correctly
- [ ] Conditional fields work properly (e.g., builder/resale only for new purchase)

## UI Requirements
- Clear visual separation for conditional fields
- Helpful tooltips for complex options" \
    "enhancement,phase-2,priority-high"

create_issue \
    "Property Details - Measurements & Values" \
    "## Description
Add property measurement and value fields:
- Property value (numeric)
- Sale deed value (numeric, for new purchase only)
- Area of property with unit dropdown (Sq. Yd., Sq. Mt., Sq. Ft.)
- Age of property (3 digits max)
- Property address (50 words)
- Other info (200 words)

## Acceptance Criteria
- [ ] Numeric validation on all value fields
- [ ] Unit conversion option available
- [ ] Address field has character limit
- [ ] Sale deed value only visible for new purchase

## Enhancement Ideas
- Add calculator for unit conversion
- Validate property value vs sale deed value" \
    "enhancement,phase-2,priority-high"

create_issue \
    "Multiple Properties Support" \
    "## Description
Enable adding multiple properties within the same lead (for cases where multiple properties are being used as collateral).

## Acceptance Criteria
- [ ] \"Add Property\" button functional
- [ ] Each property can be edited independently
- [ ] Properties can be deleted (with confirmation)
- [ ] Property list displays clearly with summary
- [ ] Zero to unlimited properties supported

## UI Requirements
- Accordion or card view for properties
- Clear property numbering/identification" \
    "enhancement,phase-2,priority-high"

create_issue \
    "Auto Loan Specific Module" \
    "## Description
Create auto loan specific fields:
- Brand input
- Model input
- Sub-model input
- Manufacturing year (4 digits max)
- Insurance validity date picker

## Acceptance Criteria
- [ ] Fields appear for auto loan type only
- [ ] Year validation (4 digits, reasonable range)
- [ ] Date picker for insurance validity
- [ ] Insurance expiry warnings

## Enhancement Ideas
- Auto-populate brand/model from database
- Insurance renewal reminders" \
    "enhancement,phase-2,priority-medium"

create_issue \
    "Machinery Loan Specific Module" \
    "## Description
Create machinery loan specific fields:
- Brand input
- Model input
- Purchase/invoice value (numeric)
- Manufacturing/purchase year
- Description (150 words)

## Acceptance Criteria
- [ ] Fields appear for machinery loan type only
- [ ] Description has character limit
- [ ] Numeric validation on value fields
- [ ] Year validation

## Enhancement Ideas
- Machinery depreciation calculator
- Maintenance schedule tracking" \
    "enhancement,phase-2,priority-medium"

# Epic 3: Company & Individual Management
echo ""
echo "=========================================="
echo "Creating Epic 3: Company & Individual Management"
echo "=========================================="

create_issue \
    "[Epic] Company & Individual Management" \
    "## Overview
This epic covers comprehensive company and individual (person) information management for applicants, co-applicants, and guarantors.

## Features Included
- Company details with multiple company support
- Individual details with multiple person support
- Contact information management
- Address management
- References tracking

## Key Requirements
- Support for zero to unlimited companies per lead
- Support for zero to unlimited individuals per lead
- Role assignment (Applicant/Co-applicant/Guarantor)
- Complete KYC information capture

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-3,priority-high"

create_issue \
    "Company Details - Core Fields" \
    "## Description
Create company details module with core fields:
- Applicant/Co-applicant/Guarantor role dropdown
- Company name
- PAN number
- Registration number with type dropdown (S.T., C.S.T., G.S.T., etc.)
- Date of incorporation

## Acceptance Criteria
- [ ] Multiple companies can be added to one lead
- [ ] Role selection works correctly
- [ ] PAN validation implemented (format: AAAAA9999A)
- [ ] Registration number type is flexible

## Validation Rules
- PAN: 10 characters, specific format
- Registration number: varies by type" \
    "enhancement,phase-3,priority-high"

create_issue \
    "Company Contact Information" \
    "## Description
Add company contact fields:
- Contact numbers with editable labels (Mobile, Work, Office, WhatsApp, Custom)
- Email ID
- Website URL
- Login code used dropdown

## Acceptance Criteria
- [ ] Multiple contact numbers supported
- [ ] Email validation (proper email format)
- [ ] URL validation for website
- [ ] Custom label input for contact numbers

## UI Requirements
- Easy add/remove of contact numbers
- Label dropdown with custom option" \
    "enhancement,phase-3,priority-high"

create_issue \
    "Company Address Management" \
    "## Description
Implement company address functionality:
- Office address
- Factory address
- \"Same as office\" checkbox for factory address
- Business premises dropdown (Rented/Owned)
- Years at office/factory (3 digits)
- Other info (150 words)

## Acceptance Criteria
- [ ] \"Same as\" checkbox auto-fills factory address
- [ ] Address fields support multi-line input
- [ ] Years validation (numeric, 3 digits max)
- [ ] Ownership tracking works

## UI Requirements
- Clear separation of office vs factory address
- Auto-fill indication when addresses are same" \
    "enhancement,phase-3,priority-high"

create_issue \
    "Individual Details - Core Fields" \
    "## Description
Create individual details module with core fields:
- Applicant/Co-applicant/Guarantor role dropdown
- Full name
- Date of birth date picker
- Marital status dropdown (Single, Married, Widow)
- Gender selection
- Education field

## Acceptance Criteria
- [ ] Multiple individuals can be added to one lead
- [ ] Age calculation from DOB
- [ ] Role selection works correctly
- [ ] All dropdowns support dynamic options

## UI Requirements
- Display calculated age next to DOB
- Clear role indicators" \
    "enhancement,phase-3,priority-high"

create_issue \
    "Individual Contact & Identity Information" \
    "## Description
Add individual contact and identity fields:
- Multiple contact numbers with labels (Mobile, Work, Office, WhatsApp, Custom)
- Email ID
- Mother's maiden name
- PAN number
- Aadhar number
- Business details (if other than applicant)

## Acceptance Criteria
- [ ] PAN validation (format: AAAAA9999A)
- [ ] Aadhar validation (12 digits)
- [ ] Multiple contact numbers supported
- [ ] Email validation

## Security Requirements
- Mask sensitive data (PAN, Aadhar) in display
- Encrypt PII data in storage" \
    "enhancement,phase-3,priority-high"

create_issue \
    "Individual Address Management" \
    "## Description
Implement individual address functionality:
- Residence address
- Permanent address
- \"Same as residence\" checkbox
- Address ownership (Rented/Owned)
- Years at residence (3 digits)

## Acceptance Criteria
- [ ] \"Same as\" checkbox auto-fills permanent address
- [ ] Ownership tracking works
- [ ] Multi-line address input supported
- [ ] Years validation (numeric, 3 digits max)

## UI Requirements
- Clear labeling of address types
- Visual indication when addresses match" \
    "enhancement,phase-3,priority-high"

create_issue \
    "References Management System" \
    "## Description
Create references module:
- Reference name
- Firm name
- Address
- Mobile number
- Relationship dropdown (Buyer, Supplier, Friend, Relative, etc.)

## Acceptance Criteria
- [ ] Unlimited references can be added
- [ ] All fields save correctly
- [ ] References can be edited/deleted
- [ ] Relationship types are configurable

## UI Requirements
- Card or list view for references
- Quick add functionality
- Search/filter references" \
    "enhancement,phase-3,priority-medium"

# Epic 4: Disbursement & Financial Tracking
echo ""
echo "=========================================="
echo "Creating Epic 4: Disbursement & Financial"
echo "=========================================="

create_issue \
    "[Epic] Disbursement & Financial Tracking" \
    "## Overview
This epic covers loan disbursement details and financial tracking features.

## Features Included
- Disbursement core details
- Financial calculations
- Insurance and expense tracking
- Document management for disbursement

## Key Requirements
- Comprehensive financial data capture
- EMI calculations
- Document upload and management
- Insurance tracking

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-4,priority-high"

create_issue \
    "Disbursement Details - Core Fields" \
    "## Description
Create disbursement details form with core fields:
- Name of financer dropdown
- Type of loan
- Loan account number
- Loan amount
- ROI with percentage indicator
- Tenure (3 digits)

## Acceptance Criteria
- [ ] All fields validate correctly
- [ ] ROI displays percentage symbol
- [ ] Tenure is numeric only
- [ ] Loan account number is unique

## Enhancement Ideas
- EMI calculator based on amount, ROI, and tenure
- Comparison with other financers" \
    "enhancement,phase-4,priority-high"

create_issue \
    "Disbursement Financial Calculations" \
    "## Description
Add financial tracking fields with calculations:
- Processing fees
- EMI amount
- Pre-EMI amount
- First EMI date picker
- Last EMI date picker

## Acceptance Criteria
- [ ] Date pickers work correctly
- [ ] Date validation (first EMI before last EMI)
- [ ] Numeric validation on amounts
- [ ] EMI schedule calculation

## Calculations Required
- Total interest payable
- Total amount payable
- EMI amount validation" \
    "enhancement,phase-4,priority-high"

create_issue \
    "Disbursement Insurance & Expenses Tracking" \
    "## Description
Add insurance and expense tracking:
- Loan cover insurance
- Property insurance
- Registered mortgage (Yes/No with conditional expense field)
- Other expenses
- Disbursement payment details

## Acceptance Criteria
- [ ] Conditional fields show/hide correctly
- [ ] All expenses tracked properly
- [ ] Total expense calculation
- [ ] Insurance renewal reminders

## UI Requirements
- Clear expense breakdown
- Total cost summary" \
    "enhancement,phase-4,priority-high"

create_issue \
    "Disbursement Document Management" \
    "## Description
Create document upload system for disbursement with predefined categories:
- Sanction letter
- Repayment schedule
- Cheque copy
- Statement of Account (SOA)
- Cheque deposit slip
- Agreement copy
- Other (with custom caption)

## Acceptance Criteria
- [ ] Unlimited documents can be uploaded
- [ ] Document categories work correctly
- [ ] Custom caption for \"Other\" category
- [ ] Download functionality
- [ ] Document version control

## Security Requirements
- Secure document storage
- Access control per document
- Audit trail for document access" \
    "enhancement,phase-4,priority-high"

# Epic 5: Configuration & Master Data
echo ""
echo "=========================================="
echo "Creating Epic 5: Configuration"
echo "=========================================="

create_issue \
    "[Epic] Configuration & Master Data Management" \
    "## Overview
This epic covers configuration and master data management features.

## Features Included
- Product and policy management
- DSA code management
- ROI updates management

## Key Requirements
- Flexible configuration system
- Dynamic dropdown population
- Version control for policies and rates

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-5,priority-medium"

create_issue \
    "Product and Policy Management System" \
    "## Description
Create product and policy configuration module:
- Name of financer
- Policy text editor (2000 words capacity)
- Add unlimited product/policy entries

## Acceptance Criteria
- [ ] Rich text editor for policy details
- [ ] Character limit enforced (2000 words)
- [ ] CRUD operations work
- [ ] Version history for policies

## UI Requirements
- User-friendly editor (WYSIWYG)
- Save drafts functionality
- Preview mode" \
    "enhancement,phase-5,priority-medium"

create_issue \
    "DSA Code Management System" \
    "## Description
Create DSA (Direct Selling Agent) code tracking module:
- Name of financer
- Registered firm name
- DSA code
- Add unlimited DSA code entries

## Acceptance Criteria
- [ ] All fields save correctly
- [ ] CRUD operations work
- [ ] DSA code is unique per financer
- [ ] Search and filter DSA codes

## UI Requirements
- List view with search
- Quick add functionality" \
    "enhancement,phase-5,priority-medium"

create_issue \
    "ROI Updates Management System" \
    "## Description
Create ROI (Rate of Interest) tracking module:
- Name of financer
- Latest ROI
- File upload capability (for rate sheets)
- Text box for manual entry
- Effective date

## Acceptance Criteria
- [ ] File upload and text entry both supported
- [ ] Unlimited ROI updates can be added
- [ ] Date tracking for updates
- [ ] Historical ROI data preserved

## Enhancement Ideas
- ROI comparison across financers
- Alert on ROI changes
- ROI trend visualization" \
    "enhancement,phase-5,priority-medium"

# Epic 6: Human Resources
echo ""
echo "=========================================="
echo "Creating Epic 6: HR Management"
echo "=========================================="

create_issue \
    "[Epic] Human Resources Management" \
    "## Overview
This epic covers employee and team management features.

## Features Included
- Employee information management
- Financial details tracking
- Team assignment capabilities

## Key Requirements
- Comprehensive employee records
- Salary and banking information
- Integration with lead assignment

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-6,priority-low"

create_issue \
    "Employee Management - Core Information" \
    "## Description
Create employee management module with core fields:
- Employee name
- Multiple contact numbers
- Email ID
- Address
- Qualification

## Acceptance Criteria
- [ ] Unlimited employees can be added
- [ ] All fields validate correctly
- [ ] Employee search and filter
- [ ] Employee can be marked as active/inactive

## UI Requirements
- Employee directory view
- Profile cards
- Quick actions" \
    "enhancement,phase-6,priority-low"

create_issue \
    "Employee Financial & Banking Details" \
    "## Description
Add employee financial tracking:
- Salary information
- Bank name
- Account number
- Bank branch
- IFSC code

## Acceptance Criteria
- [ ] IFSC code validation (11 characters)
- [ ] Account number validation
- [ ] Salary history tracking
- [ ] Bank details verification

## Security Requirements
- Encrypt sensitive financial data
- Role-based access to salary information" \
    "enhancement,phase-6,priority-low"

# Epic 7: Advanced Features
echo ""
echo "=========================================="
echo "Creating Epic 7: Advanced Features"
echo "=========================================="

create_issue \
    "[Epic] Advanced Features & Automation" \
    "## Overview
This epic covers advanced CRM features including automation, notifications, and data management.

## Features Included
- Lead lifecycle management
- Document export capabilities
- Notification system
- Reminder system
- Auto-save functionality

## Key Requirements
- Robust automation
- Real-time notifications
- Data safety and recovery

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-7,priority-high"

create_issue \
    "Dead Lead Restore Functionality" \
    "## Description
Implement functionality to restore dead leads at any time.

## Acceptance Criteria
- [ ] Dead leads can be viewed in a separate list/filter
- [ ] Restore button brings lead back to active status
- [ ] Status history is maintained
- [ ] Reason for marking dead is captured
- [ ] Restore action is logged

## UI Requirements
- Clear \"Dead Leads\" section
- One-click restore
- Confirmation dialog" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Lead to Contact Conversion" \
    "## Description
Enable converting leads to contacts when deals close.

## Acceptance Criteria
- [ ] Convert button available on leads
- [ ] All lead data transfers to contact
- [ ] Original lead is archived/marked as converted
- [ ] Conversion history is maintained

## Technical Notes
- Data migration should be transactional
- Handle references correctly" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Duplicate Lead Creation for Returning Clients" \
    "## Description
Allow creating duplicate leads for returning clients with new lead numbers.

## Acceptance Criteria
- [ ] \"Duplicate\" button copies all relevant data
- [ ] New unique lead number is generated
- [ ] Original lead remains unchanged
- [ ] Link between original and duplicate is maintained
- [ ] User can select which data to copy

## UI Requirements
- Duplicate confirmation dialog
- Data selection checkboxes
- Clear indication of duplicated lead" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Login Details Export to PDF/Word" \
    "## Description
Create login details export functionality with:
- Export to Word or PDF format
- Customizable based on applicant type
- Company letterhead formatting
- Relevant details selection

## Acceptance Criteria
- [ ] Export generates properly formatted document
- [ ] Letterhead displays correctly
- [ ] All selected details are included
- [ ] Document template is customizable
- [ ] Export includes only relevant fields based on loan type

## Technical Notes
- Use template engine for document generation
- Support for both .docx and .pdf formats" \
    "enhancement,phase-7,priority-medium"

create_issue \
    "Direct Document Sharing System" \
    "## Description
Implement direct document sharing capability with:
- Shareable link generation
- Access control options
- Expiry date for links

## Acceptance Criteria
- [ ] Share button generates shareable link
- [ ] Access control options available (password, expiry)
- [ ] Sharing log is maintained
- [ ] Download tracking
- [ ] Revoke access capability

## Security Requirements
- Secure token generation
- Access logging
- Automatic link expiration" \
    "enhancement,phase-7,priority-medium"

create_issue \
    "Full Lead/Contact Print Functionality" \
    "## Description
Add comprehensive print functionality for leads and contacts.

## Acceptance Criteria
- [ ] Print view is properly formatted
- [ ] All relevant details are included
- [ ] Print layout is printer-friendly
- [ ] Page breaks are handled correctly
- [ ] Print preview available

## UI Requirements
- Print button in header
- Customizable print template
- Option to include/exclude sections" \
    "enhancement,phase-7,priority-medium"

create_issue \
    "Comprehensive Notification System" \
    "## Description
Implement comprehensive notification system:
- Notifications for all users on updates
- Auto-generated timestamp
- Username tracking for updates
- In-app notification display
- Email notification option

## Acceptance Criteria
- [ ] Notifications appear in real-time
- [ ] Users can mark notifications as read
- [ ] Notification history is maintained
- [ ] Notification preferences configurable
- [ ] Bell icon with unread count

## Technical Notes
- Consider WebSocket or SSE for real-time
- Notification queue for reliability" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Birthday Reminder System" \
    "## Description
Create birthday reminder system for contacts and individuals.

## Acceptance Criteria
- [ ] Birthday reminders appear on dashboard
- [ ] Notifications sent on birthday (or day before)
- [ ] Option to send birthday greetings (email/SMS)
- [ ] List of upcoming birthdays (7/30 days)
- [ ] Reminder preferences configurable

## UI Requirements
- Birthday widget on dashboard
- Calendar view of birthdays
- Quick greeting action" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Loan Top-up Reminder System" \
    "## Description
Implement 12-month reminder system for loan top-up opportunities.

## Acceptance Criteria
- [ ] Reminders trigger 12 months after disbursement
- [ ] Notifications sent to assigned team member
- [ ] Reminder history tracked
- [ ] Configurable reminder timing
- [ ] Top-up offer can be initiated from reminder

## Enhancement Ideas
- Suggest top-up amount based on payment history
- Auto-calculate eligibility" \
    "enhancement,phase-7,priority-high"

create_issue \
    "Auto-Save Functionality for Data Protection" \
    "## Description
Implement auto-save to prevent data loss during updates.

## Acceptance Criteria
- [ ] Form data auto-saves every 30 seconds
- [ ] Recovery on page reload
- [ ] Visual indication of save status (\"Saving...\", \"Saved\")
- [ ] Works offline with sync on reconnection
- [ ] Handles concurrent edits gracefully

## Technical Notes
- Use local storage for offline capability
- Debounce save operations
- Conflict resolution strategy

## Priority
This is CRITICAL for user experience" \
    "enhancement,phase-7,priority-critical"

# Epic 8: Integration & Enhancement
echo ""
echo "=========================================="
echo "Creating Epic 8: Enhancements"
echo "=========================================="

create_issue \
    "[Epic] Integration & Enhancement Features" \
    "## Overview
This epic covers system enhancements, integrations, and optimization features.

## Features Included
- Advanced search and filtering
- Reporting and analytics
- Mobile responsiveness
- Audit trail system
- External integrations

## Key Requirements
- Performance optimization
- User experience improvements
- Comprehensive tracking

## Related Tasks
See FEATURE_TASKS.md for detailed task breakdown." \
    "enhancement,phase-8,priority-medium"

create_issue \
    "Advanced Search & Filter System" \
    "## Description
Enhance search and filter capabilities:
- Location-based search with auto-complete
- Multi-field filtering
- Quick search across entities
- Saved filter presets
- Global search

## Acceptance Criteria
- [ ] Search returns relevant results quickly (<1 second)
- [ ] Filters can be combined (AND/OR logic)
- [ ] Filter presets can be saved and shared
- [ ] Search performance is optimized (indexed fields)
- [ ] Fuzzy search for names

## UI Requirements
- Search bar in header
- Advanced filter panel
- Filter chips showing active filters
- Clear all filters option" \
    "enhancement,phase-8,priority-medium"

create_issue \
    "Reporting & Analytics Dashboard" \
    "## Description
Create reporting and analytics dashboard with:
- Lead status reports
- Disbursement tracking reports
- Employee performance metrics
- Revenue analytics
- Conversion funnel

## Acceptance Criteria
- [ ] Reports generate correctly with current data
- [ ] Data visualization is clear (charts, graphs)
- [ ] Export to Excel/PDF available
- [ ] Date range filtering works
- [ ] Drill-down capability

## Report Types
- Daily/Weekly/Monthly summaries
- Lead source analysis
- Conversion rates
- Team performance
- Revenue trends

## Enhancement Ideas
- Scheduled report emails
- Custom report builder
- Dashboard widgets" \
    "enhancement,phase-8,priority-low"

create_issue \
    "Mobile Responsive Interface" \
    "## Description
Ensure mobile-friendly interface across all modules.

## Acceptance Criteria
- [ ] All forms work on mobile devices (iOS and Android)
- [ ] Touch-friendly interface (button sizes, tap targets)
- [ ] Responsive layout (adapts to screen size)
- [ ] Mobile-optimized workflows
- [ ] File upload works on mobile
- [ ] Performance is acceptable on mobile networks

## Testing Requirements
- Test on various screen sizes
- Test on different mobile browsers
- Test offline functionality

## UI Requirements
- Hamburger menu for navigation
- Bottom navigation for key actions
- Swipe gestures where appropriate" \
    "enhancement,phase-8,priority-medium"

create_issue \
    "Comprehensive Audit Trail System" \
    "## Description
Implement comprehensive audit trail for all changes.

## Acceptance Criteria
- [ ] All changes logged with timestamp and user
- [ ] Audit log is searchable
- [ ] Changes can be reviewed (before/after values)
- [ ] Export audit log capability
- [ ] Retention policy configurable

## Logged Events
- Lead creation/modification
- Status changes
- Assignment changes
- Document uploads/deletions
- User actions

## UI Requirements
- Audit log viewer
- Filter by user, date, action type
- Detailed change view" \
    "enhancement,phase-8,priority-medium"

create_issue \
    "Email Integration for Notifications" \
    "## Description
Integrate email capabilities for sending notifications and documents.

## Acceptance Criteria
- [ ] Email templates configured (welcome, birthday, reminder, etc.)
- [ ] Send email from within CRM
- [ ] Email history tracked
- [ ] Attachments support
- [ ] Unsubscribe mechanism

## Technical Notes
- Use transactional email service (SendGrid, AWS SES, etc.)
- Queue emails for reliability
- Handle bounces and failures" \
    "enhancement,integration,priority-medium"

create_issue \
    "SMS Integration for Alerts" \
    "## Description
Integrate SMS gateway for notifications and reminders.

## Acceptance Criteria
- [ ] SMS can be sent from CRM
- [ ] SMS templates configured
- [ ] SMS history tracked
- [ ] Delivery status tracking
- [ ] Cost tracking per SMS

## Use Cases
- Lead assignment alerts
- Birthday wishes
- Payment reminders
- Disbursement notifications

## Technical Notes
- SMS gateway integration (Twilio, AWS SNS, etc.)
- Character limit handling
- International number support" \
    "enhancement,integration,priority-low"

create_issue \
    "WhatsApp Business Integration" \
    "## Description
Integrate WhatsApp Business API for communication.

## Acceptance Criteria
- [ ] WhatsApp messages can be sent
- [ ] Message templates configured (approved by WhatsApp)
- [ ] Message history tracked
- [ ] Rich media support (images, documents)
- [ ] Delivery and read receipts

## Use Cases
- Lead follow-ups
- Document sharing
- Payment reminders
- Birthday greetings

## Technical Notes
- WhatsApp Business API setup required
- Template approval process
- Rate limits consideration" \
    "enhancement,integration,priority-low"

echo ""
echo "=========================================="
echo "✅ GitHub Project Setup Complete!"
echo "=========================================="
echo ""
echo "Project Number: $PROJECT_NUMBER"
echo "Total Issues Created: 50+"
echo ""
echo "Next Steps:"
echo "1. Visit your GitHub repository to view the project"
echo "2. Organize issues in the project board"
echo "3. Create milestones for each phase"
echo "4. Assign issues to team members"
echo "5. Start development following the roadmap"
echo ""
echo "View project at: https://github.com/users/$REPO_OWNER/projects/$PROJECT_NUMBER"
echo ""
