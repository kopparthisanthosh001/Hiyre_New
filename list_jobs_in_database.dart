import 'package:supabase/supabase.dart';

void main() async {
  try {
    // Use the same credentials as in SupabaseService
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    print('🔧 Connecting to Supabase...');
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    // Get all jobs with company and domain information
    print('\n📊 Fetching all jobs from database...');
    final jobsResponse = await supabase
        .from('jobs')
        .select('''
          *,
          companies(name),
          domains(name)
        ''')
        .order('created_at', ascending: false);
    
    print('\n✅ Found ${jobsResponse.length} jobs in the database:\n');
    
    if (jobsResponse.isEmpty) {
      print('❌ No jobs found in the database.');
      return;
    }
    
    // Group jobs by domain for better organization
    Map<String, List<dynamic>> jobsByDomain = {};
    
    for (var job in jobsResponse) {
      final domainName = job['domains']?['name'] ?? 'Unknown Domain';
      if (!jobsByDomain.containsKey(domainName)) {
        jobsByDomain[domainName] = [];
      }
      jobsByDomain[domainName]!.add(job);
    }
    
    // Display jobs organized by domain
    int jobCounter = 1;
    for (var domain in jobsByDomain.keys) {
      print('🏷️  ${domain.toUpperCase()} DOMAIN:');
      print('=' * 50);
      
      for (var job in jobsByDomain[domain]!) {
        final companyName = job['companies']?['name'] ?? 'Unknown Company';
        final salaryRange = '₹${(job['salary_min'] / 100000).toStringAsFixed(1)}L - ₹${(job['salary_max'] / 100000).toStringAsFixed(1)}L';
        
        print('${jobCounter.toString().padLeft(2)}. 📋 ${job['title']}');
        print('    🏢 Company: $companyName');
        print('    💰 Salary: $salaryRange');
        print('    📍 Location: ${job['location']}');
        print('    🏠 Work Mode: ${job['work_mode']}');
        print('    📈 Experience: ${job['experience_level']}');
        print('    📝 Description: ${job['description'].toString().substring(0, job['description'].toString().length > 100 ? 100 : job['description'].toString().length)}${job['description'].toString().length > 100 ? '...' : ''}');
        print('    🆔 Job ID: ${job['id']}');
        print('');
        jobCounter++;
      }
      print('');
    }
    
    // Summary statistics
    print('📈 SUMMARY STATISTICS:');
    print('=' * 30);
    print('Total Jobs: ${jobsResponse.length}');
    print('Domains with Jobs: ${jobsByDomain.keys.length}');
    
    // Count by work mode
    Map<String, int> workModeCount = {};
    for (var job in jobsResponse) {
      final workMode = job['work_mode'] ?? 'unknown';
      workModeCount[workMode] = (workModeCount[workMode] ?? 0) + 1;
    }
    
    print('\nWork Mode Distribution:');
    workModeCount.forEach((mode, count) {
      print('  - ${mode.toUpperCase()}: $count jobs');
    });
    
    // Count by experience level
    Map<String, int> experienceCount = {};
    for (var job in jobsResponse) {
      final experience = job['experience_level'] ?? 'unknown';
      experienceCount[experience] = (experienceCount[experience] ?? 0) + 1;
    }
    
    print('\nExperience Level Distribution:');
    experienceCount.forEach((level, count) {
      print('  - ${level.toUpperCase()}: $count jobs');
    });
    
    // Salary range analysis
    if (jobsResponse.isNotEmpty) {
      final salaries = jobsResponse.map((job) => (job['salary_min'] + job['salary_max']) / 2).toList();
      salaries.sort();
      final minSalary = salaries.first;
      final maxSalary = salaries.last;
      final avgSalary = salaries.reduce((a, b) => a + b) / salaries.length;
      
      print('\nSalary Analysis:');
      print('  - Lowest Average: ₹${(minSalary / 100000).toStringAsFixed(1)}L');
      print('  - Highest Average: ₹${(maxSalary / 100000).toStringAsFixed(1)}L');
      print('  - Overall Average: ₹${(avgSalary / 100000).toStringAsFixed(1)}L');
    }
    
    print('\n✅ Job listing completed!');
    
  } catch (e) {
    print('❌ Error fetching jobs: $e');
  }
}