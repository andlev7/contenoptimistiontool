/*
  # Initial schema setup
  
  1. New Tables
    - `projects`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `name` (text)
      - `keyword` (text)
      - `url` (text, optional)
      - `region` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
  
  2. Security
    - Enable RLS on `projects` table
    - Add policy for authenticated users to manage their own projects
*/

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  name text NOT NULL,
  keyword text NOT NULL,
  url text,
  region text NOT NULL DEFAULT 'us USA',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'projects' 
    AND policyname = 'Users can manage their own projects'
  ) THEN
    CREATE POLICY "Users can manage their own projects"
      ON projects
      FOR ALL
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);