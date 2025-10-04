import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    // Start animations
    _animationController.forward();
    
    // Check authentication status after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthenticationStatus();
      }
    });
  }
  
  Future<void> _checkAuthenticationStatus() async {
    try {
      final currentUser = AuthService.instance.currentUser;

      if (currentUser != null) {
        // User is already signed in, check their profile
        final profile = await ProfileService.instance.getUserProfile();

        if (profile != null) {
          // Check if user has selected domains
          final selectedDomains = profile['selected_domains'] as List<dynamic>?;

          if (selectedDomains != null && selectedDomains.isNotEmpty) {
            // User has completed domain selection, check profile completeness
            if (_isProfileComplete(profile)) {
              // Profile is complete, go to job swipe deck
              Navigator.pushReplacementNamed(context, AppRoutes.jobSwipeDeck);
            } else {
              // Profile incomplete, go to profile creation
              Navigator.pushReplacementNamed(context, AppRoutes.profileCreation);
            }
          } else {
            // User hasn't selected domains yet, go to domain selection
            Navigator.pushReplacementNamed(context, AppRoutes.domainSelection);
          }
        } else {
          // No profile found, go to domain selection
          Navigator.pushReplacementNamed(context, AppRoutes.domainSelection);
        }
      } else {
        // User not signed in, go to signup
        Navigator.pushReplacementNamed(context, AppRoutes.authentication);
      }
      // If user is not signed in, stay on splash screen and wait for user action
    } catch (error) {
      print('Error checking authentication status: $error');
      // On error, stay on splash screen
    }
  }

  Future<void> _onSwipeJobsPressed() async {
    // Check authentication status first
    final currentUser = AuthService.instance.currentUser;
    
    if (currentUser == null) {
      // User not authenticated - go to signup
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.authentication,
      );
      return;
    }
    
    // User is authenticated - check if they have completed domain selection
    try {
      final profile = await ProfileService.instance.getUserProfile();
      
      if (profile != null && profile['selected_domains'] != null && 
          (profile['selected_domains'] as List).isNotEmpty) {
        // User has selected domains - check if profile is complete
        if (_isProfileComplete(profile)) {
          // Profile complete - go to job swipe deck
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.jobSwipeDeck,
          );
        } else {
          // Profile incomplete - go to profile creation
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.profileCreation,
          );
        }
      } else {
        // User hasn't selected domains yet - go to domain selection
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.domainSelection,
        );
      }
    } catch (e) {
      print('Error checking user profile: $e');
      // On error, go to domain selection as fallback
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.domainSelection,
      );
    }
  }
  
  bool _isProfileComplete(Map<String, dynamic> profile) {
    // Check if essential profile fields are filled
    return profile['full_name'] != null &&
           profile['full_name'].toString().isNotEmpty &&
           profile['email'] != null &&
           profile['email'].toString().isNotEmpty &&
           profile['phone'] != null &&
           profile['phone'].toString().isNotEmpty &&
           profile['location'] != null &&
           profile['location'].toString().isNotEmpty;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CustomIconWidget(
                      iconName: 'work_outline',
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Welcome to Hiyre',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Find your perfect job match. Swipe right on opportunities that fit your skills and career goals.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // CTA Button Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ElevatedButton(
                        onPressed: _onSwipeJobsPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Swipe Jobs',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}