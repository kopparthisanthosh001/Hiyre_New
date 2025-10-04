import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Checking users in database...');

  try {
    // Get all users from the custom users table
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=id,email,full_name,created_at&order=created_at.desc'),
      headers: {
        'Authorization': 'Bearer $supabaseKey',
        'apikey': supabaseKey,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      
      print('\n📊 Found ${users.length} users in database:');
      for (var user in users) {
        print('- ID: ${user['id']}, Email: ${user['email']}, Name: ${user['full_name']}');
      }

      if (users.isNotEmpty) {
        print('\n🗑️ Clearing all existing users to fix duplicate key issue...');
        
        // Delete all users
        final deleteResponse = await http.delete(
          Uri.parse('$supabaseUrl/rest/v1/users?id=neq.00000000-0000-0000-0000-000000000000'),
          headers: {
            'Authorization': 'Bearer $supabaseKey',
            'apikey': supabaseKey,
            'Content-Type': 'application/json',
          },
        );

        if (deleteResponse.statusCode == 204) {
          print('✅ All users deleted successfully!');
          print('✅ You can now try registration again.');
        } else {
          print('❌ Failed to delete users: ${deleteResponse.statusCode}');
          print('Response: ${deleteResponse.body}');
        }
      } else {
        print('✅ No users found in database. Registration should work now.');
      }

    } else {
      print('❌ Failed to fetch users: ${response.statusCode}');
      print('Response: ${response.body}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}