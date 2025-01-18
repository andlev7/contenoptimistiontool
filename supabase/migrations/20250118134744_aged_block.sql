/*
  # Create Initial Admin User

  This migration creates the initial admin user for the application.
  
  1. Changes
    - Sets andmaillev@gmail.com as an admin user
*/

-- Call the create_initial_admin function to set up the admin user
SELECT create_initial_admin('andmaillev@gmail.com');