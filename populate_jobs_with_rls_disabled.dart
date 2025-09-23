import 'package:supabase/supabase.dart';

void main() async {
  try {
    // Use the same credentials as in SupabaseService
    const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
    
    print('🔧 Initializing Supabase client...');
    final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
    
    // Step 1: Disable RLS on jobs table
    print('\n🔓 Disabling RLS on jobs table...');
    try {
      await supabase.rpc('disable_rls_jobs');
      print('✅ RLS disabled successfully');
    } catch (e) {
      print('⚠️  Could not disable RLS via RPC: $e');
      print('Please run this SQL command manually in Supabase:');
      print('ALTER TABLE jobs DISABLE ROW LEVEL SECURITY;');
      print('\nContinuing with job insertion...');
    }
    
    // Step 2: Get domains and companies
    print('\n📋 Fetching domains and companies...');
    final domainsResponse = await supabase.from('domains').select('*');
    final companiesResponse = await supabase.from('companies').select('*');
    
    print('Found ${domainsResponse.length} domains and ${companiesResponse.length} companies');
    
    if (domainsResponse.isEmpty || companiesResponse.isEmpty) {
      print('❌ Cannot create jobs without domains and companies');
      return;
    }
    
    // Step 3: Create realistic job data
    print('\n💼 Creating job data...');
    
    final List<Map<String, dynamic>> jobsToInsert = [];
    
    // Technology jobs
    final techDomain = domainsResponse.firstWhere((d) => d['name'] == 'Technology');
    jobsToInsert.addAll([
      {
        'title': 'Senior Flutter Developer',
        'company_id': companiesResponse[0]['id'], // TCS
        'domain_id': techDomain['id'],
        'description': 'We are looking for an experienced Flutter developer to join our mobile development team. You will be responsible for developing cross-platform mobile applications using Flutter framework.',
        'salary_min': 800000,
        'salary_max': 1200000,
        'location': 'Bangalore, India',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'React.js Developer',
        'company_id': companiesResponse[1]['id'], // Infosys
        'domain_id': techDomain['id'],
        'description': 'Join our frontend team to build modern web applications using React.js. Experience with Redux, TypeScript, and modern development practices required.',
        'salary_min': 600000,
        'salary_max': 900000,
        'location': 'Hyderabad, India',
        'work_mode': 'remote',
        'experience_level': 'mid',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Full Stack Developer',
        'company_id': companiesResponse[2]['id'], // Wipro
        'domain_id': techDomain['id'],
        'description': 'Looking for a versatile full-stack developer proficient in both frontend and backend technologies. Experience with Node.js, React, and databases required.',
        'salary_min': 700000,
        'salary_max': 1000000,
        'location': 'Pune, India',
        'work_mode': 'onsite',
        'experience_level': 'mid',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'DevOps Engineer',
        'company_id': companiesResponse[3]['id'], // HCL
        'domain_id': techDomain['id'],
        'description': 'Seeking a DevOps engineer to manage our cloud infrastructure and CI/CD pipelines. Experience with AWS, Docker, and Kubernetes preferred.',
        'salary_min': 900000,
        'salary_max': 1400000,
        'location': 'Chennai, India',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Mobile App Developer',
        'company_id': companiesResponse[5]['id'], // Flipkart
        'domain_id': techDomain['id'],
        'description': 'Join Flipkart\'s mobile team to build next-generation e-commerce mobile applications. Experience with Flutter or React Native required.',
        'salary_min': 1200000,
        'salary_max': 1800000,
        'location': 'Bangalore, India',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Finance jobs
    final financeDomain = domainsResponse.firstWhere((d) => d['name'] == 'Finance', orElse: () => domainsResponse[1]);
    jobsToInsert.addAll([
      {
        'title': 'Financial Analyst',
        'company_id': companiesResponse[0]['id'],
        'domain_id': financeDomain['id'],
        'description': 'Analyze financial data, prepare reports, and provide insights to support business decisions. Strong analytical and Excel skills required.',
        'salary_min': 500000,
        'salary_max': 800000,
        'location': 'Mumbai, India',
        'work_mode': 'onsite',
        'experience_level': 'mid',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Investment Banking Associate',
        'company_id': companiesResponse[1]['id'],
        'domain_id': financeDomain['id'],
        'description': 'Support senior bankers in deal execution, financial modeling, and client presentations. MBA preferred with strong financial background.',
        'salary_min': 1500000,
        'salary_max': 2500000,
        'location': 'Mumbai, India',
        'work_mode': 'onsite',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Marketing jobs
    final marketingDomain = domainsResponse.firstWhere((d) => d['name'] == 'Marketing', orElse: () => domainsResponse[2]);
    jobsToInsert.addAll([
      {
        'title': 'Digital Marketing Manager',
        'company_id': companiesResponse[6]['id'], // Zomato
        'domain_id': marketingDomain['id'],
        'description': 'Lead digital marketing campaigns across multiple channels. Experience with SEO, SEM, social media marketing, and analytics required.',
        'salary_min': 800000,
        'salary_max': 1200000,
        'location': 'Gurgaon, India',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Content Marketing Specialist',
        'company_id': companiesResponse[7]['id'], // Paytm
        'domain_id': marketingDomain['id'],
        'description': 'Create engaging content for various marketing channels. Strong writing skills and experience with content management systems required.',
        'salary_min': 400000,
        'salary_max': 700000,
        'location': 'Noida, India',
        'work_mode': 'remote',
        'experience_level': 'mid',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Data Science jobs
    final dataScienceDomain = domainsResponse.firstWhere((d) => d['name'] == 'Data Science', orElse: () => domainsResponse[3]);
    jobsToInsert.addAll([
      {
        'title': 'Data Scientist',
        'company_id': companiesResponse[5]['id'], // Flipkart
        'domain_id': dataScienceDomain['id'],
        'description': 'Apply machine learning and statistical analysis to solve business problems. Experience with Python, R, and ML frameworks required.',
        'salary_min': 1000000,
        'salary_max': 1600000,
        'location': 'Bangalore, India',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Machine Learning Engineer',
        'company_id': companiesResponse[8]['id'], // Ola
        'domain_id': dataScienceDomain['id'],
        'description': 'Build and deploy ML models at scale. Experience with TensorFlow, PyTorch, and cloud platforms required.',
        'salary_min': 1200000,
        'salary_max': 2000000,
        'location': 'Bangalore, India',
        'work_mode': 'onsite',
        'experience_level': 'senior',
        'employment_type': 'full_time',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Step 4: Insert jobs in batches
    print('\n📝 Inserting ${jobsToInsert.length} jobs...');
    
    int successCount = 0;
    int failCount = 0;
    
    for (int i = 0; i < jobsToInsert.length; i++) {
      try {
        await supabase.from('jobs').insert(jobsToInsert[i]);
        successCount++;
        print('✅ Inserted job ${i + 1}/${jobsToInsert.length}: ${jobsToInsert[i]['title']}');
      } catch (e) {
        failCount++;
        print('❌ Failed to insert job ${i + 1}: ${jobsToInsert[i]['title']} - $e');
      }
    }
    
    // Step 5: Verify insertion
    print('\n🔍 Verifying job insertion...');
    final finalJobsResponse = await supabase.from('jobs').select('*');
    print('✅ Total jobs in database: ${finalJobsResponse.length}');
    
    // Step 6: Re-enable RLS
    print('\n🔒 Re-enabling RLS on jobs table...');
    try {
      await supabase.rpc('enable_rls_jobs');
      print('✅ RLS re-enabled successfully');
    } catch (e) {
      print('⚠️  Could not re-enable RLS via RPC: $e');
      print('Please run this SQL command manually in Supabase:');
      print('ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;');
    }
    
    print('\n🎉 Job population completed!');
    print('📊 Summary:');
    print('- Successfully inserted: $successCount jobs');
    print('- Failed to insert: $failCount jobs');
    print('- Total jobs in database: ${finalJobsResponse.length}');
    
    if (finalJobsResponse.isNotEmpty) {
      print('\n✅ Your app should now show jobs when you select domains!');
    }
    
  } catch (e) {
    print('❌ Error during job population: $e');
  }
}