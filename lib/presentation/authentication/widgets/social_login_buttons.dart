import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  thickness: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  context: context,
                  colorScheme: colorScheme,
                  onPressed: isLoading ? null : onGooglePressed,
                  icon: 'g_translate',
                  label: 'Google',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSocialButton(
                  context: context,
                  colorScheme: colorScheme,
                  onPressed: isLoading ? null : onApplePressed,
                  icon: 'apple',
                  label: 'Apple',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required ColorScheme colorScheme,
    required VoidCallback? onPressed,
    required String icon,
    required String label,
  }) {
    return SizedBox(
      height: 6.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: CustomIconWidget(
          iconName: icon,
          color: onPressed != null
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.38),
          size: 5.w,
        ),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: onPressed != null
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.38),
            letterSpacing: 0.1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(
            color: onPressed != null
                ? colorScheme.outline.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.12),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}