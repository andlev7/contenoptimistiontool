/*
  # Add DataForSEO Service

  This migration adds the initial DataForSEO service configuration.
  
  1. Changes
    - Inserts DataForSEO service with empty credentials
*/

-- Insert DataForSEO service if it doesn't exist
INSERT INTO api_services (name, credentials, is_active)
VALUES (
  'DataForSEO',
  jsonb_build_object(
    'login', '',
    'password', ''
  ),
  true
)
ON CONFLICT (name) DO NOTHING;