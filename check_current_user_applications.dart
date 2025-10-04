import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Checking current user applications...\n');
  
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    // Check all job applications with full details
    print('1. Checking all job applications with join query...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=*,jobs(id,title,companies(name,logo_url))'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final applications = jsonDecode(response.body) as List;
      print('✅ Found ${applications.length} total applications');
      
      if (applications.isNotEmpty) {
        print('\nAll applications:');
        for (var app in applications) {
          final job = app['jobs'];
          final company = job?['companies'];
          print('  - App ID: ${app['id']}');
          print('    Applicant: ${app['applicant_id']}');
          print('    Job: ${job?['title'] ?? 'N/A'}');
          print('    Company: ${company?['name'] ?? 'N/A'}');
          print('    Status: ${app['status']}');
          print('    Applied: ${app['applied_at']}');
          print('');
        }
        
        // Check for your specific user
        print('2. Looking for your user ID...');
        final usersResponse = await http.get(
          Uri.parse('$supabaseUrl/rest/v1/users?select=id,email,full_name'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
          },
        );
        
        if (usersResponse.statusCode == 200) {
          final users = jsonDecode(usersResponse.body) as List;
          print('Available users:');
          for (var user in users) {
            print('  - ${user['email']} (ID: ${user['id']})');
            
            // Check applications for this user
            final userApps = applications.where((app) => app['applicant_id'] == user['id']).toList();
            if (userApps.isNotEmpty) {
              print('    Has ${userApps.length} applications');
            }
          }
        }
        
      } else {
        print('⚠️  No applications found - you need to apply to jobs first');
      }
    } else {
      print('❌ Failed to fetch applications: ${response.statusCode}');
      print('Response: ${response.body}');
    }
    
  } catch (error) {
    print('❌ Error: $error');
  }
}