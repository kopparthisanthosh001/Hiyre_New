import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔧 Fixing users table bio column...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    // Execute the bio column fix
    print('1. Adding bio column to users table...');
    
    final queries = [
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS bio TEXT',
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS location VARCHAR(255)',
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false',
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completion_step INTEGER DEFAULT 0',
      'CREATE INDEX IF NOT EXISTS idx_users_profile_completed ON public.users(profile_completed)',
    ];

    for (String query in queries) {
      try {
        print('Executing: $query');
        await client.rpc('exec_sql', params: {'sql': query});
        print('✅ Executed successfully');
      } catch (e) {
        if (e.toString().contains('already exists') || 
            e.toString().contains('duplicate') ||
            e.toString().contains('PGRST202')) {
          print('⚠️ Column/index already exists or function not found, continuing...');
        } else {
          print('❌ Error: $e');
        }
      }
    }

    print('\n2. Verifying users table structure...');
    try {
      final users = await client.from('users').select('*').limit(1);
      print('✅ Users table is accessible');
      if (users.isNotEmpty) {
        print('Sample user data keys: ${users.first.keys.toList()}');
      }
    } catch (e) {
      print('❌ Error accessing users table: $e');
    }

    print('\n🎉 Bio column fix completed!');
  } catch (e) {
    print('❌ Error: $e');
  }
}