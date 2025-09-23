import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🧪 Testing job insertion and reading...');
    
    // First, let's check what tables exist
    print('\n1. Checking available tables...');
    var result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      print('✅ API response: ${result.stdout}');
    }
    
    // Check companies first
    print('\n2. Checking companies...');
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/companies?select=id,name&limit=3',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var companies = jsonDecode(result.stdout);
      print('✅ Found ${companies.length} companies');
      for (var company in companies) {
        print('  - ${company['name']} (ID: ${company['id']})');
      }
    } else {
      print('❌ Cannot read companies: ${result.stderr}');
    }
    
    // Check domains
    print('\n3. Checking domains...');
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/domains?select=id,name&limit=3',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var domains = jsonDecode(result.stdout);
      print('✅ Found ${domains.length} domains');
      for (var domain in domains) {
        print('  - ${domain['name']} (ID: ${domain['id']})');
      }
      
      if (domains.isNotEmpty) {
        var firstDomain = domains[0];
        
        // Get companies again for job creation
        result = await Process.run('curl', [
          '-X', 'GET',
          '$supabaseUrl/rest/v1/companies?select=id,name&limit=1',
          '-H', 'apikey: $supabaseKey',
          '-H', 'Authorization: Bearer $supabaseKey'
        ]);
        
        if (result.exitCode == 0) {
          var companies = jsonDecode(result.stdout);
          if (companies.isNotEmpty) {
            var firstCompany = companies[0];
            
            print('\n4. Attempting to insert a test job...');
            
            var testJob = {
              'title': 'Test Software Engineer',
              'description': 'This is a test job to verify database connectivity.',
              'company_id': firstCompany['id'],
              'domain_id': firstDomain['id'],
              'employment_type': 'full-time',
              'work_mode': 'remote',
              'experience_level': 'mid',
              'salary_min': 70000,
              'salary_max': 100000,
              'location': 'Remote',
              'status': 'active'
            };
            
            result = await Process.run('curl', [
              '-X', 'POST',
              '$supabaseUrl/rest/v1/jobs',
              '-H', 'apikey: $supabaseKey',
              '-H', 'Authorization: Bearer $supabaseKey',
              '-H', 'Content-Type: application/json',
              '-H', 'Prefer: return=representation',
              '-d', jsonEncode(testJob)
            ]);
            
            if (result.exitCode == 0) {
              print('✅ Test job inserted successfully!');
              print('Response: ${result.stdout}');
            } else {
              print('❌ Failed to insert test job:');
              print('Error: ${result.stderr}');
              print('Response: ${result.stdout}');
            }
            
            // Now try to read jobs again
            print('\n5. Reading jobs after insertion...');
            result = await Process.run('curl', [
              '-X', 'GET',
              '$supabaseUrl/rest/v1/jobs?select=*&limit=5',
              '-H', 'apikey: $supabaseKey',
              '-H', 'Authorization: Bearer $supabaseKey'
            ]);
            
            if (result.exitCode == 0) {
              var jobs = jsonDecode(result.stdout);
              print('✅ Found ${jobs.length} jobs:');
              for (var job in jobs) {
                print('  - ${job['title']} (Status: ${job['status']})');
              }
            } else {
              print('❌ Cannot read jobs: ${result.stderr}');
            }
          }
        }
      }
    } else {
      print('❌ Cannot read domains: ${result.stderr}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}