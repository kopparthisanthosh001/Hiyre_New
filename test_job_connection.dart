import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'services/job_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
    
    // Test connection
    final connectionInfo = SupabaseService.instance.getConnectionInfo();
    print('📊 Connection info: $connectionInfo');
    
    final isConnected = await SupabaseService.instance.testConnection();
    if (isConnected) {
      print('✅ Supabase connection test passed');
    } else {
      print('❌ Supabase connection test failed');
    }
    
    // Test job fetching
    print('🔍 Fetching jobs from database...');
    final jobs = await JobService.instance.getJobs(limit: 10);
    print('📋 Found ${jobs.length} jobs');
    
    if (jobs.isNotEmpty) {
      print('📝 First job details:');
      print('Title: ${jobs[0]['title']}');
      print('Company: ${jobs[0]['companies']?['name'] ?? 'Unknown'}');
      print('Domain: ${jobs[0]['domains']?['name'] ?? 'Unknown'}');
    } else {
      print('⚠️ No jobs found in database');
    }
    
    // Test direct query to jobs table
    print('🔍 Testing direct query to jobs table...');
    final directJobs = await SupabaseService.instance.client
        .from('jobs')
        .select('*')
        .limit(5);
    print('📋 Direct query found ${directJobs.length} jobs');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}