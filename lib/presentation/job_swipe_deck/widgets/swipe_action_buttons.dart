import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onApply;
  final bool isEnabled;

  const SwipeActionButtons({
    super.key,
    required this.onSkip,
    required this.onApply,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 400 ? 6.w : 8.w, 
        vertical: MediaQuery.of(context).size.height < 700 ? 0.8.h : (MediaQuery.of(context).size.height > 600 ? 2.h : 1.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip button
          GestureDetector(
            onTap: isEnabled
                ? () {
                    HapticFeedback.lightImpact();
                    onSkip();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width < 400 ? 10.w : (MediaQuery.of(context).size.height < 700 ? 12.w : 15.w),
              height: MediaQuery.of(context).size.width < 400 ? 10.w : (MediaQuery.of(context).size.height < 700 ? 12.w : 15.w),
              decoration: BoxDecoration(
                color: isEnabled
                    ? colorScheme.error.withValues(alpha: 0.1)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEnabled
                      ? colorScheme.error.withValues(alpha: 0.3)
                      : colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: colorScheme.error.withValues(alpha: 0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'close',
                  color: isEnabled
                      ? colorScheme.error
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),
            ),
          ),

          // Apply button
          GestureDetector(
            onTap: isEnabled
                ? () {
                    HapticFeedback.lightImpact();
                    onApply();
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width < 400 ? 12.w : (MediaQuery.of(context).size.height < 700 ? 15.w : 18.w),
              height: MediaQuery.of(context).size.width < 400 ? 12.w : (MediaQuery.of(context).size.height < 700 ? 15.w : 18.w),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppTheme.successGreatMatch
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color:
                              AppTheme.successGreatMatch.withValues(alpha: 0.3),
                          offset: const Offset(0, 6),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'favorite',
                  color: isEnabled
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
