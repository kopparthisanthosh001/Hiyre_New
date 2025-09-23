-- Add Profile Creation Tables
-- This migration adds tables for work experience, education, and certifications
-- to support the 4-screen profile creation flow

-- Work Experience table
CREATE TABLE IF NOT EXISTS public.work_experiences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    job_title VARCHAR(255) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    employment_type VARCHAR(50) DEFAULT 'full_time', -- full_time, part_time, contract, freelance, internship
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    responsibilities TEXT,
    achievements TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Education table
CREATE TABLE IF NOT EXISTS public.education (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    degree_program VARCHAR(255) NOT NULL,
    field_of_study VARCHAR(255) NOT NULL,
    institution_name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    graduation_year INTEGER,
    gpa DECIMAL(3,2),
    academic_achievements TEXT,
    coursework TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Certifications table
CREATE TABLE IF NOT EXISTS public.certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    certification_name VARCHAR(255) NOT NULL,
    issuing_organization VARCHAR(255) NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    credential_id VARCHAR(255),
    credential_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Documents table for resume, portfolio, cover letter
CREATE TABLE IF NOT EXISTS public.user_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- resume, portfolio, cover_letter
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Update users table to include profile completion tracking
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS profile_completion_step INTEGER DEFAULT 0, -- 0-4 for the 4 screens
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS bio TEXT;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_work_experiences_user_id ON public.work_experiences(user_id);
CREATE INDEX IF NOT EXISTS idx_education_user_id ON public.education(user_id);
CREATE INDEX IF NOT EXISTS idx_certifications_user_id ON public.certifications(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_user_id ON public.user_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_type ON public.user_documents(document_type);

-- Add RLS policies
ALTER TABLE public.work_experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.education ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_documents ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can view own work experiences" ON public.work_experiences
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own work experiences" ON public.work_experiences
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own work experiences" ON public.work_experiences
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own work experiences" ON public.work_experiences
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Users can view own education" ON public.education
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own education" ON public.education
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own education" ON public.education
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own education" ON public.education
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Users can view own certifications" ON public.certifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own certifications" ON public.certifications
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own certifications" ON public.certifications
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own certifications" ON public.certifications
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Users can view own documents" ON public.user_documents
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own documents" ON public.user_documents
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own documents" ON public.user_documents
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own documents" ON public.user_documents
    FOR DELETE USING (user_id = auth.uid());