/*
  # User Preferences Schema Update

  1. New Tables
    - `user_preferences`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `theme` (text, light/dark mode)
      - `editor_height` (integer, editor height in pixels)
      - `auto_save` (boolean, enable/disable auto-save)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policy for users to manage their own preferences

  3. Changes
    - Add foreign key constraint to auth.users
    - Add default values for preferences
*/

-- User preferences table
DO $$ 
BEGIN
  CREATE TABLE IF NOT EXISTS user_preferences (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    theme text NOT NULL DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
    editor_height integer NOT NULL DEFAULT 500 CHECK (editor_height BETWEEN 200 AND 1000),
    auto_save boolean NOT NULL DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Enable RLS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE tablename = 'user_preferences'
  ) THEN
    ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policy for user access
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_preferences' 
    AND policyname = 'Users can manage their own preferences'
  ) THEN
    CREATE POLICY "Users can manage their own preferences"
      ON user_preferences
      FOR ALL
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Add unique constraint to ensure one preference set per user
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'user_preferences_user_id_key'
  ) THEN
    ALTER TABLE user_preferences 
    ADD CONSTRAINT user_preferences_user_id_key 
    UNIQUE (user_id);
  END IF;
END $$;

-- Add index for better performance
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_user_preferences_user_id'
  ) THEN
    CREATE INDEX idx_user_preferences_user_id 
    ON user_preferences(user_id);
  END IF;
END $$;

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'set_user_preferences_updated_at'
  ) THEN
    CREATE TRIGGER set_user_preferences_updated_at
      BEFORE UPDATE ON user_preferences
      FOR EACH ROW
      EXECUTE FUNCTION update_user_preferences_updated_at();
  END IF;
END $$;