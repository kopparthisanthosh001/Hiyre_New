import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase exactly like your app does
  await Supabase.initialize(
    url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
  );

  final client = Supabase.instance.client;

  print('🔍 Testing the EXACT same query your app uses...\n');

  // Test with the same domain IDs that would be selected
  final testDomainIds = [
    '550e8400-e29b-41d4-a716-446655440001', // Technology
    '550e8400-e29b-41d4-a716-446655440002', // Business
    '550e8400-e29b-41d4-a716-446655440003', // Design
  ];

  print('Testing with domain IDs: $testDomainIds');

  try {
    // This is the EXACT query from your JobService.getJobsForSelectedDomains
    final response = await client
        .from('jobs')
        .select('''
          id,
          title,
          description,
          location,
          employment_type,
          work_mode,
          experience_level,
          salary_min,
          salary_max,
          currency,
          requirements,
          benefits,
          application_deadline,
          status,
          posted_by,
          views_count,
          applications_count,
          created_at,
          updated_at,
          company:companies(id, name, logo_url, description),
          domain:domains(id, name, description)
        ''')
        .inFilter('domain_id', testDomainIds)
        .eq('status', 'active')
        .limit(50);

    print('✅ Query executed successfully!');
    print('Found ${response.length} jobs');

    if (response.isEmpty) {
      print('\n❌ NO JOBS FOUND - This is the problem!');
      
      // Let's debug why
      print('\n🔍 Debugging the issue...');
      
      // Test 1: Check if jobs exist without domain filter
      final allJobs = await client
          .from('jobs')
          .select('id, title, domain_id, status')
          .eq('status', 'active')
          .limit(10);
      
      print('Jobs with status=active: ${allJobs.length}');
      
      // Test 2: Check domain_id values in jobs
      if (allJobs.isNotEmpty) {
        print('\nSample job domain_ids:');
        for (var job in allJobs.take(5)) {
          print('  - "${job['title']}" -> domain_id: ${job['domain_id']}');
        }
      }
      
      // Test 3: Test the inFilter specifically
      print('\n🧪 Testing inFilter with first domain ID...');
      final singleDomainTest = await client
          .from('jobs')
          .select('id, title, domain_id')
          .eq('domain_id', testDomainIds[0])
          .eq('status', 'active')
          .limit(5);
      
      print('Jobs for ${testDomainIds[0]}: ${singleDomainTest.length}');
      
    } else {
      print('\n✅ Jobs found! The query works.');
      for (var job in response.take(3)) {
        print('  - ${job['title']} (${job['domain']['name']})');
      }
    }

  } catch (e, stack) {
    print('❌ Query failed: $e');
    print('Stack: $stack');
  }
}