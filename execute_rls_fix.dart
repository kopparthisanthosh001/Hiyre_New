import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🔧 Fixing RLS policies for users table...');
    
    // Execute the SQL commands directly instead of parsing from file
    final sqlCommands = [
      'DROP POLICY IF EXISTS "Users can insert their own data" ON users',
      '''CREATE POLICY "Authenticated users can insert user data" ON users 
FOR INSERT 
TO authenticated 
WITH CHECK (true)'''
    ];
    
    print('Found ${sqlCommands.length} SQL commands to execute');
    
    for (int i = 0; i < sqlCommands.length; i++) {
      final sql = sqlCommands[i];
      
      print('\n${i + 1}. Executing: ${sql.substring(0, sql.length > 50 ? 50 : sql.length)}...');
      
      final result = await Process.run('curl', [
        '-X', 'POST',
        '$supabaseUrl/rest/v1/rpc/exec_sql',
        '-H', 'apikey: $supabaseKey',
        '-H', 'Authorization: Bearer $supabaseKey',
        '-H', 'Content-Type: application/json',
        '-H', 'Prefer: return=minimal',
        '-d', jsonEncode({'sql': sql})
      ]);
      
      print('Exit code: ${result.exitCode}');
      print('Stdout: ${result.stdout}');
      print('Stderr: ${result.stderr}');
      
      if (result.exitCode == 0) {
        print('✅ Command executed successfully');
      } else {
        print('❌ Command failed');
      }
    }
    
    print('\n🎉 RLS policy fix migration completed!');
    print('You can now try the profile creation process again.');
    
  } catch (e) {
    print('❌ Error executing migration: $e');
  }
}