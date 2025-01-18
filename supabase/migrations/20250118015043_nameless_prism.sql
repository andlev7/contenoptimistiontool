/*
  # Add Project Archive Feature

  1. Changes
    - Add archived column to projects table
    - Update project policies to handle archived status

  2. Security
    - Maintain existing RLS policies
    - Add archived status checks
*/

-- Add archived column to projects table
ALTER TABLE projects ADD COLUMN IF NOT EXISTS archived boolean NOT NULL DEFAULT false;

-- Add index for archived status
CREATE INDEX IF NOT EXISTS idx_projects_archived ON projects(archived);

-- Update project policies to handle archived status
DROP POLICY IF EXISTS "Users can view their own or all projects if admin" ON projects;
DROP POLICY IF EXISTS "Users can manage their own projects" ON projects;
DROP POLICY IF EXISTS "Users can update their own projects" ON projects;
DROP POLICY IF EXISTS "Users can delete their own projects" ON projects;

-- Create new policies
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

CREATE POLICY "Users can manage their own projects"
  ON projects
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

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