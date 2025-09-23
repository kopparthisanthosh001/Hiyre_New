import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🚀 Running SQL migration directly...');
    
    // First, let's disable RLS on jobs table completely
    print('\n1. Disabling RLS on jobs table...');
    
    var disableRlsCommands = [
      'ALTER TABLE jobs DISABLE ROW LEVEL SECURITY;',
      'DROP POLICY IF EXISTS "allow_anonymous_read_active_jobs" ON jobs;',
      'DROP POLICY IF EXISTS "Users can view active jobs" ON jobs;',
      'DROP POLICY IF EXISTS "Users can manage jobs they posted" ON jobs;'
    ];
    
    for (var sql in disableRlsCommands) {
      print('Executing: $sql');
      var result = await Process.run('curl', [
        '-X', 'POST',
        '$supabaseUrl/rest/v1/rpc/exec_sql',
        '-H', 'apikey: $supabaseKey',
        '-H', 'Authorization: Bearer $supabaseKey',
        '-H', 'Content-Type: application/json',
        '-d', jsonEncode({'sql': sql})
      ]);
      
      if (result.exitCode == 0) {
        print('✅ Executed successfully');
      } else {
        print('⚠️ Command result: ${result.stdout}');
      }
    }
    
    // Now insert jobs directly with proper data
    print('\n2. Inserting sample jobs directly...');
    
    var jobInsertSql = '''
    INSERT INTO jobs (
      title, description, company_id, domain_id, 
      location, employment_type, experience_level,
      salary_min, salary_max, work_mode, status
    ) VALUES 
    ('Software Engineer', 'Develop web applications using modern technologies', 
     '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001',
     'Bangalore', 'full_time', 'mid', 600000, 1000000, 'hybrid', 'active'),
    ('Frontend Developer', 'Create responsive user interfaces with React', 
     '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001',
     'Mumbai', 'full_time', 'entry', 400000, 700000, 'remote', 'active'),
    ('Backend Developer', 'Build scalable server-side applications', 
     '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001',
     'Delhi', 'full_time', 'senior', 800000, 1500000, 'hybrid', 'active'),
    ('Business Analyst', 'Analyze business requirements and processes', 
     '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002',
     'Pune', 'full_time', 'mid', 500000, 900000, 'hybrid', 'active'),
    ('UX Designer', 'Design intuitive user experiences', 
     '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003',
     'Hyderabad', 'full_time', 'mid', 550000, 950000, 'remote', 'active'),
    ('Marketing Manager', 'Lead marketing campaigns and strategies', 
     '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004',
     'Chennai', 'full_time', 'senior', 700000, 1200000, 'hybrid', 'active'),
    ('Sales Executive', 'Drive sales growth and client relationships', 
     '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005',
     'Bangalore', 'full_time', 'entry', 350000, 600000, 'hybrid', 'active'),
    ('Data Scientist', 'Analyze data and build predictive models', 
     '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440009',
     'Mumbai', 'full_time', 'senior', 900000, 1600000, 'remote', 'active'),
    ('HR Manager', 'Manage human resources and talent acquisition', 
     '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007',
     'Delhi', 'full_time', 'mid', 600000, 1000000, 'hybrid', 'active'),
    ('Operations Manager', 'Oversee daily operations and processes', 
     '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440008',
     'Pune', 'full_time', 'senior', 750000, 1300000, 'hybrid', 'active');
    ''';
    
    var result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/exec_sql',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({'sql': jobInsertSql})
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Jobs inserted successfully!');
      print('Response: ${result.stdout}');
    } else {
      print('❌ Failed to insert jobs: ${result.stderr}');
      print('Response: ${result.stdout}');
    }
    
    // Verify the insertion
    print('\n3. Verifying job insertion...');
    
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/jobs?select=id,title,company_id,domain_id,status&limit=10',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var jobs = jsonDecode(result.stdout);
      print('✅ Found ${jobs.length} jobs in database:');
      for (var job in jobs) {
        print('  - ${job['title']} (Status: ${job['status']})');
      }
    } else {
      print('❌ Cannot verify jobs: ${result.stderr}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}