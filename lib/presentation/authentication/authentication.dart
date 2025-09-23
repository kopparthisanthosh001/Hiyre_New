import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart'; // Add this import for responsive extensions
import 'package:fluttertoast/fluttertoast.dart'; // Add this import

import '../../core/app_export.dart';
import '../../core/error_handler.dart'; // Add this import
import '../../services/auth_service.dart'; // ADD THIS LINE
import '../../widgets/custom_icon_widget.dart';
import './widgets/demo_account_button.dart';
import './widgets/email_input_field.dart';
import './widgets/otp_input_field.dart';
import './widgets/resend_timer.dart';
import './widgets/send_otp_button.dart';
import './widgets/social_login_buttons.dart';
import './widgets/verify_otp_button.dart';

enum AuthenticationState {
  emailInput,
  otpVerification,
}

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with TickerProviderStateMixin {
  
  // Add these missing state variables:
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  AuthenticationState _currentState = AuthenticationState.emailInput;
  bool _isDemoLoading = false;
  bool _isSocialLoading = false;
  String? _otpError;
  bool _showResendTimer = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
    );
  }

  // Add missing state variables
  bool _isEmailLoading = false;
  bool _isOtpLoading = false;
  String? _emailError;

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }

    setState(() {
      _isEmailLoading = true;
      _emailError = null;
    });

    try {
      // Simulate OTP sending
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isEmailLoading = false;
        _currentState = AuthenticationState.otpVerification;
        _showResendTimer = true;
      });

      _slideAnimationController.forward();
      HapticFeedback.mediumImpact();
      _showToast('OTP sent to $email');
    } catch (e) {
      setState(() {
        _isEmailLoading = false;
        _emailError = 'Failed to send OTP. Please try again.';
      });
      _showToast('Failed to send OTP', isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() => _otpError = 'Please enter the complete OTP');
      return;
    }

    setState(() {
      _isOtpLoading = true;
      _otpError = null;
    });

    try {
      // Simulate OTP verification
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isOtpLoading = false);

      HapticFeedback.mediumImpact();
      _showToast('Login successful!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/domain-selection');
      }
    } catch (e) {
      setState(() {
        _isOtpLoading = false;
        _otpError = 'Invalid OTP. Please try again.';
      });
      _showToast('Invalid OTP', isError: true);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _showResendTimer = false);
    await _sendOtp();
  }

  Future<void> _loginWithDemo() async {
    setState(() => _isDemoLoading = true);

    // Simulate demo login
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isDemoLoading = false);

    HapticFeedback.mediumImpact();
    _showToast('Demo login successful!');

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/domain-selection');
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isSocialLoading = true);

    // Simulate Google login
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSocialLoading = false);

    HapticFeedback.mediumImpact();
    _showToast('Google login successful!');

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile-creation');
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isSocialLoading = true);

    // Simulate Apple login
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSocialLoading = false);

    HapticFeedback.mediumImpact();
    _showToast('Apple login successful!');

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile-creation');
    }
  }

  void _goToProfileCreation() {
    Navigator.pushNamed(context, '/profile-creation');
  }

  void _goBack() {
    if (_currentState == AuthenticationState.otpVerification) {
      setState(() {
        _currentState = AuthenticationState.emailInput;
        _otpController.clear();
        _otpError = null;
        _showResendTimer = false;
      });
      _slideAnimationController.reverse();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // App Bar
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08, // ~4.w equivalent
                  vertical: screenHeight * 0.02, // ~2.h equivalent
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        width: screenWidth * 0.2, // ~10.w equivalent
                        height: screenWidth * 0.2, // ~10.w equivalent
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'arrow_back_ios',
                            color: colorScheme.onSurface,
                            size: screenWidth * 0.1, // ~5.w equivalent
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _currentState == AuthenticationState.emailInput
                              ? 'Sign In'
                              : 'Verify OTP',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.04, // ~16.sp equivalent
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.2), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.04), // ~4.h equivalent

                      // Logo
                      Container(
                        width: screenWidth * 0.4, // ~20.w equivalent
                        height: screenWidth * 0.4, // ~20.w equivalent
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'H',
                            style: GoogleFonts.inter(
                              fontSize: screenWidth * 0.06, // ~24.sp equivalent
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03), // ~3.h equivalent

                      // Title and Subtitle
                      Text(
                        _currentState == AuthenticationState.emailInput
                            ? 'Welcome to Hiyre'
                            : 'Check your email',
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.05, // ~20.sp equivalent
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: screenHeight * 0.01), // ~1.h equivalent

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.16), // ~8.w equivalent
                        child: Text(
                          _currentState == AuthenticationState.emailInput
                              ? 'Sign in to discover your perfect job matches'
                              : 'We sent a verification code to\n${_emailController.text}',
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.03, // ~12.sp equivalent
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.06), // ~6.h equivalent

                      // Form Content
                      if (_currentState == AuthenticationState.emailInput) ...[
                        // Email Input
                        EmailInputField(
                          controller: _emailController,
                          errorText: _emailError,
                          enabled: !_isEmailLoading,
                          onChanged: (value) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          onSubmitted: _sendOtp,
                        ),

                        SizedBox(height: screenHeight * 0.03), // ~3.h equivalent

                        // Send OTP Button
                        SendOtpButton(
                          onPressed: _sendOtp,
                          isLoading: _isEmailLoading,
                          enabled: _emailController.text.trim().isNotEmpty,
                        ),

                        SizedBox(height: screenHeight * 0.03), // ~3.h equivalent

                        // Demo Account Button
                        DemoAccountButton(
                          onPressed: _loginWithDemo,
                          isLoading: _isDemoLoading,
                        ),

                        SizedBox(height: screenHeight * 0.04), // ~4.h equivalent

                        // Social Login
                        SocialLoginButtons(
                          onGooglePressed: _loginWithGoogle,
                          onApplePressed: _loginWithApple,
                          isLoading: _isSocialLoading,
                        ),
                      ] else ...[
                        // OTP Input
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              OtpInputField(
                                controller: _otpController,
                                errorText: _otpError,
                                enabled: !_isOtpLoading,
                                onChanged: (value) {
                                  if (_otpError != null) {
                                    setState(() => _otpError = null);
                                  }
                                },
                                onCompleted: (value) {
                                  if (value.length == 6) {
                                    _verifyOtp();
                                  }
                                },
                              ),

                              SizedBox(height: screenHeight * 0.03), // ~3.h equivalent

                              // Verify OTP Button
                              VerifyOtpButton(
                                onPressed: _verifyOtp,
                                isLoading: _isOtpLoading,
                                enabled: _otpController.text.length == 6,
                              ),

                              SizedBox(height: screenHeight * 0.03), // ~3.h equivalent

                              // Resend Timer
                              ResendTimer(
                                onResend: _resendOtp,
                                isActive: _showResendTimer,
                                initialSeconds: 60,
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: screenHeight * 0.06), // ~6.h equivalent
                    ],
                  ),
                ),
              ),

              // Bottom Link
              if (_currentState == AuthenticationState.emailInput)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08, // ~4.w equivalent
                    vertical: screenHeight * 0.02, // ~2.h equivalent
                  ),
                  child: GestureDetector(
                    onTap: _goToProfileCreation,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "New user? ",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.03, // ~12.sp equivalent
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        children: [
                          TextSpan(
                            text: "Create Profile",
                            style: GoogleFonts.inter(
                              fontSize: screenWidth * 0.03, // ~12.sp equivalent
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}