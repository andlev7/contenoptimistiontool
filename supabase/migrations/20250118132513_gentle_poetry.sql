/*
  # API Services Configuration

  1. New Tables
    - `api_services`
      - `id` (uuid, primary key)
      - `name` (text) - Service name
      - `credentials` (jsonb) - Encrypted credentials
      - `is_active` (boolean) - Service status
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for admin-only access
*/

-- API Services table
CREATE TABLE IF NOT EXISTS api_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  credentials jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE api_services ENABLE ROW LEVEL SECURITY;

-- Create policies for admin-only access
CREATE POLICY "Only admins can view api services"
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

CREATE POLICY "Only admins can insert api services"
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

CREATE POLICY "Only admins can update api services"
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

CREATE POLICY "Only admins can delete api services"
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