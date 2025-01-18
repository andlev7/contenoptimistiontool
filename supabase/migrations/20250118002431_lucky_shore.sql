/*
  # Create SERP data tables

  1. New Tables
    - `serp_data`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `type` (text, either 'headers' or 'texts')
      - `content` (text)
      - `enabled` (boolean)
      - `position` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on `serp_data` table
    - Add policy for authenticated users to manage their SERP data through projects
*/

-- SERP data table
CREATE TABLE IF NOT EXISTS serp_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('headers', 'texts')),
  content text NOT NULL DEFAULT '',
  enabled boolean NOT NULL DEFAULT true,
  position integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE serp_data ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'serp_data' 
    AND policyname = 'Users can manage SERP data through their projects'
  ) THEN
    CREATE POLICY "Users can manage SERP data through their projects"
      ON serp_data
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = serp_data.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = serp_data.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_serp_data_project_id ON serp_data(project_id);