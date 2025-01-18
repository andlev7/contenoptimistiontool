/*
  # Keyword Analysis Schema Update

  1. New Tables
    - `keyword_analysis`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `keyword` (text, the analyzed keyword)
      - `count` (integer, number of occurrences)
      - `density` (numeric, keyword density percentage)
      - `positions` (integer[], array of positions in text)
      - `context` (text[], surrounding text snippets)
      - `analyzed_at` (timestamp)

    - `keyword_suggestions`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `keyword` (text, suggested keyword)
      - `relevance_score` (numeric, 0-1 relevance to main keyword)
      - `source` (text, where suggestion came from)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for users to manage their keyword data
    - Add policies for keyword suggestions

  3. Changes
    - Add foreign key constraints
    - Add indexes for performance
    - Add validation checks
*/

-- Keyword analysis table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS keyword_analysis (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    keyword text NOT NULL,
    count integer NOT NULL DEFAULT 0,
    density numeric(5,2) NOT NULL DEFAULT 0.0 CHECK (density >= 0.0 AND density <= 100.0),
    positions integer[] NOT NULL DEFAULT '{}',
    context text[] NOT NULL DEFAULT '{}',
    analyzed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Keyword suggestions table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS keyword_suggestions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    keyword text NOT NULL,
    relevance_score numeric(3,2) NOT NULL CHECK (relevance_score >= 0.0 AND relevance_score <= 1.0),
    source text NOT NULL CHECK (
      source IN (
        'competitor_analysis',
        'search_data',
        'content_analysis',
        'user_input',
        'ai_generated'
      )
    ),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Enable RLS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'keyword_analysis'
  ) THEN
    ALTER TABLE keyword_analysis ENABLE ROW LEVEL SECURITY;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'keyword_suggestions'
  ) THEN
    ALTER TABLE keyword_suggestions ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies for keyword analysis
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'keyword_analysis' 
    AND policyname = 'Users can manage keyword analysis through their projects'
  ) THEN
    CREATE POLICY "Users can manage keyword analysis through their projects"
      ON keyword_analysis
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = keyword_analysis.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = keyword_analysis.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Create policies for keyword suggestions
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'keyword_suggestions' 
    AND policyname = 'Users can manage keyword suggestions through their projects'
  ) THEN
    CREATE POLICY "Users can manage keyword suggestions through their projects"
      ON keyword_suggestions
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = keyword_suggestions.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = keyword_suggestions.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Add indexes for better performance
DO $$ 
BEGIN
  -- Keyword analysis indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_analysis_project_id'
  ) THEN
    CREATE INDEX idx_keyword_analysis_project_id 
    ON keyword_analysis(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_analysis_keyword'
  ) THEN
    CREATE INDEX idx_keyword_analysis_keyword 
    ON keyword_analysis(keyword);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_analysis_analyzed_at'
  ) THEN
    CREATE INDEX idx_keyword_analysis_analyzed_at 
    ON keyword_analysis(analyzed_at);
  END IF;

  -- Keyword suggestions indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_suggestions_project_id'
  ) THEN
    CREATE INDEX idx_keyword_suggestions_project_id 
    ON keyword_suggestions(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_suggestions_keyword'
  ) THEN
    CREATE INDEX idx_keyword_suggestions_keyword 
    ON keyword_suggestions(keyword);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_keyword_suggestions_relevance_score'
  ) THEN
    CREATE INDEX idx_keyword_suggestions_relevance_score 
    ON keyword_suggestions(relevance_score DESC);
  END IF;
END $$;