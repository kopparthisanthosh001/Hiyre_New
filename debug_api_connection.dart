import 'package:supabase/supabase.dart';

void main() async {
  try {
    // Use the same credentials as in SupabaseService
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    print('🔧 Testing API connection to jobs table...');
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    // Test 1: Basic job fetch to get count
    print('\n1. Testing basic job fetch...');
    try {
      final basicJobs = await supabase
          .from('jobs')
          .select('id, title, status')
          .limit(1000);
      print('✅ Total jobs found: ${basicJobs.length}');
      if (basicJobs.isNotEmpty) {
        print('   Sample: ${basicJobs[0]['title']} (Status: ${basicJobs[0]['status']})');
      }
    } catch (e) {
      print('❌ Basic fetch failed: $e');
    }
    
    // Test 2: Job fetch with joins (like the app does)
    print('\n2. Testing job fetch with joins...');
    try {
      final joinedJobs = await supabase
          .from('jobs')
          .select('''
            *,
            companies(id, name, logo_url, industry),
            domains(id, name)
          ''')
          .eq('status', 'active')
          .limit(5);
      print('✅ Joined fetch: ${joinedJobs.length} jobs');
      if (joinedJobs.isNotEmpty) {
        final job = joinedJobs[0];
        print('   Sample: ${job['title']} at ${job['companies']?['name']} in ${job['domains']?['name']}');
      }
    } catch (e) {
      print('❌ Joined fetch failed: $e');
    }
    
    // Test 3: Domain-filtered query (the problematic one)
    print('\n3. Testing domain-filtered query...');
    try {
      // Get a sample domain ID first
      final domains = await supabase.from('domains').select('id, name').limit(1);
      if (domains.isNotEmpty) {
        final domainId = domains[0]['id'];
        final domainName = domains[0]['name'];
        
        final filteredJobs = await supabase
            .from('jobs')
            .select('''
              *,
              companies(id, name, logo_url, industry),
              domains(id, name)
            ''')
            .eq('domain_id', domainId)
            .eq('status', 'active')
            .limit(10);
            
        print('✅ Domain-filtered fetch for "$domainName": ${filteredJobs.length} jobs');
        
        if (filteredJobs.isEmpty) {
          print('⚠️  No jobs found for domain "$domainName"');
          
          // Check if there are any jobs with this domain_id at all
          final anyJobs = await supabase
              .from('jobs')
              .select('id, title, domain_id, status')
              .eq('domain_id', domainId);
          print('   Total jobs for this domain (any status): ${anyJobs.length}');
          
          if (anyJobs.isNotEmpty) {
            print('   Sample job statuses:');
            for (var job in anyJobs.take(3)) {
              print('     - ${job['title']}: ${job['status']}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Domain-filtered fetch failed: $e');
    }
    
    // Test 4: Check job statuses
    print('\n4. Checking job statuses...');
    try {
      final allJobs = await supabase
          .from('jobs')
          .select('status');
      
      final statusCounts = <String, int>{};
      for (var job in allJobs) {
        final status = job['status'] ?? 'null';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      
      print('✅ Job status distribution:');
      statusCounts.forEach((status, count) {
        print('   - $status: $count jobs');
      });
    } catch (e) {
      print('❌ Status check failed: $e');
    }
    
    // Test 5: Test multiple domain filtering
    print('\n5. Testing multiple domain filtering...');
    try {
      // Get multiple domains
      final domains = await supabase.from('domains').select('id, name').limit(3);
      if (domains.isNotEmpty) {
        final domainIds = domains.map((d) => d['id']).toList();
        print('   Testing with domain IDs: $domainIds');
        
        // Test each domain individually first
        for (var domain in domains) {
          final singleDomainJobs = await supabase
              .from('jobs')
              .select('id, title, domain_id, status')
              .eq('domain_id', domain['id'])
              .eq('status', 'active');
          print('   Domain "${domain['name']}": ${singleDomainJobs.length} active jobs');
        }
      }
    } catch (e) {
      print('❌ Multiple domain test failed: $e');
    }
    
    print('\n🎯 API Connection Test Complete');
    
  } catch (e) {
    print('❌ Critical error during API test: $e');
  }
}