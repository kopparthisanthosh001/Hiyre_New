import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🚀 Inserting jobs directly via REST API...');
    
    // First, let's verify we can read companies and domains
    print('\n1. Checking companies...');
    var result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/companies?select=id,name&limit=5',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var companies = jsonDecode(result.stdout);
      print('✅ Found ${companies.length} companies');
      for (var company in companies) {
        print('  - ${company['name']} (${company['id']})');
      }
    }
    
    print('\n2. Checking domains...');
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/domains?select=id,name&limit=5',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var domains = jsonDecode(result.stdout);
      print('✅ Found ${domains.length} domains');
      for (var domain in domains) {
        print('  - ${domain['name']} (${domain['id']})');
      }
    }
    
    // Now let's try inserting jobs one by one
    print('\n3. Inserting jobs one by one...');
    
    var jobsToInsert = [
      {
        'title': 'Software Engineer',
        'description': 'Develop web applications using modern technologies like React, Node.js, and databases.',
        'company_id': '660e8400-e29b-41d4-a716-446655440001',
        'domain_id': '550e8400-e29b-41d4-a716-446655440001',
        'location': 'Bangalore',
        'employment_type': 'full_time',
        'experience_level': 'mid',
        'salary_min': 600000,
        'salary_max': 1000000,
        'work_mode': 'hybrid',
        'status': 'active'
      },
      {
        'title': 'Frontend Developer',
        'description': 'Create responsive user interfaces with React, Vue.js, and modern CSS frameworks.',
        'company_id': '660e8400-e29b-41d4-a716-446655440002',
        'domain_id': '550e8400-e29b-41d4-a716-446655440001',
        'location': 'Mumbai',
        'employment_type': 'full_time',
        'experience_level': 'entry',
        'salary_min': 400000,
        'salary_max': 700000,
        'work_mode': 'remote',
        'status': 'active'
      },
      {
        'title': 'Backend Developer',
        'description': 'Build scalable server-side applications using Python, Java, or Node.js.',
        'company_id': '660e8400-e29b-41d4-a716-446655440003',
        'domain_id': '550e8400-e29b-41d4-a716-446655440001',
        'location': 'Delhi',
        'employment_type': 'full_time',
        'experience_level': 'senior',
        'salary_min': 800000,
        'salary_max': 1500000,
        'work_mode': 'hybrid',
        'status': 'active'
      },
      {
        'title': 'Business Analyst',
        'description': 'Analyze business requirements and processes to improve efficiency.',
        'company_id': '660e8400-e29b-41d4-a716-446655440001',
        'domain_id': '550e8400-e29b-41d4-a716-446655440002',
        'location': 'Pune',
        'employment_type': 'full_time',
        'experience_level': 'mid',
        'salary_min': 500000,
        'salary_max': 900000,
        'work_mode': 'hybrid',
        'status': 'active'
      },
      {
        'title': 'UX Designer',
        'description': 'Design intuitive user experiences and create wireframes and prototypes.',
        'company_id': '660e8400-e29b-41d4-a716-446655440002',
        'domain_id': '550e8400-e29b-41d4-a716-446655440003',
        'location': 'Hyderabad',
        'employment_type': 'full_time',
        'experience_level': 'mid',
        'salary_min': 550000,
        'salary_max': 950000,
        'work_mode': 'remote',
        'status': 'active'
      }
    ];
    
    int successCount = 0;
    
    for (int i = 0; i < jobsToInsert.length; i++) {
      var job = jobsToInsert[i];
      print('Inserting job ${i + 1}: ${job['title']}');
      
      result = await Process.run('curl', [
        '-X', 'POST',
        '$supabaseUrl/rest/v1/jobs',
        '-H', 'apikey: $supabaseKey',
        '-H', 'Authorization: Bearer $supabaseKey',
        '-H', 'Content-Type: application/json',
        '-H', 'Prefer: return=representation',
        '-d', jsonEncode(job)
      ]);
      
      if (result.exitCode == 0) {
        try {
          var response = jsonDecode(result.stdout);
          if (response is List && response.isNotEmpty) {
            print('✅ Job inserted successfully: ${response[0]['id']}');
            successCount++;
          } else if (response is Map && response.containsKey('id')) {
            print('✅ Job inserted successfully: ${response['id']}');
            successCount++;
          } else {
            print('⚠️ Unexpected response: ${result.stdout}');
          }
        } catch (e) {
          print('⚠️ Response parsing error: $e');
          print('Raw response: ${result.stdout}');
        }
      } else {
        print('❌ Failed to insert job: ${result.stderr}');
        print('Response: ${result.stdout}');
      }
      
      // Small delay between requests
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    print('\n📊 Successfully inserted $successCount out of ${jobsToInsert.length} jobs');
    
    // Verify the insertion
    print('\n4. Verifying job insertion...');
    
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/jobs?select=id,title,company_id,domain_id,status&limit=10',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var jobs = jsonDecode(result.stdout);
      print('✅ Found ${jobs.length} jobs in database:');
      for (var job in jobs) {
        print('  - ${job['title']} (Status: ${job['status']})');
      }
      
      if (jobs.length > 0) {
        print('\n🎉 SUCCESS! Jobs are now available in the database.');
        print('The Flutter app should now be able to display jobs in the matched jobs page.');
      }
    } else {
      print('❌ Cannot verify jobs: ${result.stderr}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}