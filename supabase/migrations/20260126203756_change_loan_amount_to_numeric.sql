-- Change loan_amount_required from BIGINT to NUMERIC for better precision
ALTER TABLE custom_features.lead_extensions
  ALTER COLUMN loan_amount_required TYPE NUMERIC(19, 2);
