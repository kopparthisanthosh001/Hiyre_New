import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SelectedDomainsChipsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> selectedDomains;
  final Function(Map<String, dynamic>) onRemove;

  const SelectedDomainsChipsWidget({
    super.key,
    required this.selectedDomains,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (selectedDomains.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: selectedDomains.map((domain) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 3.w, top: 1.h, bottom: 1.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: domain['icon'] as String,
                          color: colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          domain['title'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRemove(domain);
                    },
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      margin: EdgeInsets.only(left: 1.w, right: 1.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: colorScheme.primary,
                        size: 3.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
