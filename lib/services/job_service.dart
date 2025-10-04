import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import '../models/application_stats.dart';
import 'supabase_service.dart';

class JobService {
  JobService._();
  static final JobService instance = JobService._();
  SupabaseClient get _client => SupabaseService.instance.client;

  /// Fetch all jobs with related company and domain info
  Future<List<JobModel>> getAllJobs() async {
    try {
      print("Fetching jobs with joins...");
      final response = await _client.from('jobs').select('''
        id,
        title,
        description,
        location,
        salary,
        experience,
        created_at,
        company:companies(id, name, logo_url, description),
        domain:domains(id, name, description)
      ''');
      print("Response received: $response");

      return (response as List<dynamic>)
          .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print("Error fetching jobs with joins: $e\n$stack");
      return _getJobsWithoutJoins();
    }
  }

  /// Fetch jobs without joins (with fallback queries for company and domain)
  Future<List<JobModel>> _getJobsWithoutJoins() async {
    try {
      print("Fetching jobs without joins...");
      final response = await _client.from('jobs').select();
      print("Jobs fetched: $response");

      return (response as List<dynamic>).map((job) {
        final jobData = job as Map<String, dynamic>;
        return JobModel.fromJson({
          ...jobData,
          'company': _fetchCompany(jobData['company_id']),
          'domain': _fetchDomain(jobData['domain_id']),
        });
      }).toList();
    } catch (e, stack) {
      print("Error fetching jobs without joins: $e\n$stack");
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchCompany(int? companyId) async {
    if (companyId == null) return {};
    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('id', companyId)
          .single();
      return response;
    } catch (e) {
      print("Error fetching company: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> _fetchDomain(int? domainId) async {
    if (domainId == null) return {};
    try {
      final response =
          await _client.from('domains').select().eq('id', domainId).single();
      return response;
    } catch (e) {
      print("Error fetching domain: $e");
      return {};
    }
  }

  /// Test Supabase connection
  Future<bool> testConnection() async {
    try {
      final response = 
        await _client.from('jobs').select('*').limit(1);
      print("✅ Supabase connection successful: $response");
      return true;
    } catch (e, stack) {
      print("❌ Supabase connection failed: $e\n$stack");
      return false;
    }
  }

  /// Generate mock jobs (for testing only)
  List<JobModel> generateMockJobs(int count) {
    final random = Random();
    final jobTitles = [
      'Software Engineer',
      'Product Manager',
      'Data Scientist',
      'UX Designer',
      'Mobile Developer'
    ];
    final companies = ['TechCorp', 'InnoSoft', 'DataLabs', 'DesignHub', 'AppWorks'];
    final locations = ['Remote', 'Bangalore', 'Hyderabad', 'Delhi', 'Pune'];

    return List.generate(count, (index) {
      final salaryAmount = (random.nextInt(20) + 5) * 10000;
      return JobModel(
        id: index.toString(),
        title: jobTitles[random.nextInt(jobTitles.length)],
        description: 'This is a description for job $index',
        location: locations[random.nextInt(locations.length)],
        employmentType: 'full_time',
        workMode: 'remote',
        experienceLevel: 'mid',
        salaryMin: salaryAmount,
        salaryMax: salaryAmount + 20000,
        currency: 'USD',
        status: 'active',
        postedBy: 'recruiter-$index',
        viewsCount: random.nextInt(100),
        applicationsCount: random.nextInt(20),
        createdAt: DateTime.now()
            .subtract(Duration(days: random.nextInt(30))),
        updatedAt: DateTime.now(),
        company: CompanyModel(
          id: index.toString(),
          name: companies[random.nextInt(companies.length)],
          logoUrl: 'https://via.placeholder.com/150',
          description: 'Leading company in their field',
          isVerified: true,
        ),
        domain: DomainModel(
          id: index.toString(),
          name: 'Technology',
          description: 'Tech domain',
        ),
      );
    });
  }

  /// Calculate job match score based on user profile
  double calculateJobMatchScore(JobModel job, Map<String, dynamic> userProfile) {
    double score = 0;
    int factors = 0;

    // Skill match
    if (userProfile['skills'] != null) {
      factors++;
      final skills = List<String>.from(userProfile['skills']);
      final matches =
          skills.where((skill) => job.description.contains(skill)).length;
      score += (matches / skills.length) * 100;
    }

    // Location match
    if (userProfile['preferred_location'] != null && job.location != null) {
      factors++;
      if (job.location == userProfile['preferred_location']) {
        score += 100;
      } else {
        score += 50;
      }
    }

    // Experience match
    if (userProfile['experience'] != null) {
      factors++;
      final userExp = int.tryParse(userProfile['experience'].toString()) ?? 0;
      final jobExp =
          int.tryParse(job.experienceLevel.split(' ').first ?? '') ?? 0;
      final expDiff = (userExp - jobExp).abs();
      score += expDiff <= 1 ? 100 : 50;
    }

    // Avoid divide by zero
    if (factors == 0) return 0;

    // Normalize score (0–100)
    final normalizedScore = score / factors;
    return normalizedScore;
  }

  /// Fetch application statistics for a given user
  Future<ApplicationStats> getApplicationStats(int userId) async {
    try {
      final totalResponse = await _client
          .from('job_applications')
          .select('*')
          .eq('applicant_id', userId);

      final pendingResponse = await _client
          .from('job_applications')
          .select('*')
          .eq('applicant_id', userId)
          .eq('status', 'pending');

      final interviewedResponse = await _client
          .from('job_applications')
          .select('*')
          .eq('applicant_id', userId)
          .eq('status', 'interviewed');

      final offeredResponse = await _client
          .from('job_applications')
          .select('*')
          .eq('applicant_id', userId)
          .eq('status', 'offered');

      return ApplicationStats(
        totalApplications: totalResponse.length,
        pendingApplications: pendingResponse.length,
        interviewedApplications: interviewedResponse.length,
        offeredApplications: offeredResponse.length,
      );
    } catch (e, stack) {
      print("Error fetching application stats: $e\n$stack");
      return ApplicationStats.defaultStats();
    }
  }

  /// Get user applications
  Future<List<Map<String, dynamic>>> getUserApplications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('job_applications')
          .select('''
            *,
            jobs(
              id,
              title,
              description,
              location,
              employment_type,
              work_mode,
              salary_min,
              salary_max,
              companies(name, logo_url)
            )
          ''')
          .eq('applicant_id', user.id)
          .order('applied_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print("Error fetching user applications: $e\n$stack");
      return [];
    }
  }

  /// Get jobs for selected domains
  Future<List<JobModel>> getJobsForSelectedDomains(List<String> domainIds, {int limit = 50}) async {
    try {
      print('🔍 Fetching jobs for domain IDs: $domainIds');
      print('🔍 Query limit: $limit');
      
      // First, let's check what domains exist in the database
      try {
        final allDomains = await _client.from('domains').select('id, name').limit(20);
        print('📋 Available domains in database:');
        for (var domain in allDomains) {
          print('   - ${domain['name']}: ${domain['id']}');
        }
      } catch (domainError) {
        print('❌ Could not fetch domains: $domainError');
      }
      
      // Check if there are any jobs at all
      try {
        final allJobs = await _client.from('jobs').select('id, title, domain_id, status').limit(10);
        print('📋 Sample jobs in database (${allJobs.length} total):');
        for (var job in allJobs) {
          print('   - ${job['title']} (domain: ${job['domain_id']}, status: ${job['status']})');
        }
      } catch (jobError) {
        print('❌ Could not fetch sample jobs: $jobError');
      }
      
      // Now try the actual query
      print('🚀 Executing main query with inFilter...');
      final response = await _client
          .from('jobs')
          .select('''
            id,
            title,
            description,
            location,
            employment_type,
            work_mode,
            experience_level,
            salary_min,
            salary_max,
            salary_range,
            requirements,
            benefits,
            status,
            posted_by,
            created_at,
            updated_at,
            companies:company_id(id, name, logo_url, description),
            domains:domain_id(id, name, description)
          ''')
          .inFilter('domain_id', domainIds)
          .eq('status', 'active')
          .limit(limit);

      print('📊 Query completed successfully');
      print('📈 Found ${response.length} jobs for selected domains');
      
      if (response.isEmpty) {
        print('⚠️ No jobs returned for domains: $domainIds');
        
        // Try without the status filter to see if that's the issue
        try {
          final responseNoStatus = await _client
              .from('jobs')
              .select('id, title, domain_id, status')
              .inFilter('domain_id', domainIds)
              .limit(5);
          print('🔍 Jobs without status filter: ${responseNoStatus.length}');
          for (var job in responseNoStatus) {
            print('   - ${job['title']} (status: ${job['status']})');
          }
        } catch (testError) {
          print('❌ Test query failed: $testError');
        }
      } else {
        // Log first few jobs for debugging
        print('✅ Successfully loaded jobs:');
        for (int i = 0; i < (response.length > 3 ? 3 : response.length); i++) {
          final job = response[i];
          print('   - ${job['title']} (${job['domain']?['name'] ?? 'No domain'})');
        }
      }
      
      return (response as List<dynamic>)
          .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print("❌ Error fetching jobs for selected domains: $e");
      print("📍 Stack trace: $stack");
      
      return [];
    }
  }

  /// Get recommended jobs
  Future<List<JobModel>> getRecommendedJobs({int limit = 50}) async {
    try {
      final response = await _client
          .from('jobs')
          .select('''
            id,
            title,
            description,
            location,
            employment_type,
            work_mode,
            experience_level,
            salary_min,
            salary_max,
            currency,
            requirements,
            benefits,
            application_deadline,
            status,
            posted_by,
            views_count,
            applications_count,
            created_at,
            updated_at,
            company:companies(id, name, logo_url, description),
            domain:domains(id, name, description)
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print("Error fetching recommended jobs: $e\n$stack");
      return [];
    }
  }

  /// Apply to a job
  Future<void> applyToJob({required String jobId}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('job_applications').insert({
        'job_id': jobId,
        'applicant_id': user.id,
        'status': 'pending',
        'applied_at': DateTime.now().toIso8601String(),
      });

      // Increment applications count
      await _client.rpc('increment_applications_count', params: {'job_id': jobId});
    } catch (e, stack) {
      print("Error applying to job: $e\n$stack");
      throw Exception('Failed to apply to job: $e');
    }
  }

  /// Track job view
  Future<void> trackJobView(String jobId) async {
    try {
      await _client.rpc('increment_views_count', params: {'job_id': jobId});
    } catch (e, stack) {
      print("Error tracking job view: $e\n$stack");
      // Don't throw error for view tracking as it's not critical
    }
  }
}
