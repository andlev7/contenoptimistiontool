/*
  # Create AI prompts and results tables

  1. New Tables
    - `ai_prompts`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `type` (text, either 'headers' or 'writing')
      - `step` (integer)
      - `prompt` (text)
      - `enabled` (boolean)
      - `created_at` (timestamptz)

    - `ai_results`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `prompt_id` (uuid, references ai_prompts)
      - `content` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to manage their data through projects
*/

-- AI prompts table
CREATE TABLE IF NOT EXISTS ai_prompts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('headers', 'writing')),
  step integer NOT NULL DEFAULT 1,
  prompt text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'ai_prompts' 
    AND policyname = 'Users can manage AI prompts through their projects'
  ) THEN
    CREATE POLICY "Users can manage AI prompts through their projects"
      ON ai_prompts
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = ai_prompts.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = ai_prompts.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- AI results table
CREATE TABLE IF NOT EXISTS ai_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  prompt_id uuid REFERENCES ai_prompts(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE ai_results ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'ai_results' 
    AND policyname = 'Users can manage AI results through their projects'
  ) THEN
    CREATE POLICY "Users can manage AI results through their projects"
      ON ai_results
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = ai_results.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = ai_results.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ai_prompts_project_id ON ai_prompts(project_id);
CREATE INDEX IF NOT EXISTS idx_ai_results_project_id ON ai_results(project_id);
CREATE INDEX IF NOT EXISTS idx_ai_results_prompt_id ON ai_results(prompt_id);