import 'package:supabase/supabase.dart';

void main() async {
  try {
    // Use the same credentials as in SupabaseService
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    print('🔧 Initializing Supabase client...');
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    // Check jobs table
    print('\n📊 Checking jobs table...');
    final jobsResponse = await supabase.from('jobs').select('*').limit(5);
    print('Jobs count: ${jobsResponse.length}');
    if (jobsResponse.isNotEmpty) {
      print('Sample job: ${jobsResponse.first}');
    } else {
      print('⚠️  Jobs table is empty!');
    }
    
    // Check domains table
    print('\n🏷️ Checking domains table...');
    final domainsResponse = await supabase.from('domains').select('*');
    print('Domains count: ${domainsResponse.length}');
    if (domainsResponse.isNotEmpty) {
      print('Available domains:');
      for (var domain in domainsResponse) {
        print('  - ${domain['name']} (ID: ${domain['id']})');
      }
    }
    
    // Check companies table
    print('\n🏢 Checking companies table...');
    final companiesResponse = await supabase.from('companies').select('*');
    print('Companies count: ${companiesResponse.length}');
    if (companiesResponse.isNotEmpty) {
      print('Available companies:');
      for (var company in companiesResponse) {
        print('  - ${company['name']} (ID: ${company['id']})');
      }
    }
    
    // Try to insert a test job
    print('\n🧪 Attempting to insert a test job...');
    try {
      final testJob = {
        'title': 'Test Developer Position',
        'company_id': companiesResponse.isNotEmpty ? companiesResponse.first['id'] : null,
        'domain_id': domainsResponse.isNotEmpty ? domainsResponse.first['id'] : null,
        'description': 'This is a test job for debugging purposes',
        'salary_min': 50000,
        'salary_max': 80000,
        'location': 'Test City',
        'work_mode': 'remote',
        'experience_level': 'mid',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final insertResponse = await supabase.from('jobs').insert(testJob).select();
      print('✅ Test job inserted successfully!');
      print('Job ID: ${insertResponse.first['id']}');
      
      // Clean up - delete the test job
      await supabase.from('jobs').delete().eq('id', insertResponse.first['id']);
      print('🧹 Test job cleaned up');
      
    } catch (insertError) {
      print('❌ Failed to insert test job: $insertError');
      
      if (insertError.toString().contains('RLS') || 
          insertError.toString().contains('policy') ||
          insertError.toString().contains('42501')) {
        print('\n🔒 RLS Policy Issue Detected!');
        print('\nThis means the jobs table has Row Level Security enabled');
        print('but no policy allows anonymous users to insert data.');
        print('\nSolutions:');
        print('1. Disable RLS temporarily: ALTER TABLE jobs DISABLE ROW LEVEL SECURITY;');
        print('2. Create a policy that allows inserts for anonymous users');
        print('3. Use service role key instead of anon key for admin operations');
        print('4. Authenticate users before allowing job operations');
      }
    }
    
    // Test querying jobs with domain filter (like the app does)
    if (domainsResponse.isNotEmpty) {
      print('\n🔍 Testing domain-filtered job query...');
      final domainId = domainsResponse.first['id'];
      final filteredJobs = await supabase
          .from('jobs')
          .select('*')
          .eq('domain_id', domainId)
          .limit(10);
      print('Jobs for domain "${domainsResponse.first['name']}": ${filteredJobs.length}');
    }
    
    print('\n✅ Database debug completed');
    print('\n📋 Summary:');
    print('- Jobs: ${jobsResponse.length}');
    print('- Domains: ${domainsResponse.length}');
    print('- Companies: ${companiesResponse.length}');
    
    if (jobsResponse.isEmpty) {
      print('\n🎯 ROOT CAUSE: The jobs table is empty!');
      print('This is why no jobs appear in the app after domain selection.');
      print('\nNext steps:');
      print('1. Populate the jobs table with real data');
      print('2. Or fix the RLS policies to allow job insertion');
      print('3. Or use a service account to populate initial data');
    }
    
  } catch (e) {
    print('❌ Error during database debug: $e');
  }
} 