import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
  );

  final client = Supabase.instance.client;

  print('🔍 Checking for duplicate users...');

  try {
    // Check users in custom users table
    final usersResponse = await client
        .from('users')
        .select('id, email, full_name, created_at')
        .order('created_at', ascending: false);

    print('\n📊 Users in custom users table:');
    for (var user in usersResponse) {
      print('- ID: ${user['id']}, Email: ${user['email']}, Name: ${user['full_name']}');
    }

    // Check for specific email if you know it
    print('\n🔍 Enter the email you\'re trying to register with:');
    // For now, let's check for common test emails
    final testEmails = ['test@example.com', 'user@test.com', 'demo@hiyre.com'];
    
    for (String email in testEmails) {
      final existingUser = await client
          .from('users')
          .select('id, email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        print('⚠️  Found existing user with email $email: ${existingUser['id']}');
        
        // Option to delete the existing user
        print('🗑️  Deleting existing user with email $email...');
        await client
            .from('users')
            .delete()
            .eq('email', email);
        print('✅ Deleted user with email $email');
      }
    }

    print('\n✅ Cleanup completed. You can now try registration again.');

  } catch (e) {
    print('❌ Error during cleanup: $e');
  }
}