import 'dart:convert';
import 'dart:io';

void main() async {
  // Supabase REST API endpoint
  const String supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  final client = HttpClient();
  
  try {
    print('Checking database structure and user data');
    print('=' * 50);

    // Check users table structure
    final request1 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/users?limit=10'));
    request1.headers.set('apikey', supabaseKey);
    request1.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response1 = await request1.close();
    final responseBody1 = await response1.transform(utf8.decoder).join();
    
    print('Users Table (first 10 entries):');
    if (responseBody1.isNotEmpty && responseBody1 != '[]') {
      final users = jsonDecode(responseBody1) as List;
      for (var user in users) {
        print('User: $user');
        // Check if this is vamshi kopparthi
        if (user['full_name'] != null && 
            user['full_name'].toString().toLowerCase().contains('vamshi')) {
          print('*** FOUND VAMSHI KOPPARTHI: $user ***');
        }
      }
    } else {
      print('No users found in users table');
    }
    print('');

    // Check user_profiles table structure
    final request2 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/user_profiles?limit=10'));
    request2.headers.set('apikey', supabaseKey);
    request2.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response2 = await request2.close();
    final responseBody2 = await response2.transform(utf8.decoder).join();
    
    print('User Profiles Table (first 10 entries):');
    if (responseBody2.isNotEmpty && responseBody2 != '[]') {
      final profiles = jsonDecode(responseBody2) as List;
      for (var profile in profiles) {
        print('Profile: $profile');
        // Check if this is vamshi kopparthi
        if (profile['email'] != null && 
            profile['email'].toString().toLowerCase().contains('vamshi')) {
          print('*** FOUND VAMSHI KOPPARTHI PROFILE: $profile ***');
        }
      }
    } else {
      print('No profiles found in user_profiles table');
    }
    print('');

    // Check auth.users table (Supabase built-in)
    print('Note: User registration data is stored in Supabase auth.users table');
    print('This table is not directly accessible via REST API for security reasons.');
    print('User signup data (email, metadata) is managed by Supabase Auth.');

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  print('\n${'=' * 50}');
  print('SUPABASE DASHBOARD ACCESS:');
  print('Dashboard URL: https://supabase.com/dashboard/project/jalkqdrzbfnklpoerwui');
  print('\nTo view user "vamshi kopparthi" data:');
  print('1. Go to Authentication > Users in the Supabase dashboard');
  print('2. Look for user with email or name containing "vamshi kopparthi"');
  print('3. User registration data is stored in auth.users table');
  print('4. Additional profile data may be in user_profiles or users table');
  print('\nDirect link to Authentication page:');
  print('https://supabase.com/dashboard/project/jalkqdrzbfnklpoerwui/auth/users');
}