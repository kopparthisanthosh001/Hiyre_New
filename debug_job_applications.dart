import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Diagnosing Job Applications Issues...\n');
  
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    // Test 1: Check Supabase connection
    print('1. Testing Supabase Connection...');
    final connectionResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/domains?select=id,name&limit=1'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (connectionResponse.statusCode == 200) {
      print('✅ Supabase connection successful');
    } else {
      print('❌ Supabase connection failed: ${connectionResponse.statusCode}');
      return;
    }
    
    // Test 2: Check job_applications table structure
    print('\n2. Checking job_applications table structure...');
    final structureResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=*&limit=0'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (structureResponse.statusCode == 200) {
      print('✅ job_applications table exists and is accessible');
    } else {
      print('❌ job_applications table issue: ${structureResponse.statusCode}');
      print('Response: ${structureResponse.body}');
    }
    
    // Test 3: Check if there are any job applications in the database
    print('\n3. Checking existing job applications...');
    final applicationsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=id,job_id,applicant_id,status,applied_at'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (applicationsResponse.statusCode == 200) {
      final applications = jsonDecode(applicationsResponse.body) as List;
      print('✅ Found ${applications.length} job applications in database');
      
      if (applications.isNotEmpty) {
        print('Sample applications:');
        for (var app in applications.take(3)) {
          print('  - ID: ${app['id']}, Job: ${app['job_id']}, Applicant: ${app['applicant_id']}, Status: ${app['status']}');
        }
      } else {
        print('⚠️  No job applications found in database');
      }
    } else {
      print('❌ Failed to fetch job applications: ${applicationsResponse.statusCode}');
      print('Response: ${applicationsResponse.body}');
    }
    
    // Test 4: Check users table for current user
    print('\n4. Checking users table...');
    final usersResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=id,email,full_name'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (usersResponse.statusCode == 200) {
      final users = jsonDecode(usersResponse.body) as List;
      print('✅ Found ${users.length} users in database');
      
      if (users.isNotEmpty) {
        print('Sample users:');
        for (var user in users.take(3)) {
          print('  - ID: ${user['id']}, Email: ${user['email']}, Name: ${user['full_name']}');
        }
      }
    } else {
      print('❌ Failed to fetch users: ${usersResponse.statusCode}');
    }
    
    // Test 5: Check jobs table
    print('\n5. Checking jobs table...');
    final jobsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title,company_id&limit=5'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (jobsResponse.statusCode == 200) {
      final jobs = jsonDecode(jobsResponse.body) as List;
      print('✅ Found ${jobs.length} jobs in database');
      
      if (jobs.isNotEmpty) {
        print('Sample jobs:');
        for (var job in jobs) {
          print('  - ID: ${job['id']}, Title: ${job['title']}');
        }
      }
    } else {
      print('❌ Failed to fetch jobs: ${jobsResponse.statusCode}');
    }
    
    // Test 6: Try to create a test job application
    print('\n6. Testing job application creation...');
    
    // First, get a user ID and job ID
    if (usersResponse.statusCode == 200 && jobsResponse.statusCode == 200) {
      final users = jsonDecode(usersResponse.body) as List;
      final jobs = jsonDecode(jobsResponse.body) as List;
      
      if (users.isNotEmpty && jobs.isNotEmpty) {
        final testUserId = users[0]['id'];
        final testJobId = jobs[0]['id'];
        
        print('Attempting to create test application...');
        print('User ID: $testUserId');
        print('Job ID: $testJobId');
        
        final createResponse = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/job_applications'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode({
            'job_id': testJobId,
            'applicant_id': testUserId,
            'status': 'pending',
            'applied_at': DateTime.now().toIso8601String(),
          }),
        );
        
        if (createResponse.statusCode == 201) {
          print('✅ Test job application created successfully');
        } else {
          print('❌ Failed to create test job application: ${createResponse.statusCode}');
          print('Response: ${createResponse.body}');
        }
      }
    }
    
    // Test 7: Test the join query used by getUserApplications
    print('\n7. Testing getUserApplications join query...');
    final joinResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=*,jobs(id,title,description,companies(name,logo_url))'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (joinResponse.statusCode == 200) {
      final joinData = jsonDecode(joinResponse.body) as List;
      print('✅ Join query successful, found ${joinData.length} applications with job details');
      
      if (joinData.isNotEmpty) {
        print('Sample joined data:');
        for (var app in joinData.take(2)) {
          final job = app['jobs'];
          final company = job?['companies'];
          print('  - Application ID: ${app['id']}');
          print('    Job Title: ${job?['title'] ?? 'N/A'}');
          print('    Company: ${company?['name'] ?? 'N/A'}');
          print('    Status: ${app['status']}');
        }
      }
    } else {
      print('❌ Join query failed: ${joinResponse.statusCode}');
      print('Response: ${joinResponse.body}');
    }
    
  } catch (error) {
    print('❌ Error during diagnosis: $error');
  }
  
  print('\n🔍 Diagnosis complete!');
}