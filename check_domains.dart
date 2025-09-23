import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  
  try {
    print('🔍 Checking domains in database...');
    
    final request = await client.openUrl('GET', Uri.parse('https://lxotlcyarcbztakbxzjl.supabase.co/rest/v1/domains?select=id,name'));
    request.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b3RsY3lhcmNienRha2J4empsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDA5NTUsImV4cCI6MjA3MjkxNjk1NX0.ZNGUW3rBNNFvYF-J9s6B0zHLbthamFYPhRKHuTVR7zA');
    request.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b3RsY3lhcmNienRha2J4empsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDA5NTUsImV4cCI6MjA3MjkxNjk1NX0.ZNGUW3rBNNFvYF-J9s6B0zHLbthamFYPhRKHuTVR7zA');
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final domains = jsonDecode(body) as List;
      print('\n📋 Domains found in database:');
      for (var domain in domains) {
        print('  - Name: "${domain['name']}" -> ID: ${domain['id']}');
      }
      print('\nTotal domains: ${domains.length}');
    } else {
      print('❌ Error: ${response.statusCode}');
      print('Response: $body');
    }
    
    // Also check jobs
    print('\n🔍 Checking jobs in database...');
    final jobRequest = await client.openUrl('GET', Uri.parse('https://lxotlcyarcbztakbxzjl.supabase.co/rest/v1/jobs?select=id,title,domain_id&limit=5'));
    jobRequest.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b3RsY3lhcmNienRha2J4empsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDA5NTUsImV4cCI6MjA3MjkxNjk1NX0.ZNGUW3rBNNFvYF-J9s6B0zHLbthamFYPhRKHuTVR7zA');
    jobRequest.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b3RsY3lhcmNienRha2J4empsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczNDA5NTUsImV4cCI6MjA3MjkxNjk1NX0.ZNGUW3rBNNFvYF-J9s6B0zHLbthamFYPhRKHuTVR7zA');
    
    final jobResponse = await jobRequest.close();
    final jobBody = await jobResponse.transform(utf8.decoder).join();
    
    if (jobResponse.statusCode == 200) {
      final jobs = jsonDecode(jobBody) as List;
      print('\n💼 Sample jobs found:');
      for (var job in jobs) {
        print('  - Title: "${job['title']}" -> Domain ID: ${job['domain_id']}');
      }
      print('\nTotal jobs: ${jobs.length}');
    } else {
      print('❌ Error fetching jobs: ${jobResponse.statusCode}');
      print('Response: $jobBody');
    }
    
  } catch (error) {
    print('❌ Error: $error');
  } finally {
    client.close();
  }
}