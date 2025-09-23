import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://rnqjqhqhqhqhqhqhqhqh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJucWpxaHFocWhxaHFocWhxaHFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0MjE5NzQsImV4cCI6MjA1MTk5Nzk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8',
  );

  final client = Supabase.instance.client;

  print('🔍 Testing Flutter Supabase Client Query...\n');

  try {
    // Test 1: Get some domain IDs first
    print('1. Getting domain IDs...');
    final domainsResponse = await client
        .from('domains')
        .select('id, name')
        .limit(3);
    
    print('Found domains: ${domainsResponse.length}');
    for (var domain in domainsResponse) {
      print('  - ${domain['name']} (ID: ${domain['id']})');
    }

    if (domainsResponse.isEmpty) {
      print('❌ No domains found!');
      return;
    }

    // Test 2: Test the exact query your app uses
    final domainIds = domainsResponse.map((d) => d['id'].toString()).toList();
    print('\n2. Testing with domain IDs: $domainIds');

    // Create the OR conditions exactly like your app
    final orConditions = domainIds.map((id) => 'domain_id.eq.$id').join(',');
    print('OR conditions: $orConditions');

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
        .or(orConditions)
        .eq('status', 'active')
        .limit(50);

    print('\n✅ Query executed successfully!');
    print('Found ${response.length} jobs');

    if (response.isNotEmpty) {
      print('\nFirst job details:');
      final firstJob = response[0];
      print('  - Title: ${firstJob['title']}');
      print('  - Domain ID: ${firstJob['domain_id']}');
      print('  - Status: ${firstJob['status']}');
      print('  - Company: ${firstJob['company']?['name'] ?? 'N/A'}');
      print('  - Domain: ${firstJob['domain']?['name'] ?? 'N/A'}');
    } else {
      print('❌ No jobs found with OR filter!');
      
      // Test 3: Check if jobs exist without domain filter
      print('\n3. Testing without domain filter...');
      final allJobsResponse = await client
          .from('jobs')
          .select('id, title, domain_id, status')
          .eq('status', 'active')
          .limit(10);
      
      print('Found ${allJobsResponse.length} active jobs total');
      if (allJobsResponse.isNotEmpty) {
        print('Sample job domain_ids:');
        for (var job in allJobsResponse.take(5)) {
          print('  - Job "${job['title']}" has domain_id: ${job['domain_id']} (type: ${job['domain_id'].runtimeType})');
        }
      }
    }

  } catch (e, stack) {
    print('❌ Error: $e');
    print('Stack: $stack');
  }
}