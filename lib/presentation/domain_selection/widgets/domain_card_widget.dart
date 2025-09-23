import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DomainCardWidget extends StatelessWidget {
  final Map<String, dynamic> domain;
  final bool isSelected;
  final VoidCallback onTap;

  const DomainCardWidget({
    super.key,
    required this.domain,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: domain['icon'] as String,
                    color: isSelected ? Colors.white : colorScheme.primary,
                    size: 6.w,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Domain title
              Text(
                domain['title'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (domain['description'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  domain['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
