-- Add standalone lead fields to support Phase 1 lead capture form
-- These fields allow creating leads without requiring a contact_id first

ALTER TABLE custom_features.lead_extensions
  ADD COLUMN IF NOT EXISTS customer_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_number VARCHAR(50);

-- Make contact_id nullable for standalone leads
ALTER TABLE custom_features.lead_extensions
  ALTER COLUMN contact_id DROP NOT NULL;

-- Create index on customer name for searching
CREATE INDEX IF NOT EXISTS idx_lead_extensions_customer_name 
  ON custom_features.lead_extensions(customer_name);

-- Create index on contact number for searching
CREATE INDEX IF NOT EXISTS idx_lead_extensions_contact_number 
  ON custom_features.lead_extensions(contact_number);
