/*
  # User Roles and Permissions Setup

  1. Changes
    - Drop existing project policies first to remove dependencies
    - Create user_roles table with proper constraints
    - Create simplified role policies
    - Create functions for user management
    - Recreate project policies
    
  2. Security
    - Enable RLS on user_roles table
    - Add policies for role management
    - Set up proper admin access controls
*/

-- First, drop project policies to remove dependencies
DROP POLICY IF EXISTS "Users can view their own or all projects if admin" ON projects;
DROP POLICY IF EXISTS "Users can update their own projects or any if admin" ON projects;
DROP POLICY IF EXISTS "Users can delete their own projects or any if admin" ON projects;

-- Now we can safely handle the user_roles table
DROP POLICY IF EXISTS "Admins can manage all roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON user_roles;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Recreate user_roles table with proper constraints
DROP TABLE IF EXISTS user_roles CASCADE;
CREATE TABLE user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  role text NOT NULL CHECK (role IN ('admin', 'client')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Create simplified policies without circular dependencies
CREATE POLICY "Users can view any role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only super admin can insert roles"
  ON user_roles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM user_roles 
      WHERE role = 'admin' 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Only super admin can update roles"
  ON user_roles
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT user_id FROM user_roles 
      WHERE role = 'admin' 
      AND user_id = auth.uid()
    )
  )
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM user_roles 
      WHERE role = 'admin' 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Only super admin can delete roles"
  ON user_roles
  FOR DELETE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT user_id FROM user_roles 
      WHERE role = 'admin' 
      AND user_id = auth.uid()
    )
  );

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO user_roles (user_id, role)
  VALUES (NEW.id, 'client')
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Function to create initial admin user
CREATE OR REPLACE FUNCTION create_initial_admin(admin_email text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_user_id uuid;
BEGIN
  -- Get the user ID for the provided email
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = admin_email;

  -- If user exists, make them an admin
  IF admin_user_id IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_user_id, 'admin')
    ON CONFLICT (user_id) DO UPDATE
    SET role = 'admin';
  END IF;
END;
$$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);

-- Recreate project policies
CREATE POLICY "Users can view their own or all projects if admin"
  ON projects
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() 
    OR 
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Users can update their own projects or any if admin"
  ON projects
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = user_id
    OR
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    auth.uid() = user_id
    OR
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Users can delete their own projects or any if admin"
  ON projects
  FOR DELETE
  TO authenticated
  USING (
    auth.uid() = user_id
    OR
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );