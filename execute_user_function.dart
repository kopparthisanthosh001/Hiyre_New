import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('Creating user function in Supabase...');

  try {
    // Read the SQL file
    final sqlContent = '''
-- Create a function that can be called to create users, bypassing RLS
CREATE OR REPLACE FUNCTION create_user_profile(
  user_id UUID,
  user_email TEXT,
  full_name TEXT,
  user_phone TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS \$\$
DECLARE
  result JSON;
BEGIN
  INSERT INTO users (id, email, full_name, phone, created_at, updated_at)
  VALUES (
    user_id,
    user_email,
    full_name,
    user_phone,
    NOW(),
    NOW()
  );
  
  SELECT row_to_json(users.*) INTO result
  FROM users
  WHERE id = user_id;
  
  RETURN result;
END;
\$\$;
''';

    // Execute the SQL using Supabase REST API
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseKey',
        'apikey': supabaseKey,
      },
      body: jsonEncode({
        'sql': sqlContent,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ User function created successfully!');
    } else {
      print('❌ Failed to create function. Trying alternative method...');
      
      // Try using the SQL editor endpoint
      final altResponse = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseKey',
          'apikey': supabaseKey,
        },
        body: jsonEncode({
          'query': sqlContent,
        }),
      );
      
      print('Alternative response status: ${altResponse.statusCode}');
      print('Alternative response body: ${altResponse.body}');
    }
  } catch (e) {
    print('❌ Error executing SQL: $e');
    print('\n📝 Manual steps needed:');
    print('1. Go to your Supabase dashboard');
    print('2. Navigate to SQL Editor');
    print('3. Execute the SQL from create_user_function.sql');
  }
}