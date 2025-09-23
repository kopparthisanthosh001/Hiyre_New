import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase with hardcoded credentials
  await Supabase.initialize(
    url: 'https://ixqjqfkqjqjqjqjqjqjq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4cWpxZmtxanFqcWpxanFqcWpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4NzQ4NzQsImV4cCI6MjA0MTQ1MDg3NH0.example',
  );

  final client = Supabase.instance.client;

  print('Testing different OR query formats...\n');

  // Test domain IDs (using actual domain IDs from your database)
  final domainIds = [
    '550e8400-e29b-41d4-a716-446655440001', // Technology
    '550e8400-e29b-41d4-a716-446655440002', // Business
  ];

  // Test 1: Current broken format
  try {
    print('Test 1: Current broken OR format');
    final orConditions = domainIds.map((id) => 'domain_id.eq.$id').join(',');
    print('OR conditions: $orConditions');
    
    final response1 = await client
        .from('jobs')
        .select('id, title, domain_id')
        .or(orConditions)
        .eq('status', 'active')
        .limit(10);
    
    print('Result 1: ${response1.length} jobs found');
    for (var job in response1) {
      print('  - ${job['title']} (domain: ${job['domain_id']})');
    }
  } catch (e) {
    print('Error in Test 1: $e');
  }

  print('\n---\n');

  // Test 2: Correct inFilter format
  try {
    print('Test 2: Using inFilter (correct approach)');
    
    final response2 = await client
        .from('jobs')
        .select('id, title, domain_id')
        .inFilter('domain_id', domainIds)
        .eq('status', 'active')
        .limit(10);
    
    print('Result 2: ${response2.length} jobs found');
    for (var job in response2) {
      print('  - ${job['title']} (domain: ${job['domain_id']})');
    }
  } catch (e) {
    print('Error in Test 2: $e');
  }

  print('\n---\n');

  // Test 3: Multiple individual queries
  try {
    print('Test 3: Individual queries per domain');
    
    List<Map<String, dynamic>> allJobs = [];
    
    for (String domainId in domainIds) {
      final response = await client
          .from('jobs')
          .select('id, title, domain_id')
          .eq('domain_id', domainId)
          .eq('status', 'active')
          .limit(5);
      
      print('Domain $domainId: ${response.length} jobs');
      allJobs.addAll(List<Map<String, dynamic>>.from(response));
    }
    
    print('Total jobs from individual queries: ${allJobs.length}');
  } catch (e) {
    print('Error in Test 3: $e');
  }

  print('\n---\n');

  // Test 4: Check what domains actually exist
  try {
    print('Test 4: Available domains');
    final domains = await client
        .from('domains')
        .select('id, name');
    
    print('Available domains:');
    for (var domain in domains) {
      print('  - ${domain['name']}: ${domain['id']}');
    }
  } catch (e) {
    print('Error in Test 4: $e');
  }
}