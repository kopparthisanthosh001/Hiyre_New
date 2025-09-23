import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';

class JobSeekerLoginScreen extends StatefulWidget {
  const JobSeekerLoginScreen({super.key});

  @override
  State<JobSeekerLoginScreen> createState() => _JobSeekerLoginScreenState();
}

class _JobSeekerLoginScreenState extends State<JobSeekerLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showToast('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      HapticFeedback.lightImpact();
      _showToast('Login successful!');

      if (mounted) {
        // Navigate back to job swipe deck or profile creation based on profile status
        Navigator.pop(context, true); // Return true to indicate successful login
      }
    } catch (error) {
      _showToast('Login failed: ${error.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final success = await AuthService.instance.signInWithGoogle();
      
      if (success) {
        HapticFeedback.lightImpact();
        _showToast('Google sign in successful!');
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showToast('Google sign in cancelled');
      }
    } catch (error) {
      _showToast('Google sign in failed: ${error.toString()}');
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showToast('Please enter your email address first');
      return;
    }

    try {
      await AuthService.instance.resetPassword(email: _emailController.text.trim());
      _showToast('Password reset email sent! Check your inbox.');
    } catch (error) {
      _showToast('Failed to send reset email: ${error.toString()}');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/profile-creation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Primary green
              Color(0xFF388E3C), // Darker green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and title
                      Column(
                        children: [
                          Text(
                            'Hiyre',
                            style: GoogleFonts.inter(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Find your perfect match.',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.9),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.9),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 6.h),
                      
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107), // Secondary yellow
                            foregroundColor: const Color(0xFF212121),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF212121),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Sign up link
                      GestureDetector(
                        onTap: _navigateToSignUp,
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFC107),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'OR',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Google sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF424242),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isGoogleLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF424242),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google icon using Image.network
                                    Image.network(
                                      'https://developers.google.com/identity/images/g-logo.png',
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.g_mobiledata,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Sign in with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
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

// Custom painter for Google icon
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Google "G" icon paths
    final path1 = Path();
    path1.moveTo(size.width * 0.5, size.height * 0.2);
    path1.cubicTo(size.width * 0.7, size.height * 0.2, size.width * 0.85, size.height * 0.35, size.width * 0.85, size.height * 0.5);
    path1.lineTo(size.width * 0.5, size.height * 0.5);
    path1.lineTo(size.width * 0.5, size.height * 0.4);
    path1.lineTo(size.width * 0.75, size.height * 0.4);
    
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(path1, paint);
    
    // Red section
    final path2 = Path();
    path2.moveTo(size.width * 0.5, size.height * 0.2);
    path2.cubicTo(size.width * 0.3, size.height * 0.2, size.width * 0.15, size.height * 0.35, size.width * 0.15, size.height * 0.5);
    path2.cubicTo(size.width * 0.15, size.height * 0.65, size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.8);
    path2.lineTo(size.width * 0.5, size.height * 0.5);
    path2.close();
    
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(path2, paint);
    
    // Yellow section
    final path3 = Path();
    path3.moveTo(size.width * 0.5, size.height * 0.8);
    path3.cubicTo(size.width * 0.7, size.height * 0.8, size.width * 0.85, size.height * 0.65, size.width * 0.85, size.height * 0.5);
    path3.lineTo(size.width * 0.5, size.height * 0.5);
    path3.close();
    
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(path3, paint);
    
    // Green section
    final path4 = Path();
    path4.moveTo(size.width * 0.15, size.height * 0.5);
    path4.cubicTo(size.width * 0.15, size.height * 0.35, size.width * 0.25, size.height * 0.25, size.width * 0.4, size.height * 0.22);
    path4.lineTo(size.width * 0.5, size.height * 0.5);
    path4.close();
    
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}