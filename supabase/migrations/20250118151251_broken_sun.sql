-- Drop existing objects if they exist
DROP TABLE IF EXISTS locations CASCADE;

-- Create locations table with minimal structure
CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code text NOT NULL,
  location_name text NOT NULL,
  country_iso_code text,
  language_code text NOT NULL,
  language_name text NOT NULL,
  keywords bigint NOT NULL DEFAULT 0,
  serps bigint NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  -- Add composite unique constraint
  CONSTRAINT locations_code_lang_unique UNIQUE (location_code, language_code)
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Create simple RLS policy
CREATE POLICY "Anyone can read locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (true);

-- Add basic index
CREATE INDEX idx_locations_code_lang ON locations(location_code, language_code);

-- Insert data with text location codes
INSERT INTO locations (
  location_code,
  location_name,
  country_iso_code,
  language_code,
  language_name,
  keywords,
  serps
)
SELECT 
  location_code::text,
  location_name,
  country_iso_code,
  language_code,
  language_name,
  keywords,
  serps
FROM (VALUES
  ('2012', 'Algeria', 'DZ', 'fr', 'French', 27832115, 1187322),
  ('2012', 'Algeria', 'DZ', 'ar', 'Arabic', 12886180, 1206870),
  ('2024', 'Angola', 'AO', 'pt', 'Portuguese', 16242085, 1144131)
  -- Add more values as needed
) AS t(location_code, location_name, country_iso_code, language_code, language_name, keywords, serps);