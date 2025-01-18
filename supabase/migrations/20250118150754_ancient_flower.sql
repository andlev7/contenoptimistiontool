-- Drop existing objects if they exist
DROP TABLE IF EXISTS locations CASCADE;

-- Create locations table with prefixed location codes
CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code text NOT NULL, -- Changed to text to support prefixes
  location_name text NOT NULL,
  location_code_parent text, -- Changed to text to match location_code
  country_iso_code text,
  location_type text NOT NULL,
  available_sources text[] NOT NULL,
  language_name text NOT NULL,
  language_code text NOT NULL,
  keywords bigint NOT NULL,
  serps bigint NOT NULL,
  created_at timestamptz DEFAULT now(),
  -- Add composite unique constraint
  CONSTRAINT locations_code_lang_unique UNIQUE (location_code, language_code)
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Add indexes for better performance
CREATE INDEX idx_locations_location_code ON locations(location_code);
CREATE INDEX idx_locations_country_iso_code ON locations(country_iso_code);
CREATE INDEX idx_locations_language_code ON locations(language_code);
CREATE INDEX idx_locations_location_type ON locations(location_type);

-- Create RLS policy
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'locations' 
    AND policyname = 'Authenticated users can read locations'
  ) THEN
    CREATE POLICY "Authenticated users can read locations"
      ON locations
      FOR SELECT
      TO authenticated
      USING (true);
  END IF;
END $$;

-- Insert locations data with prefixed location codes (LOC_)
INSERT INTO locations (
  location_code,
  location_name,
  location_code_parent,
  country_iso_code,
  location_type,
  available_sources,
  language_name,
  language_code,
  keywords,
  serps
) VALUES
  ('LOC_2012', 'Algeria', NULL, 'DZ', 'Country', '{google}', 'French', 'fr', 27832115, 1187322),
  ('LOC_2012', 'Algeria', NULL, 'DZ', 'Country', '{google}', 'Arabic', 'ar', 12886180, 1206870),
  ('LOC_2024', 'Angola', NULL, 'AO', 'Country', '{google}', 'Portuguese', 'pt', 16242085, 1144131),
  ('LOC_2031', 'Azerbaijan', NULL, 'AZ', 'Country', '{google}', 'Azeri', 'az', 15485693, 413396),
  ('LOC_2032', 'Argentina', NULL, 'AR', 'Country', '{google}', 'Spanish', 'es', 60091399, 4252849),
  ('LOC_2036', 'Australia', NULL, 'AU', 'Country', '{google}', 'English', 'en', 263583314, 17361794),
  ('LOC_2040', 'Austria', NULL, 'AT', 'Country', '{google}', 'German', 'de', 58517673, 2936579),
  ('LOC_2048', 'Bahrain', NULL, 'BH', 'Country', '{google}', 'Arabic', 'ar', 12534522, 409986),
  ('LOC_2050', 'Bangladesh', NULL, 'BD', 'Country', '{google}', 'Bengali', 'bn', 31260281, 1642303),
  ('LOC_2051', 'Armenia', NULL, 'AM', 'Country', '{google}', 'Armenian', 'hy', 3359135, 207248),
  ('LOC_2056', 'Belgium', NULL, 'BE', 'Country', '{google}', 'French', 'fr', 29276243, 287500),
  ('LOC_2056', 'Belgium', NULL, 'BE', 'Country', '{google}', 'Dutch', 'nl', 66176031, 3498685),
  ('LOC_2056', 'Belgium', NULL, 'BE', 'Country', '{google}', 'German', 'de', 20008349, 626300);

-- Now that data is inserted, add the foreign key constraint
ALTER TABLE locations ADD CONSTRAINT locations_parent_fk 
  FOREIGN KEY (location_code_parent) 
  REFERENCES locations(location_code)
  ON DELETE SET NULL;

-- Create a view for unique locations (ignoring language variants)
CREATE OR REPLACE VIEW unique_locations AS
SELECT DISTINCT ON (location_code)
  id,
  location_code,
  location_name,
  country_iso_code,
  location_type,
  location_code_parent
FROM locations
ORDER BY location_code, language_code;