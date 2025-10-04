import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Diagnosing Profile Submission Issues...\n');
  
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    // Test 1: Check Supabase connection
    print('1. Testing Supabase Connection...');
    final connectionResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/domains?select=id,name&limit=1'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (connectionResponse.statusCode == 200) {
      print('✅ Supabase connection successful');
    } else {
      print('❌ Supabase connection failed: ${connectionResponse.statusCode}');
      print('Response: ${connectionResponse.body}');
      return;
    }
    
    // Test 2: Check if create_user_profile function exists
    print('\n2. Checking if create_user_profile function exists...');
    final functionResponse = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/create_user_profile'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': '00000000-0000-0000-0000-000000000000',
        'user_email': 'test@example.com',
        'full_name': 'Test User',
        'user_phone': null,
      }),
    );
    
    if (functionResponse.statusCode == 404) {
      print('❌ create_user_profile function does not exist');
      print('Need to create the function in Supabase dashboard');
    } else if (functionResponse.statusCode == 409 || functionResponse.body.contains('duplicate')) {
      print('✅ create_user_profile function exists (got duplicate key error as expected)');
    } else {
      print('Function response: ${functionResponse.statusCode} - ${functionResponse.body}');
    }
    
    // Test 3: Check users table structure
    print('\n3. Checking users table structure...');
    final tableResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=*&limit=0'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (tableResponse.statusCode == 200) {
      print('✅ Users table accessible');
    } else {
      print('❌ Users table access failed: ${tableResponse.statusCode}');
      print('Response: ${tableResponse.body}');
    }
    
    // Test 4: Test direct insert to users table (will likely fail due to RLS)
    print('\n4. Testing direct insert to users table...');
    final testUserId = '11111111-1111-1111-1111-111111111111';
    final insertResponse = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/users'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'id': testUserId,
        'email': 'test@example.com',
        'full_name': 'Test User',
        'phone': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );
    
    if (insertResponse.statusCode == 201) {
      print('✅ Direct insert successful');
      // Clean up test user
      await http.delete(
        Uri.parse('$supabaseUrl/rest/v1/users?id=eq.$testUserId'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );
    } else {
      print('❌ Direct insert failed: ${insertResponse.statusCode}');
      print('Response: ${insertResponse.body}');
      
      if (insertResponse.body.contains('RLS') || insertResponse.body.contains('policy')) {
        print('🔒 RLS policy is blocking the insert');
      }
    }
    
    // Test 5: Check authentication status
    print('\n5. Testing authentication flow...');
    final authTestResponse = await http.post(
      Uri.parse('$supabaseUrl/auth/v1/signup'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': 'test@example.com',
        'password': 'TestPassword123!',
      }),
    );
    
    print('Auth test response: ${authTestResponse.statusCode}');
    if (authTestResponse.statusCode != 200 && authTestResponse.statusCode != 400) {
      print('Auth response body: ${authTestResponse.body}');
    }
    
    print('\n📋 DIAGNOSIS SUMMARY:');
    print('1. If create_user_profile function doesn\'t exist, create it in Supabase dashboard');
    print('2. If direct insert fails due to RLS, the function should handle it');
    print('3. Check that the RLS policy allows authenticated users to insert');
    print('\n🔧 NEXT STEPS:');
    print('1. Run this script to see specific errors');
    print('2. Create the function if missing');
    print('3. Test profile creation again');
    
  } catch (e) {
    print('❌ Error during diagnosis: $e');
  }
}