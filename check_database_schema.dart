import 'package:supabase/supabase.dart';

void main() async {
  print('=== Checking Database Schema ===\n');
  
  try {
    // Initialize Supabase client
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    print('✓ Supabase client initialized\n');
    
    // Check what tables are available by trying common ones
    final tablesToCheck = [
      'domains',
      'jobs', 
      'users',
      'profiles',
      'user_profiles',
      'education',
      'educations',
      'work_experiences',
      'work_experience',
      'experiences',
      'skills',
      'user_skills',
      'certifications',
      'certificates',
      'job_applications',
      'applications',
      'user_preferences'
    ];
    
    print('Checking available tables:\n');
    
    for (String table in tablesToCheck) {
      try {
        final response = await client.from(table).select('*').limit(1);
        print('✓ $table - EXISTS (${response.length} sample records)');
        
        // Show column structure if data exists
        if (response.isNotEmpty) {
          final columns = response.first.keys.toList();
          print('   Columns: ${columns.join(', ')}');
        }
        print('');
      } catch (e) {
        if (e.toString().contains('PGRST205') || e.toString().contains('does not exist')) {
          print('✗ $table - DOES NOT EXIST');
        } else {
          print('? $table - ERROR: $e');
        }
      }
    }
    
    print('\n=== Detailed Data Analysis ===\n');
    
    // Check domains in detail
    try {
      final domains = await client.from('domains').select('*').limit(3);
      print('DOMAINS TABLE:');
      print('Records: ${domains.length}');
      if (domains.isNotEmpty) {
        print('Sample data:');
        for (var domain in domains) {
          print('  - ID: ${domain['id']}, Name: ${domain['name']}');
        }
      }
      print('');
    } catch (e) {
      print('Error checking domains: $e\n');
    }
    
    // Check jobs in detail
    try {
      final jobs = await client.from('jobs').select('*').limit(3);
      print('JOBS TABLE:');
      print('Records: ${jobs.length}');
      if (jobs.isNotEmpty) {
        print('Sample data:');
        for (var job in jobs) {
          print('  - ID: ${job['id']}, Title: ${job['title']}, Domain: ${job['domain_id']}');
        }
      }
      print('');
    } catch (e) {
      print('Error checking jobs: $e\n');
    }
    
    // Check users in detail
    try {
      final users = await client.from('users').select('*').limit(3);
      print('USERS TABLE:');
      print('Records: ${users.length}');
      if (users.isNotEmpty) {
        print('Sample data:');
        for (var user in users) {
          print('  - ID: ${user['id']}, Name: ${user['full_name']}, Email: ${user['email']}');
        }
      } else {
        print('No user records found');
      }
      print('');
    } catch (e) {
      print('Error checking users: $e\n');
    }
    
    // Check skills table structure
    try {
      final skills = await client.from('skills').select('*').limit(3);
      print('SKILLS TABLE:');
      print('Records: ${skills.length}');
      if (skills.isNotEmpty) {
        print('Sample data:');
        for (var skill in skills) {
          print('  - Available columns: ${skill.keys.join(', ')}');
          print('  - Sample record: $skill');
          break; // Just show one sample
        }
      }
      print('');
    } catch (e) {
      print('Error checking skills: $e\n');
    }
    
  } catch (error) {
    print('Fatal error: $error');
  }
}