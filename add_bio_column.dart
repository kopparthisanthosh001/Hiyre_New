import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔧 Adding bio column to users table...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    // First check if bio column exists
    print('1. Checking if bio column exists...');
    try {
      await client.from('users').select('bio').limit(1);
      print('✅ Bio column already exists!');
      return;
    } catch (e) {
      print('❌ Bio column missing, will add it now...');
    }

    // Try to add the bio column using a direct SQL approach
    print('2. Adding bio column...');
    
    // Use the SQL editor/admin panel approach by creating a migration-like query
    final response = await client.rpc('sql', params: {
      'query': 'ALTER TABLE public.users ADD COLUMN bio TEXT;'
    });
    
    print('✅ Bio column added successfully!');
    
    // Verify the column was added
    print('3. Verifying bio column...');
    try {
      await client.from('users').select('bio').limit(1);
      print('✅ Bio column verified successfully!');
    } catch (e) {
      print('❌ Bio column verification failed: $e');
    }

  } catch (e) {
    print('❌ Error: $e');
    print('Note: You may need to add the bio column manually in Supabase dashboard');
  }
}