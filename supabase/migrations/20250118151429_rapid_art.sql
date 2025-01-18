-- Drop existing objects if they exist
DROP TABLE IF EXISTS locations CASCADE;

-- Create locations table
CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code text NOT NULL,
  location_name text NOT NULL,
  country_iso_code text,
  location_type text NOT NULL DEFAULT 'Country',
  available_sources text[] NOT NULL DEFAULT '{google}',
  language_name text NOT NULL,
  language_code text NOT NULL,
  keywords bigint NOT NULL DEFAULT 0,
  serps bigint NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  -- Add composite unique constraint
  CONSTRAINT locations_code_lang_unique UNIQUE (location_code, language_code)
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Anyone can read locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (true);

-- Add indexes
CREATE INDEX idx_locations_code_lang ON locations(location_code, language_code);
CREATE INDEX idx_locations_country ON locations(country_iso_code);

-- Insert data
INSERT INTO locations (
  location_code,
  location_name,
  country_iso_code,
  location_type,
  available_sources,
  language_name,
  language_code,
  keywords,
  serps
) VALUES
  ('2012', 'Algeria', 'DZ', 'Country', '{google}', 'French', 'fr', 27832115, 1187322),
  ('2012', 'Algeria', 'DZ', 'Country', '{google}', 'Arabic', 'ar', 12886180, 1206870),
  ('2024', 'Angola', 'AO', 'Country', '{google}', 'Portuguese', 'pt', 16242085, 1144131),
  ('2031', 'Azerbaijan', 'AZ', 'Country', '{google}', 'Azeri', 'az', 15485693, 413396),
  ('2032', 'Argentina', 'AR', 'Country', '{google}', 'Spanish', 'es', 60091399, 4252849),
  ('2036', 'Australia', 'AU', 'Country', '{google}', 'English', 'en', 263583314, 17361794),
  ('2040', 'Austria', 'AT', 'Country', '{google}', 'German', 'de', 58517673, 2936579),
  ('2048', 'Bahrain', 'BH', 'Country', '{google}', 'Arabic', 'ar', 12534522, 409986),
  ('2050', 'Bangladesh', 'BD', 'Country', '{google}', 'Bengali', 'bn', 31260281, 1642303),
  ('2051', 'Armenia', 'AM', 'Country', '{google}', 'Armenian', 'hy', 3359135, 207248),
  ('2056', 'Belgium', 'BE', 'Country', '{google}', 'French', 'fr', 29276243, 287500),
  ('2056', 'Belgium', 'BE', 'Country', '{google}', 'Dutch', 'nl', 66176031, 3498685),
  ('2056', 'Belgium', 'BE', 'Country', '{google}', 'German', 'de', 20008349, 626300),
  ('2840', 'United States', 'US', 'Country', '{google,bing,amazon}', 'English', 'en', 1122464691, 199887763),
  ('2840', 'United States', 'US', 'Country', '{google}', 'Spanish', 'es', 146539017, 6606085),
  ('2804', 'Ukraine', 'UA', 'Country', '{google}', 'Ukrainian', 'uk', 132640758, 11247222),
  ('2804', 'Ukraine', 'UA', 'Country', '{google}', 'Russian', 'ru', 112563923, 5695329);

-- Create view for unique locations
CREATE VIEW unique_locations AS
SELECT DISTINCT ON (location_code)
  id,
  location_code,
  location_name,
  country_iso_code,
  location_type
FROM locations
ORDER BY location_code, language_code;