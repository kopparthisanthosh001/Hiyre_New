import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  ProfileService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get user profile with all related data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.from('users').select('*').eq('id', userId).single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  // Update personal information
  Future<bool> updatePersonalInfo({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String industry,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('users').update({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'location': location,
        'industry': industry,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (error) {
      print('Error updating personal info: $error');
      return false;
    }
  }

  // Add work experience
  Future<bool> addWorkExperience({
    required String jobTitle,
    required String companyName,
    required String location,
    required String employmentType,
    required DateTime startDate,
    DateTime? endDate,
    required bool currentlyWorking,
    required String responsibilities,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('work_experiences').insert({
        'user_id': userId,
        'job_title': jobTitle,
        'company_name': companyName,
        'location': location,
        'employment_type': employmentType,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'currently_working': currentlyWorking,
        'responsibilities': responsibilities,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (error) {
      print('Error adding work experience: $error');
      return false;
    }
  }

  // Get user work experiences
  Future<List<Map<String, dynamic>>> getWorkExperiences() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('work_experiences')
          .select('*')
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error getting work experiences: $error');
      return [];
    }
  }

  // Update work experience
  Future<bool> updateWorkExperience({
    required String experienceId,
    required String jobTitle,
    required String companyName,
    required String location,
    required String employmentType,
    required DateTime startDate,
    DateTime? endDate,
    required bool currentlyWorking,
    required String responsibilities,
  }) async {
    try {
      await _client.from('work_experiences').update({
        'job_title': jobTitle,
        'company_name': companyName,
        'location': location,
        'employment_type': employmentType,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'currently_working': currentlyWorking,
        'responsibilities': responsibilities,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', experienceId);

      return true;
    } catch (error) {
      print('Error updating work experience: $error');
      return false;
    }
  }

  // Delete work experience
  Future<bool> deleteWorkExperience(String experienceId) async {
    try {
      await _client
          .from('work_experiences')
          .delete()
          .eq('id', experienceId);

      return true;
    } catch (error) {
      print('Error deleting work experience: $error');
      return false;
    }
  }

  // Add education
  Future<bool> addEducation({
    required String degree,
    required String fieldOfStudy,
    required String institution,
    required String location,
    required String graduationYear,
    String? achievements,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('education').insert({
        'user_id': userId,
        'degree': degree,
        'field_of_study': fieldOfStudy,
        'institution': institution,
        'location': location,
        'graduation_year': graduationYear,
        'achievements': achievements,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (error) {
      print('Error adding education: $error');
      return false;
    }
  }

  // Get user education
  Future<List<Map<String, dynamic>>> getEducation() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('education')
          .select('*')
          .eq('user_id', userId)
          .order('graduation_year', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error getting education: $error');
      return [];
    }
  }

  // Update education
  Future<bool> updateEducation({
    required String educationId,
    required String degree,
    required String fieldOfStudy,
    required String institution,
    required String location,
    required String graduationYear,
    String? achievements,
  }) async {
    try {
      await _client.from('education').update({
        'degree': degree,
        'field_of_study': fieldOfStudy,
        'institution': institution,
        'location': location,
        'graduation_year': graduationYear,
        'achievements': achievements,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', educationId);

      return true;
    } catch (error) {
      print('Error updating education: $error');
      return false;
    }
  }

  // Delete education
  Future<bool> deleteEducation(String educationId) async {
    try {
      await _client
          .from('education')
          .delete()
          .eq('id', educationId);

      return true;
    } catch (error) {
      print('Error deleting education: $error');
      return false;
    }
  }

  // Update user skills
  Future<bool> updateSkills(List<String> skills) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('users').update({
        'skills': skills,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (error) {
      print('Error updating skills: $error');
      return false;
    }
  }

  // Add certification
  Future<bool> addCertification({
    required String name,
    required String issuingOrganization,
    String? issueDate,
    String? expirationDate,
    String? credentialId,
    String? credentialUrl,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('certifications').insert({
        'user_id': userId,
        'name': name,
        'issuing_organization': issuingOrganization,
        'issue_date': issueDate,
        'expiration_date': expirationDate,
        'credential_id': credentialId,
        'credential_url': credentialUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (error) {
      print('Error adding certification: $error');
      return false;
    }
  }

  // Get user certifications
  Future<List<Map<String, dynamic>>> getCertifications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('certifications')
          .select('*')
          .eq('user_id', userId)
          .order('issue_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error getting certifications: $error');
      return [];
    }
  }

  // Update certification
  Future<bool> updateCertification({
    required String certificationId,
    required String name,
    required String issuingOrganization,
    String? issueDate,
    String? expirationDate,
    String? credentialId,
    String? credentialUrl,
  }) async {
    try {
      await _client.from('certifications').update({
        'name': name,
        'issuing_organization': issuingOrganization,
        'issue_date': issueDate,
        'expiration_date': expirationDate,
        'credential_id': credentialId,
        'credential_url': credentialUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', certificationId);

      return true;
    } catch (error) {
      print('Error updating certification: $error');
      return false;
    }
  }

  // Delete certification
  Future<bool> deleteCertification(String certificationId) async {
    try {
      await _client
          .from('certifications')
          .delete()
          .eq('id', certificationId);

      return true;
    } catch (error) {
      print('Error deleting certification: $error');
      return false;
    }
  }

  // Upload document (resume, portfolio, cover letter)
  Future<String?> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType, // 'resume', 'portfolio', 'cover_letter'
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final filePath = '$userId/$documentType/$fileName';
      
      await _client.storage
          .from('documents')
          .uploadBinary(filePath, fileBytes);

      final publicUrl = _client.storage
          .from('documents')
          .getPublicUrl(filePath);

      // Update user record with document URL
      await _client.from('users').update({
        '${documentType}_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return publicUrl;
    } catch (error) {
      print('Error uploading document: $error');
      return null;
    }
  }

  // Update user preferences
  Future<Map<String, dynamic>> updateUserPreferences({
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upsert preferences
      final response = await _client
          .from('user_preferences')
          .upsert({
            'user_id': userId,
            ...preferences,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update user preferences: $error');
    }
  }

  // Mark profile as completed
  Future<void> markProfileCompleted() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('user_profiles')
          .update({'profile_completed': true}).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to mark profile as completed: $error');
    }
  }

  // Get all available skills
  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      final response = await _client
          .from('skills')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch skills: $error');
    }
  }

  // Search skills
  Future<List<Map<String, dynamic>>> searchSkills(String query) async {
    try {
      final response = await _client
          .from('skills')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search skills: $error');
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(
      String filePath, List<int> fileBytes) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = 'profile_$userId.jpg';

      await _client.storage.from('profiles').uploadBinary(fileName, Uint8List.fromList(fileBytes));

      final imageUrl = _client.storage.from('profiles').getPublicUrl(fileName);

      // Update profile with image URL
      await _client
          .from('user_profiles')
          .update({'profile_image_url': imageUrl}).eq('id', userId);

      return imageUrl;
    } catch (error) {
      throw Exception('Failed to upload profile image: $error');
    }
  }

  // Create user profile in users table (alternative to AuthService sync)
  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role, // Keep parameter for compatibility but don't use in insert
    String? phone,
    String? location,
    String? bio,
    List<String>? skills,
  }) async {
    try {
      final profileData = {
        'id': userId, // Use the same UUID from auth.users
        'email': email,
        'full_name': fullName,
        // 'role': role, // Remove this line - role column doesn't exist in users table
        'phone': phone,
        'location': location,
        'bio': bio,
        // 'skills': skills, // Remove this line - skills column doesn't exist in users table
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('users')
          .insert(profileData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create user profile: $error');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Delete user profile (cascade will handle related data)
      await _client.from('users').delete().eq('id', userId);

      // Sign out
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Failed to delete account: $error');
    }
  }
}
