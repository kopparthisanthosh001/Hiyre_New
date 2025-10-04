import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 Checking users table for bio column...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );

    final client = Supabase.instance.client;

    print('1. Checking users table structure...');
    try {
      final users = await client.from('users').select('*').limit(1);
      if (users.isNotEmpty) {
        print('✅ Users table columns: ${users.first.keys.toList()}');
        
        if (users.first.containsKey('bio')) {
          print('✅ Bio column EXISTS in users table!');
        } else {
          print('❌ Bio column MISSING from users table');
        }
      } else {
        print('⚠️ Users table is empty, checking with select bio specifically...');
        
        try {
          await client.from('users').select('bio').limit(1);
          print('✅ Bio column EXISTS (table is just empty)');
        } catch (e) {
          print('❌ Bio column MISSING: $e');
        }
      }
    } catch (e) {
      print('❌ Error accessing users table: $e');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}