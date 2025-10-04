-- Complete Database Reset and Rebuild
-- This migration drops all existing tables and recreates the entire schema
-- with proper data population for the Hiyre job platform

-- Drop all existing tables (in reverse dependency order)
DROP TABLE IF EXISTS job_applications CASCADE;
DROP TABLE IF EXISTS job_skills CASCADE;
DROP TABLE IF EXISTS job_views CASCADE;
DROP TABLE IF EXISTS user_domains CASCADE;
DROP TABLE IF EXISTS user_preferences CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS skills CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS domains CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(20),
    bio TEXT,
    location VARCHAR(255),
    profile_completed BOOLEAN DEFAULT false,
    profile_completion_step INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Domains table
CREATE TABLE domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    website_url TEXT,
    industry VARCHAR(100),
    size VARCHAR(50),
    location VARCHAR(255),
    founded_year INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Skills table
CREATE TABLE skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Jobs table
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    location VARCHAR(255),
    employment_type VARCHAR(50) DEFAULT 'full_time',
    experience_level VARCHAR(50) DEFAULT 'mid',
    salary_min INTEGER,
    salary_max INTEGER,
    salary_range VARCHAR(50),
    work_mode VARCHAR(50) DEFAULT 'hybrid',
    requirements TEXT,
    benefits TEXT,
    status VARCHAR(20) DEFAULT 'active',
    posted_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create User Profiles table
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    experience_years INTEGER,
    current_position VARCHAR(255),
    location VARCHAR(255),
    resume_url TEXT,
    portfolio_url TEXT,
    linkedin_url TEXT,
    github_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create User Preferences table
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    preferred_employment_types TEXT[],
    preferred_work_modes TEXT[],
    preferred_locations TEXT[],
    salary_expectation_min INTEGER,
    salary_expectation_max INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create User Domains table (many-to-many)
CREATE TABLE user_domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, domain_id)
);

-- Create Job Skills table (many-to-many)
CREATE TABLE job_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, skill_id)
);

-- Create Job Applications table
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    applicant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending',
    cover_letter TEXT,
    resume_url TEXT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, applicant_id)
);

-- Create Job Views table (for tracking)
CREATE TABLE job_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_jobs_company_id ON jobs(company_id);
CREATE INDEX idx_jobs_domain_id ON jobs(domain_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_created_at ON jobs(created_at);
CREATE INDEX idx_job_applications_job_id ON job_applications(job_id);
CREATE INDEX idx_job_applications_applicant_id ON job_applications(applicant_id);
CREATE INDEX idx_user_domains_user_id ON user_domains(user_id);
CREATE INDEX idx_user_domains_domain_id ON user_domains(domain_id);

-- Insert 10 unique domains
INSERT INTO domains (id, name, description, icon) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Technology', 'Software development, IT, and technical roles', 'computer'),
('550e8400-e29b-41d4-a716-446655440002', 'Business', 'Business analysis, strategy, and operations', 'business_center'),
('550e8400-e29b-41d4-a716-446655440003', 'Design', 'UI/UX design, graphic design, and creative roles', 'palette'),
('550e8400-e29b-41d4-a716-446655440004', 'Marketing', 'Digital marketing, content, and advertising', 'campaign'),
('550e8400-e29b-41d4-a716-446655440005', 'Sales', 'Sales, business development, and customer relations', 'trending_up'),
('550e8400-e29b-41d4-a716-446655440006', 'Finance', 'Financial analysis, accounting, and investment', 'account_balance'),
('550e8400-e29b-41d4-a716-446655440007', 'Human Resources', 'HR, talent acquisition, and people operations', 'people'),
('550e8400-e29b-41d4-a716-446655440008', 'Operations', 'Operations management and process optimization', 'settings'),
('550e8400-e29b-41d4-a716-446655440009', 'Data Science', 'Data analysis, machine learning, and analytics', 'analytics'),
('550e8400-e29b-41d4-a716-446655440010', 'Healthcare', 'Medical, pharmaceutical, and healthcare services', 'local_hospital');

-- Insert 10 Indian companies
INSERT INTO companies (id, name, description, industry, size, location, founded_year, website_url) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Tata Consultancy Services', 'Leading IT services and consulting company', 'Information Technology', '500000+', 'Mumbai, India', 1968, 'https://www.tcs.com'),
('660e8400-e29b-41d4-a716-446655440002', 'Infosys', 'Global leader in next-generation digital services', 'Information Technology', '250000+', 'Bangalore, India', 1981, 'https://www.infosys.com'),
('660e8400-e29b-41d4-a716-446655440003', 'Wipro', 'Leading technology services and consulting company', 'Information Technology', '200000+', 'Bangalore, India', 1945, 'https://www.wipro.com'),
('660e8400-e29b-41d4-a716-446655440004', 'HCL Technologies', 'Global technology company providing IT services', 'Information Technology', '150000+', 'Noida, India', 1976, 'https://www.hcltech.com'),
('660e8400-e29b-41d4-a716-446655440005', 'Tech Mahindra', 'Digital transformation and consulting services', 'Information Technology', '125000+', 'Pune, India', 1986, 'https://www.techmahindra.com'),
('660e8400-e29b-41d4-a716-446655440006', 'Flipkart', 'Leading e-commerce marketplace in India', 'E-commerce', '50000+', 'Bangalore, India', 2007, 'https://www.flipkart.com'),
('660e8400-e29b-41d4-a716-446655440007', 'Zomato', 'Food delivery and restaurant discovery platform', 'Food Technology', '5000+', 'Gurgaon, India', 2008, 'https://www.zomato.com'),
('660e8400-e29b-41d4-a716-446655440008', 'Paytm', 'Digital payments and financial services platform', 'Fintech', '25000+', 'Noida, India', 2010, 'https://www.paytm.com'),
('660e8400-e29b-41d4-a716-446655440009', 'BYJU\'S', 'Educational technology and online learning platform', 'EdTech', '50000+', 'Bangalore, India', 2011, 'https://www.byjus.com'),
('660e8400-e29b-41d4-a716-446655440010', 'Ola', 'Mobility platform and ride-hailing service', 'Transportation', '10000+', 'Bangalore, India', 2010, 'https://www.olacabs.com');

-- Create a dedicated recruiter user for posting jobs
INSERT INTO users (id, email, full_name, phone) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'recruiter@hiyre.com', 'Hiyre Recruiter', '+91-9876543210');

-- Function to generate job data for each domain and company combination
DO $$
DECLARE
    domain_record RECORD;
    company_record RECORD;
    job_counter INTEGER := 1;
    job_titles TEXT[];
    job_descriptions TEXT[];
    employment_types TEXT[] := ARRAY['full_time', 'part_time', 'contract', 'internship'];
    experience_levels TEXT[] := ARRAY['entry', 'mid', 'senior', 'lead'];
    work_modes TEXT[] := ARRAY['remote', 'onsite', 'hybrid'];
    locations TEXT[] := ARRAY['Mumbai, India', 'Bangalore, India', 'Delhi, India', 'Pune, India', 'Hyderabad, India', 'Chennai, India', 'Kolkata, India', 'Gurgaon, India', 'Noida, India', 'Remote'];
BEGIN
    -- Loop through each domain
    FOR domain_record IN SELECT * FROM domains LOOP
        -- Define job titles and descriptions based on domain
        CASE domain_record.name
            WHEN 'Technology' THEN
                job_titles := ARRAY['Software Engineer', 'Senior Developer', 'Full Stack Developer', 'DevOps Engineer', 'System Architect', 'Technical Lead', 'Backend Developer', 'Frontend Developer', 'Mobile App Developer', 'Cloud Engineer', 'Data Engineer', 'Security Engineer', 'QA Engineer', 'Site Reliability Engineer', 'Platform Engineer', 'Machine Learning Engineer', 'AI Researcher', 'Blockchain Developer', 'Game Developer', 'Embedded Systems Engineer', 'Network Engineer', 'Database Administrator', 'Solutions Architect', 'Principal Engineer', 'Engineering Manager', 'CTO', 'VP Engineering', 'Tech Consultant', 'Integration Specialist', 'Performance Engineer'];
                job_descriptions := ARRAY['Develop and maintain software applications', 'Lead technical projects and mentor junior developers', 'Build end-to-end web applications', 'Manage infrastructure and deployment pipelines', 'Design scalable system architectures', 'Guide technical decisions and code reviews', 'Develop server-side applications and APIs', 'Create user interfaces and web experiences', 'Build mobile applications for iOS and Android', 'Manage cloud infrastructure and services'];
            WHEN 'Business' THEN
                job_titles := ARRAY['Business Analyst', 'Product Manager', 'Project Manager', 'Business Consultant', 'Strategy Manager', 'Operations Manager', 'Program Manager', 'Business Development Manager', 'Account Manager', 'Relationship Manager', 'Process Improvement Specialist', 'Business Intelligence Analyst', 'Management Consultant', 'Product Owner', 'Scrum Master', 'Agile Coach', 'Change Management Specialist', 'Risk Manager', 'Compliance Officer', 'Quality Assurance Manager', 'Vendor Manager', 'Contract Manager', 'Business Operations Lead', 'Strategic Planning Manager', 'Performance Manager', 'Business Process Analyst', 'Requirements Analyst', 'Systems Analyst', 'Data Analyst', 'Market Research Analyst'];
                job_descriptions := ARRAY['Analyze business requirements and processes', 'Define product strategy and roadmap', 'Manage project timelines and deliverables', 'Provide strategic business consulting', 'Develop and execute business strategies', 'Optimize operational processes and efficiency', 'Coordinate cross-functional programs', 'Drive business growth and partnerships', 'Manage client relationships and accounts', 'Build and maintain stakeholder relationships'];
            WHEN 'Design' THEN
                job_titles := ARRAY['UI/UX Designer', 'Product Designer', 'Graphic Designer', 'Visual Designer', 'Interaction Designer', 'User Researcher', 'Design Lead', 'Creative Director', 'Brand Designer', 'Web Designer', 'Mobile Designer', 'Motion Graphics Designer', 'Illustrator', 'Art Director', 'Design Systems Designer', 'Service Designer', 'Experience Designer', 'Design Strategist', 'Design Manager', 'Principal Designer', 'Senior Designer', 'Junior Designer', 'Design Intern', 'Freelance Designer', 'Design Consultant', 'Creative Producer', 'Design Researcher', 'Usability Specialist', 'Information Architect', 'Content Designer'];
                job_descriptions := ARRAY['Design user interfaces and experiences', 'Create end-to-end product designs', 'Develop visual design assets and branding', 'Design user-centered digital experiences', 'Create interactive design prototypes', 'Conduct user research and usability testing', 'Lead design teams and projects', 'Direct creative vision and strategy', 'Develop brand identity and guidelines', 'Design responsive web interfaces'];
            WHEN 'Marketing' THEN
                job_titles := ARRAY['Digital Marketing Manager', 'Content Marketing Specialist', 'Social Media Manager', 'SEO Specialist', 'PPC Manager', 'Email Marketing Manager', 'Brand Manager', 'Marketing Analyst', 'Growth Hacker', 'Performance Marketing Manager', 'Influencer Marketing Manager', 'Product Marketing Manager', 'Field Marketing Manager', 'Event Marketing Manager', 'PR Manager', 'Communications Manager', 'Content Creator', 'Copywriter', 'Marketing Coordinator', 'Campaign Manager', 'Marketing Automation Specialist', 'Conversion Rate Optimizer', 'Marketing Data Analyst', 'Customer Acquisition Manager', 'Retention Marketing Manager', 'Affiliate Marketing Manager', 'Partnership Marketing Manager', 'Community Manager', 'Marketing Operations Manager', 'CMO'];
                job_descriptions := ARRAY['Develop and execute digital marketing strategies', 'Create engaging content across multiple channels', 'Manage social media presence and campaigns', 'Optimize website search engine rankings', 'Manage paid advertising campaigns', 'Design and execute email marketing campaigns', 'Build and maintain brand identity', 'Analyze marketing performance and ROI', 'Drive user acquisition and growth', 'Optimize marketing performance and conversions'];
            WHEN 'Sales' THEN
                job_titles := ARRAY['Sales Manager', 'Account Executive', 'Business Development Representative', 'Sales Development Representative', 'Inside Sales Representative', 'Outside Sales Representative', 'Key Account Manager', 'Regional Sales Manager', 'Sales Director', 'VP Sales', 'Sales Engineer', 'Technical Sales Specialist', 'Channel Partner Manager', 'Sales Operations Manager', 'Customer Success Manager', 'Account Manager', 'Territory Manager', 'Sales Analyst', 'Sales Coordinator', 'Lead Generation Specialist', 'Sales Consultant', 'Pre-Sales Consultant', 'Post-Sales Support', 'Renewal Manager', 'Upsell Specialist', 'Sales Trainer', 'Sales Enablement Manager', 'CRM Administrator', 'Sales Process Manager', 'Revenue Operations Manager'];
                job_descriptions := ARRAY['Lead sales team and drive revenue growth', 'Manage client accounts and close deals', 'Generate new business opportunities', 'Qualify leads and schedule demos', 'Handle inbound sales inquiries', 'Develop territory and field sales', 'Manage strategic enterprise accounts', 'Oversee regional sales performance', 'Direct sales strategy and operations', 'Lead sales organization and strategy'];
            WHEN 'Finance' THEN
                job_titles := ARRAY['Financial Analyst', 'Investment Analyst', 'Accountant', 'Senior Accountant', 'Finance Manager', 'Controller', 'CFO', 'Treasury Analyst', 'Risk Analyst', 'Credit Analyst', 'Budget Analyst', 'Cost Analyst', 'Tax Specialist', 'Audit Manager', 'Internal Auditor', 'External Auditor', 'Compliance Analyst', 'Financial Planning Analyst', 'Corporate Finance Analyst', 'Equity Research Analyst', 'Portfolio Manager', 'Investment Banking Analyst', 'Wealth Manager', 'Financial Advisor', 'Insurance Analyst', 'Actuarial Analyst', 'Quantitative Analyst', 'Financial Risk Manager', 'Derivatives Trader', 'Fixed Income Analyst'];
                job_descriptions := ARRAY['Analyze financial data and create reports', 'Evaluate investment opportunities and risks', 'Manage financial records and transactions', 'Oversee accounting processes and compliance', 'Lead financial planning and analysis', 'Manage financial reporting and controls', 'Direct financial strategy and operations', 'Manage cash flow and treasury operations', 'Assess and mitigate financial risks', 'Evaluate creditworthiness and lending risks'];
            WHEN 'Human Resources' THEN
                job_titles := ARRAY['HR Manager', 'Talent Acquisition Specialist', 'Recruiter', 'HR Business Partner', 'Compensation Analyst', 'Benefits Administrator', 'Training Manager', 'Learning & Development Specialist', 'Employee Relations Specialist', 'HR Generalist', 'HRIS Analyst', 'Payroll Specialist', 'Performance Management Specialist', 'Organizational Development Consultant', 'Diversity & Inclusion Manager', 'HR Operations Manager', 'Talent Management Specialist', 'Executive Recruiter', 'Campus Recruiter', 'HR Coordinator', 'People Operations Manager', 'Culture & Engagement Manager', 'HR Data Analyst', 'Workforce Planning Analyst', 'HR Compliance Specialist', 'Employee Experience Manager', 'Chief People Officer', 'VP Human Resources', 'HR Director', 'Talent Development Manager'];
                job_descriptions := ARRAY['Manage HR operations and employee relations', 'Source and recruit top talent', 'Full-cycle recruiting and hiring', 'Partner with business leaders on HR strategy', 'Analyze compensation and benefits programs', 'Administer employee benefits and programs', 'Design and deliver training programs', 'Develop learning and development initiatives', 'Handle employee relations and conflicts', 'Provide generalist HR support across functions'];
            WHEN 'Operations' THEN
                job_titles := ARRAY['Operations Manager', 'Supply Chain Manager', 'Logistics Coordinator', 'Process Improvement Manager', 'Operations Analyst', 'Production Manager', 'Quality Manager', 'Facilities Manager', 'Inventory Manager', 'Procurement Manager', 'Vendor Manager', 'Operations Director', 'COO', 'Business Process Manager', 'Continuous Improvement Specialist', 'Lean Six Sigma Specialist', 'Operations Coordinator', 'Planning Manager', 'Scheduling Coordinator', 'Distribution Manager', 'Warehouse Manager', 'Transportation Manager', 'Customer Service Manager', 'Call Center Manager', 'Service Delivery Manager', 'Operations Excellence Manager', 'Performance Improvement Manager', 'Operational Risk Manager', 'Compliance Manager', 'Audit Manager'];
                job_descriptions := ARRAY['Oversee daily operations and processes', 'Manage supply chain and vendor relationships', 'Coordinate logistics and distribution', 'Drive process optimization and efficiency', 'Analyze operational performance and metrics', 'Manage production schedules and quality', 'Ensure quality standards and compliance', 'Manage facilities and workplace operations', 'Optimize inventory levels and management', 'Manage procurement and sourcing activities'];
            WHEN 'Data Science' THEN
                job_titles := ARRAY['Data Scientist', 'Senior Data Scientist', 'Machine Learning Engineer', 'Data Analyst', 'Business Intelligence Analyst', 'Data Engineer', 'Analytics Manager', 'Research Scientist', 'AI Engineer', 'Deep Learning Engineer', 'Computer Vision Engineer', 'NLP Engineer', 'Data Architect', 'Big Data Engineer', 'Statistical Analyst', 'Quantitative Researcher', 'Data Product Manager', 'Analytics Consultant', 'Data Visualization Specialist', 'Predictive Modeler', 'Data Mining Specialist', 'Business Analyst', 'Marketing Analyst', 'Financial Analyst', 'Operations Research Analyst', 'Biostatistician', 'Econometrician', 'Data Science Manager', 'Chief Data Officer', 'VP Analytics'];
                job_descriptions := ARRAY['Build predictive models and analyze data', 'Lead data science projects and initiatives', 'Develop machine learning algorithms and systems', 'Analyze data to generate business insights', 'Create dashboards and business intelligence reports', 'Build data pipelines and infrastructure', 'Manage analytics teams and strategy', 'Conduct advanced research and experimentation', 'Develop AI solutions and applications', 'Build deep learning models and neural networks'];
            WHEN 'Healthcare' THEN
                job_titles := ARRAY['Healthcare Analyst', 'Medical Writer', 'Clinical Research Associate', 'Regulatory Affairs Specialist', 'Pharmacovigilance Specialist', 'Medical Affairs Manager', 'Health Economics Researcher', 'Clinical Data Manager', 'Biostatistician', 'Medical Device Specialist', 'Healthcare Consultant', 'Hospital Administrator', 'Health Information Manager', 'Quality Assurance Specialist', 'Compliance Manager', 'Medical Coder', 'Health Informatics Specialist', 'Telemedicine Coordinator', 'Patient Care Coordinator', 'Healthcare Project Manager', 'Medical Sales Representative', 'Pharmaceutical Sales Rep', 'Clinical Trial Manager', 'Drug Safety Associate', 'Medical Communications Manager', 'Healthcare Marketing Manager', 'Public Health Analyst', 'Epidemiologist', 'Health Policy Analyst', 'Healthcare Data Analyst'];
                job_descriptions := ARRAY['Analyze healthcare data and outcomes', 'Create medical and scientific content', 'Manage clinical research studies', 'Ensure regulatory compliance and submissions', 'Monitor drug safety and adverse events', 'Manage medical affairs and communications', 'Conduct health economics research', 'Manage clinical trial data and systems', 'Perform statistical analysis of medical data', 'Support medical device development and compliance'];
        END CASE;
        
        -- Create 30 jobs for this domain (3 jobs per company)
        FOR company_record IN SELECT * FROM companies LOOP
            FOR i IN 1..3 LOOP
                INSERT INTO jobs (
                    title,
                    description,
                    company_id,
                    domain_id,
                    location,
                    employment_type,
                    experience_level,
                    salary_min,
                    salary_max,
                    salary_range,
                    work_mode,
                    requirements,
                    benefits,
                    status,
                    posted_by
                ) VALUES (
                    job_titles[((job_counter - 1) % array_length(job_titles, 1)) + 1],
                    job_descriptions[((job_counter - 1) % array_length(job_descriptions, 1)) + 1] || ' at ' || company_record.name || '. Join our dynamic team and contribute to innovative projects in ' || domain_record.name || '.',
                    company_record.id,
                    domain_record.id,
                    locations[((job_counter - 1) % array_length(locations, 1)) + 1],
                    employment_types[((job_counter - 1) % array_length(employment_types, 1)) + 1],
                    experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1],
                    CASE 
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'entry' THEN 300000 + (RANDOM() * 200000)::INTEGER
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'mid' THEN 600000 + (RANDOM() * 400000)::INTEGER
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'senior' THEN 1000000 + (RANDOM() * 800000)::INTEGER
                        ELSE 1500000 + (RANDOM() * 1000000)::INTEGER
                    END,
                    CASE 
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'entry' THEN 500000 + (RANDOM() * 300000)::INTEGER
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'mid' THEN 800000 + (RANDOM() * 600000)::INTEGER
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'senior' THEN 1200000 + (RANDOM() * 1000000)::INTEGER
                        ELSE 2000000 + (RANDOM() * 1500000)::INTEGER
                    END,
                    CASE 
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'entry' THEN '3-5 LPA'
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'mid' THEN '6-10 LPA'
                        WHEN experience_levels[((job_counter - 1) % array_length(experience_levels, 1)) + 1] = 'senior' THEN '10-18 LPA'
                        ELSE '15-25 LPA'
                    END,
                    work_modes[((job_counter - 1) % array_length(work_modes, 1)) + 1],
                    'Strong technical skills, excellent communication, team collaboration, problem-solving abilities, and relevant experience in ' || domain_record.name || '.',
                    'Competitive salary, health insurance, flexible working hours, professional development opportunities, performance bonuses, and comprehensive benefits package.',
                    'active',
                    '770e8400-e29b-41d4-a716-446655440001'
                );
                
                job_counter := job_counter + 1;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- Insert some sample skills
INSERT INTO skills (name, category) VALUES
('JavaScript', 'Programming'),
('Python', 'Programming'),
('Java', 'Programming'),
('React', 'Frontend'),
('Node.js', 'Backend'),
('SQL', 'Database'),
('AWS', 'Cloud'),
('Docker', 'DevOps'),
('Git', 'Version Control'),
('Agile', 'Methodology'),
('Figma', 'Design'),
('Photoshop', 'Design'),
('Excel', 'Analytics'),
('Tableau', 'Analytics'),
('Salesforce', 'CRM'),
('Project Management', 'Management'),
('Communication', 'Soft Skills'),
('Leadership', 'Soft Skills'),
('Problem Solving', 'Soft Skills'),
('Teamwork', 'Soft Skills');

-- Enable Row Level Security (RLS) but with permissive policies for now
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_views ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for public read access
CREATE POLICY "Public read access for companies" ON companies FOR SELECT USING (true);
CREATE POLICY "Public read access for domains" ON domains FOR SELECT USING (true);
CREATE POLICY "Public read access for jobs" ON jobs FOR SELECT USING (true);
CREATE POLICY "Public read access for skills" ON skills FOR SELECT USING (true);
CREATE POLICY "Public read access for job_skills" ON job_skills FOR SELECT USING (true);

-- Create policies for authenticated users
CREATE POLICY "Users can read their own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own data" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert their own data" ON users FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage their profiles" ON user_profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their preferences" ON user_preferences FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their domains" ON user_domains FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their applications" ON job_applications FOR ALL USING (auth.uid() = applicant_id);
CREATE POLICY "Users can manage their job views" ON job_views FOR ALL USING (auth.uid() = user_id);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON job_applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Summary
-- This migration creates:
-- - 10 unique domains
-- - 10 Indian companies
-- - 300 jobs total (30 jobs per domain, 3 jobs per company per domain)
-- - Proper table relationships and constraints
-- - Indexes for performance
-- - Row Level Security with permissive policies
-- - All necessary columns and data types
-- - Realistic salary ranges in Indian Rupees (LPA)
-- - Diverse job titles and descriptions for each domain
-- - Proper foreign key relationships
-- - Updated_at triggers for data tracking