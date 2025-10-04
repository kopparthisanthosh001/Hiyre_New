import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Supabase configuration - using actual credentials from your app
  const String supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Checking Authentication State...\n');

  try {
    // 1. Check auth.users table
    print('1. Checking auth.users table...');
    final authResponse = await http.get(
      Uri.parse('$supabaseUrl/auth/v1/user'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    print('Auth response status: ${authResponse.statusCode}');
    if (authResponse.statusCode == 200) {
      final authData = jsonDecode(authResponse.body);
      print('Current auth user: ${authData}');
    } else {
      print('No authenticated user found');
    }

    // 2. Check users table
    print('\n2. Checking users table...');
    final usersResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=id,email,full_name'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    if (usersResponse.statusCode == 200) {
      final users = jsonDecode(usersResponse.body) as List;
      print('Users in database: ${users.length}');
      for (var user in users) {
        print('  - ${user['email']} (ID: ${user['id']})');
      }
    } else {
      print('Failed to fetch users: ${usersResponse.statusCode}');
    }

    // 3. Check job applications
    print('\n3. Checking job applications...');
    final appsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=*'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    if (appsResponse.statusCode == 200) {
      final apps = jsonDecode(appsResponse.body) as List;
      print('Total applications: ${apps.length}');
    } else {
      print('Failed to fetch applications: ${appsResponse.statusCode}');
    }

    print('\n✅ Authentication state check complete!');
    print('\n📝 To test swipe limit functionality:');
    print('1. Make sure you are NOT logged in (no user in auth.users)');
    print('2. Clear app data/cache if needed');
    print('3. Open the app and go to job swipe screen');
    print('4. Swipe 3 jobs - you should see login prompt');
    
  } catch (error) {
    print('❌ Error checking auth state: $error');
  }
}