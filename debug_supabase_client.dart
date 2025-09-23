import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Testing Supabase Client Query Logic...\n');

  // Your REAL Supabase credentials
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  final client = HttpClient();

  try {
    // Test 1: Get domain IDs first
    print('1. Getting domain IDs...');
    final domainsRequest = await client.getUrl(Uri.parse(
        '$supabaseUrl/rest/v1/domains?select=id,name&limit=3'));
    domainsRequest.headers.set('apikey', supabaseKey);
    domainsRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final domainsResponse = await domainsRequest.close();
    final domainsBody = await domainsResponse.transform(utf8.decoder).join();
    
    print('Response status: ${domainsResponse.statusCode}');
    print('Response body: $domainsBody');
    
    if (domainsResponse.statusCode != 200) {
      print('❌ Failed to get domains: ${domainsResponse.statusCode}');
      return;
    }
    
    final domainsData = jsonDecode(domainsBody);
    
    // Check if it's an error object
    if (domainsData is Map && domainsData.containsKey('error')) {
      print('❌ API Error: ${domainsData['error']}');
      return;
    }
    
    final domains = domainsData as List;

    print('Found ${domains.length} domains:');
    for (var domain in domains) {
      print('  - ${domain['name']} (ID: ${domain['id']}, Type: ${domain['id'].runtimeType})');
    }

    if (domains.isEmpty) {
      print('❌ No domains found!');
      return;
    }

    // Test 2: Test the OR query that should work
    final domainIds = domains.map((d) => d['id'].toString()).toList();
    print('\n2. Testing OR query with domain IDs: $domainIds');

    final orConditions = domainIds.map((id) => 'domain_id.eq.$id').join(',');
    print('OR conditions: $orConditions');

    final jobsRequest = await client.getUrl(Uri.parse(
        '$supabaseUrl/rest/v1/jobs?select=id,title,domain_id,status,company:companies(name),domain:domains(name)&or=($orConditions)&status=eq.active&limit=10'));
    jobsRequest.headers.set('apikey', supabaseKey);
    jobsRequest.headers.set('Authorization', 'Bearer $supabaseKey');

    final jobsResponse = await jobsRequest.close();
    final jobsBody = await jobsResponse.transform(utf8.decoder).join();
    
    print('Jobs response status: ${jobsResponse.statusCode}');
    
    if (jobsResponse.statusCode == 200) {
      final jobsData = jsonDecode(jobsBody);
      
      if (jobsData is Map && jobsData.containsKey('error')) {
        print('❌ Jobs API Error: ${jobsData['error']}');
        return;
      }
      
      final jobs = jobsData as List;
      print('✅ Found ${jobs.length} jobs with OR query');
      
      if (jobs.isNotEmpty) {
        print('\nFirst job:');
        final firstJob = jobs[0];
        print('  - Title: ${firstJob['title']}');
        print('  - Domain ID: ${firstJob['domain_id']} (Type: ${firstJob['domain_id'].runtimeType})');
        print('  - Status: ${firstJob['status']}');
        print('  - Company: ${firstJob['company']?['name'] ?? 'N/A'}');
        print('  - Domain: ${firstJob['domain']?['name'] ?? 'N/A'}');
      }
    } else {
      print('❌ Query failed with status: ${jobsResponse.statusCode}');
      print('Response: $jobsBody');
    }

  } catch (e, stack) {
    print('❌ Error: $e');
    print('Stack: $stack');
  } finally {
    client.close();
  }
}