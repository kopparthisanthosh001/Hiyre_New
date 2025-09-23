import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String currentSortOption;
  final ValueChanged<String> onSortChanged;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  static const List<Map<String, dynamic>> sortOptions = [
    {
      'key': 'date_desc',
      'label': 'Most Recent',
      'description': 'Latest applications first',
      'icon': 'schedule',
    },
    {
      'key': 'date_asc',
      'label': 'Oldest First',
      'description': 'Earliest applications first',
      'icon': 'history',
    },
    {
      'key': 'match_desc',
      'label': 'Best Match',
      'description': 'Highest match percentage first',
      'icon': 'favorite',
    },
    {
      'key': 'status_priority',
      'label': 'Status Priority',
      'description': 'Interviews and offers first',
      'icon': 'priority_high',
    },
    {
      'key': 'company_name',
      'label': 'Company Name',
      'description': 'Alphabetical by company',
      'icon': 'business',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Sort Applications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 5.w,
                  ),
                  splashRadius: 6.w,
                ),
              ],
            ),
          ),

          // Sort options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: sortOptions.length,
            separatorBuilder: (context, index) => Divider(
              color: colorScheme.outline.withValues(alpha: 0.1),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final option = sortOptions[index];
              final String key = (option['key'] as String?) ?? '';
              final String label = (option['label'] as String?) ?? '';
              final String description =
                  (option['description'] as String?) ?? '';
              final String iconName = (option['icon'] as String?) ?? 'sort';
              final bool isSelected = currentSortOption == key;

              return ListTile(
                onTap: () {
                  onSortChanged(key);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
                title: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: colorScheme.primary,
                        size: 5.w,
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 1.h,
                ),
              );
            },
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String currentSortOption,
    required ValueChanged<String> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSortOption: currentSortOption,
        onSortChanged: onSortChanged,
      ),
    );
  }
}
