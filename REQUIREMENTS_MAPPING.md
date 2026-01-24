# Requirements Mapping Document

This document maps each requirement from the problem statement to specific implementation strategies.

## Level 1 - Web Based Form

### Customer Name
**Status**: ✅ Fully Supported  
**Implementation**: Use existing `first_name` and `last_name` fields in Contact entity  
**Database Fields**: `contacts.first_name`, `contacts.last_name`  
**Frontend Component**: `src/components/atomic-crm/contacts/ContactForm.tsx`

### Contact Number
**Status**: ✅ Fully Supported  
**Implementation**: Use existing `phone_jsonb` field (supports multiple numbers with types)  
**Database Fields**: `contacts.phone_jsonb` (JSONB array)  
**Frontend Component**: Already supports multiple phone numbers  
**Example JSON**: 
```json
[
  {"number": "+1234567890", "type": "Mobile"},
  {"number": "+0987654321", "type": "Work"}
]
```

### Product (with dropdown, add more anytime)
**Status**: ⚠️ Needs Implementation  
**Implementation Strategy**:
1. Add new field to Contact entity: `product` (VARCHAR)
2. Add configuration in App.tsx for product options
3. Create UI dropdown component
4. Store options in database table `products` for dynamic management

**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN product VARCHAR(255);

CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Frontend Changes**:
- Add `productOptions` prop to CRM component
- Create product management page (similar to tags)
- Add dropdown in contact form

### Loan Amount Required
**Status**: ⚠️ Needs Implementation  
**Implementation**: Add new field to Contact entity  
**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN loan_amount_required BIGINT;
```
**Frontend**: Add number input field in ContactForm

### Location (type and auto search)
**Status**: ⚠️ Needs Implementation with Third-party Service  
**Implementation Options**:
1. Google Places API
2. Mapbox Geocoding API
3. OpenStreetMap Nominatim

**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN location VARCHAR(500);
ALTER TABLE contacts ADD COLUMN location_coordinates POINT;
```

**Frontend Implementation**:
```typescript
// Use react-google-places-autocomplete or similar
import GooglePlacesAutocomplete from 'react-google-places-autocomplete';

<GooglePlacesAutocomplete
  apiKey="YOUR_API_KEY"
  selectProps={{
    value: location,
    onChange: setLocation,
  }}
/>
```

### Lead Referred By
**Status**: ⚠️ Needs Implementation  
**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN lead_referred_by VARCHAR(255);
```
**Frontend**: Add text input field

### Short Description (500 words)
**Status**: ✅ Partially Supported  
**Implementation**: Use existing `background` field or add new `short_description`  
**Database**: `contacts.background` (TEXT field, already exists)  
**Frontend**: Add textarea with 500-word limit validation

---

## Level 2 - Lead Management

### Lead No/File No (Auto Generated)
**Status**: ⚠️ Needs Implementation  
**Implementation**: Generate on contact creation  
**Format**: `LEAD-YYYYMMDD-XXXXX` (e.g., LEAD-20260124-00001)

**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN lead_number VARCHAR(50) UNIQUE;

-- Create sequence for auto-increment
CREATE SEQUENCE lead_number_seq START 1;

-- Create trigger for auto-generation
CREATE OR REPLACE FUNCTION generate_lead_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.lead_number := 'LEAD-' || 
                     TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
                     LPAD(nextval('lead_number_seq')::TEXT, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_lead_number
BEFORE INSERT ON contacts
FOR EACH ROW
WHEN (NEW.lead_number IS NULL)
EXECUTE FUNCTION generate_lead_number();
```

### Lead Assigned To
**Status**: ✅ Fully Supported  
**Implementation**: Use existing `sales_id` foreign key  
**Database**: `contacts.sales_id` → `sales.id`  
**Frontend**: Dropdown populated from sales table

### Lead Status
**Status**: ⚠️ Needs Custom Values  
**Required Values**: New, In talk, Logged in, Sanctioned, Disbursed, Dead, Recycled

**Database Changes**:
```sql
-- Create enum type for lead status
CREATE TYPE lead_status_enum AS ENUM (
  'new',
  'in_talk',
  'logged_in',
  'sanctioned',
  'disbursed',
  'dead',
  'recycled'
);

ALTER TABLE contacts ADD COLUMN lead_status lead_status_enum DEFAULT 'new';
```

**Frontend**: Configure in App.tsx:
```typescript
<CRM
  leadStatuses={[
    { value: 'new', label: 'New' },
    { value: 'in_talk', label: 'In Talk' },
    { value: 'logged_in', label: 'Logged In' },
    { value: 'sanctioned', label: 'Sanctioned' },
    { value: 'disbursed', label: 'Disbursed' },
    { value: 'dead', label: 'Dead' },
    { value: 'recycled', label: 'Recycled' },
  ]}
/>
```

### Business Details (Complex Structure)

**Status**: ❌ Needs Full Implementation  
**Strategy**: Store as JSONB for flexibility

**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN business_details JSONB;
```

**JSON Structure**:
```json
{
  "employment_type": "Self Employed",
  "industry_type": "Manufacturing",
  "lead_ownership": "Owner Name",
  "business_type": "Oil mill",
  "constitution": "PROPRIETOR",
  "years_in_business": 5,
  "existing_loans": [
    {
      "financer_name": "Bank ABC",
      "loan_type": "Term Loan",
      "tenure_months": 60,
      "paid_emi_months": 24,
      "emi_amount": 50000,
      "remaining_tenure": 36
    }
  ],
  "monthly_net_salary": 100000,
  "other_info": "Additional business information..."
}
```

**Frontend**: Create `BusinessDetailsForm` component with:
- Employment type dropdown
- Industry type dropdown
- Dynamic loan details (add/remove multiple loans)
- Automatic remaining tenure calculation: `tenure - paid_emi`

### Property Details (Conditional Display)

**Status**: ❌ Needs Full Implementation  
**Condition**: Show only for: Home Loan, Loan Against Property, Working Capital, Overdraft, Project Finance, SME Loans

**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN property_details JSONB;
```

**JSON Structure**:
```json
{
  "properties": [
    {
      "property_type": "RESIDENCE",
      "ownership": "owned",
      "purchase_type": "new_purchase",
      "builder_or_resale": "builder",
      "possession_status": "ready",
      "classification": "Flat",
      "property_value": 5000000,
      "sell_deed_value": 4800000,
      "area": 1200,
      "area_unit": "Sq. Ft.",
      "age_years": 0,
      "address": "Property address here...",
      "other_info": "Additional property information..."
    }
  ]
}
```

**Frontend Implementation**:
- Conditional rendering based on `product` field
- Array of properties (add/remove multiple)
- Conditional fields based on ownership/purchase type

### Auto Loan Details

**Status**: ❌ Needs Implementation  
**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN auto_loan_details JSONB;
```

**JSON Structure**:
```json
{
  "brand": "Toyota",
  "model": "Fortuner",
  "sub_model": "4x4 AT",
  "mfg_year": 2023,
  "insurance_validity": "2025-12-31"
}
```

### Machinery Loan Details

**Status**: ❌ Needs Implementation  
**Database Changes**:
```sql
ALTER TABLE contacts ADD COLUMN machinery_loan_details JSONB;
```

**JSON Structure**:
```json
{
  "brand": "Caterpillar",
  "model": "320 Excavator",
  "purchase_value": 5000000,
  "mfg_year": 2023,
  "description": "Detailed machinery description..."
}
```

### Notes, Reminders, Updates, File Uploading

**Status**: ✅ Mostly Supported  
**Implementation**: Use existing `contactNotes` table with `attachments` JSONB array

**Existing Schema**:
```sql
CREATE TABLE contactNotes (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  text TEXT,
  date TIMESTAMP DEFAULT NOW(),
  sales_id BIGINT REFERENCES sales(id),
  status VARCHAR(50),
  attachments JSONB[]
);
```

**Enhancement Needed**: Add caption field for uploaded files
```json
{
  "attachments": [
    {
      "src": "https://storage.example.com/file.pdf",
      "title": "Aadhar Card",
      "caption": "Customer's Aadhar card front side",
      "uploaded_at": "2024-01-24T10:30:00Z",
      "uploaded_by": "John Doe"
    }
  ]
}
```

---

## Level 3 - Company & Individual Details

### Company Details (Multiple Companies per Lead)

**Status**: ❌ Major Schema Change Required  
**Current**: 1 Contact → 1 Company relationship  
**Required**: 1 Contact → N Companies relationship

**New Table Structure**:
```sql
CREATE TABLE contact_companies (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  role VARCHAR(50), -- APPLICANT, CO-APPLICANT, GUARANTOR
  company_id BIGINT REFERENCES companies(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Extend companies table with new fields
ALTER TABLE companies ADD COLUMN pan_no VARCHAR(20);
ALTER TABLE companies ADD COLUMN registration_details JSONB;
-- registration_details: {"type": "GST", "number": "27AABCU9603R1ZP"}
ALTER TABLE companies ADD COLUMN contact_numbers JSONB;
ALTER TABLE companies ADD COLUMN date_of_incorporation DATE;
ALTER TABLE companies ADD COLUMN email VARCHAR(255);
ALTER TABLE companies ADD COLUMN factory_address TEXT;
ALTER TABLE companies ADD COLUMN same_as_office BOOLEAN DEFAULT false;
ALTER TABLE companies ADD COLUMN business_premises VARCHAR(50); -- RENTED or OWNED
ALTER TABLE companies ADD COLUMN years_at_location INTEGER;
ALTER TABLE companies ADD COLUMN login_code VARCHAR(100);
ALTER TABLE companies ADD COLUMN other_info TEXT;
```

### Individual Details (Multiple Individuals per Lead)

**Status**: ❌ Major Schema Change Required  
**Strategy**: Create many-to-many relationship

**New Table Structure**:
```sql
CREATE TABLE individuals (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  contact_numbers JSONB,
  email VARCHAR(255),
  date_of_birth DATE,
  marital_status VARCHAR(20), -- SINGLE, MARRIED, WIDOW
  gender VARCHAR(20),
  residence_address TEXT,
  permanent_address TEXT,
  same_as_residence BOOLEAN DEFAULT false,
  ownership VARCHAR(20), -- RENTED or OWNED
  mother_maiden_name VARCHAR(255),
  pan_no VARCHAR(20),
  aadhar_no VARCHAR(20),
  education VARCHAR(255),
  years_at_residence INTEGER,
  business_details TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE contact_individuals (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  individual_id BIGINT REFERENCES individuals(id),
  role VARCHAR(50), -- APPLICANT, CO-APPLICANT, GUARANTOR
  created_at TIMESTAMP DEFAULT NOW()
);
```

### References

**Status**: ❌ Needs Implementation  
**Database Structure**:
```sql
CREATE TABLE contact_references (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  name VARCHAR(255),
  firm_name VARCHAR(255),
  address TEXT,
  mobile_number VARCHAR(20),
  relationship VARCHAR(100), -- BUYER, SUPPLIER, FRIEND, RELATIVE
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Disbursement Details

**Status**: ❌ Needs Full Implementation  
**Database Structure**:
```sql
CREATE TABLE disbursements (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  financer_name VARCHAR(255),
  loan_type VARCHAR(100),
  loan_account_number VARCHAR(100),
  loan_amount BIGINT,
  roi DECIMAL(5,2), -- Rate of Interest
  tenure_months INTEGER,
  processing_fees BIGINT,
  emi BIGINT,
  pre_emi BIGINT,
  first_emi_date DATE,
  last_emi_date DATE,
  loan_cover_insurance BIGINT,
  property_insurance BIGINT,
  registered_mortgage BOOLEAN,
  mortgage_expenses BIGINT,
  other_expenses BIGINT,
  payment_details TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Document Uploading

**Status**: ❌ Needs Structured Implementation  
**Database Structure**:
```sql
CREATE TABLE disbursement_documents (
  id BIGSERIAL PRIMARY KEY,
  disbursement_id BIGINT REFERENCES disbursements(id),
  document_type VARCHAR(100), -- SANCTION_LETTER, REPAYMENT_SCHEDULE, etc.
  file_url TEXT,
  file_name VARCHAR(255),
  caption TEXT,
  uploaded_at TIMESTAMP DEFAULT NOW(),
  uploaded_by BIGINT REFERENCES sales(id)
);
```

**Document Types**:
- SANCTION_LETTER
- REPAYMENT_SCHEDULE
- CHEQUE_COPY
- SOA (Statement of Account)
- CHEQUE_DEPOSIT_SLIP
- AGREEMENT_COPY
- OTHER (with custom caption)

### Product and Policy

**Status**: ❌ Needs Implementation  
**Database Structure**:
```sql
CREATE TABLE product_policies (
  id BIGSERIAL PRIMARY KEY,
  financer_name VARCHAR(255),
  policy_text TEXT, -- 2000 words capacity
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by BIGINT REFERENCES sales(id)
);
```

### DSA Code List

**Status**: ❌ Needs Implementation  
**Database Structure**:
```sql
CREATE TABLE dsa_codes (
  id BIGSERIAL PRIMARY KEY,
  financer_name VARCHAR(255),
  registered_firm_name VARCHAR(255),
  dsa_code VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### ROI Updates

**Status**: ❌ Needs Implementation  
**Database Structure**:
```sql
CREATE TABLE roi_updates (
  id BIGSERIAL PRIMARY KEY,
  financer_name VARCHAR(255),
  latest_roi DECIMAL(5,2),
  document_url TEXT,
  notes TEXT,
  updated_at TIMESTAMP DEFAULT NOW(),
  updated_by BIGINT REFERENCES sales(id)
);
```

### Employee Management

**Status**: ✅ Partially Supported  
**Current**: `sales` table exists  
**Enhancements Needed**:
```sql
ALTER TABLE sales ADD COLUMN contact_numbers JSONB;
ALTER TABLE sales ADD COLUMN address TEXT;
ALTER TABLE sales ADD COLUMN salary BIGINT;
ALTER TABLE sales ADD COLUMN bank_details JSONB;
-- bank_details: {"bank_name": "HDFC", "account_number": "123456", "branch": "Mumbai", "ifsc": "HDFC0001234"}
ALTER TABLE sales ADD COLUMN qualification VARCHAR(255);
```

---

## Additional Features

### Dead Lead Restoration

**Status**: ✅ Partially Supported  
**Implementation**: Use `archived_at` field with restore functionality

**Database**: `deals.archived_at` (already exists for deals, add to contacts)
```sql
ALTER TABLE contacts ADD COLUMN archived_at TIMESTAMP;
```

**Frontend**: Add "Restore" button in archived contacts list

### Lead Duplication

**Status**: ⚠️ Needs Implementation  
**Implementation**: Create duplicate contact with new lead number

**Frontend Button**: "Duplicate Lead" → Creates new contact with:
- All existing data copied
- New auto-generated lead number
- Status reset to "New"
- New creation timestamp

**Backend Endpoint**:
```java
@PostMapping("/contacts/{id}/duplicate")
public ResponseEntity<ContactDTO> duplicateContact(@PathVariable Long id) {
    return ResponseEntity.ok(contactService.duplicateContact(id));
}
```

### Login Details Export (PDF/Word)

**Status**: ❌ Needs Implementation  
**Required Fields**:
- Applicant details (firm or individual)
- All individual applicants
- References
- Property details (if applicable)

**Implementation Options**:
1. **PDF**: Use `pdfmake` (JavaScript) or `iText` (Java)
2. **Word**: Use `docx` (JavaScript) or `Apache POI` (Java)

**Frontend**:
```typescript
const exportLoginDetails = async (contactId: number, format: 'pdf' | 'word') => {
  const response = await fetch(`/api/contacts/${contactId}/export?format=${format}`);
  const blob = await response.blob();
  downloadFile(blob, `login-details-${contactId}.${format}`);
};
```

### Full Lead/Contact Print

**Status**: ⚠️ Needs Implementation  
**Implementation**: Generate comprehensive PDF/HTML view

**Features**:
- Company letterhead
- All contact details
- Business details
- Property details
- Loan details
- Notes and attachments
- References

### Auto-save Functionality

**Status**: ❌ Needs Implementation  
**Strategy**: Implement periodic auto-save with localStorage backup

**Frontend Implementation**:
```typescript
// Auto-save every 30 seconds
useEffect(() => {
  const interval = setInterval(() => {
    localStorage.setItem('formDraft', JSON.stringify(formData));
    // Optionally save to backend
    saveFormDraft(formData);
  }, 30000);
  
  return () => clearInterval(interval);
}, [formData]);

// Restore on mount
useEffect(() => {
  const draft = localStorage.getItem('formDraft');
  if (draft) {
    setFormData(JSON.parse(draft));
  }
}, []);
```

### Birthday Reminders

**Status**: ❌ Needs Implementation  
**Database Structure**:
```sql
CREATE TABLE reminders (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES contacts(id),
  reminder_type VARCHAR(50), -- BIRTHDAY, LOAN_TOPUP
  reminder_date DATE,
  message TEXT,
  sent BOOLEAN DEFAULT false,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create view for upcoming birthdays
CREATE VIEW upcoming_birthdays AS
SELECT 
  c.id,
  c.first_name,
  c.last_name,
  i.date_of_birth,
  DATE_PART('year', AGE(CURRENT_DATE, i.date_of_birth)) as age
FROM contacts c
JOIN contact_individuals ci ON c.id = ci.contact_id
JOIN individuals i ON ci.individual_id = i.id
WHERE 
  EXTRACT(MONTH FROM i.date_of_birth) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(DAY FROM i.date_of_birth) = EXTRACT(DAY FROM CURRENT_DATE);
```

**Backend**: Create scheduled job (Spring @Scheduled or Supabase cron)
```java
@Scheduled(cron = "0 0 9 * * ?") // Run at 9 AM daily
public void sendBirthdayReminders() {
    List<Contact> birthdayContacts = contactRepository.findTodayBirthdays();
    birthdayContacts.forEach(this::sendBirthdayReminder);
}
```

### 12-Month Loan Topup Reminder

**Status**: ❌ Needs Implementation  
**Implementation**: Track disbursement dates and create reminders

**Logic**:
```sql
-- Find loans eligible for topup (12 months since disbursement)
SELECT 
  c.id,
  c.first_name,
  c.last_name,
  d.financer_name,
  d.first_emi_date,
  AGE(CURRENT_DATE, d.first_emi_date) as loan_age
FROM contacts c
JOIN disbursements d ON c.id = d.contact_id
WHERE 
  d.first_emi_date IS NOT NULL
  AND DATE_PART('month', AGE(CURRENT_DATE, d.first_emi_date)) = 12;
```

### Notifications for Updates

**Status**: ✅ Partially Supported (needs enhancement)  
**Current**: Activity log exists  
**Enhancement**: Real-time notifications

**Implementation Options**:
1. **WebSocket**: For real-time updates
2. **Server-Sent Events (SSE)**: For one-way notifications
3. **Polling**: Simple but less efficient

**Database**:
```sql
CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES sales(id),
  type VARCHAR(50), -- NOTE_ADDED, STATUS_CHANGED, DOCUMENT_UPLOADED
  message TEXT,
  link TEXT,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Implementation Priority

### Phase 1 (Weeks 1-2): Critical Fields
1. ✅ Lead number auto-generation
2. ✅ Product dropdown
3. ✅ Loan amount required
4. ✅ Lead status custom values
5. ✅ Lead referred by

### Phase 2 (Weeks 3-4): Business Logic
1. ✅ Business details structure
2. ✅ Location autocomplete
3. ✅ Property details (conditional)
4. ✅ Auto loan details
5. ✅ Machinery loan details

### Phase 3 (Weeks 5-6): Complex Relationships
1. ✅ Multiple companies per lead
2. ✅ Multiple individuals per lead
3. ✅ References system
4. ✅ Update existing forms and views

### Phase 4 (Weeks 7-8): Financial Features
1. ✅ Disbursement details
2. ✅ Document management
3. ✅ Product and policy
4. ✅ DSA codes
5. ✅ ROI updates

### Phase 5 (Weeks 9-10): User Experience
1. ✅ Auto-save functionality
2. ✅ Birthday reminders
3. ✅ Loan topup reminders
4. ✅ Notifications system
5. ✅ Export to PDF/Word

### Phase 6 (Weeks 11-12): Testing & Polish
1. ✅ Integration testing
2. ✅ User acceptance testing
3. ✅ Performance optimization
4. ✅ Documentation
5. ✅ Deployment

---

## Summary Statistics

- **Fully Supported**: 6 features (12%)
- **Partially Supported**: 8 features (16%)
- **Needs Implementation**: 36 features (72%)

**Total Estimated Effort**: 12-16 weeks for full implementation

**Recommended Approach**: Start with Phase 1-2 (4 weeks) to get a working MVP, then iterate based on user feedback.
