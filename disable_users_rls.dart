import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
  );

  final client = Supabase.instance.client;

  try {
    print('🔧 Attempting to disable RLS on users table...');
    
    // Try to disable RLS using raw SQL through rpc
    final result = await client.rpc('exec', params: {
      'sql': 'ALTER TABLE users DISABLE ROW LEVEL SECURITY;'
    });
    
    print('✅ RLS disabled successfully');
    print('Result: $result');
    
  } catch (error) {
    print('❌ Failed to disable RLS: $error');
    print('\n📋 Manual steps needed:');
    print('1. Go to Supabase Dashboard');
    print('2. Navigate to Database > Tables');
    print('3. Find the "users" table');
    print('4. Click on RLS settings');
    print('5. Temporarily disable RLS for the users table');
    print('6. Or add a policy that allows INSERT for authenticated users');
  }
}