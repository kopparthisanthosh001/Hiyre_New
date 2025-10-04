import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔧 Adding ALL missing columns to users table...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    // List of SQL commands to add all missing columns
    final sqlCommands = [
      // Add bio column (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS bio TEXT',
      
      // Add profile tracking columns (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false',
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completion_step INTEGER DEFAULT 0',
      
      // Add phone column (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone VARCHAR(20)',
      
      // Add location column (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS location VARCHAR(255)',
      
      // Add full_name column (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS full_name VARCHAR(255)',
      
      // Add timestamps (if not exists)
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()',
      'ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()',
      
      // Create indexes for better performance
      'CREATE INDEX IF NOT EXISTS idx_users_profile_completed ON public.users(profile_completed)',
      'CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email)',
      'CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at)',
    ];

    print('📋 Executing SQL commands to add missing columns...');
    
    for (int i = 0; i < sqlCommands.length; i++) {
      final sql = sqlCommands[i];
      print('${i + 1}/${sqlCommands.length}: ${sql.substring(0, 50)}...');
      
      try {
        await client.rpc('exec_sql', params: {'sql': sql});
        print('   ✅ Success');
      } catch (e) {
        print('   ⚠️ Error (might be expected): $e');
      }
    }

    print('\n🔍 Verifying users table structure after changes...');
    
    // Test each expected column
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
    
    for (String col in expectedColumns) {
      try {
        await client.from('users').select(col).limit(1);
        print('✅ $col - EXISTS');
      } catch (e) {
        print('❌ $col - STILL MISSING: $e');
      }
    }

    print('\n🧪 Testing profile creation with all columns...');
    
    final testUserId = 'test-user-${DateTime.now().millisecondsSinceEpoch}';
    final testProfileData = {
      'id': testUserId,
      'email': 'test@example.com',
      'full_name': 'Test User',
      'phone': '+1234567890',
      'bio': 'Test bio content',
      'location': 'Test Location',
      'profile_completed': false,
      'profile_completion_step': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await client
          .from('users')
          .insert(testProfileData)
          .select()
          .single();
      
      print('✅ Test profile creation successful!');
      print('📄 Created profile: ${response['email']} with bio: ${response['bio']}');
      
      // Clean up test data
      await client.from('users').delete().eq('id', testUserId);
      print('🧹 Test data cleaned up');
      
    } catch (e) {
      print('❌ Test profile creation failed: $e');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}