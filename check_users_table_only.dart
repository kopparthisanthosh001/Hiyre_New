import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 Checking USERS table structure specifically...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    print('📋 Expected columns from migration file:');
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
      print('   - $col');
    }

    print('\n📋 Checking actual USERS table structure...');
    try {
      final users = await client.from('users').select('*').limit(1);
      
      if (users.isNotEmpty) {
        final actualColumns = users.first.keys.toList();
        print('✅ Actual columns in database:');
        for (String col in actualColumns) {
          print('   - $col');
        }
        
        print('\n🔍 Column comparison:');
        final missingColumns = <String>[];
        final extraColumns = <String>[];
        
        for (String expected in expectedColumns) {
          if (!actualColumns.contains(expected)) {
            missingColumns.add(expected);
          }
        }
        
        for (String actual in actualColumns) {
          if (!expectedColumns.contains(actual)) {
            extraColumns.add(actual);
          }
        }
        
        if (missingColumns.isNotEmpty) {
          print('❌ MISSING columns:');
          for (String col in missingColumns) {
            print('   - $col');
          }
        }
        
        if (extraColumns.isNotEmpty) {
          print('⚠️ EXTRA columns (not in migration):');
          for (String col in extraColumns) {
            print('   - $col');
          }
        }
        
        if (missingColumns.isEmpty && extraColumns.isEmpty) {
          print('✅ All columns match perfectly!');
        }
        
      } else {
        print('⚠️ Users table is empty, testing column access individually...');
        
        for (String col in expectedColumns) {
          try {
            await client.from('users').select(col).limit(1);
            print('✅ $col - EXISTS');
          } catch (e) {
            print('❌ $col - MISSING: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error accessing users table: $e');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}