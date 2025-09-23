-- Location: supabase/migrations/20250908142428_hiyre_job_platform.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete job platform with authentication
-- Module: Job Platform with Authentication (signin, signup, job matching, applications)

-- 1. ENUMS AND TYPES
CREATE TYPE public.user_role AS ENUM ('job_seeker', 'recruiter', 'admin');
CREATE TYPE public.experience_level AS ENUM ('entry', 'mid', 'senior', 'lead', 'executive');
CREATE TYPE public.employment_type AS ENUM ('full_time', 'part_time', 'contract', 'freelance', 'internship');
CREATE TYPE public.work_mode AS ENUM ('remote', 'hybrid', 'onsite');
CREATE TYPE public.application_status AS ENUM ('pending', 'viewed', 'shortlisted', 'interviewed', 'offered', 'rejected', 'withdrawn');
CREATE TYPE public.job_status AS ENUM ('draft', 'active', 'paused', 'closed');

-- 2. CORE TABLES

-- User profiles table (intermediary for auth.users)
CREATE TABLE public.user_profiles (
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

-- Domains/Industries table
CREATE TABLE public.domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Skills table
CREATE TABLE public.skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Companies table
CREATE TABLE public.companies (
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

-- Jobs table
CREATE TABLE public.jobs (
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

-- User Skills junction table
CREATE TABLE public.user_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE,
    proficiency_level INTEGER DEFAULT 1 CHECK (proficiency_level >= 1 AND proficiency_level <= 5),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, skill_id)
);

-- User preferred domains junction table
CREATE TABLE public.user_domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES public.domains(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, domain_id)
);

-- Job Skills junction table
CREATE TABLE public.job_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(job_id, skill_id)
);

-- Job applications table
CREATE TABLE public.job_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    applicant_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status public.application_status DEFAULT 'pending'::public.application_status,
    cover_letter TEXT,
    resume_url TEXT,
    applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(job_id, applicant_id)
);

-- Job views tracking table
CREATE TABLE public.job_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(job_id, user_id)
);

-- User preferences table
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    preferred_employment_types public.employment_type[],
    preferred_work_modes public.work_mode[],
    preferred_experience_levels public.experience_level[],
    preferred_salary_min INTEGER,
    preferred_salary_max INTEGER,
    preferred_locations TEXT[],
    notification_settings JSONB DEFAULT '{"email": true, "push": true, "sms": false}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. INDEXES for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_jobs_company_id ON public.jobs(company_id);
CREATE INDEX idx_jobs_domain_id ON public.jobs(domain_id);
CREATE INDEX idx_jobs_status ON public.jobs(status);
CREATE INDEX idx_jobs_employment_type ON public.jobs(employment_type);
CREATE INDEX idx_jobs_work_mode ON public.jobs(work_mode);
CREATE INDEX idx_jobs_experience_level ON public.jobs(experience_level);
CREATE INDEX idx_jobs_created_at ON public.jobs(created_at DESC);
CREATE INDEX idx_job_applications_job_id ON public.job_applications(job_id);
CREATE INDEX idx_job_applications_applicant_id ON public.job_applications(applicant_id);
CREATE INDEX idx_job_applications_status ON public.job_applications(status);
CREATE INDEX idx_user_skills_user_id ON public.user_skills(user_id);
CREATE INDEX idx_user_domains_user_id ON public.user_domains(user_id);
CREATE INDEX idx_job_views_job_id ON public.job_views(job_id);
CREATE INDEX idx_job_views_user_id ON public.job_views(user_id);

-- 4. FUNCTIONS (must come before RLS policies)

-- Function for automatic user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  INSERT INTO public.user_profiles (
    id, 
    email, 
    full_name, 
    role
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'job_seeker')::public.user_role
  );
  RETURN NEW;
END;
$func$;

-- Function to update job application counts
CREATE OR REPLACE FUNCTION public.update_job_application_count()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.jobs 
    SET applications_count = applications_count + 1
    WHERE id = NEW.job_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.jobs 
    SET applications_count = applications_count - 1
    WHERE id = OLD.job_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$func$;

-- Function to update job view counts
CREATE OR REPLACE FUNCTION public.update_job_view_count()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  UPDATE public.jobs 
  SET views_count = views_count + 1
  WHERE id = NEW.job_id;
  RETURN NEW;
END;
$func$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$func$;

-- 5. ENABLE RLS ON ALL TABLES
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES (using correct patterns to avoid circular dependencies)

-- Pattern 1: Core user table - Simple, direct policies
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read access for reference tables
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

-- Pattern 2: Simple user ownership for user-related tables
CREATE POLICY "users_manage_own_user_skills"
ON public.user_skills
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_domains"
ON public.user_domains
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_preferences"
ON public.user_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read, private write for companies
CREATE POLICY "public_can_read_companies"
ON public.companies
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_companies"
ON public.companies
FOR INSERT, UPDATE, DELETE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Pattern 4: Public read, recruiter write for jobs
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

-- Job skills can be managed by job owners
CREATE POLICY "job_owners_manage_job_skills"
ON public.job_skills
FOR ALL
TO authenticated
USING (job_id IN (SELECT id FROM public.jobs WHERE posted_by = auth.uid()))
WITH CHECK (job_id IN (SELECT id FROM public.jobs WHERE posted_by = auth.uid()));

-- Pattern 2: Simple user ownership for applications
CREATE POLICY "applicants_manage_own_applications"
ON public.job_applications
FOR ALL
TO authenticated
USING (applicant_id = auth.uid())
WITH CHECK (applicant_id = auth.uid());

-- Allow job owners to view and update applications
CREATE POLICY "job_owners_view_applications"
ON public.job_applications
FOR SELECT
TO authenticated
USING (job_id IN (SELECT id FROM public.jobs WHERE posted_by = auth.uid()));

CREATE POLICY "job_owners_update_applications"
ON public.job_applications
FOR UPDATE
TO authenticated
USING (job_id IN (SELECT id FROM public.jobs WHERE posted_by = auth.uid()));

-- Pattern 2: User views tracking
CREATE POLICY "users_manage_own_job_views"
ON public.job_views
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. TRIGGERS
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_job_applications_count
  AFTER INSERT OR DELETE ON public.job_applications
  FOR EACH ROW EXECUTE FUNCTION public.update_job_application_count();

CREATE TRIGGER update_job_views_count
  AFTER INSERT ON public.job_views
  FOR EACH ROW EXECUTE FUNCTION public.update_job_view_count();

-- Updated at triggers
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_companies_updated_at
  BEFORE UPDATE ON public.companies
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at
  BEFORE UPDATE ON public.jobs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at
  BEFORE UPDATE ON public.job_applications
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 8. MOCK DATA for testing
DO $$
DECLARE
    job_seeker_id UUID := gen_random_uuid();
    recruiter_id UUID := gen_random_uuid();
    admin_id UUID := gen_random_uuid();
    company1_id UUID := gen_random_uuid();
    company2_id UUID := gen_random_uuid();
    tech_domain_id UUID := gen_random_uuid();
    design_domain_id UUID := gen_random_uuid();
    javascript_skill_id UUID := gen_random_uuid();
    react_skill_id UUID := gen_random_uuid();
    job1_id UUID := gen_random_uuid();
    job2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields for signin
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (job_seeker_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john.doe@gmail.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "role": "job_seeker"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (recruiter_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'sarah.wilson@outlook.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Wilson", "role": "recruiter"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@hiyre.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert domains
    INSERT INTO public.domains (id, name, description) VALUES
        (tech_domain_id, 'Technology', 'Software development, IT, and technology roles'),
        (design_domain_id, 'Design', 'UI/UX, graphic design, and creative roles'),
        (gen_random_uuid(), 'Marketing', 'Digital marketing, content, and growth roles'),
        (gen_random_uuid(), 'Sales', 'Business development and sales roles'),
        (gen_random_uuid(), 'Finance', 'Accounting, finance, and investment roles');

    -- Insert skills
    INSERT INTO public.skills (id, name, category) VALUES
        (javascript_skill_id, 'JavaScript', 'Programming'),
        (react_skill_id, 'React', 'Frontend'),
        (gen_random_uuid(), 'Node.js', 'Backend'),
        (gen_random_uuid(), 'Python', 'Programming'),
        (gen_random_uuid(), 'Figma', 'Design'),
        (gen_random_uuid(), 'UI/UX Design', 'Design'),
        (gen_random_uuid(), 'Project Management', 'Management'),
        (gen_random_uuid(), 'SQL', 'Database');

    -- Insert companies
    INSERT INTO public.companies (id, name, description, industry, size, location, created_by) VALUES
        (company1_id, 'TechCorp', 'Leading technology solutions company', 'Technology', '500-1000', 'San Francisco, CA', recruiter_id),
        (company2_id, 'Design Studio', 'Creative design and branding agency', 'Design', '50-100', 'New York, NY', recruiter_id),
        (gen_random_uuid(), 'StartupXYZ', 'Fast-growing fintech startup', 'Finance', '10-50', 'Austin, TX', recruiter_id);

    -- Insert jobs
    INSERT INTO public.jobs (id, title, description, company_id, domain_id, employment_type, work_mode, experience_level, salary_min, salary_max, location, posted_by) VALUES
        (job1_id, 'Senior React Developer', 'Join our team to build amazing web applications using React and modern technologies.', company1_id, tech_domain_id, 'full_time'::public.employment_type, 'remote'::public.work_mode, 'senior'::public.experience_level, 90000, 130000, 'Remote', recruiter_id),
        (job2_id, 'UX Designer', 'Create intuitive and beautiful user experiences for our mobile and web products.', company2_id, design_domain_id, 'full_time'::public.employment_type, 'hybrid'::public.work_mode, 'mid'::public.experience_level, 70000, 95000, 'New York, NY', recruiter_id),
        (gen_random_uuid(), 'Full Stack Developer', 'Work with cutting-edge technologies to build scalable web applications.', company1_id, tech_domain_id, 'full_time'::public.employment_type, 'onsite'::public.work_mode, 'mid'::public.experience_level, 80000, 110000, 'San Francisco, CA', recruiter_id);

    -- Insert job skills
    INSERT INTO public.job_skills (job_id, skill_id, is_required) VALUES
        (job1_id, javascript_skill_id, true),
        (job1_id, react_skill_id, true),
        (job2_id, (SELECT id FROM public.skills WHERE name = 'Figma'), true),
        (job2_id, (SELECT id FROM public.skills WHERE name = 'UI/UX Design'), true);

    -- Update profile completion status for job seeker
    UPDATE public.user_profiles SET profile_completed = true WHERE id = job_seeker_id;

    -- Insert user skills for job seeker
    INSERT INTO public.user_skills (user_id, skill_id, proficiency_level) VALUES
        (job_seeker_id, javascript_skill_id, 4),
        (job_seeker_id, react_skill_id, 4),
        (job_seeker_id, (SELECT id FROM public.skills WHERE name = 'Node.js'), 3);

    -- Insert user domains for job seeker
    INSERT INTO public.user_domains (user_id, domain_id) VALUES
        (job_seeker_id, tech_domain_id);

    -- Insert user preferences for job seeker
    INSERT INTO public.user_preferences (user_id, preferred_employment_types, preferred_work_modes, preferred_experience_levels, preferred_salary_min, preferred_salary_max) VALUES
        (job_seeker_id, ARRAY['full_time'::public.employment_type], ARRAY['remote'::public.work_mode, 'hybrid'::public.work_mode], ARRAY['mid'::public.experience_level, 'senior'::public.experience_level], 80000, 120000);

    -- Insert sample job application
    INSERT INTO public.job_applications (job_id, applicant_id, status, cover_letter) VALUES
        (job1_id, job_seeker_id, 'pending'::public.application_status, 'I am very excited about this opportunity and believe my React experience makes me a great fit for this role.');

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Some mock data already exists, skipping duplicates';
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Error inserting mock data: %', SQLERRM;
END $$;