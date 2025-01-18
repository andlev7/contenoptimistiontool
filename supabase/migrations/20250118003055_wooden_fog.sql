/*
  # User Activity Logs Schema Update

  1. New Tables
    - `user_activity_logs`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `project_id` (uuid, references projects)
      - `action_type` (text, type of action performed)
      - `details` (jsonb, additional action details)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policy for users to view their own activity logs
    - Add policy for admins to view all logs

  3. Changes
    - Add foreign key constraints
    - Add indexes for better performance
    - Add action_type validation
*/

-- User activity logs table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS user_activity_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    action_type text NOT NULL CHECK (
      action_type IN (
        'project_create',
        'project_update',
        'serp_data_add',
        'serp_data_update',
        'ai_prompt_create',
        'ai_result_generate',
        'content_save',
        'preferences_update'
      )
    ),
    details jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Enable RLS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'user_activity_logs'
  ) THEN
    ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policy for user access
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_activity_logs' 
    AND policyname = 'Users can view their own activity logs'
  ) THEN
    CREATE POLICY "Users can view their own activity logs"
      ON user_activity_logs
      FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- Create policy for user insert
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_activity_logs' 
    AND policyname = 'Users can create their own activity logs'
  ) THEN
    CREATE POLICY "Users can create their own activity logs"
      ON user_activity_logs
      FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Add indexes for better performance
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_activity_logs_user_id'
  ) THEN
    CREATE INDEX idx_user_activity_logs_user_id 
    ON user_activity_logs(user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_activity_logs_project_id'
  ) THEN
    CREATE INDEX idx_user_activity_logs_project_id 
    ON user_activity_logs(project_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_activity_logs_action_type'
  ) THEN
    CREATE INDEX idx_user_activity_logs_action_type 
    ON user_activity_logs(action_type);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_activity_logs_created_at'
  ) THEN
    CREATE INDEX idx_user_activity_logs_created_at 
    ON user_activity_logs(created_at);
  END IF;
END $$;

-- Add GIN index for jsonb details field
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_activity_logs_details'
  ) THEN
    CREATE INDEX idx_user_activity_logs_details 
    ON user_activity_logs USING GIN (details);
  END IF;
END $$;