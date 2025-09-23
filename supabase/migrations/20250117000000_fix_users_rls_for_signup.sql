-- Fix RLS policies for users table to allow signup process
-- Drop the existing restrictive INSERT policy
DROP POLICY IF EXISTS "Users can insert their own data" ON users;

-- Create a more permissive INSERT policy that allows authenticated users to insert
-- This is needed for the signup process where the user is authenticated but needs to create their profile
CREATE POLICY "Authenticated users can insert user data" ON users 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- Keep the existing SELECT and UPDATE policies as they are secure
-- Users can still only read and update their own data