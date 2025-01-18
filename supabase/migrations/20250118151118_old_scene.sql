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