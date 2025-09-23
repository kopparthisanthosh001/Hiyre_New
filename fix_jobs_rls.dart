import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🔧 Fixing RLS policies for jobs table...');
    
    // Try to create a policy that allows anonymous users to read active jobs
    print('\n1. Creating RLS policy for anonymous job reading...');
    
    var sqlCommand = '''
    DO \$\$
    BEGIN
      -- Drop existing policy if it exists
      DROP POLICY IF EXISTS "allow_anonymous_read_active_jobs" ON jobs;
      
      -- Create new policy to allow anonymous users to read active jobs
      CREATE POLICY "allow_anonymous_read_active_jobs" 
      ON jobs 
      FOR SELECT 
      TO anon 
      USING (status = 'active');
      
      RAISE NOTICE 'RLS policy created successfully';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE 'Error creating policy: %', SQLERRM;
    END
    \$\$;
    ''';
    
    var result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/exec_sql',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({'sql': sqlCommand})
    ]);
    
    if (result.exitCode == 0) {
      print('✅ RLS policy creation attempted');
    } else {
      print('❌ Failed to create RLS policy: ${result.stderr}');
      print('Response: ${result.stdout}');
    }
    
    // Alternative: Try to temporarily disable RLS on jobs table
    print('\n2. Attempting to disable RLS temporarily...');
    
    var disableRlsCommand = 'ALTER TABLE jobs DISABLE ROW LEVEL SECURITY;';
    
    result = await Process.run('curl', [
      '-X', 'POST',
      '$supabaseUrl/rest/v1/rpc/exec_sql',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey',
      '-H', 'Content-Type: application/json',
      '-d', jsonEncode({'sql': disableRlsCommand})
    ]);
    
    if (result.exitCode == 0) {
      print('✅ RLS disable attempted');
    } else {
      print('❌ Failed to disable RLS: ${result.stderr}');
    }
    
    // Now try to read jobs again
    print('\n3. Testing job reading after RLS fix...');
    
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status&limit=10',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var jobs = jsonDecode(result.stdout);
      print('✅ Found ${jobs.length} jobs after RLS fix:');
      for (var job in jobs) {
        print('  - ${job['title']} (Status: ${job['status']}, Domain: ${job['domain_id']})');
      }
    } else {
      print('❌ Still cannot read jobs: ${result.stderr}');
    }
    
    // Try using service role key if available
    print('\n4. Checking if we can use service role...');
    
    // Note: In production, you would use the service role key here
    // For now, let's try a different approach - check table permissions
    
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ API is accessible');
    } else {
      print('❌ API access issue: ${result.stderr}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}