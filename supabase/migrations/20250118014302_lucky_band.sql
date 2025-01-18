/*
  # Fix User Roles Policies

  1. Changes
    - Remove circular dependency in admin policies
    - Add initial admin user creation
    - Simplify role-based access control

  2. Security
    - Maintain secure access control
    - Prevent infinite recursion
    - Allow bootstrapping admin user
*/

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Admins can manage all roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;

-- Create new policies without circular dependencies
CREATE POLICY "Users can view their own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Admins can manage roles"
  ON user_roles
  FOR ALL
  TO authenticated
  USING (
    role = 'admin'
    AND user_id = auth.uid()
  )
  WITH CHECK (
    role = 'admin'
    AND user_id = auth.uid()
  );

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