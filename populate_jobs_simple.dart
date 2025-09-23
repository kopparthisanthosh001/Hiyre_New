import 'dart:convert';
import 'dart:io';

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  
  try {
    print('🚀 Starting job population...');
    
    // First, get companies and domains
    print('\n1. Fetching companies...');
    var result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/companies?select=id,name',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode != 0) {
      print('❌ Failed to fetch companies: ${result.stderr}');
      return;
    }
    
    var companies = jsonDecode(result.stdout) as List;
    print('Found ${companies.length} companies');
    
    if (companies.isEmpty) {
      print('❌ No companies found. Creating sample companies first...');
      
      // Create sample companies
      var sampleCompanies = [
        {'name': 'TechCorp', 'industry': 'Technology', 'location': 'San Francisco'},
        {'name': 'DataSoft', 'industry': 'Software', 'location': 'New York'},
        {'name': 'InnovateLab', 'industry': 'Research', 'location': 'Boston'},
        {'name': 'CloudTech', 'industry': 'Cloud Computing', 'location': 'Seattle'},
        {'name': 'StartupHub', 'industry': 'Startup', 'location': 'Austin'}
      ];
      
      for (var company in sampleCompanies) {
        var createResult = await Process.run('curl', [
          '-X', 'POST',
          '$supabaseUrl/rest/v1/companies',
          '-H', 'apikey: $supabaseKey',
          '-H', 'Authorization: Bearer $supabaseKey',
          '-H', 'Content-Type: application/json',
          '-d', jsonEncode(company)
        ]);
        
        if (createResult.exitCode == 0) {
          print('✅ Created company: ${company['name']}');
        } else {
          print('❌ Failed to create company ${company['name']}: ${createResult.stderr}');
        }
      }
      
      // Fetch companies again
      result = await Process.run('curl', [
        '-X', 'GET',
        '$supabaseUrl/rest/v1/companies?select=id,name',
        '-H', 'apikey: $supabaseKey',
        '-H', 'Authorization: Bearer $supabaseKey'
      ]);
      
      companies = jsonDecode(result.stdout) as List;
      print('Now have ${companies.length} companies');
    }
    
    print('\n2. Fetching domains...');
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/domains?select=id,name',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode != 0) {
      print('❌ Failed to fetch domains: ${result.stderr}');
      return;
    }
    
    var domains = jsonDecode(result.stdout) as List;
    print('Found ${domains.length} domains');
    
    if (companies.isEmpty || domains.isEmpty) {
      print('❌ Cannot create jobs without companies and domains');
      return;
    }
    
    print('\n3. Creating sample jobs...');
    
    // Sample jobs for different domains
    var jobTemplates = [
      // Technology jobs
      {'title': 'Senior Software Engineer', 'domain': 'Technology', 'description': 'Build scalable web applications using modern technologies.', 'employment_type': 'full-time', 'work_mode': 'hybrid', 'experience_level': 'senior', 'salary_min': 80000, 'salary_max': 120000, 'location': 'San Francisco'},
      {'title': 'Frontend Developer', 'domain': 'Technology', 'description': 'Create beautiful and responsive user interfaces.', 'employment_type': 'full-time', 'work_mode': 'remote', 'experience_level': 'mid', 'salary_min': 60000, 'salary_max': 90000, 'location': 'Remote'},
      {'title': 'DevOps Engineer', 'domain': 'Technology', 'description': 'Manage cloud infrastructure and deployment pipelines.', 'employment_type': 'full-time', 'work_mode': 'on-site', 'experience_level': 'senior', 'salary_min': 90000, 'salary_max': 130000, 'location': 'Seattle'},
      
      // Data Science jobs
      {'title': 'Data Scientist', 'domain': 'Data Science', 'description': 'Analyze large datasets to extract business insights.', 'employment_type': 'full-time', 'work_mode': 'hybrid', 'experience_level': 'mid', 'salary_min': 70000, 'salary_max': 110000, 'location': 'New York'},
      {'title': 'Machine Learning Engineer', 'domain': 'Data Science', 'description': 'Build and deploy ML models at scale.', 'employment_type': 'full-time', 'work_mode': 'remote', 'experience_level': 'senior', 'salary_min': 100000, 'salary_max': 150000, 'location': 'Remote'},
      
      // Business jobs
      {'title': 'Product Manager', 'domain': 'Business', 'description': 'Lead product strategy and development.', 'employment_type': 'full-time', 'work_mode': 'hybrid', 'experience_level': 'senior', 'salary_min': 85000, 'salary_max': 125000, 'location': 'Austin'},
      {'title': 'Business Analyst', 'domain': 'Business', 'description': 'Analyze business processes and requirements.', 'employment_type': 'full-time', 'work_mode': 'on-site', 'experience_level': 'mid', 'salary_min': 55000, 'salary_max': 80000, 'location': 'Boston'},
      
      // Design jobs
      {'title': 'UX Designer', 'domain': 'Design', 'description': 'Design intuitive user experiences.', 'employment_type': 'full-time', 'work_mode': 'hybrid', 'experience_level': 'mid', 'salary_min': 60000, 'salary_max': 90000, 'location': 'San Francisco'},
      {'title': 'UI Designer', 'domain': 'Design', 'description': 'Create beautiful user interfaces.', 'employment_type': 'contract', 'work_mode': 'remote', 'experience_level': 'junior', 'salary_min': 45000, 'salary_max': 70000, 'location': 'Remote'},
      
      // Marketing jobs
      {'title': 'Digital Marketing Manager', 'domain': 'Marketing', 'description': 'Lead digital marketing campaigns.', 'employment_type': 'full-time', 'work_mode': 'hybrid', 'experience_level': 'senior', 'salary_min': 65000, 'salary_max': 95000, 'location': 'New York'},
    ];
    
    int successCount = 0;
    int failCount = 0;
    
    for (var jobTemplate in jobTemplates) {
      // Find matching domain
      var domain = domains.firstWhere(
        (d) => d['name'] == jobTemplate['domain'],
        orElse: () => domains.first
      );
      
      // Pick a random company
      var company = companies[successCount % companies.length];
      
      var job = {
        'title': jobTemplate['title'],
        'description': jobTemplate['description'],
        'company_id': company['id'],
        'domain_id': domain['id'],
        'employment_type': jobTemplate['employment_type'],
        'work_mode': jobTemplate['work_mode'],
        'experience_level': jobTemplate['experience_level'],
        'salary_min': jobTemplate['salary_min'],
        'salary_max': jobTemplate['salary_max'],
        'location': jobTemplate['location'],
        'status': 'active'
      };
      
      var createResult = await Process.run('curl', [
        '-X', 'POST',
        '$supabaseUrl/rest/v1/jobs',
        '-H', 'apikey: $supabaseKey',
        '-H', 'Authorization: Bearer $supabaseKey',
        '-H', 'Content-Type: application/json',
        '-H', 'Prefer: return=minimal',
        '-d', jsonEncode(job)
      ]);
      
      if (createResult.exitCode == 0) {
        successCount++;
        print('✅ Created job: ${job['title']}');
      } else {
        failCount++;
        print('❌ Failed to create job ${job['title']}: ${createResult.stderr}');
      }
      
      // Small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    print('\n🎉 Job population completed!');
    print('📊 Summary:');
    print('- Successfully created: $successCount jobs');
    print('- Failed to create: $failCount jobs');
    
    // Verify final count
    result = await Process.run('curl', [
      '-X', 'GET',
      '$supabaseUrl/rest/v1/jobs?select=count',
      '-H', 'apikey: $supabaseKey',
      '-H', 'Authorization: Bearer $supabaseKey'
    ]);
    
    if (result.exitCode == 0) {
      var countResult = jsonDecode(result.stdout);
      print('- Total jobs in database: ${countResult.length}');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}