import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BottomActionBarWidget extends StatelessWidget {
  final int selectedCount;
  final bool isLoading;
  final VoidCallback onContinue;

  const BottomActionBarWidget({
    super.key,
    required this.selectedCount,
    required this.isLoading,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSelection = selectedCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selection count badge
              if (hasSelection)
                Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: colorScheme.primary,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '$selectedCount ${selectedCount == 1 ? 'industry' : 'industries'} selected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: hasSelection && !isLoading
                      ? () {
                          HapticFeedback.mediumImpact();
                          onContinue();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSelection
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.12),
                    foregroundColor: hasSelection
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          hasSelection ? 'Continue' : 'Select industries',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasSelection
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface.withValues(alpha: 0.38),
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
