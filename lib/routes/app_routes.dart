import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication/authentication.dart';
import '../presentation/authentication/job_seeker_login_screen.dart';
import '../presentation/authentication/signup_with_resume_screen.dart';
import '../presentation/profile_creation/profile_creation.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/job_swipe_deck/job_swipe_deck.dart';
import '../presentation/applied_jobs/applied_jobs.dart';
import '../presentation/domain_selection/domain_selection.dart';
import '../presentation/resume_upload/resume_upload_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String authentication = '/authentication';
  static const String appliedJobs = '/applied-jobs';
  static const String splash = '/splash';
  static const String profileCreation = '/profile-creation';
  static const String profile = '/profile';
  static const String jobSwipeDeck = '/job-swipe-deck';
  static const String domainSelection = '/domain-selection';
  static const String resumeUpload = '/resume-upload';
  static const String jobSeekerLogin = '/job-seeker-login';
  static const String signupWithResume = '/signup-with-resume';

  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (context) => const SplashScreen(),
      authentication: (context) => const Authentication(),
      appliedJobs: (context) => const AppliedJobs(),
      splash: (context) => const SplashScreen(),
      profileCreation: (context) => const ProfileCreation(),
      profile: (context) => const ProfileScreen(),
      jobSwipeDeck: (context) => const JobSwipeDeck(),
      '/domain-selection': (context) => const DomainSelection(),
      resumeUpload: (context) => const ResumeUploadScreen(),
      jobSeekerLogin: (context) => const JobSeekerLoginScreen(),
      signupWithResume: (context) => const SignupWithResumeScreen(),
    };
  }
}
