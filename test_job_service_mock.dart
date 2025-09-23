import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/job_service.dart';

Future<void> main() async {
  print('=== Testing JobService with Mock Jobs ===\n');
  
  try {
    // Initialize Supabase (you may need to adjust the URL and key)
    await Supabase.initialize(
      url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
    );
    
    final jobService = JobService.instance;
    
    // Test 1: Test connection
    print('1. Testing Supabase connection...');
    final isConnected = await jobService.testConnection();
    print('   Connection status: ${isConnected ? "✅ Connected" : "❌ Failed"}\n');
    
    // Test 2: Get all jobs (should return mock jobs if database is empty)
    print('2. Fetching all jobs...');
    final allJobs = await jobService.getAllJobs();
    print('   Found ${allJobs.length} jobs');
    
    if (allJobs.isNotEmpty) {
      print('   Sample jobs:');
      for (int i = 0; i < (allJobs.length > 3 ? 3 : allJobs.length); i++) {
        final job = allJobs[i];
        print('   - ${job.title} at ${job.company['name']} (${job.domain?['name']})');
      }
    }
    print('');
    
    // Test 3: Get jobs for specific domains
    print('3. Fetching jobs for Technology and Business domains...');
    final domainJobs = await jobService.getJobsForDomains(['Technology', 'Business']);
    print('   Found ${domainJobs.length} jobs for specified domains');
    
    if (domainJobs.isNotEmpty) {
      print('   Sample domain-specific jobs:');
      for (int i = 0; i < (domainJobs.length > 3 ? 3 : domainJobs.length); i++) {
        final job = domainJobs[i];
        print('   - ${job.title} (${job.domain?['name']}) - ${job.location}');
      }
    }
    print('');
    
    // Test 4: Generate mock jobs directly
    print('4. Generating mock jobs directly...');
    final mockJobs = jobService.generateMockJobs(5);
    print('   Generated ${mockJobs.length} mock jobs:');
    for (final job in mockJobs) {
      print('   - ${job.title} at ${job.company['name']} - ${job.formattedSalary}');
    }
    print('');
    
    // Test 5: Test job matching
    print('5. Testing job match scoring...');
    final userProfile = {
      'skills': ['Flutter', 'Dart', 'React'],
      'preferred_location': 'Remote',
      'experience': '3',
      'preferred_domains': ['Technology', 'Design']
    };
    
    if (allJobs.isNotEmpty) {
      final job = allJobs.first;
      final matchScore = jobService.calculateJobMatchScore(job, userProfile);
      print('   Match score for "${job.title}": ${matchScore.toStringAsFixed(1)}%');
    }
    
    print('\n=== JobService Test Completed Successfully ===');
    
  } catch (e, stackTrace) {
    print('❌ Error during testing: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}