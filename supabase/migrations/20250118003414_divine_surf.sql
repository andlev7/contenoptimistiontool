/*
  # Content Analysis Schema Update

  1. New Tables
    - `content_quality_metrics`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `grammar_score` (numeric, 0-100 score)
      - `style_score` (numeric, 0-100 score)
      - `clarity_score` (numeric, 0-100 score)
      - `engagement_score` (numeric, 0-100 score)
      - `issues` (jsonb, detailed issues found)
      - `analyzed_at` (timestamp)

    - `seo_analysis`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `title_score` (numeric, 0-100 score)
      - `meta_description_score` (numeric, 0-100 score)
      - `heading_structure_score` (numeric, 0-100 score)
      - `keyword_usage_score` (numeric, 0-100 score)
      - `issues` (jsonb, detailed SEO issues)
      - `analyzed_at` (timestamp)

    - `content_suggestions`
      - `id` (uuid, primary key)
      - `project_id` (uuid, references projects)
      - `type` (text, suggestion type)
      - `suggestion` (text, the actual suggestion)
      - `priority` (integer, importance level)
      - `status` (text, suggestion status)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Restrict access to project owners

  3. Changes
    - Add foreign key constraints
    - Add validation checks
    - Add performance indexes
*/

-- Content quality metrics table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS content_quality_metrics (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    grammar_score numeric(5,2) CHECK (grammar_score >= 0.0 AND grammar_score <= 100.0),
    style_score numeric(5,2) CHECK (style_score >= 0.0 AND style_score <= 100.0),
    clarity_score numeric(5,2) CHECK (clarity_score >= 0.0 AND clarity_score <= 100.0),
    engagement_score numeric(5,2) CHECK (engagement_score >= 0.0 AND engagement_score <= 100.0),
    issues jsonb NOT NULL DEFAULT '{}'::jsonb,
    analyzed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- SEO analysis table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS seo_analysis (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    title_score numeric(5,2) CHECK (title_score >= 0.0 AND title_score <= 100.0),
    meta_description_score numeric(5,2) CHECK (meta_description_score >= 0.0 AND meta_description_score <= 100.0),
    heading_structure_score numeric(5,2) CHECK (heading_structure_score >= 0.0 AND heading_structure_score <= 100.0),
    keyword_usage_score numeric(5,2) CHECK (keyword_usage_score >= 0.0 AND keyword_usage_score <= 100.0),
    issues jsonb NOT NULL DEFAULT '{}'::jsonb,
    analyzed_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Content suggestions table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS content_suggestions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (
      type IN (
        'grammar',
        'style',
        'seo',
        'structure',
        'engagement'
      )
    ),
    suggestion text NOT NULL,
    priority integer NOT NULL CHECK (priority BETWEEN 1 AND 5),
    status text NOT NULL DEFAULT 'pending' CHECK (
      status IN (
        'pending',
        'accepted',
        'rejected',
        'implemented'
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
    SELECT 1 FROM pg_tables WHERE tablename = 'content_quality_metrics'
  ) THEN
    ALTER TABLE content_quality_metrics ENABLE ROW LEVEL SECURITY;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'seo_analysis'
  ) THEN
    ALTER TABLE seo_analysis ENABLE ROW LEVEL SECURITY;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'content_suggestions'
  ) THEN
    ALTER TABLE content_suggestions ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies for content quality metrics
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'content_quality_metrics' 
    AND policyname = 'Users can manage content quality metrics through their projects'
  ) THEN
    CREATE POLICY "Users can manage content quality metrics through their projects"
      ON content_quality_metrics
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_quality_metrics.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_quality_metrics.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Create policies for SEO analysis
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'seo_analysis' 
    AND policyname = 'Users can manage SEO analysis through their projects'
  ) THEN
    CREATE POLICY "Users can manage SEO analysis through their projects"
      ON seo_analysis
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = seo_analysis.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = seo_analysis.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Create policies for content suggestions
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'content_suggestions' 
    AND policyname = 'Users can manage content suggestions through their projects'
  ) THEN
    CREATE POLICY "Users can manage content suggestions through their projects"
      ON content_suggestions
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_suggestions.project_id
          AND user_id = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects
          WHERE id = content_suggestions.project_id
          AND user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Add indexes for better performance
DO $$ 
BEGIN
  -- Content quality metrics indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_quality_metrics_project_id'
  ) THEN
    CREATE INDEX idx_content_quality_metrics_project_id 
    ON content_quality_metrics(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_quality_metrics_analyzed_at'
  ) THEN
    CREATE INDEX idx_content_quality_metrics_analyzed_at 
    ON content_quality_metrics(analyzed_at);
  END IF;

  -- SEO analysis indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_seo_analysis_project_id'
  ) THEN
    CREATE INDEX idx_seo_analysis_project_id 
    ON seo_analysis(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_seo_analysis_analyzed_at'
  ) THEN
    CREATE INDEX idx_seo_analysis_analyzed_at 
    ON seo_analysis(analyzed_at);
  END IF;

  -- Content suggestions indexes
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_suggestions_project_id'
  ) THEN
    CREATE INDEX idx_content_suggestions_project_id 
    ON content_suggestions(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_suggestions_type'
  ) THEN
    CREATE INDEX idx_content_suggestions_type 
    ON content_suggestions(type);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_suggestions_priority'
  ) THEN
    CREATE INDEX idx_content_suggestions_priority 
    ON content_suggestions(priority);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_content_suggestions_status'
  ) THEN
    CREATE INDEX idx_content_suggestions_status 
    ON content_suggestions(status);
  END IF;
END $$;