import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Testing the EXACT same query logic your app uses...\n');

  // Test with the same domain IDs that would be selected
  final testDomainIds = [
    '550e8400-e29b-41d4-a716-446655440001', // Technology
    '550e8400-e29b-41d4-a716-446655440002', // Business
    '550e8400-e29b-41d4-a716-446655440003', // Design
  ];

  print('Testing with domain IDs: $testDomainIds\n');

  try {
    // Step 1: Test the inFilter logic (this is what your app uses)
    print('📋 Step 1: Testing inFilter with multiple domain IDs...');
    final inFilterQuery = testDomainIds.map((id) => 'domain_id.eq.$id').join(',');
    final inFilterUrl = '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status&or=($inFilterQuery)&status=eq.active&limit=50';
    
    print('Query URL: $inFilterUrl');
    
    final inFilterResponse = await http.get(
      Uri.parse(inFilterUrl),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('Status: ${inFilterResponse.statusCode}');
    if (inFilterResponse.statusCode == 200) {
      final jobs = json.decode(inFilterResponse.body) as List;
      print('✅ Found ${jobs.length} jobs with inFilter logic');
      
      if (jobs.isEmpty) {
        print('❌ NO JOBS FOUND with inFilter - This is the app problem!');
      } else {
        print('Sample jobs:');
        for (var job in jobs.take(3)) {
          print('  - "${job['title']}" (domain: ${job['domain_id']}, status: ${job['status']})');
        }
      }
    } else {
      print('❌ inFilter query failed: ${inFilterResponse.body}');
    }

    print('\n📋 Step 2: Testing individual domain queries...');
    for (var domainId in testDomainIds) {
      final singleUrl = '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status&domain_id=eq.$domainId&status=eq.active&limit=10';
      
      final singleResponse = await http.get(
        Uri.parse(singleUrl),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
      );

      if (singleResponse.statusCode == 200) {
        final jobs = json.decode(singleResponse.body) as List;
        print('Domain $domainId: ${jobs.length} jobs');
      }
    }

    print('\n📋 Step 3: Checking job status distribution...');
    final allJobsUrl = '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status&limit=20';
    
    final allJobsResponse = await http.get(
      Uri.parse(allJobsUrl),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    if (allJobsResponse.statusCode == 200) {
      final allJobs = json.decode(allJobsResponse.body) as List;
      print('Sample of all jobs (first 20):');
      
      final statusCounts = <String, int>{};
      for (var job in allJobs) {
        final status = job['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        print('  - "${job['title']}" -> domain: ${job['domain_id']}, status: $status');
      }
      
      print('\nStatus distribution in sample:');
      statusCounts.forEach((status, count) {
        print('  - $status: $count jobs');
      });
    }

    print('\n📋 Step 4: Testing the complex join query (like your app)...');
    final complexUrl = '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status,company:companies(name),domain:domains(name)&status=eq.active&limit=10';
    
    final complexResponse = await http.get(
      Uri.parse(complexUrl),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('Complex join query status: ${complexResponse.statusCode}');
    if (complexResponse.statusCode == 200) {
      final jobs = json.decode(complexResponse.body) as List;
      print('✅ Complex join works: ${jobs.length} jobs');
      
      if (jobs.isNotEmpty) {
        print('Sample with joins:');
        for (var job in jobs.take(2)) {
          print('  - "${job['title']}" at ${job['company']?['name']} (${job['domain']?['name']})');
        }
      }
    } else {
      print('❌ Complex join failed: ${complexResponse.body}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}