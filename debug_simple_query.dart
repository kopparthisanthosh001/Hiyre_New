import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing Supabase OR query formats...\n');

  // Your actual Supabase credentials (from working scripts)
  final supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  final client = HttpClient();

  // Test domain IDs
  final domainIds = [
    '550e8400-e29b-41d4-a716-446655440001', // Technology
    '550e8400-e29b-41d4-a716-446655440002', // Business
  ];

  try {
    // Test 1: Current broken OR format
    print('Test 1: Current broken OR format');
    final orConditions = domainIds.map((id) => 'domain_id.eq.$id').join(',');
    print('OR conditions: $orConditions');
    
    final uri1 = Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title,domain_id&or=($orConditions)&status=eq.active&limit=10');
    final request1 = await client.getUrl(uri1);
    request1.headers.set('apikey', supabaseKey);
    request1.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response1 = await request1.close();
    final responseBody1 = await response1.transform(utf8.decoder).join();
    
    print('Status: ${response1.statusCode}');
    if (response1.statusCode == 200) {
      final data1 = jsonDecode(responseBody1) as List;
      print('Result 1: ${data1.length} jobs found');
      for (var job in data1.take(3)) {
        print('  - ${job['title']} (domain: ${job['domain_id']})');
      }
    } else {
      print('Error: $responseBody1');
    }

    print('\n---\n');

    // Test 2: Using in filter (correct approach)
    print('Test 2: Using in filter (correct approach)');
    final inFilter = domainIds.map((id) => '"$id"').join(',');
    print('IN filter: domain_id=in.($inFilter)');
    
    final uri2 = Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title,domain_id&domain_id=in.($inFilter)&status=eq.active&limit=10');
    final request2 = await client.getUrl(uri2);
    request2.headers.set('apikey', supabaseKey);
    request2.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response2 = await request2.close();
    final responseBody2 = await response2.transform(utf8.decoder).join();
    
    print('Status: ${response2.statusCode}');
    if (response2.statusCode == 200) {
      final data2 = jsonDecode(responseBody2) as List;
      print('Result 2: ${data2.length} jobs found');
      for (var job in data2.take(3)) {
        print('  - ${job['title']} (domain: ${job['domain_id']})');
      }
    } else {
      print('Error: $responseBody2');
    }

    print('\n---\n');

    // Test 3: Check available domains
    print('Test 3: Available domains');
    final uri3 = Uri.parse('$supabaseUrl/rest/v1/domains?select=id,name');
    final request3 = await client.getUrl(uri3);
    request3.headers.set('apikey', supabaseKey);
    request3.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response3 = await request3.close();
    final responseBody3 = await response3.transform(utf8.decoder).join();
    
    print('Status: ${response3.statusCode}');
    if (response3.statusCode == 200) {
      final data3 = jsonDecode(responseBody3) as List;
      print('Available domains:');
      for (var domain in data3) {
        print('  - ${domain['name']}: ${domain['id']}');
      }
    } else {
      print('Error: $responseBody3');
    }

    print('\n---\n');

    // Test 4: Count jobs per domain
    print('Test 4: Count jobs per domain');
    for (String domainId in domainIds) {
      final uri4 = Uri.parse('$supabaseUrl/rest/v1/jobs?select=id&domain_id=eq.$domainId&status=eq.active');
      final request4 = await client.getUrl(uri4);
      request4.headers.set('apikey', supabaseKey);
      request4.headers.set('Authorization', 'Bearer $supabaseKey');
      
      final response4 = await request4.close();
      final responseBody4 = await response4.transform(utf8.decoder).join();
      
      if (response4.statusCode == 200) {
        final data4 = jsonDecode(responseBody4) as List;
        print('Domain $domainId: ${data4.length} jobs');
      } else {
        print('Domain $domainId: Error - $responseBody4');
      }
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}