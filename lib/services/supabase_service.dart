import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // TEMPORARY FIX: Hardcoded credentials to bypass environment variable issues
  static String get supabaseUrl {
    return 'https://jalkqdrzbfnklpoerwui.supabase.co';
  }

  static String get supabaseAnonKey {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino';
  }

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  // Test connection to Supabase with better error handling
  Future<bool> testConnection() async {
    try {
      print('Testing Supabase connection...');
      
      // Try a simple query to test connectivity
      final response = await client
          .from('domains')
          .select('id, name')
          .limit(1);
      
      print('✅ Supabase connection successful');
      return true;
    } catch (e) {
      print('❌ Supabase connection failed: $e');
      return false;
    }
  }

  // Get connection info for debugging
  Map<String, String> getConnectionInfo() {
    return {
      'url': supabaseUrl,
      'hasAnonKey': supabaseAnonKey.isNotEmpty ? 'Yes' : 'No',
      'isInitialized': Supabase.instance.client != null ? 'Yes' : 'No',
    };
  }

  // Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }
}
