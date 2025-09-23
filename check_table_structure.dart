import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking table structure...');
  
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
  
  final client = HttpClient();
  
  try {
    // Check domains table structure
    await _checkTableStructure(client, supabaseUrl, supabaseKey, 'domains');
    
    // Check companies table structure
    await _checkTableStructure(client, supabaseUrl, supabaseKey, 'companies');
    
    // Check jobs table structure
    await _checkTableStructure(client, supabaseUrl, supabaseKey, 'jobs');
    
    // Check skills table structure
    await _checkTableStructure(client, supabaseUrl, supabaseKey, 'skills');
    
  } catch (error) {
    print('❌ Error: $error');
  } finally {
    client.close();
  }
}

Future<void> _checkTableStructure(HttpClient client, String supabaseUrl, String supabaseKey, String tableName) async {
  print('\n📋 Checking $tableName table structure...');
  
  try {
    // Get first record to see structure
    final request = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/$tableName?limit=1'));
    request.headers.set('apikey', supabaseKey);
    request.headers.set('Authorization', 'Bearer $supabaseKey');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List;
      
      if (data.isNotEmpty) {
        final record = data.first as Map<String, dynamic>;
        print('   ✅ Available columns:');
        
        for (var key in record.keys) {
          final value = record[key];
          final type = value?.runtimeType.toString() ?? 'null';
          print('      - $key: $type');
        }
        
        print('   📄 Sample record:');
        print('      ${jsonEncode(record)}');
      } else {
        print('   ⚠️  Table is empty, cannot determine structure');
      }
    } else {
      print('   ❌ Failed to query $tableName: ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (error) {
    print('   ❌ Error checking $tableName: $error');
  }
}