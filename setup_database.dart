import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://jalkqdrzbfnklpoerwui.supabase.co';
  const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzU4MDQ2MywiZXhwIjoyMDczMTU2NDYzfQ.h6BGK9-A6BZrPVH8Yhb_q05inMKN1TDw_eNr5Hjfi_4';

  print('🚀 Setting up database schema...');

  // Create basic tables using RPC calls
  final tables = [
    {
      'name': 'domains',
      'sql': '''
        CREATE TABLE IF NOT EXISTS domains (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          name VARCHAR(100) UNIQUE NOT NULL,
          description TEXT,
          icon VARCHAR(50),
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      '''
    },
    {
      'name': 'companies',
      'sql': '''
        CREATE TABLE IF NOT EXISTS companies (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          name VARCHAR(255) UNIQUE NOT NULL,
          description TEXT,
          logo_url TEXT,
          website_url TEXT,
          industry VARCHAR(100),
          size VARCHAR(50),
          location VARCHAR(255),
          founded_year INTEGER,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      '''
    },
    {
      'name': 'users',
      'sql': '''
        CREATE TABLE IF NOT EXISTS users (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          email VARCHAR(255) UNIQUE NOT NULL,
          full_name VARCHAR(255),
          phone VARCHAR(20),
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      '''
    },
    {
      'name': 'jobs',
      'sql': '''
        CREATE TABLE IF NOT EXISTS jobs (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          title VARCHAR(255) NOT NULL,
          description TEXT NOT NULL,
          company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
          domain_id UUID REFERENCES domains(id) ON DELETE CASCADE,
          location VARCHAR(255),
          employment_type VARCHAR(50) DEFAULT 'full_time',
          experience_level VARCHAR(50) DEFAULT 'mid',
          salary_min INTEGER,
          salary_max INTEGER,
          salary_range VARCHAR(50),
          work_mode VARCHAR(50) DEFAULT 'hybrid',
          requirements TEXT,
          benefits TEXT,
          status VARCHAR(20) DEFAULT 'active',
          posted_by UUID REFERENCES users(id),
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      '''
    },
    {
      'name': 'job_applications',
      'sql': '''
        CREATE TABLE IF NOT EXISTS job_applications (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
          applicant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          status VARCHAR(20) DEFAULT 'pending',
          applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          UNIQUE(job_id, applicant_id)
        );
      '''
    }
  ];

  // Execute each table creation
  for (var table in tables) {
    try {
      print('Creating table: ${table['name']}');
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
        headers: {
          'apikey': supabaseServiceKey,
          'Authorization': 'Bearer $supabaseServiceKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sql': table['sql']
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully created ${table['name']} table');
      } else {
        print('❌ Failed to create ${table['name']}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating ${table['name']}: $e');
    }
  }

  // Insert sample domains
  print('\n📋 Inserting sample domains...');
  final domains = [
    {'name': 'Technology', 'description': 'Software development, IT, and tech roles', 'icon': '💻'},
    {'name': 'Business', 'description': 'Business analysis, consulting, and management', 'icon': '💼'},
    {'name': 'Marketing', 'description': 'Digital marketing, content, and growth roles', 'icon': '📈'},
    {'name': 'Design', 'description': 'UI/UX, graphic design, and creative roles', 'icon': '🎨'},
    {'name': 'Sales', 'description': 'Sales, business development, and account management', 'icon': '💰'},
    {'name': 'Human Resources', 'description': 'HR, talent acquisition, and people operations', 'icon': '👥'},
  ];

  for (var domain in domains) {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/domains'),
        headers: {
          'apikey': supabaseServiceKey,
          'Authorization': 'Bearer $supabaseServiceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        },
        body: json.encode(domain),
      );

      if (response.statusCode == 201) {
        print('✅ Created domain: ${domain['name']}');
      } else {
        print('❌ Failed to create domain ${domain['name']}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating domain ${domain['name']}: $e');
    }
  }

  // Insert sample companies
  print('\n🏢 Inserting sample companies...');
  final companies = [
    {
      'name': 'Tata Consultancy Services',
      'description': 'Leading IT services and consulting company',
      'industry': 'Technology',
      'location': 'Mumbai, India',
      'website_url': 'https://www.tcs.com',
      'size': '500000+'
    },
    {
      'name': 'Infosys',
      'description': 'Global leader in next-generation digital services',
      'industry': 'Technology',
      'location': 'Bangalore, India',
      'website_url': 'https://www.infosys.com',
      'size': '250000+'
    },
    {
      'name': 'Wipro',
      'description': 'Leading technology services and consulting company',
      'industry': 'Technology',
      'location': 'Bangalore, India',
      'website_url': 'https://www.wipro.com',
      'size': '200000+'
    },
    {
      'name': 'HCL Technologies',
      'description': 'Global technology company',
      'industry': 'Technology',
      'location': 'Noida, India',
      'website_url': 'https://www.hcltech.com',
      'size': '150000+'
    },
  ];

  for (var company in companies) {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/companies'),
        headers: {
          'apikey': supabaseServiceKey,
          'Authorization': 'Bearer $supabaseServiceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        },
        body: json.encode(company),
      );

      if (response.statusCode == 201) {
        print('✅ Created company: ${company['name']}');
      } else {
        print('❌ Failed to create company ${company['name']}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating company ${company['name']}: $e');
    }
  }

  print('\n🎉 Database setup completed!');
}