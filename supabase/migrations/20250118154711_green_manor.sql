-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Only admins can view api services" ON api_services;
  DROP POLICY IF EXISTS "Only admins can insert api services" ON api_services;
  DROP POLICY IF EXISTS "Only admins can update api services" ON api_services;
  DROP POLICY IF EXISTS "Only admins can delete api services" ON api_services;
EXCEPTION
  WHEN undefined_table THEN NULL;
END $$;

-- Drop existing table if it exists
DROP TABLE IF EXISTS api_services CASCADE;

-- Create API Services table
CREATE TABLE api_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  credentials jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(credentials) = 'object'),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE api_services ENABLE ROW LEVEL SECURITY;

-- Create policies for admin-only access
DO $$ 
BEGIN
  CREATE POLICY "Admin select api services"
    ON api_services
    FOR SELECT
    TO authenticated
    USING (
      EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
      )
    );

  CREATE POLICY "Admin insert api services"
    ON api_services
    FOR INSERT
    TO authenticated
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
      )
    );

  CREATE POLICY "Admin update api services"
    ON api_services
    FOR UPDATE
    TO authenticated
    USING (
      EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
      )
    )
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
      )
    );

  CREATE POLICY "Admin delete api services"
    ON api_services
    FOR DELETE
    TO authenticated
    USING (
      EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
      )
    );
END $$;

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_api_services_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_api_services_updated_at
  BEFORE UPDATE ON api_services
  FOR EACH ROW
  EXECUTE FUNCTION update_api_services_updated_at();

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_api_services_name ON api_services(name);
CREATE INDEX IF NOT EXISTS idx_api_services_is_active ON api_services(is_active);

-- Insert initial DataForSEO service with proper credentials structure
DO $$
BEGIN
  INSERT INTO api_services (name, credentials, is_active)
  VALUES (
    'DataForSEO',
    jsonb_build_object(
      'login', 'andmaillev@gmail.com',
      'password', 'b4c5a2e7c8f6'
    ),
    true
  )
  ON CONFLICT (name) DO UPDATE 
  SET credentials = EXCLUDED.credentials,
      updated_at = CURRENT_TIMESTAMP,
      is_active = true;
END $$;