/*
  # Content Optimization Tool Schema

  1. New Tables
    - `projects`
    - `serp_data`
    - `ai_prompts`
    - `ai_results`

  2. Security
    - Enable RLS on all tables
    - Add policies with existence checks
    - Cascade deletions from projects to related tables

  3. Performance
    - Add indexes on foreign keys
*/

-- Projects table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS projects (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),
    name text NOT NULL,
    keyword text NOT NULL,
    url text,
    region text NOT NULL DEFAULT 'us USA',
    content text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'projects'
  ) THEN
    ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

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

-- SERP data table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS serp_data (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('headers', 'texts')),
    content text NOT NULL DEFAULT '',
    enabled boolean NOT NULL DEFAULT true,
    position integer NOT NULL,
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'serp_data'
  ) THEN
    ALTER TABLE serp_data ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

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

-- AI prompts table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS ai_prompts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('headers', 'writing')),
    step integer NOT NULL DEFAULT 1,
    prompt text NOT NULL,
    enabled boolean NOT NULL DEFAULT true,
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'ai_prompts'
  ) THEN
    ALTER TABLE ai_prompts ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

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
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS ai_results (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    prompt_id uuid REFERENCES ai_prompts(id) ON DELETE CASCADE,
    content text NOT NULL,
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'ai_results'
  ) THEN
    ALTER TABLE ai_results ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

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
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_projects_user_id'
  ) THEN
    CREATE INDEX idx_projects_user_id ON projects(user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_serp_data_project_id'
  ) THEN
    CREATE INDEX idx_serp_data_project_id ON serp_data(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_prompts_project_id'
  ) THEN
    CREATE INDEX idx_ai_prompts_project_id ON ai_prompts(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_results_project_id'
  ) THEN
    CREATE INDEX idx_ai_results_project_id ON ai_results(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ai_results_prompt_id'
  ) THEN
    CREATE INDEX idx_ai_results_prompt_id ON ai_results(prompt_id);
  END IF;
END $$;