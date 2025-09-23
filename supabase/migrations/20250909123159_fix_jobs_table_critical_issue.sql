-- Location: supabase/migrations/20250909123159_fix_jobs_table_critical_issue.sql
-- Schema Analysis: Database exists but missing enum types required for jobs table
-- Integration Type: Emergency fix for missing enum types and jobs table preventing core functionality
-- Module: Critical database fix for job platform core functionality

-- 1. FIRST: Create all required enum types if they don't exist
DO $$ 
BEGIN
    -- Create user_role enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('job_seeker', 'recruiter', 'admin');
    END IF;
    
    -- Create experience_level enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'experience_level') THEN
        CREATE TYPE public.experience_level AS ENUM ('entry', 'mid', 'senior', 'lead', 'executive');
    END IF;
    
    -- Create employment_type enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employment_type') THEN
        CREATE TYPE public.employment_type AS ENUM ('full_time', 'part_time', 'contract', 'freelance', 'internship');
    END IF;
    
    -- Create work_mode enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'work_mode') THEN
        CREATE TYPE public.work_mode AS ENUM ('remote', 'hybrid', 'onsite');
    END IF;
    
    -- Create application_status enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_status') THEN
        CREATE TYPE public.application_status AS ENUM ('pending', 'viewed', 'shortlisted', 'interviewed', 'offered', 'rejected', 'withdrawn');
    END IF;
    
    -- Create job_status enum if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'job_status') THEN
        CREATE TYPE public.job_status AS ENUM ('draft', 'active', 'paused', 'closed');
    END IF;
END $$;

-- 2. Create essential reference tables if they don't exist
CREATE TABLE IF NOT EXISTS public.domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'job_seeker'::public.user_role,
    phone_number TEXT,
    profile_image_url TEXT,
    location TEXT,
    bio TEXT,
    is_active BOOLEAN DEFAULT true,
    profile_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    website_url TEXT,
    industry TEXT,
    size TEXT,
    location TEXT,
    founded_year INTEGER,
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. NOW create the jobs table with proper structure
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES public.domains(id) ON DELETE SET NULL,
    employment_type public.employment_type NOT NULL,
    work_mode public.work_mode NOT NULL,
    experience_level public.experience_level NOT NULL,
    salary_min INTEGER,
    salary_max INTEGER,
    currency TEXT DEFAULT 'USD',
    location TEXT,
    requirements TEXT,
    benefits TEXT,
    application_deadline DATE,
    status public.job_status DEFAULT 'active'::public.job_status,
    posted_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    views_count INTEGER DEFAULT 0,
    applications_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Enable RLS on all tables
DO $$
BEGIN
    -- Enable RLS for all tables, ignore if already enabled
    BEGIN
        ALTER TABLE public.domains ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN duplicate_object THEN
        NULL; -- RLS already enabled, continue
    END;
    
    BEGIN
        ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    
    BEGIN
        ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    
    BEGIN
        ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
    
    BEGIN
        ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN duplicate_object THEN
        NULL;
    END;
END $$;

-- 5. Drop existing policies if they exist to avoid conflicts, then recreate
DROP POLICY IF EXISTS "public_can_read_domains" ON public.domains;
DROP POLICY IF EXISTS "public_can_read_skills" ON public.skills;
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "public_can_read_companies" ON public.companies;
DROP POLICY IF EXISTS "users_manage_own_companies" ON public.companies;
DROP POLICY IF EXISTS "public_can_read_active_jobs" ON public.jobs;
DROP POLICY IF EXISTS "recruiters_manage_own_jobs" ON public.jobs;

-- 6. Create RLS policies
CREATE POLICY "public_can_read_domains"
ON public.domains
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "public_can_read_skills"
ON public.skills
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

CREATE POLICY "public_can_read_companies"
ON public.companies
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_companies"
ON public.companies
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "public_can_read_active_jobs"
ON public.jobs
FOR SELECT
TO public
USING (status = 'active'::public.job_status);

CREATE POLICY "recruiters_manage_own_jobs"
ON public.jobs
FOR ALL
TO authenticated
USING (posted_by = auth.uid())
WITH CHECK (posted_by = auth.uid());

-- 7. Create essential indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_domains_is_active ON public.domains(is_active);
CREATE INDEX IF NOT EXISTS idx_skills_is_active ON public.skills(is_active);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_companies_created_by ON public.companies(created_by);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_domain_id ON public.jobs(domain_id);
CREATE INDEX IF NOT EXISTS idx_jobs_company_id ON public.jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_employment_type ON public.jobs(employment_type);
CREATE INDEX IF NOT EXISTS idx_jobs_work_mode ON public.jobs(work_mode);
CREATE INDEX IF NOT EXISTS idx_jobs_experience_level ON public.jobs(experience_level);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON public.jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_by ON public.jobs(posted_by);

-- 8. Ensure essential domain data exists for job creation
INSERT INTO public.domains (id, name, description, is_active) VALUES 
    ('550e8400-e29b-41d4-a716-446655440001', 'Technology', 'Software development, IT, and technology roles', true),
    ('550e8400-e29b-41d4-a716-446655440002', 'Business', 'Business strategy, consulting, and operations', true),
    ('550e8400-e29b-41d4-a716-446655440003', 'Design', 'UI/UX, graphic design, and creative roles', true),
    ('550e8400-e29b-41d4-a716-446655440004', 'Marketing', 'Digital marketing, content, and advertising', true),
    ('550e8400-e29b-41d4-a716-446655440005', 'Sales', 'Sales, business development, and account management', true),
    ('550e8400-e29b-41d4-a716-446655440006', 'Finance', 'Finance, accounting, and investment roles', true)
ON CONFLICT (name) DO UPDATE SET 
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active;

-- 9. Ensure essential skills data exists
INSERT INTO public.skills (name, category) VALUES 
    ('JavaScript', 'Programming'),
    ('React', 'Frontend'),
    ('Node.js', 'Backend'),
    ('Python', 'Programming'),
    ('Java', 'Programming'),
    ('SQL', 'Database'),
    ('UI/UX Design', 'Design'),
    ('Figma', 'Design'),
    ('Adobe Creative Suite', 'Design'),
    ('Project Management', 'Management'),
    ('Marketing Strategy', 'Marketing'),
    ('Sales', 'Sales'),
    ('Financial Analysis', 'Finance'),
    ('Data Analysis', 'Analytics')
ON CONFLICT (name) DO NOTHING;

-- 10. Create test jobs immediately to fix the critical issue
DO $$
DECLARE
    test_recruiter_id UUID;
    tech_company_id UUID := gen_random_uuid();
    business_company_id UUID := gen_random_uuid();
    design_company_id UUID := gen_random_uuid();
BEGIN
    -- Create test recruiter user if doesn't exist
    SELECT id INTO test_recruiter_id FROM auth.users WHERE email = 'test.recruiter@hiyre.com';
    
    IF test_recruiter_id IS NULL THEN
        test_recruiter_id := gen_random_uuid();
        
        -- Insert into auth.users first
        INSERT INTO auth.users (
            id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
            created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
            is_sso_user, is_anonymous
        ) VALUES (
            test_recruiter_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
            'test.recruiter@hiyre.com', crypt('testpass123', gen_salt('bf')), now(), 
            now(), now(),
            '{"full_name": "Test Recruiter", "role": "recruiter"}'::jsonb,
            '{"provider": "email", "providers": ["email"]}'::jsonb,
            false, false
        );
        
        -- Insert into user_profiles
        INSERT INTO public.user_profiles (id, email, full_name, role, profile_completed) VALUES
            (test_recruiter_id, 'test.recruiter@hiyre.com', 'Test Recruiter', 'recruiter'::public.user_role, true);
    END IF;

    -- Insert test companies
    INSERT INTO public.companies (id, name, description, industry, size, location, created_by) VALUES
        (tech_company_id, 'TechCorp Solutions', 'Leading technology company', 'Technology', '500-1000', 'San Francisco, CA', test_recruiter_id),
        (business_company_id, 'Business Pro Inc', 'Business consulting firm', 'Consulting', '100-500', 'New York, NY', test_recruiter_id),
        (design_company_id, 'Creative Design Lab', 'Design and creative agency', 'Design', '50-100', 'Los Angeles, CA', test_recruiter_id)
    ON CONFLICT (id) DO NOTHING;

    -- Insert critical test jobs to make the app functional
    INSERT INTO public.jobs (title, description, company_id, domain_id, employment_type, work_mode, experience_level, salary_min, salary_max, location, posted_by) VALUES
        ('Senior React Developer', 'Build amazing web applications with React and modern technologies. Join our innovative team to create cutting-edge software solutions.', tech_company_id, '550e8400-e29b-41d4-a716-446655440001', 'full_time'::public.employment_type, 'remote'::public.work_mode, 'senior'::public.experience_level, 90000, 130000, 'Remote', test_recruiter_id),
        ('Full Stack Engineer', 'Work with both frontend and backend technologies to build scalable applications. Experience with React, Node.js, and databases required.', tech_company_id, '550e8400-e29b-41d4-a716-446655440001', 'full_time'::public.employment_type, 'hybrid'::public.work_mode, 'mid'::public.experience_level, 80000, 110000, 'San Francisco, CA', test_recruiter_id),
        ('Business Analyst', 'Analyze business processes and identify improvement opportunities. Work with stakeholders to drive strategic initiatives and optimize operations.', business_company_id, '550e8400-e29b-41d4-a716-446655440002', 'full_time'::public.employment_type, 'onsite'::public.work_mode, 'mid'::public.experience_level, 65000, 85000, 'New York, NY', test_recruiter_id),
        ('UX Designer', 'Create intuitive user experiences for our digital products. Conduct user research and design beautiful, functional interfaces.', design_company_id, '550e8400-e29b-41d4-a716-446655440003', 'full_time'::public.employment_type, 'hybrid'::public.work_mode, 'mid'::public.experience_level, 70000, 95000, 'Los Angeles, CA', test_recruiter_id),
        ('Marketing Manager', 'Lead marketing campaigns and strategies to drive growth. Manage digital marketing channels and analyze campaign performance.', business_company_id, '550e8400-e29b-41d4-a716-446655440004', 'full_time'::public.employment_type, 'remote'::public.work_mode, 'senior'::public.experience_level, 75000, 105000, 'Remote', test_recruiter_id),
        ('Frontend Developer', 'Create responsive and interactive user interfaces using modern web technologies. Collaborate with designers and backend developers.', tech_company_id, '550e8400-e29b-41d4-a716-446655440001', 'full_time'::public.employment_type, 'remote'::public.work_mode, 'entry'::public.experience_level, 60000, 80000, 'Remote', test_recruiter_id),
        ('Product Designer', 'Design end-to-end product experiences from concept to launch. Work closely with product managers and engineering teams.', design_company_id, '550e8400-e29b-41d4-a716-446655440003', 'full_time'::public.employment_type, 'hybrid'::public.work_mode, 'senior'::public.experience_level, 85000, 115000, 'Los Angeles, CA', test_recruiter_id),
        ('DevOps Engineer', 'Build and maintain CI/CD pipelines and cloud infrastructure. Ensure reliable deployments and system scalability.', tech_company_id, '550e8400-e29b-41d4-a716-446655440001', 'full_time'::public.employment_type, 'remote'::public.work_mode, 'mid'::public.experience_level, 85000, 115000, 'Remote', test_recruiter_id),
        ('Sales Representative', 'Drive business growth through client acquisition and relationship building. Identify opportunities and close deals.', business_company_id, '550e8400-e29b-41d4-a716-446655440005', 'full_time'::public.employment_type, 'onsite'::public.work_mode, 'entry'::public.experience_level, 45000, 65000, 'New York, NY', test_recruiter_id),
        ('Graphic Designer', 'Create visual designs for marketing materials and brand assets. Work with Adobe Creative Suite and modern design tools.', design_company_id, '550e8400-e29b-41d4-a716-446655440003', 'full_time'::public.employment_type, 'onsite'::public.work_mode, 'mid'::public.experience_level, 50000, 70000, 'Los Angeles, CA', test_recruiter_id)
    ON CONFLICT DO NOTHING;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Some test data already exists, continuing...';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating test data: %', SQLERRM;
END $$;

-- 11. Refresh the schema cache to ensure jobs table is visible
NOTIFY pgrst, 'reload schema';

-- 12. Validate the fix by checking if jobs table exists and has data
DO $$
DECLARE
    job_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO job_count FROM public.jobs;
    RAISE NOTICE 'Jobs table created successfully with % jobs', job_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error validating jobs table: %', SQLERRM;
END $$;