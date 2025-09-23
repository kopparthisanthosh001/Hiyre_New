import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ApplicationsHeaderWidget extends StatelessWidget {
  final int totalApplications;
  final VoidCallback? onSortPressed;
  final VoidCallback? onSearchPressed;

  const ApplicationsHeaderWidget({
    super.key,
    required this.totalApplications,
    this.onSortPressed,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Applications count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Applications',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$totalApplications application${totalApplications != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Search button
              IconButton(
                onPressed: onSearchPressed,
                icon: CustomIconWidget(
                  iconName: 'search',
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 5.w,
                ),
                tooltip: 'Search applications',
                splashRadius: 6.w,
              ),

              SizedBox(width: 1.w),

              // Sort button
              IconButton(
                onPressed: onSortPressed,
                icon: CustomIconWidget(
                  iconName: 'sort',
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 5.w,
                ),
                tooltip: 'Sort applications',
                splashRadius: 6.w,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
