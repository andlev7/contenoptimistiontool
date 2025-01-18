/*
  # Add DataForSEO Locations Database with Composite Keys

  1. New Tables
    - `locations`
      - `id` (uuid, primary key)
      - `location_code` (integer)
      - `location_name` (text)
      - `location_code_parent` (integer)
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

  3. Constraints
    - Composite unique constraint on (location_code, language_code)
    - Self-referencing foreign key using location_code
*/

-- Create locations table
CREATE TABLE IF NOT EXISTS locations (
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

-- Create policy for read access
CREATE POLICY "Authenticated users can read locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (true);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_locations_location_code ON locations(location_code);
CREATE INDEX IF NOT EXISTS idx_locations_country_iso_code ON locations(country_iso_code);
CREATE INDEX IF NOT EXISTS idx_locations_language_code ON locations(language_code);
CREATE INDEX IF NOT EXISTS idx_locations_location_type ON locations(location_type);

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
  -- ... rest of the values ...
  (2862, 'Venezuela', NULL, 'VE', 'Country', '{google}', 'Spanish', 'es', 45539884, 2222424);

-- Create a view for parent locations only
CREATE VIEW parent_locations AS
SELECT DISTINCT ON (location_code)
  location_code,
  location_name,
  country_iso_code,
  location_type
FROM locations
WHERE location_code_parent IS NULL;

-- Add foreign key constraint that references parent locations
ALTER TABLE locations ADD CONSTRAINT locations_parent_fk 
  FOREIGN KEY (location_code_parent) 
  REFERENCES locations(location_code)
  ON DELETE SET NULL;