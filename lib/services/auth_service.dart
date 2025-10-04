import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/error_handler.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseClient get supabase => _client; // Add this getter

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Send OTP to email with better error handling
  Future<void> sendOTP(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (error) {
      throw Exception(ErrorHandler.getReadableError(error));
    }
  }

  // Verify OTP with better error handling
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: email,
      );
      
      return response;
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (error) {
      throw Exception(ErrorHandler.getReadableError(error));
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Sign up with email and password - UPDATED VERSION
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role, // Add role parameter
  }) async {
    try {
      print('🔄 Starting signup process...');
      
      // Step 1: Create user in Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role ?? 'job_seeker', // Include role in metadata
        },
      );

      print('✅ Auth user created: ${response.user?.id}');

      // Step 2: Sync with users table (only if auth user was created)
      if (response.user != null) {
        await _syncUserToCustomTable(response.user!);
      }

      return response;
    } catch (error) {
      print('❌ Signup failed: $error');
      throw Exception('Sign up failed: $error');
    }
  }

  // IMPROVED: More robust user sync with better error handling
  Future<void> _syncUserToCustomTable(User user) async {
    try {
      // First check if user already exists
      final existingUser = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
  
      if (existingUser != null) {
        print('User already exists in custom table');
        return;
      }
  
      // Try to use the RPC function first (recommended approach)
      try {
        final result = await _client.rpc(
          'create_user_profile',
          params: {
            'user_id': user.id,
            'user_email': user.email ?? '',
            'user_full_name': user.userMetadata?['full_name'] ?? '',
            'user_phone': user.phone ?? '',
          },
        );
        
        print('User profile created via RPC function: $result');
        return;
      } catch (rpcError) {
        print('RPC function failed, trying direct insert: $rpcError');
        
        // Fallback to direct insert (should work after RLS fix)
        final userData = {
          'id': user.id,
          'email': user.email ?? '',
          'full_name': user.userMetadata?['full_name'] ?? '',
          'phone': user.phone ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
  
        await _client.from('users').insert(userData);
        print('User profile created via direct insert');
      }
    } catch (e) {
      print('Error syncing user to custom table: $e');
      
      // Check if it's a duplicate key error (user already exists)
      if (e.toString().contains('duplicate key') || 
          e.toString().contains('already exists')) {
        print('User already exists, continuing...');
        return;
      }
      
      // For other errors, rethrow
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign in with Google - CORRECTED return type
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(OAuthProvider.google);
      return response;
    } catch (error) {
      throw Exception('Google sign in failed: $error');
    }
  }

  // Sign in with Apple - CORRECTED return type  
  Future<bool> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(OAuthProvider.apple);
      return response;
    } catch (error) {
      throw Exception('Apple sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Reset password - FIXED method signature
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update password
  Future<UserResponse> updatePassword({
    required String password,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: password),
      );
      return response;
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return false;
      return profile['full_name'] != null && profile['email'] != null;
    } catch (error) {
      return false;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String _getAuthErrorMessage(AuthException e) {
    switch (e.statusCode) {
      case '400':
        return 'Invalid email or password format.';
      case '422':
        return 'Email already registered or invalid.';
      case '429':
        return 'Too many requests. Please wait before trying again.';
      case '500':
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
