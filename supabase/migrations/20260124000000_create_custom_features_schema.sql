-- Create custom_features schema for custom microservice
CREATE SCHEMA IF NOT EXISTS custom_features;

-- Grant access to service_role
GRANT USAGE ON SCHEMA custom_features TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA custom_features TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA custom_features TO service_role;

-- Lead Extensions Table
CREATE TABLE custom_features.lead_extensions (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES public.contacts(id) ON DELETE CASCADE,
  lead_number VARCHAR(50) UNIQUE NOT NULL,
  product VARCHAR(255),
  loan_amount_required BIGINT,
  location VARCHAR(500),
  lead_referred_by VARCHAR(255),
  short_description TEXT,
  lead_assigned_to BIGINT REFERENCES public.sales(id),
  lead_status VARCHAR(50) DEFAULT 'new',
  business_details JSONB,
  property_details JSONB,
  auto_loan_details JSONB,
  machinery_loan_details JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Business Details Table
CREATE TABLE custom_features.business_details (
  id BIGSERIAL PRIMARY KEY,
  lead_extension_id BIGINT REFERENCES custom_features.lead_extensions(id) ON DELETE CASCADE,
  type_of_employment VARCHAR(100),
  type_of_industry VARCHAR(100),
  type_of_business VARCHAR(100),
  constitution VARCHAR(100),
  years_in_business INT,
  monthly_net_salary BIGINT,
  other_info TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Property Details Table
CREATE TABLE custom_features.property_details (
  id BIGSERIAL PRIMARY KEY,
  lead_extension_id BIGINT REFERENCES custom_features.lead_extensions(id) ON DELETE CASCADE,
  type_of_property VARCHAR(100),
  is_new_purchase BOOLEAN,
  is_builder_purchase BOOLEAN,
  is_ready_possession BOOLEAN,
  classification_of_property VARCHAR(100),
  property_value BIGINT,
  sell_deed_value BIGINT,
  area_of_property DECIMAL(10, 2),
  area_unit VARCHAR(20),
  age_of_property INT,
  property_address TEXT,
  other_info TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Reminders Table
CREATE TABLE custom_features.reminders (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES public.contacts(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  due_date DATE NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_lead_extensions_contact_id ON custom_features.lead_extensions(contact_id);
CREATE INDEX idx_lead_extensions_status ON custom_features.lead_extensions(lead_status);
CREATE INDEX idx_lead_extensions_lead_number ON custom_features.lead_extensions(lead_number);
CREATE INDEX idx_business_details_lead_id ON custom_features.business_details(lead_extension_id);
CREATE INDEX idx_property_details_lead_id ON custom_features.property_details(lead_extension_id);
CREATE INDEX idx_reminders_contact_id ON custom_features.reminders(contact_id);
CREATE INDEX idx_reminders_due_date ON custom_features.reminders(due_date);
CREATE INDEX idx_reminders_status ON custom_features.reminders(status);

-- Enable RLS (Row Level Security)
ALTER TABLE custom_features.lead_extensions ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.business_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.property_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.reminders ENABLE ROW LEVEL SECURITY;

-- Create policies (users can access all data when authenticated)
CREATE POLICY "Authenticated users can view leads" ON custom_features.lead_extensions
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert leads" ON custom_features.lead_extensions
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update leads" ON custom_features.lead_extensions
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete leads" ON custom_features.lead_extensions
  FOR DELETE USING (auth.role() = 'authenticated');

-- Business details policies
CREATE POLICY "Authenticated users can view business details" ON custom_features.business_details
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert business details" ON custom_features.business_details
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update business details" ON custom_features.business_details
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete business details" ON custom_features.business_details
  FOR DELETE USING (auth.role() = 'authenticated');

-- Property details policies
CREATE POLICY "Authenticated users can view property details" ON custom_features.property_details
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert property details" ON custom_features.property_details
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update property details" ON custom_features.property_details
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete property details" ON custom_features.property_details
  FOR DELETE USING (auth.role() = 'authenticated');

-- Reminders policies
CREATE POLICY "Authenticated users can view reminders" ON custom_features.reminders
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert reminders" ON custom_features.reminders
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update reminders" ON custom_features.reminders
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete reminders" ON custom_features.reminders
  FOR DELETE USING (auth.role() = 'authenticated');

-- Create function to auto-update updated_at
CREATE OR REPLACE FUNCTION custom_features.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_lead_extensions_updated_at 
  BEFORE UPDATE ON custom_features.lead_extensions
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();

CREATE TRIGGER update_business_details_updated_at 
  BEFORE UPDATE ON custom_features.business_details
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();

CREATE TRIGGER update_property_details_updated_at 
  BEFORE UPDATE ON custom_features.property_details
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();

-- Grant future table permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA custom_features GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA custom_features GRANT ALL ON SEQUENCES TO service_role;
