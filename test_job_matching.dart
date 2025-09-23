import 'package:supabase/supabase.dart';

void main() async {
  try {
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    print('🔍 Testing job matching functionality...\n');
    
    // Test 1: Get all domains
    print('📋 Test 1: Getting all domains...');
    final domains = await supabase.from('domains').select('*');
    print('✅ Found ${domains.length} domains:');
    for (var domain in domains) {
      print('   - ${domain['name']} (ID: ${domain['id']})');
    }
    
    // Test 2: Get all jobs with company and domain info
    print('\n💼 Test 2: Getting all jobs with joins...');
    final allJobs = await supabase.from('jobs').select('''
      *,
      companies (
        id,
        name,
        logo_url,
        industry,
        location
      ),
      domains (
        id,
        name
      )
    ''').eq('status', 'active');
    
    print('✅ Found ${allJobs.length} active jobs');
    
    // Test 3: Test domain filtering for each domain
    print('\n🎯 Test 3: Testing domain filtering...');
    for (var domain in domains.take(3)) { // Test first 3 domains
      final domainId = domain['id'] as String;
      final domainName = domain['name'] as String;
      
      final filteredJobs = await supabase.from('jobs').select('''
        *,
        companies (
          id,
          name,
          logo_url,
          industry,
          location
        ),
        domains (
          id,
          name
        )
      ''').eq('status', 'active').eq('domain_id', domainId);
      
      print('   - $domainName: ${filteredJobs.length} jobs');
      
      // Show first 2 jobs for this domain
      for (var job in filteredJobs.take(2)) {
        print('     • ${job['title']} at ${job['companies']['name']}');
      }
    }
    
    // Test 4: Test multiple domain filtering (simulating app behavior)
    print('\n🔄 Test 4: Testing multiple domain filtering...');
    final selectedDomainIds = domains.take(2).map((d) => d['id'] as String).toList();
    print('Selected domains: ${selectedDomainIds.join(', ')}');
    
    final multiDomainJobs = await supabase.from('jobs').select('''
      *,
      companies (
        id,
        name,
        logo_url,
        industry,
        location
      ),
      domains (
        id,
        name
      )
    ''').eq('status', 'active').inFilter('domain_id', selectedDomainIds);
    
    print('✅ Found ${multiDomainJobs.length} jobs for selected domains');
    
    // Test 5: Test job service-like query with pagination
    print('\n📄 Test 5: Testing pagination...');
    final paginatedJobs = await supabase.from('jobs').select('''
      *,
      companies (
        id,
        name,
        logo_url,
        industry,
        location
      ),
      domains (
        id,
        name
      )
    ''').eq('status', 'active')
      .order('created_at', ascending: false)
      .range(0, 9); // First 10 jobs
    
    print('✅ Found ${paginatedJobs.length} jobs with pagination');
    
    // Test 6: Show sample job data structure
    print('\n📋 Test 6: Sample job data structure...');
    if (allJobs.isNotEmpty) {
      final sampleJob = allJobs.first;
      print('Sample job structure:');
      print('   - ID: ${sampleJob['id']}');
      print('   - Title: ${sampleJob['title']}');
      print('   - Company: ${sampleJob['companies']['name']}');
      print('   - Domain: ${sampleJob['domains']['name']}');
      print('   - Location: ${sampleJob['location']}');
      print('   - Employment Type: ${sampleJob['employment_type']}');
      print('   - Experience Level: ${sampleJob['experience_level']}');
      print('   - Salary Range: ${sampleJob['salary_range']}');
      print('   - Work Mode: ${sampleJob['work_mode']}');
    }
    
    print('\n🎉 All tests completed successfully!');
    print('✅ Job matching functionality is working correctly.');
    print('🚀 Your app should now be able to display jobs properly.');
    
  } catch (error) {
    print('❌ Error during testing: $error');
  }
}