import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 Verifying ALL columns are now working after SQL fix...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    print('📋 Testing all expected columns exist...');
    
    // Test each expected column individually
    final expectedColumns = [
      'id',
      'email', 
      'full_name',
      'phone',
      'bio',
      'location',
      'profile_completed',
      'profile_completion_step',
      'created_at',
      'updated_at'
    ];
    
    final missingColumns = <String>[];
    
    for (String col in expectedColumns) {
      try {
        await client.from('users').select(col).limit(1);
        print('✅ $col - EXISTS');
      } catch (e) {
        print('❌ $col - MISSING: $e');
        missingColumns.add(col);
      }
    }

    if (missingColumns.isNotEmpty) {
      print('\n❌ STILL MISSING COLUMNS: ${missingColumns.join(', ')}');
      print('The SQL script may not have been executed properly.');
      return;
    }

    print('\n🧪 Testing complete profile creation (like resume upload does)...');
    
    final testUserId = 'test-user-${DateTime.now().millisecondsSinceEpoch}';
    final testProfileData = {
      'id': testUserId,
      'email': 'test-resume-upload@example.com',
      'full_name': 'Resume Upload Test User',
      'phone': '+1234567890',
      'bio': 'This is a test bio from resume upload simulation',
      'location': 'Test City, Test State',
      'profile_completed': false,
      'profile_completion_step': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      print('📝 Creating test profile with ALL columns...');
      final response = await client
          .from('users')
          .insert(testProfileData)
          .select()
          .single();
      
      print('✅ SUCCESS! Profile created with all columns:');
      print('   📧 Email: ${response['email']}');
      print('   👤 Name: ${response['full_name']}');
      print('   📱 Phone: ${response['phone']}');
      print('   📝 Bio: ${response['bio']}');
      print('   📍 Location: ${response['location']}');
      print('   ✅ Profile Completed: ${response['profile_completed']}');
      print('   📊 Completion Step: ${response['profile_completion_step']}');
      
      print('\n🔄 Testing profile update (like profile completion does)...');
      await client
          .from('users')
          .update({
            'profile_completed': true,
            'profile_completion_step': 4,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', testUserId);
      
      print('✅ Profile update successful!');
      
      // Clean up test data
      await client.from('users').delete().eq('id', testUserId);
      print('🧹 Test data cleaned up');
      
      print('\n🎉 ALL TESTS PASSED! Resume upload should now work perfectly!');
      
    } catch (e) {
      print('❌ Profile creation test FAILED: $e');
      print('This means there are still issues with the database schema.');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}