import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('📋 Fetching all domains from database...\n');

  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/domains?select=id,name,description&order=name.asc'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final domains = json.decode(response.body) as List;
      
      print('✅ Found ${domains.length} domains:\n');
      print('Domain ID                                | Domain Name');
      print('----------------------------------------|------------------');
      
      for (var domain in domains) {
        final id = domain['id'] as String;
        final name = domain['name'] as String;
        print('${id.padRight(39)} | $name');
      }

      print('\n📊 Summary:');
      print('Total domains: ${domains.length}');
      
      // Also show jobs count per domain
      print('\n💼 Checking jobs per domain...');
      for (var domain in domains) {
        final domainId = domain['id'];
        final domainName = domain['name'];
        
        final jobsResponse = await http.get(
          Uri.parse('$supabaseUrl/rest/v1/jobs?select=id&domain_id=eq.$domainId'),
          headers: {
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
            'Content-Type': 'application/json',
          },
        );
        
        if (jobsResponse.statusCode == 200) {
          final jobs = json.decode(jobsResponse.body) as List;
          print('${domainName.padRight(20)} | ${jobs.length} jobs');
        }
      }

    } else {
      print('❌ Failed to fetch domains');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}