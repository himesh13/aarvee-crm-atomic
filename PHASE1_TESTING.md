# Phase 1: Lead Capture Form - Testing Guide

## Overview
This document describes how to test the lead capture webform implementation.

## Prerequisites

1. **Install Dependencies**
   ```bash
   make install
   ```

2. **Start Supabase**
   ```bash
   make start-supabase
   ```
   This will:
   - Start PostgreSQL on port 54322
   - Apply all migrations including:
     - Products table creation with sample data
     - Lead extensions table with standalone lead fields
     - Loan amount type change to NUMERIC

3. **Start Custom Service (Spring Boot)**
   ```bash
   cd crm-custom-service-spring
   cp .env.example .env
   mvn spring-boot:run
   ```
   The service will start on http://localhost:3001

4. **Start Frontend**
   ```bash
   npm run dev
   ```
   The frontend will start on http://localhost:5173

## Testing the Lead Form

### 1. Access the Application
- Navigate to http://localhost:5173
- Login with demo credentials (or create an account)

### 2. Navigate to Leads
- Click on "Leads" in the sidebar navigation
- You should see the leads list (empty initially)

### 3. Create a New Lead
- Click the "Create Lead" button
- Fill in the form:
  - **Customer Name**: John Doe (required)
  - **Contact Number**: +1234567890 (required)
  - **Product**: Select from dropdown (required) - e.g., "Home Loan"
  - **Loan Amount Required**: 250000 (optional)
  - **Location**: New York, NY (optional)
  - **Lead Referred By**: Jane Smith (optional)
  - **Short Description**: Customer interested in home loan (optional)
- Click "Save"

### 4. Verify Lead Creation
- You should be redirected to the leads list
- The new lead should appear with:
  - Auto-generated lead number (e.g., LEAD-A1B2C3D4)
  - All entered information
  - Status: "new"
  - Timestamps

## Features Implemented

### Form Fields
1. **Customer Name** - Text input (required)
2. **Contact Number** - Text input (required)
3. **Product** - Dropdown populated from products table (required)
4. **Loan Amount Required** - Number input with decimal precision
5. **Location** - Text input (auto-search can be added later)
6. **Lead Referred By** - Text input
7. **Short Description** - Multiline text area (500 words max)

### Dynamic Product Dropdown
Products are stored in the `public.products` table and can be edited via SQL:

```sql
-- Add new product
INSERT INTO public.products (name, description, active)
VALUES ('Education Loan', 'Student and education financing', true);

-- Deactivate a product
UPDATE public.products SET active = false WHERE name = 'Personal Loan';

-- View all products
SELECT * FROM public.products WHERE active = true;
```

### Backend API
The custom service provides these endpoints for leads:
- `POST /api/leads` - Create new lead
- `GET /api/leads` - List all leads with pagination
- `GET /api/leads/{id}` - Get single lead
- `PUT /api/leads/{id}` - Update lead
- `DELETE /api/leads/{id}` - Delete lead

All endpoints require authentication via Bearer token.

### Data Storage
Leads are stored in `custom_features.lead_extensions` table with:
- UUID-based lead numbers for uniqueness
- Nullable contact_id (allows standalone leads)
- BigDecimal for loan amounts (accurate financial calculations)
- All required and optional fields from business requirements

## Architecture

### Frontend
- **Components**: React with TypeScript
- **Forms**: React Hook Form with validation
- **UI**: Shadcn UI components matching existing CRM style
- **State**: React Query for server state
- **Routing**: React Router v7

### Backend
- **API**: Spring Boot 3.2.0
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: JWT tokens from Supabase
- **Data Provider**: Composite provider routing leads to custom service

### Database
- **Products**: `public.products` table
- **Leads**: `custom_features.lead_extensions` table
- **Migrations**: All changes versioned in `supabase/migrations/`

## User Access Control

The form is accessible to all authenticated users. To restrict access to specific users:

1. Create a user role in Supabase:
   ```sql
   ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';
   ```

2. Update RLS policies to check role:
   ```sql
   CREATE POLICY "Lead form access" ON custom_features.lead_extensions
     FOR ALL USING (
       EXISTS (
         SELECT 1 FROM auth.users
         WHERE auth.uid() = id AND role IN ('admin', 'lead_entry')
       )
     );
   ```

3. Assign roles to users via Supabase dashboard or SQL

## Next Steps (Future Enhancements)

1. **Location Auto-search**: Integrate Google Places API or similar
2. **File Attachments**: Add document upload capability
3. **Lead Assignment**: Auto-assign to sales team members
4. **Email Notifications**: Notify on new lead creation
5. **Lead Conversion**: Convert leads to contacts/deals
6. **Advanced Filters**: Filter leads by status, product, date range
7. **Export**: Export leads to CSV/Excel
8. **Analytics Dashboard**: Lead metrics and conversion rates

## Troubleshooting

### Products dropdown is empty
Check that products table has active products:
```sql
SELECT * FROM public.products WHERE active = true;
```

### Lead creation fails
1. Check that custom service is running on port 3001
2. Verify environment variable: `VITE_CUSTOM_SERVICE_URL=http://localhost:3001/api`
3. Check browser console for errors
4. Verify Supabase is running and migrations applied

### Authentication issues
1. Ensure Supabase is running
2. Check JWT secret matches in both frontend and backend
3. Verify user is logged in before accessing leads

## Security Summary

✅ No vulnerabilities detected by CodeQL analysis
✅ All form inputs validated on frontend
✅ Backend validates required fields
✅ Row-level security enabled on lead_extensions table
✅ JWT authentication required for all API calls
✅ UUID-based lead numbers prevent collisions
✅ BigDecimal used for monetary amounts (precision)
