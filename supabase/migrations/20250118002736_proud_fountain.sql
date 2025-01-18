/*
  # Add content column to projects table

  1. Changes
    - Add content column to projects table to store editor content
    - Add policy check to ensure it doesn't already exist
  
  2. Security
    - No changes to existing RLS policies
*/

-- Add content column to projects table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'projects' 
    AND column_name = 'content'
  ) THEN
    ALTER TABLE projects ADD COLUMN content text;
  END IF;
END $$;