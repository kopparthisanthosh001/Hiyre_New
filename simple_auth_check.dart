import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Using actual Supabase credentials from your app
  const String supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Simple Authentication State Check...\n');

  try {
    // 1. Check users table
    print('1. Checking users in database...');
    final usersResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=id,email,full_name'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    if (usersResponse.statusCode == 200) {
      final users = jsonDecode(usersResponse.body) as List;
      print('✅ Found ${users.length} users in database:');
      for (var user in users) {
        print('  - ${user['email']} (ID: ${user['id']})');
      }
      
      if (users.isEmpty) {
        print('✅ No users found - perfect for testing swipe limit!');
      }
    } else {
      print('❌ Failed to fetch users: ${usersResponse.statusCode}');
      print('Response: ${usersResponse.body}');
    }

    // 2. Check job applications
    print('\n2. Checking job applications...');
    final appsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/job_applications?select=*'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    if (appsResponse.statusCode == 200) {
      final apps = jsonDecode(appsResponse.body) as List;
      print('✅ Found ${apps.length} job applications');
    } else {
      print('❌ Failed to fetch applications: ${appsResponse.statusCode}');
    }

    // 3. Check jobs table
    print('\n3. Checking available jobs...');
    final jobsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title&limit=5'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    
    if (jobsResponse.statusCode == 200) {
      final jobs = jsonDecode(jobsResponse.body) as List;
      print('✅ Found ${jobs.length} jobs available for swiping');
      if (jobs.isNotEmpty) {
        print('Sample jobs:');
        for (var job in jobs.take(3)) {
          print('  - ${job['title']}');
        }
      }
    } else {
      print('❌ Failed to fetch jobs: ${jobsResponse.statusCode}');
    }

    print('\n📱 Testing Instructions:');
    print('1. Since there are no authenticated users, the swipe limit should work');
    print('2. Open your Flutter app');
    print('3. Navigate to the job swipe screen');
    print('4. Swipe exactly 3 jobs (left or right)');
    print('5. After the 3rd swipe, you should see the login screen');
    print('\n🔧 If the swipe limit still doesn\'t work:');
    print('- Try hot restarting the app (not just hot reload)');
    print('- Clear app data/cache');
    print('- Check if there are any cached authentication tokens');
    
  } catch (error) {
    print('❌ Error: $error');
  }
}