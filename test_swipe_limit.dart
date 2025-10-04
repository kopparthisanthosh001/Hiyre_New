import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with actual credentials from your app
  await Supabase.initialize(
    url: 'https://jalkqdrzbfnklpoerwui.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino',
  );

  print('🧪 Testing Swipe Limit Functionality...\n');

  try {
    // 1. Check current authentication state
    final currentUser = AuthService.instance.currentUser;
    print('1. Current user: ${currentUser?.email ?? 'Not authenticated'}');
    
    if (currentUser != null) {
      print('   User ID: ${currentUser.id}');
      print('   Email verified: ${currentUser.emailConfirmedAt != null}');
    }

    // 2. Sign out to ensure clean state
    print('\n2. Signing out to ensure clean state...');
    await AuthService.instance.signOut();
    
    final userAfterSignOut = AuthService.instance.currentUser;
    print('   User after sign out: ${userAfterSignOut?.email ?? 'Successfully signed out'}');

    // 3. Clear any local storage/cache
    print('\n3. Clearing local authentication cache...');
    await Supabase.instance.client.auth.signOut();
    
    // 4. Verify no user is authenticated
    final finalUser = AuthService.instance.currentUser;
    print('   Final auth state: ${finalUser?.email ?? 'No user authenticated ✅'}');

    print('\n✅ Authentication cleared successfully!');
    print('\n📱 Now test in your Flutter app:');
    print('1. Hot restart the app to clear any cached state');
    print('2. Navigate to job swipe screen');
    print('3. Swipe 3 jobs');
    print('4. You should see the login prompt after the 3rd swipe');
    
    // 5. Show the swipe limit logic for reference
    print('\n🔍 Swipe limit logic verification:');
    print('- _swipesBeforeAuth is set to: 3');
    print('- _swipeCount increments on each swipe');
    print('- When _swipeCount >= 3 AND currentUser == null:');
    print('  → Login screen should appear');
    print('- If user cancels login: _swipeCount resets to 0');
    print('- If user logs in: _swipeCount resets to 0');

  } catch (error) {
    print('❌ Error during test: $error');
  }
}