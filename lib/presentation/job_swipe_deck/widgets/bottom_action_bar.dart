import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onBookmark;
  final VoidCallback? onMatchExplanation;
  final bool canUndo;

  const BottomActionBar({
    super.key,
    this.onUndo,
    this.onBookmark,
    this.onMatchExplanation,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Undo button
            _buildActionButton(
              context,
              icon: 'undo',
              label: 'Undo',
              color: canUndo
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.3),
              onTap: canUndo
                  ? () {
                      HapticFeedback.lightImpact();
                      onUndo?.call();
                    }
                  : null,
            ),

            // Bookmark button
            _buildActionButton(
              context,
              icon: 'bookmark_border',
              label: 'Save',
              color: colorScheme.secondary,
              onTap: () {
                HapticFeedback.lightImpact();
                onBookmark?.call();
              },
            ),

            // Match explanation button
            _buildActionButton(
              context,
              icon: 'info_outline',
              label: 'Match Info',
              color: AppTheme.infoGoodMatch,
              onTap: () {
                HapticFeedback.lightImpact();
                onMatchExplanation?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
