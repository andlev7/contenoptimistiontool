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
  -- ... [rest of the INSERT VALUES] ...
  (2862, 'Venezuela', NULL, 'VE', 'Country', '{google}', 'Spanish', 'es', 45539884, 2222424);

-- Now that data is inserted, add the foreign key constraint
ALTER TABLE locations ADD CONSTRAINT locations_parent_fk 
  FOREIGN KEY (location_code_parent) 
  REFERENCES locations(location_code)
  ON DELETE SET NULL;