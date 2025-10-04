-- Fix all missing columns in users table
-- This script adds all columns that are expected by the application but missing from the database

-- Add bio column (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS bio TEXT;

-- Add profile tracking columns (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completion_step INTEGER DEFAULT 0;

-- Add phone column (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

-- Add location column (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS location VARCHAR(255);

-- Add full_name column (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS full_name VARCHAR(255);

-- Add timestamps (if not exists)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_profile_completed ON public.users(profile_completed);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- Update existing records to have proper timestamps if they're null
UPDATE public.users 
SET created_at = NOW() 
WHERE created_at IS NULL;

UPDATE public.users 
SET updated_at = NOW() 
WHERE updated_at IS NULL;

-- Verify the table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND table_schema = 'public'
ORDER BY ordinal_position;