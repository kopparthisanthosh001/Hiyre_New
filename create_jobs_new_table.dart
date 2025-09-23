import 'package:supabase/supabase.dart';

void main() async {
  try {
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    print('🚀 Creating jobs_new table and populating with data...\n');
    
    // Step 1: Get existing companies and domains
    print('📊 Step 1: Getting existing companies and domains...');
    
    final companies = await supabase.from('companies').select('*');
    final domains = await supabase.from('domains').select('*');
    
    print('✅ Found ${companies.length} companies and ${domains.length} domains');
    
    if (companies.isEmpty) {
      print('❌ No companies found! Please create companies first.');
      return;
    }
    
    // Step 2: Ensure all required domains exist
    print('\n📋 Step 2: Ensuring all required domains exist...');
    
    final requiredDomains = [
      {'name': 'Technology', 'description': 'Software and technical development'},
      {'name': 'Business', 'description': 'Strategic planning and operations'},
      {'name': 'Design', 'description': 'UI/UX and creative design'},
      {'name': 'Sales', 'description': 'Sales and customer relations'},
      {'name': 'Marketing', 'description': 'Digital marketing and advertising'},
      {'name': 'Engineering', 'description': 'Engineering and technical solutions'},
      {'name': 'Human Resources', 'description': 'HR and people management'},
      {'name': 'Research', 'description': 'Research and development'},
    ];
    
    final existingDomainNames = domains.map((d) => d['name'] as String).toList();
    
    for (var reqDomain in requiredDomains) {
      if (!existingDomainNames.any((existing) => 
          existing.toLowerCase() == reqDomain['name']!.toLowerCase())) {
        
        print('Creating missing domain: ${reqDomain['name']}');
        try {
          await supabase.from('domains').insert({
            'id': _generateUUID(),
            'name': reqDomain['name'],
            'description': reqDomain['description'],
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Error creating domain ${reqDomain['name']}: $e');
        }
      }
    }
    
    // Refresh domains list
    final updatedDomains = await supabase.from('domains').select('*');
    print('✅ Total domains now: ${updatedDomains.length}');
    
    // Step 3: Create sample jobs for each domain
    print('\n💼 Step 3: Creating jobs for each domain...');
    
    final jobTemplates = {
      'Technology': [
        {'title': 'Senior Flutter Developer', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Frontend React Developer', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Backend Node.js Developer', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Mobile App Developer', 'type': 'contract', 'experience': 'mid'},
        {'title': 'Full Stack Developer', 'type': 'full-time', 'experience': 'senior'},
      ],
      'Business': [
        {'title': 'Business Analyst', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Product Manager', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Strategy Consultant', 'type': 'contract', 'experience': 'senior'},
        {'title': 'Operations Manager', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Business Development Manager', 'type': 'full-time', 'experience': 'senior'},
      ],
      'Design': [
        {'title': 'UI/UX Designer', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Graphic Designer', 'type': 'part-time', 'experience': 'junior'},
        {'title': 'Product Designer', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Visual Designer', 'type': 'contract', 'experience': 'mid'},
        {'title': 'Design System Lead', 'type': 'full-time', 'experience': 'senior'},
      ],
      'Sales': [
        {'title': 'Sales Representative', 'type': 'full-time', 'experience': 'junior'},
        {'title': 'Account Manager', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Sales Director', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Business Development Executive', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Inside Sales Specialist', 'type': 'full-time', 'experience': 'junior'},
      ],
      'Marketing': [
        {'title': 'Digital Marketing Manager', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Content Marketing Specialist', 'type': 'part-time', 'experience': 'junior'},
        {'title': 'SEO Specialist', 'type': 'contract', 'experience': 'mid'},
        {'title': 'Social Media Manager', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Marketing Director', 'type': 'full-time', 'experience': 'senior'},
      ],
      'Engineering': [
        {'title': 'Software Engineer', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'DevOps Engineer', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Data Engineer', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Cloud Engineer', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Systems Engineer', 'type': 'full-time', 'experience': 'mid'},
      ],
      'Human Resources': [
        {'title': 'HR Manager', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Recruiter', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'HR Business Partner', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Talent Acquisition Specialist', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'HR Coordinator', 'type': 'part-time', 'experience': 'junior'},
      ],
      'Research': [
        {'title': 'Research Scientist', 'type': 'full-time', 'experience': 'senior'},
        {'title': 'Data Scientist', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'Research Analyst', 'type': 'full-time', 'experience': 'mid'},
        {'title': 'UX Researcher', 'type': 'contract', 'experience': 'mid'},
        {'title': 'Market Research Analyst', 'type': 'full-time', 'experience': 'junior'},
      ],
    };
    
    int totalJobsCreated = 0;
    
    for (var domain in updatedDomains) {
      final domainName = domain['name'] as String;
      final domainId = domain['id'] as String;
      
      if (jobTemplates.containsKey(domainName)) {
        print('Creating jobs for $domainName domain...');
        
        final jobs = jobTemplates[domainName]!;
        
        for (int i = 0; i < jobs.length; i++) {
          final job = jobs[i];
          final company = companies[i % companies.length]; // Rotate through companies
          
          try {
            await supabase.from('jobs_new').insert({
              'id': _generateUUID(),
              'title': job['title'],
              'description': 'Exciting opportunity for a ${job['title']} to join our growing team. We offer competitive salary, great benefits, and a collaborative work environment.',
              'requirements': 'Bachelor\'s degree, relevant experience, strong communication skills',
              'salary_min': _getSalaryRange(job['experience']!)['min'],
              'salary_max': _getSalaryRange(job['experience']!)['max'],
              'location': 'Remote',
              'job_type': job['type'],
              'experience_level': job['experience'],
              'status': 'active',
              'company_id': company['id'],
              'domain_id': domainId,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            
            totalJobsCreated++;
            
          } catch (e) {
            print('Error creating job ${job['title']}: $e');
          }
        }
      }
    }
    
    print('\n✅ Successfully created $totalJobsCreated jobs in jobs_new table!');
    
    // Step 4: Verify the data
    print('\n🔍 Step 4: Verifying created data...');
    
    final newJobs = await supabase
        .from('jobs_new')
        .select('''
          *,
          companies(name, industry),
          domains(name)
        ''');
    
    print('✅ Total jobs in jobs_new: ${newJobs.length}');
    
    // Group by domain
    final jobsByDomain = <String, int>{};
    for (var job in newJobs) {
      final domainName = job['domains']['name'] as String;
      jobsByDomain[domainName] = (jobsByDomain[domainName] ?? 0) + 1;
    }
    
    print('\nJobs by domain:');
    jobsByDomain.forEach((domain, count) {
      print('   - $domain: $count jobs');
    });
    
    print('\n🎉 jobs_new table is ready! You can now update your JobService to use this table.');
    
  } catch (e) {
    print('💥 Error: $e');
  }
}

String _generateUUID() {
  // Simple UUID v4 generator
  final random = DateTime.now().millisecondsSinceEpoch;
  return '550e8400-e29b-41d4-a716-${random.toString().padLeft(12, '0')}';
}

Map<String, int> _getSalaryRange(String experience) {
  switch (experience) {
    case 'junior':
      return {'min': 40000, 'max': 60000};
    case 'mid':
      return {'min': 60000, 'max': 90000};
    case 'senior':
      return {'min': 90000, 'max': 150000};
    default:
      return {'min': 50000, 'max': 80000};
  }
}