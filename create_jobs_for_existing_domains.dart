import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  
  const supabaseUrl = 'https://lxotlcyarcbztakbxzjl.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b3RsY3lhcmNienRha2J4empsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDA5NTUsImV4cCI6MjA3MjkxNjk1NX0.ZNGUW3rBNNFvYF-J9s6B0zHLbthamFYPhRKHuTVR7zA';
  
  try {
    print('🚀 Creating jobs for existing domains...');

    // Helper function to make HTTP requests
    Future<Map<String, dynamic>> makeRequest(String method, String endpoint, [Map<String, dynamic>? body]) async {
      final request = await client.openUrl(method, Uri.parse('$supabaseUrl/rest/v1/$endpoint'));
      request.headers.set('apikey', supabaseKey);
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=representation');
      
      if (body != null) {
        request.write(jsonEncode(body));
      }
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(responseBody), 'status': response.statusCode};
      } else {
        return {'success': false, 'error': responseBody, 'status': response.statusCode};
      }
    }

    // Check existing companies
    print('🏢 Checking companies...');
    final companiesResponse = await makeRequest('GET', 'companies?select=id,name');
    
    String? companyId;
    if (companiesResponse['success']) {
      final existingCompanies = companiesResponse['data'] as List;
      print('Existing companies: ${existingCompanies.length}');
      
      if (existingCompanies.isNotEmpty) {
        companyId = existingCompanies.first['id'];
        print('✅ Using existing company: ${existingCompanies.first['name']}');
      }
    }

    // Domain IDs from the database
    final domainIds = {
      'Technology': '550e8400-e29b-41d4-a716-446655440001',
      'Business': '550e8400-e29b-41d4-a716-446655440002', 
      'Design': '550e8400-e29b-41d4-a716-446655440003',
      'Marketing': '550e8400-e29b-41d4-a716-446655440004',
      'Sales': '550e8400-e29b-41d4-a716-446655440005',
      'Finance': '550e8400-e29b-41d4-a716-446655440006'
    };

    // Create sample jobs for each domain (without company_id if no companies exist)
    final sampleJobs = [
      {
        'title': 'Senior Flutter Developer',
        'description': 'Build amazing mobile apps with Flutter. Work with a dynamic team on cutting-edge projects.',
        'domain_id': domainIds['Technology'],
        'employment_type': 'full_time',
        'work_mode': 'remote',
        'experience_level': 'senior',
        'salary_min': 100000,
        'salary_max': 130000,
        'location': 'Remote',
        'status': 'active'
      },
      {
        'title': 'UX/UI Designer',
        'description': 'Design beautiful and intuitive user experiences. Work closely with product and engineering teams.',
        'domain_id': domainIds['Design'],
        'employment_type': 'full_time',
        'work_mode': 'hybrid',
        'experience_level': 'mid',
        'salary_min': 70000,
        'salary_max': 95000,
        'location': 'San Francisco, CA',
        'status': 'active'
      },
      {
        'title': 'Digital Marketing Manager',
        'description': 'Lead digital marketing campaigns and grow our online presence. Experience with SEO, SEM, and social media required.',
        'domain_id': domainIds['Marketing'],
        'employment_type': 'full_time',
        'work_mode': 'hybrid',
        'experience_level': 'senior',
        'salary_min': 80000,
        'salary_max': 110000,
        'location': 'New York, NY',
        'status': 'active'
      },
      {
        'title': 'Business Analyst',
        'description': 'Analyze business processes and identify improvement opportunities. Work with stakeholders to implement solutions.',
        'domain_id': domainIds['Business'],
        'employment_type': 'full_time',
        'work_mode': 'hybrid',
        'experience_level': 'mid',
        'salary_min': 65000,
        'salary_max': 85000,
        'location': 'Chicago, IL',
        'status': 'active'
      },
      {
        'title': 'Sales Manager',
        'description': 'Lead sales team and drive revenue growth. Develop sales strategies and manage client relationships.',
        'domain_id': domainIds['Sales'],
        'employment_type': 'full_time',
        'work_mode': 'onsite',
        'experience_level': 'senior',
        'salary_min': 75000,
        'salary_max': 100000,
        'location': 'Austin, TX',
        'status': 'active'
      },
      {
        'title': 'Financial Analyst',
        'description': 'Analyze financial data and create reports. Support budgeting and forecasting processes.',
        'domain_id': domainIds['Finance'],
        'employment_type': 'full_time',
        'work_mode': 'hybrid',
        'experience_level': 'mid',
        'salary_min': 60000,
        'salary_max': 80000,
        'location': 'Seattle, WA',
        'status': 'active'
      }
    ];

    // Add company_id if we have one
    if (companyId != null) {
      for (var job in sampleJobs) {
        job['company_id'] = companyId;
      }
      print('✅ Adding company_id to all jobs');
    } else {
      print('⚠️  Creating jobs without company_id (no companies available)');
    }

    // Insert jobs one by one
    int successCount = 0;
    for (int i = 0; i < sampleJobs.length; i++) {
      final job = sampleJobs[i];
      final createResponse = await makeRequest('POST', 'jobs', job);
      
      if (createResponse['success']) {
        successCount++;
        print('✅ Created job: ${job['title']}');
      } else {
        print('❌ Failed to create job "${job['title']}": ${createResponse['error']}');
      }
    }

    print('\n🎉 Job creation complete!');
    print('📊 Successfully created $successCount out of ${sampleJobs.length} jobs');
    
    if (successCount > 0) {
      print('\n✨ Your Hiyre app should now show real jobs!');
      print('🔄 Refresh your app to see the new jobs!');
    } else {
      print('\n❌ No jobs were created. There might be database permission issues.');
    }

  } catch (error) {
    print('❌ Error creating jobs: $error');
    exit(1);
  } finally {
    client.close();
  }

  exit(0);
}