import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';

  print('🔍 Checking database schema...');
  
  // Check companies table structure
  print('\n🏢 Companies table:');
  try {
    final companiesResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/companies?select=*&limit=1'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${companiesResponse.statusCode}');
    if (companiesResponse.statusCode == 200) {
      final companies = json.decode(companiesResponse.body);
      if (companies.isNotEmpty) {
        print('Sample company structure:');
        print(json.encode(companies[0]));
      } else {
        print('No companies found');
      }
    } else {
      print('Error: ${companiesResponse.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
  
  // Check jobs table structure
  print('\n💼 Jobs table:');
  try {
    final jobsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/jobs?select=*&limit=1'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${jobsResponse.statusCode}');
    if (jobsResponse.statusCode == 200) {
      final jobs = json.decode(jobsResponse.body);
      if (jobs.isNotEmpty) {
        print('Sample job structure:');
        print(json.encode(jobs[0]));
      } else {
        print('No jobs found');
      }
    } else {
      print('Error: ${jobsResponse.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
  
  // Check users table structure
  print('\n👤 Users table:');
  try {
    final usersResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=*&limit=1'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );
    
    print('Status: ${usersResponse.statusCode}');
    if (usersResponse.statusCode == 200) {
      final users = json.decode(usersResponse.body);
      if (users.isNotEmpty) {
        print('Sample user structure:');
        print(json.encode(users[0]));
      } else {
        print('No users found');
      }
    } else {
      print('Error: ${usersResponse.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
  
  // Try to get schema information using OpenAPI
  print('\n📋 Trying to get schema info...');
  try {
    final schemaResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Accept': 'application/openapi+json',
      },
    );
    
    if (schemaResponse.statusCode == 200) {
      final schema = json.decode(schemaResponse.body);
      
      // Extract table definitions
      if (schema['definitions'] != null) {
        print('\nTable definitions found:');
        
        if (schema['definitions']['companies'] != null) {
          print('\nCompanies table columns:');
          final companiesProps = schema['definitions']['companies']['properties'];
          for (var key in companiesProps.keys) {
            print('  - $key: ${companiesProps[key]['type']}');
          }
        }
        
        if (schema['definitions']['jobs'] != null) {
          print('\nJobs table columns:');
          final jobsProps = schema['definitions']['jobs']['properties'];
          for (var key in jobsProps.keys) {
            print('  - $key: ${jobsProps[key]['type']}');
          }
        }
        
        if (schema['definitions']['users'] != null) {
          print('\nUsers table columns:');
          final usersProps = schema['definitions']['users']['properties'];
          for (var key in usersProps.keys) {
            print('  - $key: ${usersProps[key]['type']}');
          }
        }
      }
    } else {
      print('Failed to get schema: ${schemaResponse.statusCode}');
    }
  } catch (e) {
    print('Error getting schema: $e');
  }
}