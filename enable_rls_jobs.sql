-- Re-enable Row Level Security on jobs table
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Optional: Create a policy to allow reading jobs for authenticated users
-- CREATE POLICY "Allow reading jobs" ON jobs FOR SELECT TO authenticated USING (true);

-- Optional: Create a policy to allow anonymous users to read jobs
-- CREATE POLICY "Allow anonymous reading jobs" ON jobs FOR SELECT TO anon USING (true);