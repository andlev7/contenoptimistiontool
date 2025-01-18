-- Drop existing objects if they exist
DROP TABLE IF EXISTS locations CASCADE;

-- Create locations table
CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code integer NOT NULL,
  location_name text NOT NULL,
  location_code_parent integer,
  country_iso_code text,
  location_type text NOT NULL,
  available_sources text[] NOT NULL,
  language_name text NOT NULL,
  language_code text NOT NULL,
  keywords bigint NOT NULL,
  serps bigint NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT locations_code_lang_unique UNIQUE (location_code, language_code)
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Add indexes for better performance
CREATE INDEX idx_locations_location_code ON locations(location_code);
CREATE INDEX idx_locations_country_iso_code ON locations(country_iso_code);
CREATE INDEX idx_locations_language_code ON locations(language_code);
CREATE INDEX idx_locations_location_type ON locations(location_type);

-- Create RLS policy using DO block to avoid duplicate policy error
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

-- Insert locations data
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
  (2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'French', 'fr', 27832115, 1187322),
  (2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'Arabic', 'ar', 12886180, 1206870),
  (2024, 'Angola', NULL, 'AO', 'Country', '{google}', 'Portuguese', 'pt', 16242085, 1144131),
  (2031, 'Azerbaijan', NULL, 'AZ', 'Country', '{google}', 'Azeri', 'az', 15485693, 413396),
  (2032, 'Argentina', NULL, 'AR', 'Country', '{google}', 'Spanish', 'es', 60091399, 4252849),
  (2036, 'Australia', NULL, 'AU', 'Country', '{google}', 'English', 'en', 263583314, 17361794),
  (2040, 'Austria', NULL, 'AT', 'Country', '{google}', 'German', 'de', 58517673, 2936579),
  (2048, 'Bahrain', NULL, 'BH', 'Country', '{google}', 'Arabic', 'ar', 12534522, 409986),
  (2050, 'Bangladesh', NULL, 'BD', 'Country', '{google}', 'Bengali', 'bn', 31260281, 1642303),
  (2051, 'Armenia', NULL, 'AM', 'Country', '{google}', 'Armenian', 'hy', 3359135, 207248),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'French', 'fr', 29276243, 287500),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'Dutch', 'nl', 66176031, 3498685),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'German', 'de', 20008349, 626300),
  (2840, 'United States', NULL, 'US', 'Country', '{google,bing,amazon}', 'English', 'en', 1122464691, 199887763),
  (2840, 'United States', NULL, 'US', 'Country', '{google}', 'Spanish', 'es', 146539017, 6606085),
  (2804, 'Ukraine', NULL, 'UA', 'Country', '{google}', 'Ukrainian', 'uk', 132640758, 11247222),
  (2804, 'Ukraine', NULL, 'UA', 'Country', '{google}', 'Russian', 'ru', 112563923, 5695329);

-- Create view for unique locations
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