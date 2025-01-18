/*
  # Readability Analysis Schema Update

  1. New Tables
    - `readability_metrics`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `flesch_reading_ease` (numeric, readability score)
      - `flesch_kincaid_grade` (numeric, grade level)
      - `avg_sentence_length` (numeric, average words per sentence)
      - `avg_word_length` (numeric, average characters per word)
      - `complex_word_percentage` (numeric, percentage of complex words)
      - `analyzed_at` (timestamp)

    - `content_statistics`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `paragraph_count` (integer)
      - `sentence_count` (integer)
      - `word_count` (integer)
      - `character_count` (integer)
      - `analyzed_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for readability metrics
    - Add policies for content statistics

  3. Changes
    - Add foreign key constraints
    - Add indexes for performance
    - Add validation checks
*/

-- Readability metrics table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS readability_metrics (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    flesch_reading_ease numeric(5,2) CHECK (flesch_reading_ease >= 0.0 AND flesch_reading_ease <= 100.0),
    flesch_kincaid_grade numeric(4,1) CHECK (flesch_kincaid_grade >= 0.0),
    avg_sentence_length numeric(5,2) CHECK (avg_sentence_length >= 0.0),
    avg_word_length numeric(4,2) CHECK (avg_word_length >= 0.0),
    complex_word_percentage numeric(5,2) CHECK (complex_word_percentage >= 0.0 AND complex_word_percentage <= 100.0),
    analyzed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Content statistics table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS content_statistics (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    paragraph_count integer NOT NULL DEFAULT 0 CHECK (paragraph_count >= 0),
    sentence_count integer NOT NULL DEFAULT 0 CHECK (sentence_count >= 0),
    word_count integer NOT NULL DEFAULT 0 CHECK (word_count >= 0),
    character_count integer NOT NULL DEFAULT 0 CHECK (character_count >= 0),
    analyzed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Enable RLS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'readability_metrics'
  ) THEN
    ALTER TABLE readability_metrics ENABLE ROW LEVEL SECURITY;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'content_statistics'
  ) THEN
    ALTER TABLE content_statistics ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies for readability metrics
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'readability_metrics' 
    AND policyname = 'Users can manage readability metrics through their projects'
  ) THEN
    CREATE POLICY "Users can manage readability metrics through their projects"
      ON readability_metrics
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = readability_metrics.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = readability_metrics.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Create policies for content statistics
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'content_statistics' 
    AND policyname = 'Users can manage content statistics through their projects'
  ) THEN
    CREATE POLICY "Users can manage content statistics through their projects"
      ON content_statistics
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_statistics.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_statistics.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Add indexes for better performance
DO $$ 
BEGIN
  -- Readability metrics indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_readability_metrics_project_id'
  ) THEN
    CREATE INDEX idx_readability_metrics_project_id 
    ON readability_metrics(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_readability_metrics_analyzed_at'
  ) THEN
    CREATE INDEX idx_readability_metrics_analyzed_at 
    ON readability_metrics(analyzed_at);
  END IF;

  -- Content statistics indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_statistics_project_id'
  ) THEN
    CREATE INDEX idx_content_statistics_project_id 
    ON content_statistics(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_statistics_analyzed_at'
  ) THEN
    CREATE INDEX idx_content_statistics_analyzed_at 
    ON content_statistics(analyzed_at);
  END IF;
END $$;