import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Load environment variables
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'your_supabase_url';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'your_supabase_key';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final client = Supabase.instance.client;

  try {
    print('🔄 Running RLS fix migration...');
    
    // Read and execute the migration file
    final migrationFile = File('supabase/migrations/20250117000000_fix_users_rls_for_signup.sql');
    final migrationSql = await migrationFile.readAsString();
    
    await client.rpc('exec_sql', params: {'sql': migrationSql});
    
    print('✅ RLS fix migration completed successfully!');
  } catch (error) {
    print('❌ Migration failed: $error');
  }
}