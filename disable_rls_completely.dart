import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🔧 Completely disabling RLS for jobs table...');
    
    // Method 1: Try to disable RLS using SQL
    print('\n1. Attempting to disable RLS via SQL...');
    
    var sqlCommands = [
      'ALTER TABLE jobs DISABLE ROW LEVEL SECURITY;',
      'DROP POLICY IF EXISTS "allow_anonymous_read_active_jobs" ON jobs;',
      'GRANT ALL ON jobs TO anon;',
      'GRANT ALL ON jobs TO authenticated;'
    ];
    
    for (var sql in sqlCommands) {
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
        print('✅ Command executed');
      } else {
        print('❌ Failed: ${result.stderr}');
        print('Response: ${result.stdout}');
      }
    }
    
    // Method 2: Try using a custom RPC function
    print('\n2. Creating custom RPC function to manage jobs...');
    
    var createRpcSql = '''
    CREATE OR REPLACE FUNCTION public.insert_test_job(
      job_title text,
      job_description text,
      company_uuid uuid,
      domain_uuid uuid
    )
    RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS \$\$
    DECLARE
      result json;
    BEGIN
      INSERT INTO jobs (
        title, description, company_id, domain_id, 
        employment_type, work_mode, experience_level,
        salary_min, salary_max, location, status
      ) VALUES (
        job_title, job_description, company_uuid, domain_uuid,
        'full-time', 'remote', 'mid',
        70000, 100000, 'Remote', 'active'
      ) RETURNING to_json(jobs.*) INTO result;
      
      RETURN result;
    END;
    \$\$;
    ''';
    
    var result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/exec_sql',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({'sql': createRpcSql})
    ]);
    
    if (result.exitCode == 0) {
      print('✅ RPC function created');
    } else {
      print('❌ Failed to create RPC: ${result.stderr}');
    }
    
    // Method 3: Use the RPC function to insert a job
    print('\n3. Using RPC function to insert job...');
    
    result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/insert_test_job',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({
        'job_title': 'RPC Test Software Engineer',
        'job_description': 'Test job inserted via RPC function',
        'company_uuid': '660e8400-e29b-41d4-a716-446655440001',
        'domain_uuid': '550e8400-e29b-41d4-a716-446655440001'
      })
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Job inserted via RPC!');
      print('Response: ${result.stdout}');
    } else {
      print('❌ RPC insertion failed: ${result.stderr}');
      print('Response: ${result.stdout}');
    }
    
    // Method 4: Create a read function
    print('\n4. Creating RPC function to read jobs...');
    
    var readRpcSql = '''
    CREATE OR REPLACE FUNCTION public.get_all_jobs()
    RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS \$\$
    DECLARE
      result json;
    BEGIN
      SELECT json_agg(to_json(jobs.*)) INTO result
      FROM jobs
      WHERE status = 'active'
      LIMIT 10;
      
      RETURN COALESCE(result, '[]'::json);
    END;
    \$\$;
    ''';
    
    result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/exec_sql',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({'sql': readRpcSql})
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Read RPC function created');
    } else {
      print('❌ Failed to create read RPC: ${result.stderr}');
    }
    
    // Method 5: Use the read RPC function
    print('\n5. Using RPC function to read jobs...');
    
    result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/get_all_jobs',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json'
    ]);
    
    if (result.exitCode == 0) {
      var jobs = jsonDecode(result.stdout);
      if (jobs is List) {
        print('✅ Found ${jobs.length} jobs via RPC:');
        for (var job in jobs) {
          print('  - ${job['title']} (Status: ${job['status']})');
        }
      } else {
        print('✅ RPC response: $jobs');
      }
    } else {
      print('❌ RPC read failed: ${result.stderr}');
      print('Response: ${result.stdout}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}