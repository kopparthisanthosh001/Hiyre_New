import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 Starting complete database population with correct schema...');
  
  // Load environment configuration
  final envFile = File('env.json');
  if (!envFile.existsSync()) {
    print('❌ env.json file not found!');
    exit(1);
  }
  
  final envContent = await envFile.readAsString();
  final env = jsonDecode(envContent);
  
  final supabaseUrl = env['SUPABASE_URL'];
  final supabaseKey = env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseKey == null) {
    print('❌ Missing Supabase configuration in env.json');
    exit(1);
  }
  
  print('📋 Supabase URL: $supabaseUrl');
  print('🔑 Using API key: ${supabaseKey.substring(0, 20)}...');
  
  final client = HttpClient();
  
  try {
    // First, let's check current data counts
    await _checkCurrentData(client, supabaseUrl, supabaseKey);
    
    // Insert additional domains if needed
    await _insertAdditionalDomains(client, supabaseUrl, supabaseKey);
    
    // Insert additional companies if needed
    await _insertAdditionalCompanies(client, supabaseUrl, supabaseKey);
    
    // Insert additional skills if needed
    await _insertAdditionalSkills(client, supabaseUrl, supabaseKey);
    
    // Insert additional jobs if needed
    await _insertAdditionalJobs(client, supabaseUrl, supabaseKey);
    
    // Verify the final setup
    await _verifyFinalSetup(client, supabaseUrl, supabaseKey);
    
    print('\n🎉 Database population completed successfully!');
    
  } catch (error) {
    print('❌ Database population failed: $error');
    exit(1);
  } finally {
    client.close();
  }
}

Future<void> _checkCurrentData(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n🔍 Checking current data...');
  
  final tables = ['domains', 'companies', 'jobs', 'skills'];
  
  for (String table in tables) {
    try {
      final request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/$table?select=count'));
      request.headers.set('apikey', supabaseKey);
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as List;
        print('   📊 Table "$table": ${data.length} records');
      } else {
        print('   ❌ Table "$table": Error ${response.statusCode}');
      }
    } catch (error) {
      print('   ❌ Table "$table": $error');
    }
  }
}

Future<void> _insertAdditionalDomains(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n📋 Adding additional domains...');
  
  // Using the correct column names from the actual schema
  final additionalDomains = [
    {'id': '550e8400-e29b-41d4-a716-446655440004', 'name': 'Marketing', 'description': 'Digital marketing, content, and brand management'},
    {'id': '550e8400-e29b-41d4-a716-446655440005', 'name': 'Sales', 'description': 'Sales development, account management, and revenue roles'},
    {'id': '550e8400-e29b-41d4-a716-446655440006', 'name': 'Finance', 'description': 'Financial analysis, accounting, and investment roles'},
    {'id': '550e8400-e29b-41d4-a716-446655440007', 'name': 'Operations', 'description': 'Operations management, logistics, and process optimization'},
    {'id': '550e8400-e29b-41d4-a716-446655440008', 'name': 'Human Resources', 'description': 'HR management, talent acquisition, and people operations'},
    {'id': '550e8400-e29b-41d4-a716-446655440009', 'name': 'Data Science', 'description': 'Data analysis, machine learning, and analytics roles'},
    {'id': '550e8400-e29b-41d4-a716-446655440010', 'name': 'Product Management', 'description': 'Product strategy, roadmap, and feature development'},
  ];
  
  await _insertDataSafely(client, supabaseUrl, supabaseKey, 'domains', additionalDomains);
}

Future<void> _insertAdditionalCompanies(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n🏢 Adding additional companies...');
  
  // Using the correct column names from the actual schema
  final additionalCompanies = [
    {'id': '660e8400-e29b-41d4-a716-446655440006', 'name': 'Flipkart', 'description': 'Leading e-commerce marketplace', 'location': 'Bangalore, India', 'industry': 'E-commerce'},
    {'id': '660e8400-e29b-41d4-a716-446655440007', 'name': 'Zomato', 'description': 'Food delivery and restaurant discovery platform', 'location': 'Gurugram, India', 'industry': 'Food Technology'},
    {'id': '660e8400-e29b-41d4-a716-446655440008', 'name': 'Paytm', 'description': 'Digital payments and financial services', 'location': 'Noida, India', 'industry': 'Fintech'},
    {'id': '660e8400-e29b-41d4-a716-446655440009', 'name': 'Byju\'s', 'description': 'Online education and learning platform', 'location': 'Bangalore, India', 'industry': 'Education Technology'},
    {'id': '660e8400-e29b-41d4-a716-446655440010', 'name': 'Swiggy', 'description': 'Food delivery and quick commerce platform', 'location': 'Bangalore, India', 'industry': 'Food Technology'},
    {'id': '660e8400-e29b-41d4-a716-446655440011', 'name': 'Ola', 'description': 'Ride-sharing and mobility platform', 'location': 'Bangalore, India', 'industry': 'Transportation'},
    {'id': '660e8400-e29b-41d4-a716-446655440012', 'name': 'PhonePe', 'description': 'Digital payments and financial services', 'location': 'Bangalore, India', 'industry': 'Fintech'},
  ];
  
  await _insertDataSafely(client, supabaseUrl, supabaseKey, 'companies', additionalCompanies);
}

Future<void> _insertAdditionalSkills(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n🛠️ Adding additional skills...');
  
  // Using the correct column names from the actual schema
  final additionalSkills = [
    {'id': '770e8400-e29b-41d4-a716-446655440011', 'name': 'TypeScript', 'category': 'Programming'},
    {'id': '770e8400-e29b-41d4-a716-446655440012', 'name': 'Java', 'category': 'Programming'},
    {'id': '770e8400-e29b-41d4-a716-446655440013', 'name': 'Flutter', 'category': 'Framework'},
    {'id': '770e8400-e29b-41d4-a716-446655440014', 'name': 'Vue.js', 'category': 'Framework'},
    {'id': '770e8400-e29b-41d4-a716-446655440015', 'name': 'PostgreSQL', 'category': 'Database'},
    {'id': '770e8400-e29b-41d4-a716-446655440016', 'name': 'MongoDB', 'category': 'Database'},
    {'id': '770e8400-e29b-41d4-a716-446655440017', 'name': 'Kubernetes', 'category': 'DevOps'},
    {'id': '770e8400-e29b-41d4-a716-446655440018', 'name': 'Adobe XD', 'category': 'Design'},
    {'id': '770e8400-e29b-41d4-a716-446655440019', 'name': 'Sketch', 'category': 'Design'},
    {'id': '770e8400-e29b-41d4-a716-446655440020', 'name': 'Agile Methodology', 'category': 'Management'},
  ];
  
  await _insertDataSafely(client, supabaseUrl, supabaseKey, 'skills', additionalSkills);
}

Future<void> _insertAdditionalJobs(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n💼 Adding additional jobs...');
  
  // Get existing domain and company IDs
  final domainIds = {
    'Technology': '550e8400-e29b-41d4-a716-446655440001',
    'Business': '550e8400-e29b-41d4-a716-446655440002',
    'Design': '550e8400-e29b-41d4-a716-446655440003',
    'Marketing': '550e8400-e29b-41d4-a716-446655440004',
    'Sales': '550e8400-e29b-41d4-a716-446655440005',
    'Finance': '550e8400-e29b-41d4-a716-446655440006',
  };
  
  final companyIds = [
    '660e8400-e29b-41d4-a716-446655440006', // Flipkart
    '660e8400-e29b-41d4-a716-446655440007', // Zomato
    '660e8400-e29b-41d4-a716-446655440008', // Paytm
    '660e8400-e29b-41d4-a716-446655440009', // Byju's
    '660e8400-e29b-41d4-a716-446655440010', // Swiggy
  ];
  
  final jobTemplates = {
    'Technology': [
      {'title': 'Senior Flutter Developer', 'description': 'Build cross-platform mobile applications using Flutter and Dart.'},
      {'title': 'Backend Engineer', 'description': 'Develop scalable backend services and APIs.'},
      {'title': 'Mobile App Developer', 'description': 'Create innovative mobile applications for iOS and Android.'},
    ],
    'Marketing': [
      {'title': 'Digital Marketing Manager', 'description': 'Lead digital marketing campaigns and strategy.'},
      {'title': 'Content Marketing Specialist', 'description': 'Create engaging content for various marketing channels.'},
      {'title': 'Social Media Manager', 'description': 'Manage social media presence and engagement.'},
    ],
    'Sales': [
      {'title': 'Sales Development Representative', 'description': 'Generate and qualify leads for the sales team.'},
      {'title': 'Account Manager', 'description': 'Manage client relationships and drive revenue growth.'},
      {'title': 'Business Development Manager', 'description': 'Identify and pursue new business opportunities.'},
    ],
    'Design': [
      {'title': 'Senior UI Designer', 'description': 'Design beautiful and intuitive user interfaces.'},
      {'title': 'UX Researcher', 'description': 'Conduct user research to inform design decisions.'},
      {'title': 'Brand Designer', 'description': 'Create and maintain brand identity and visual assets.'},
    ],
  };
  
  final jobs = <Map<String, dynamic>>[];
  int jobCounter = 100; // Start from 100 to avoid conflicts
  
  for (String domain in jobTemplates.keys) {
    final templates = jobTemplates[domain]!;
    final domainId = domainIds[domain];
    
    if (domainId == null) continue;
    
    for (int companyIndex = 0; companyIndex < companyIds.length; companyIndex++) {
      for (int templateIndex = 0; templateIndex < templates.length; templateIndex++) {
        final template = templates[templateIndex];
        final companyId = companyIds[companyIndex];
        
        // Using the correct column names from the actual schema
        jobs.add({
          'id': '880e8400-e29b-41d4-a716-${(446655440000 + jobCounter).toString().padLeft(12, '0')}',
          'title': template['title'],
          'description': template['description'],
          'company_id': companyId,
          'domain_id': domainId,
          'location': 'India',
          'employment_type': 'full_time',
          'experience_level': 'mid_level',
          'salary_min': 500000 + (jobCounter * 1000),
          'salary_max': 1000000 + (jobCounter * 2000),
          'salary_range': '5-10 LPA',
          'work_mode': 'hybrid',
          'requirements': 'Strong technical skills, excellent communication, team collaboration, problem-solving abilities.',
          'benefits': 'Competitive salary, health insurance, flexible working hours, professional development opportunities.',
          'status': 'active',
          'posted_by': '770e8400-e29b-41d4-a716-446655440001', // Use existing user ID
        });
        
        jobCounter++;
      }
    }
  }
  
  await _insertDataSafely(client, supabaseUrl, supabaseKey, 'jobs', jobs);
}

Future<void> _insertDataSafely(HttpClient client, String supabaseUrl, String supabaseKey, String table, List<Map<String, dynamic>> data) async {
  try {
    // Insert data in smaller batches to avoid conflicts
    const batchSize = 5;
    int successCount = 0;
    
    for (int i = 0; i < data.length; i += batchSize) {
      final batch = data.skip(i).take(batchSize).toList();
      
      final request = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/$table'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('apikey', supabaseKey);
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      request.headers.set('Prefer', 'return=minimal');
      
      final requestBody = jsonEncode(batch);
      request.add(utf8.encode(requestBody));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        successCount += batch.length;
        print('   ✅ Inserted batch of ${batch.length} records into $table');
      } else if (response.statusCode == 409) {
        print('   ⚠️  Batch conflict (records may already exist): ${batch.length} records');
        successCount += batch.length; // Count as success since data exists
      } else {
        print('   ❌ Failed to insert batch into $table: ${response.statusCode}');
        print('   Response: $responseBody');
      }
      
      // Small delay between batches
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    print('   📊 Total successful insertions: $successCount/${data.length}');
    
  } catch (error) {
    print('   ❌ Error inserting into $table: $error');
  }
}

Future<void> _verifyFinalSetup(HttpClient client, String supabaseUrl, String supabaseKey) async {
  print('\n🔍 Verifying final database setup...');
  
  final tables = ['domains', 'companies', 'jobs', 'skills'];
  
  for (String table in tables) {
    try {
      final request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/$table?select=count'));
      request.headers.set('apikey', supabaseKey);
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as List;
        print('   ✅ Table "$table": ${data.length} records');
      } else {
        print('   ❌ Table "$table": Error ${response.statusCode}');
      }
    } catch (error) {
      print('   ❌ Table "$table": $error');
    }
  }
  
  // Test complex join queries to ensure relationships work
  try {
    print('\n🔗 Testing complex join queries...');
    
    // Test jobs with companies and domains
    final jobsRequest = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title,companies(name),domains(name)&limit=5'));
    jobsRequest.headers.set('apikey', supabaseKey);
    jobsRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final jobsResponse = await jobsRequest.close();
    final jobsResponseBody = await jobsResponse.transform(utf8.decoder).join();
    
    if (jobsResponse.statusCode == 200) {
      final jobs = jsonDecode(jobsResponseBody) as List;
      print('   ✅ Jobs with relationships: ${jobs.length} records');
      
      for (var job in jobs.take(3)) {
        final company = job['companies'];
        final domain = job['domains'];
        print('   📋 "${job['title']}" at ${company?['name'] ?? 'Unknown'} in ${domain?['name'] ?? 'Unknown'}');
      }
    } else {
      print('   ❌ Jobs join query failed: ${jobsResponse.statusCode}');
    }
    
    // Test domain-based job filtering (the core functionality)
    final filterRequest = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/jobs?select=id,title,domains(name)&domain_id=eq.550e8400-e29b-41d4-a716-446655440001&limit=3'));
    filterRequest.headers.set('apikey', supabaseKey);
    filterRequest.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final filterResponse = await filterRequest.close();
    final filterResponseBody = await filterResponse.transform(utf8.decoder).join();
    
    if (filterResponse.statusCode == 200) {
      final filteredJobs = jsonDecode(filterResponseBody) as List;
      print('   ✅ Domain filtering works: ${filteredJobs.length} Technology jobs found');
    } else {
      print('   ❌ Domain filtering failed: ${filterResponse.statusCode}');
    }
    
  } catch (error) {
    print('   ❌ Join query error: $error');
  }
  
  print('\n✅ Database verification completed!');
}