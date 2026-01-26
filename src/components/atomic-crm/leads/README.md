# Leads Component

This directory contains the lead capture form implementation for Phase 1 of the business requirements.

## Components

### LeadCreate.tsx
Main component for creating new leads. Features:
- Form with validation
- UUID-based lead number generation
- Success/error notifications
- Redirect to list after creation

### LeadInputs.tsx
Form input fields organized into two columns:

**Customer Information (Left Column):**
- Customer Name (required)
- Contact Number (required)
- Product (required dropdown from products table)
- Loan Amount Required (optional, BigDecimal precision)

**Additional Details (Right Column):**
- Location (optional)
- Lead Referred By (optional)
- Short Description (optional multiline, 500 words)

### LeadList.tsx
Displays all leads in a card-based layout showing:
- Lead number
- Customer name and contact
- Product and loan amount
- Location and referral source
- Status and timestamps
- Full description (when present)

### index.ts
Resource configuration exporting:
- List component
- Create component
- Icon (ClipboardList)
- Record representation function

## Data Flow

```
User fills form → LeadCreate validates → 
Composite Data Provider routes to Custom Service →
Spring Boot API creates record →
PostgreSQL stores in custom_features.lead_extensions →
Success notification → Redirect to LeadList
```

## Integration Points

- **Data Provider**: Uses composite data provider
- **Backend**: Spring Boot custom service (port 3001)
- **Database**: custom_features.lead_extensions table
- **Products**: Loaded from public.products table
- **Auth**: Standard Supabase JWT authentication

## Styling

All components use:
- Shadcn UI components (Card, Button, etc.)
- Tailwind CSS v4 for styling
- React Hook Form for form management
- Responsive design (mobile/desktop)

## Field Validation

- Customer Name: required
- Contact Number: required
- Product: required (from dropdown)
- Loan Amount: optional, numeric
- Location: optional, text
- Lead Referred By: optional, text
- Short Description: optional, text (multiline)
