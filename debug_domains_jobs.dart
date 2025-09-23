import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    print('=== CHECKING SUPABASE DATABASE ===');
    
    // Check domains table
    print('\n1. Checking domains table...');
    var result = await Process.run('curl', [
      '-X', 'GET',
      'https://jalkqdrzbfnklpoerwui.supabase.co/rest/v1/domains?select=*',
       '-H', 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
       '-H', 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino'
    ]);
    
    if (result.exitCode == 0) {
      var domains = jsonDecode(result.stdout);
      print('Found ${domains.length} domains:');
      for (var domain in domains) {
        print('  ID: ${domain['id']}, Name: ${domain['name']}');
      }
    } else {
      print('Error fetching domains: ${result.stderr}');
    }
    
    // Check jobs table
    print('\n2. Checking jobs table...');
    result = await Process.run('curl', [
      '-X', 'GET',
      'https://jalkqdrzbfnklpoerwui.supabase.co/rest/v1/jobs?select=id,title,domain_id,status&limit=20',
       '-H', 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
       '-H', 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino'
    ]);
    
    if (result.exitCode == 0) {
      var jobs = jsonDecode(result.stdout);
      print('Found ${jobs.length} jobs:');
      for (var job in jobs) {
        print('  Job: ${job['title']}, Domain ID: ${job['domain_id']}, Status: ${job['status']}');
      }
    } else {
      print('Error fetching jobs: ${result.stderr}');
    }
    
    // Check active jobs count
    print('\n3. Checking active jobs count...');
    result = await Process.run('curl', [
      '-X', 'GET',
      'https://jalkqdrzbfnklpoerwui.supabase.co/rest/v1/jobs?select=domain_id&status=eq.active',
       '-H', 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
       '-H', 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino'
    ]);
    
    if (result.exitCode == 0) {
      var activeJobs = jsonDecode(result.stdout);
      print('Found ${activeJobs.length} active jobs');
      
      Map<String, int> domainCounts = {};
      for (var job in activeJobs) {
        String domainId = job['domain_id']?.toString() ?? 'null';
        domainCounts[domainId] = (domainCounts[domainId] ?? 0) + 1;
      }
      
      print('Active jobs by domain:');
      domainCounts.forEach((domainId, count) {
        print('  Domain ID: $domainId -> $count jobs');
      });
    } else {
      print('Error fetching active jobs: ${result.stderr}');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}