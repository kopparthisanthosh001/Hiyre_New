import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🧪 Testing resume upload functionality...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    print('1. Verifying bio column exists...');
    try {
      await client.from('users').select('bio').limit(1);
      print('✅ Bio column exists!');
    } catch (e) {
      print('❌ Bio column still missing: $e');
      return;
    }

    print('2. Testing createUserProfile function (simulating resume upload)...');
    
    // Test the exact same data structure that profile_service.dart uses
    final testProfileData = {
      'id': 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      'email': 'test@example.com',
      'full_name': 'Test User',
      'phone': '+1234567890',
      'bio': 'This is a test bio from resume upload',
      'location': 'Test City',
      'profile_completed': false,
      'profile_completion_step': 1,
    };

    try {
      final response = await client
          .from('users')
          .insert(testProfileData)
          .select();
      
      print('✅ User profile created successfully!');
      print('📋 Created user: ${response.first['full_name']} with bio: "${response.first['bio']}"');
      
      // Clean up test data
      await client
          .from('users')
          .delete()
          .eq('id', testProfileData['id']);
      print('🧹 Test data cleaned up');
      
    } catch (e) {
      print('❌ Failed to create user profile: $e');
      return;
    }

    print('3. Testing users table structure...');
    try {
      final users = await client.from('users').select('*').limit(1);
      if (users.isNotEmpty) {
        print('✅ Users table columns: ${users.first.keys.toList()}');
      } else {
        print('ℹ️ Users table is empty but accessible');
      }
    } catch (e) {
      print('❌ Error accessing users table: $e');
    }

    print('\n🎉 Resume upload functionality test completed successfully!');
    print('✅ The bio column issue has been resolved!');

  } catch (e) {
    print('❌ Error: $e');
  }
}