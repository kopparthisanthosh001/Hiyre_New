// Complete Signup Flow Example
// This demonstrates how to sync Supabase Auth with your custom users table

import 'package:supabase_flutter/supabase_flutter.dart';
import './lib/services/auth_service.dart';
import './lib/services/profile_service.dart';

// Example 1: Using AuthService (Recommended - Automatic Sync)
void signupWithAuthService() async {
  try {
    // This will create user in both auth.users AND your users table
    final response = await AuthService.instance.signUp(
      email: 'user@example.com',
      password: 'SecurePassword123!',
      fullName: 'John Doe',
      role: 'job_seeker',
      phone: '+1234567890', // Optional
      location: 'New York, NY', // Optional
    );

    if (response.user != null) {
      print('✅ User created successfully!');
      print('Auth ID: ${response.user!.id}');
      print('Email: ${response.user!.email}');
      
      // The users table now has a matching record with the same ID
      // You can immediately use ProfileService methods
      final profile = await ProfileService.instance.getUserProfile();
      print('Profile: $profile');
    }
  } catch (error) {
    print('❌ Signup failed: $error');
  }
}

// Example 2: Manual approach using ProfileService.createUserProfile
void signupManualSync() async {
  try {
    // Step 1: Create user in Supabase Auth only
    final supabase = Supabase.instance.client;
    final authResponse = await supabase.auth.signUp(
      email: 'user2@example.com',
      password: 'SecurePassword123!',
      data: {
        'full_name': 'Jane Smith',
        'role': 'job_seeker',
      },
    );

    if (authResponse.user != null) {
      // Step 2: Manually create matching record in users table
      final profile = await ProfileService.instance.createUserProfile(
        userId: authResponse.user!.id, // Same UUID from auth.users
        email: 'user2@example.com',
        fullName: 'Jane Smith',
        role: 'job_seeker',
        phone: '+0987654321',
        location: 'San Francisco, CA',
        bio: 'Software developer passionate about mobile apps',
        skills: ['Flutter', 'Dart', 'Firebase'],
      );

      print('✅ User and profile created successfully!');
      print('Auth ID: ${authResponse.user!.id}');
      print('Profile ID: ${profile['id']}');
      print('IDs match: ${authResponse.user!.id == profile['id']}');
    }
  } catch (error) {
    print('❌ Manual signup failed: $error');
  }
}

// Example 3: Complete profile creation flow (like in your app)
void completeProfileCreation() async {
  try {
    // Collect user data from form controllers
    final email = 'newuser@example.com';
    final firstName = 'Alice';
    final lastName = 'Johnson';
    final phone = '+1122334455';
    final bio = 'Marketing professional with 5 years experience';
    final skills = ['Digital Marketing', 'SEO', 'Content Strategy'];
    final preferredLocation = 'Remote';

    // Create user with AuthService (automatic sync)
    final authResponse = await AuthService.instance.signUp(
      email: email,
      password: 'UserChosenPassword123!',
      fullName: '$firstName $lastName',
      role: 'job_seeker',
      phone: phone,
      location: preferredLocation,
    );

    if (authResponse.user != null) {
      // Update additional profile information
      await ProfileService.instance.updatePersonalInfo(
        fullName: '$firstName $lastName',
        email: email,
        phone: phone,
        location: preferredLocation,
        industry: 'Marketing',
      );

      // Add skills
      if (skills.isNotEmpty) {
        await ProfileService.instance.updateSkills(skills);
      }

      print('✅ Complete profile created!');
      print('User can now use all ProfileService methods');
      
      // Test existing methods still work
      final userProfile = await ProfileService.instance.getUserProfile();
      print('Retrieved profile: ${userProfile?['full_name']}');
    }
  } catch (error) {
    print('❌ Profile creation failed: $error');
  }
}

// Example 4: Verify sync between auth.users and users table
void verifySyncIntegrity() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Get current auth user
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      print('❌ No authenticated user');
      return;
    }

    // Get profile from users table
    final profile = await ProfileService.instance.getUserProfile();
    
    if (profile != null) {
      print('✅ Sync verification:');
      print('Auth User ID: ${authUser.id}');
      print('Profile User ID: ${profile['id']}');
      print('IDs Match: ${authUser.id == profile['id']}');
      print('Email Match: ${authUser.email == profile['email']}');
      print('Full Name: ${profile['full_name']}');
      print('Role: ${profile['role']}');
    } else {
      print('❌ No profile found in users table');
    }
  } catch (error) {
    print('❌ Verification failed: $error');
  }
}

// Main function to test all examples
void main() async {
  // Initialize Supabase first
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  print('🚀 Testing Signup Flow Examples\n');
  
  // Test different approaches
  print('1. AuthService Automatic Sync:');
  signupWithAuthService();
  
  print('\n2. Manual Sync with ProfileService:');
  signupManualSync();
  
  print('\n3. Complete Profile Creation:');
  completeProfileCreation();
  
  print('\n4. Verify Sync Integrity:');
  verifySyncIntegrity();
}

/*
KEY BENEFITS OF THIS APPROACH:

1. ✅ Automatic Sync: AuthService.signUp() handles both tables
2. ✅ ID Consistency: users.id always matches auth.users.id
3. ✅ Backward Compatibility: All existing ProfileService methods work unchanged
4. ✅ Error Handling: Proper cleanup if sync fails
5. ✅ Flexibility: Can use manual approach when needed

IMPORTANT NOTES:

- The users.id field must be UUID type and match auth.users.id
- Consider adding database triggers for additional sync safety
- Test thoroughly with your specific database schema
- Add proper error handling for production use
*/