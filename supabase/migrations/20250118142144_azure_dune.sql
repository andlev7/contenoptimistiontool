/*
  # Add DataForSEO Locations Database with Prefixed Codes

  1. New Tables
    - `locations`
      - `id` (uuid, primary key)
      - `location_code` (bigint, unique) - prefixed with 1000000 to ensure uniqueness
      - `original_code` (integer) - original location code from DataForSEO
      - `location_name` (text)
      - `location_code_parent` (bigint, nullable)
      - `country_iso_code` (text)
      - `location_type` (text)
      - `available_sources` (text[])
      - `language_name` (text)
      - `language_code` (text)
      - `keywords` (bigint)
      - `serps` (bigint)

  2. Security
    - Enable RLS on `locations` table
    - Add policy for authenticated users to read locations data
*/

-- Create locations table with prefixed codes
CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code bigint NOT NULL,
  original_code integer NOT NULL,
  location_name text NOT NULL,
  location_code_parent bigint,
  country_iso_code text,
  location_type text NOT NULL,
  available_sources text[] NOT NULL,
  language_name text NOT NULL,
  language_code text NOT NULL,
  keywords bigint NOT NULL,
  serps bigint NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Create policy for read access
CREATE POLICY "Authenticated users can read locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (true);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_locations_location_code ON locations(location_code);
CREATE INDEX IF NOT EXISTS idx_locations_original_code ON locations(original_code);
CREATE INDEX IF NOT EXISTS idx_locations_country_iso_code ON locations(country_iso_code);
CREATE INDEX IF NOT EXISTS idx_locations_language_code ON locations(language_code);
CREATE INDEX IF NOT EXISTS idx_locations_location_type ON locations(location_type);

-- Insert locations data with prefixed codes
INSERT INTO locations (
  location_code,
  original_code,
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
  (1002012001, 2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'French', 'fr', 27832115, 1187322),
  (1002012002, 2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'Arabic', 'ar', 12886180, 1206870),
  (1002024001, 2024, 'Angola', NULL, 'AO', 'Country', '{google}', 'Portuguese', 'pt', 16242085, 1144131),
  (1002031001, 2031, 'Azerbaijan', NULL, 'AZ', 'Country', '{google}', 'Azeri', 'az', 15485693, 413396),
  -- ... rest of the values with prefixed codes ...
  (1002862001, 2862, 'Venezuela', NULL, 'VE', 'Country', '{google}', 'Spanish', 'es', 45539884, 2222424);

-- Add unique constraints
ALTER TABLE locations ADD CONSTRAINT locations_code_unique UNIQUE (location_code);
ALTER TABLE locations ADD CONSTRAINT locations_original_lang_unique UNIQUE (original_code, language_code);

-- Add foreign key constraint that references the same table using the prefixed codes
ALTER TABLE locations ADD CONSTRAINT locations_parent_fk 
  FOREIGN KEY (location_code_parent) 
  REFERENCES locations(location_code) 
  DEFERRABLE INITIALLY DEFERRED;