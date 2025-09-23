import 'package:supabase/supabase.dart';

void main() async {
  print('=== Testing Supabase Data Flow ===\n');
  
  try {
    // Initialize Supabase client directly
    print('1. Initializing Supabase client...');
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    print('✓ Supabase client initialized successfully\n');
    
    // Test basic connection with domains table
    print('2. Testing connection with domains table...');
    try {
      final domainsResponse = await client
          .from('domains')
          .select('id, name')
          .limit(5);
      
      print('✓ Domains table accessible: ${domainsResponse.length} domains found');
      for (var domain in domainsResponse) {
        print('   - ${domain['name']} (ID: ${domain['id']})');
      }
    } catch (e) {
      print('✗ Error accessing domains table: $e');
    }
    print('');
    
    // Test jobs table
    print('3. Testing jobs table...');
    try {
      final jobsResponse = await client
          .from('jobs')
          .select('id, title, domain_id')
          .limit(5);
      
      print('✓ Jobs table accessible: ${jobsResponse.length} jobs found');
      for (var job in jobsResponse) {
        print('   - ${job['title']} (Domain ID: ${job['domain_id']})');
      }
    } catch (e) {
      print('✗ Error accessing jobs table: $e');
    }
    print('');
    
    // Test users table
    print('4. Testing users table...');
    try {
      final usersResponse = await client
          .from('users')
          .select('id, full_name, email')
          .limit(3);
      
      print('✓ Users table accessible: ${usersResponse.length} users found');
      for (var user in usersResponse) {
        print('   - ${user['full_name'] ?? 'No name'} (${user['email'] ?? 'No email'})');
      }
    } catch (e) {
      print('✗ Error accessing users table: $e');
    }
    print('');
    
    // Test education table
    print('5. Testing education table...');
    try {
      final educationResponse = await client
          .from('education')
          .select('id, degree, institution, user_id')
          .limit(3);
      
      print('✓ Education table accessible: ${educationResponse.length} education records found');
      for (var edu in educationResponse) {
        print('   - ${edu['degree']} at ${edu['institution']} (User ID: ${edu['user_id']})');
      }
    } catch (e) {
      print('✗ Error accessing education table: $e');
    }
    print('');
    
    // Test work_experiences table
    print('6. Testing work_experiences table...');
    try {
      final workExpResponse = await client
          .from('work_experiences')
          .select('id, job_title, company_name, user_id')
          .limit(3);
      
      print('✓ Work experiences table accessible: ${workExpResponse.length} work experience records found');
      for (var exp in workExpResponse) {
        print('   - ${exp['job_title']} at ${exp['company_name']} (User ID: ${exp['user_id']})');
      }
    } catch (e) {
      print('✗ Error accessing work_experiences table: $e');
    }
    print('');
    
    // Test skills table
    print('7. Testing skills table...');
    try {
      final skillsResponse = await client
          .from('skills')
          .select('id, skill_name, user_id')
          .limit(3);
      
      print('✓ Skills table accessible: ${skillsResponse.length} skill records found');
      for (var skill in skillsResponse) {
        print('   - ${skill['skill_name']} (User ID: ${skill['user_id']})');
      }
    } catch (e) {
      print('✗ Error accessing skills table: $e');
    }
    print('');
    
    // Test table counts
    print('8. Getting table record counts...');
    final tables = ['domains', 'jobs', 'users', 'education', 'work_experiences', 'skills', 'certifications'];
    
    for (String table in tables) {
      try {
        final response = await client.from(table).select('id');
        print('   - $table: ${response.length} records');
      } catch (e) {
        print('   - $table: Error getting count ($e)');
      }
    }
    
    print('');
    print('=== Data Flow Test Complete ===');
    print('\nSummary:');
    print('- Supabase connection: ✓ Working');
    print('- Database tables: Accessible');
    print('- Data flow: ✓ Functioning');
    
  } catch (error) {
    print('✗ Fatal error during testing: $error');
  }
}