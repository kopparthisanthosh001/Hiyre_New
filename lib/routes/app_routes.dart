import 'package:flutter/material.dart';
import '../presentation/authentication/authentication.dart';
import '../presentation/applied_jobs/applied_jobs.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/profile_creation/profile_creation.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/job_swipe_deck/job_swipe_deck.dart';
import '../presentation/domain_selection/domain_selection.dart';
import '../presentation/authentication/job_seeker_login_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String authentication = '/authentication';
  static const String appliedJobs = '/applied-jobs';
  static const String splash = '/splash-screen';
  static const String profileCreation = '/profile-creation';
  static const String profile = '/profile';
  static const String jobSwipeDeck = '/job-swipe-deck';
  static const String domainSelection = '/domain-selection';
  static const String jobSeekerLogin = '/job-seeker-login';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    authentication: (context) => const Authentication(),
    appliedJobs: (context) => const AppliedJobs(),
    splash: (context) => const SplashScreen(),
    profileCreation: (context) => const ProfileCreation(),
    profile: (context) => const ProfileScreen(),
    jobSwipeDeck: (context) => const JobSwipeDeck(),
    domainSelection: (context) => const DomainSelection(),
    jobSeekerLogin: (context) => const JobSeekerLoginScreen(),
    // TODO: Add your other routes here
  };
}
