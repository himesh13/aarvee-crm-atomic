-- Add stage and index columns to lead_extensions for Kanban board functionality
ALTER TABLE custom_features.lead_extensions
  ADD COLUMN IF NOT EXISTS stage VARCHAR(50) DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS index SMALLINT DEFAULT 0;

-- Create index for performance on stage and index columns
CREATE INDEX IF NOT EXISTS idx_lead_extensions_stage_index 
  ON custom_features.lead_extensions(stage, index);

-- Update existing leads to have default stage and sequential index
UPDATE custom_features.lead_extensions 
SET stage = 'new', index = (ROW_NUMBER() OVER (ORDER BY created_at))::SMALLINT
WHERE stage IS NULL OR index IS NULL;
