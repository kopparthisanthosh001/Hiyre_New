import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Testing Supabase connection...');
  print('URL: $supabaseUrl');
  print('Key: ${supabaseAnonKey.substring(0, 20)}...');
  print('');

  // Test 1: Check if we can connect to domains table
  print('📋 Test 1: Fetching domains...');
  try {
    final domainsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/domains?select=*'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${domainsResponse.statusCode}');
    if (domainsResponse.statusCode == 200) {
      final domains = json.decode(domainsResponse.body);
      print('✅ Domains fetched successfully: ${domains.length} domains');
      for (var domain in domains.take(3)) {
        print('  - ${domain['name']} (${domain['id']})');
      }
    } else {
      print('❌ Failed to fetch domains: ${domainsResponse.body}');
    }
  } catch (e) {
    print('❌ Error fetching domains: $e');
  }
  
  print('');

  // Test 2: Check if we can connect to jobs table
  print('💼 Test 2: Fetching jobs...');
  try {
    final jobsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/jobs?select=*&limit=5'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${jobsResponse.statusCode}');
    if (jobsResponse.statusCode == 200) {
      final jobs = json.decode(jobsResponse.body);
      print('✅ Jobs fetched successfully: ${jobs.length} jobs');
      for (var job in jobs.take(3)) {
        print('  - ${job['title']} at ${job['company_id']} (Status: ${job['status']})');
      }
    } else {
      print('❌ Failed to fetch jobs: ${jobsResponse.body}');
    }
  } catch (e) {
    print('❌ Error fetching jobs: $e');
  }
  
  print('');

  // Test 3: Check if we can fetch jobs with company info (with joins)
  print('🏢 Test 3: Fetching jobs with company info...');
  try {
    final jobsWithCompaniesResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/jobs?select=*,companies(*)&limit=3'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${jobsWithCompaniesResponse.statusCode}');
    if (jobsWithCompaniesResponse.statusCode == 200) {
      final jobs = json.decode(jobsWithCompaniesResponse.body);
      print('✅ Jobs with companies fetched successfully: ${jobs.length} jobs');
      for (var job in jobs) {
        final company = job['companies'];
        print('  - ${job['title']} at ${company != null ? company['name'] : 'Unknown Company'}');
      }
    } else {
      print('❌ Failed to fetch jobs with companies: ${jobsWithCompaniesResponse.body}');
    }
  } catch (e) {
    print('❌ Error fetching jobs with companies: $e');
  }
  
  print('');
  print('🔍 Connection test completed!');
}