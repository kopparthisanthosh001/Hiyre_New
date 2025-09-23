import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/error_handler.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Send OTP to email with better error handling
  Future<void> signInWithOtp({required String email}) async {
    try {
      await _client.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (error) {
      throw Exception(ErrorHandler.getReadableError(error));
    }
  }

  // Verify OTP with better error handling
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
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
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Sign up method with users table sync
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    try {
      // First, create user in Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      // If signup successful and user is created, sync with users table
      if (response.user != null) {
        await _syncUserToCustomTable(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          role: role,
          phone: phone,
        );
      }

      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Private method to sync auth user with custom users table
  Future<void> _syncUserToCustomTable({
    required String userId,
    required String email,
    required String fullName,
    required String role, // Keep parameter for compatibility but don't use in insert
    String? phone,
  }) async {
    try {
      await _client.from('users').insert({
        'id': userId, // Use the same UUID from auth.users
        'email': email,
        'full_name': fullName,
        // 'role': role, // Remove this line - role column doesn't exist in users table
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // If users table insert fails, we should clean up the auth user
      // But for now, we'll just log the error
      print('Warning: Failed to sync user to custom table: $error');
      throw Exception('Failed to create user profile: $error');
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

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign in failed: $error');
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.apple);
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

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update password
  Future<UserResponse> updatePassword({required String password}) async {
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
          .from('user_profiles')
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
      return profile['profile_completed'] == true;
    } catch (error) {
      return false;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get auth token
  Future<String?> getAccessToken() async {
    final session = _client.auth.currentSession;
    return session?.accessToken;
  }

  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password. Please try again.';
      case 'Email not confirmed':
        return 'Please verify your email before signing in.';
      case 'Too many requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'Invalid OTP':
        return 'Invalid verification code. Please check and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
