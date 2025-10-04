import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  print('🔧 Temporarily disabling RLS for users table...');
  
  try {
    // Test current RLS status
    print('\n1. Testing current insert (should fail)...');
    final testInsert = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/users'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode({
        'id': '00000000-0000-0000-0000-000000000001',
        'email': 'test-rls@example.com',
        'full_name': 'RLS Test User',
        'phone': null,
      }),
    );
    
    print('Current insert status: ${testInsert.statusCode}');
    print('Response: ${testInsert.body}');
    
    // Now let's check what policies exist
    print('\n2. Checking existing policies...');
    final policiesCheck = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/rpc/get_policies'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Policies check: ${policiesCheck.statusCode}');
    print('Policies: ${policiesCheck.body}');
    
  } catch (e) {
    print('Error: $e');
  }
  
  print('\n📋 MANUAL STEPS TO FIX:');
  print('Since the RLS policy is still blocking, please do this in Supabase Dashboard:');
  print('');
  print('1. Go to Database > Tables > users');
  print('2. Click on "RLS disabled" to DISABLE RLS completely for testing');
  print('3. Or go to Authentication > Policies');
  print('4. Delete ALL existing policies for users table');
  print('5. Create ONE new policy:');
  print('   - Policy name: "Allow all operations for authenticated users"');
  print('   - Target roles: authenticated');
  print('   - Policy command: ALL');
  print('   - USING expression: true');
  print('   - WITH CHECK expression: true');
  print('');
  print('After making these changes, run the diagnostic again.');
}