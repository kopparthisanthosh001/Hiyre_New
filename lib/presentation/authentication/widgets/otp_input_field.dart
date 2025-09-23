import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const OtpInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 6.h,
      textStyle: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary,
          width: 2.0,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error,
          width: 1.0,
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter OTP',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 1.h),
          Pinput(
            controller: controller,
            length: 6,
            enabled: enabled,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            errorPinTheme: errorText != null ? errorPinTheme : null,
            onCompleted: onCompleted,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            cursor: Container(
              width: 1,
              height: 3.h,
              color: colorScheme.primary,
            ),
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            animationDuration: const Duration(milliseconds: 200),
            animationCurve: Curves.easeInOut,
            enableSuggestions: true,
            isCursorAnimationEnabled: true,
            showCursor: true,
            autofocus: true,
          ),
          if (errorText != null) ...[
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Text(
                errorText!,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}