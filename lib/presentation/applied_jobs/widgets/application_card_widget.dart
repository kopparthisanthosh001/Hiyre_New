import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ApplicationCardWidget extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;
  final VoidCallback? onViewDetails;
  final VoidCallback? onContactEmployer;

  const ApplicationCardWidget({
    super.key,
    required this.application,
    this.onTap,
    this.onWithdraw,
    this.onViewDetails,
    this.onContactEmployer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String status = (application['status'] as String?) ?? 'Applied';
    final String jobTitle =
        (application['jobTitle'] as String?) ?? 'Unknown Position';
    final String companyName =
        (application['companyName'] as String?) ?? 'Unknown Company';
    final String companyLogo = (application['companyLogo'] as String?) ?? '';
    final DateTime appliedDate =
        application['appliedDate'] as DateTime? ?? DateTime.now();
    final double matchPercentage =
        (application['matchPercentage'] as num?)?.toDouble() ?? 0.0;
    final int applicationNumber =
        (application['applicationNumber'] as int?) ?? 1;
    final int totalApplications =
        (application['totalApplications'] as int?) ?? 100;
    final String location = (application['location'] as String?) ?? '';
    final String workMode = (application['workMode'] as String?) ?? '';

    return Slidable(
      key: ValueKey(application['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onViewDetails?.call(),
            backgroundColor: AppTheme.infoGoodMatch,
            foregroundColor: Colors.white,
            icon: Icons.visibility_outlined,
            label: 'View',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onContactEmployer?.call(),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.message_outlined,
            label: 'Contact',
            borderRadius: BorderRadius.circular(12),
          ),
          if (status == 'Applied' || status == 'Under Review')
            SlidableAction(
              onPressed: (_) => onWithdraw?.call(),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon: Icons.cancel_outlined,
              label: 'Withdraw',
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company logo and status
              Row(
                children: [
                  // Company logo
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: companyLogo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageWidget(
                              imageUrl: companyLogo,
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: CustomIconWidget(
                              iconName: 'business',
                              color: colorScheme.primary,
                              size: 6.w,
                            ),
                          ),
                  ),
                  SizedBox(width: 3.w),
                  // Job title and company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(status, colorScheme),
                ],
              ),

              SizedBox(height: 3.h),

              // Match percentage and application stats
              Row(
                children: [
                  // Match percentage
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.getMatchTierColor(matchPercentage)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'favorite',
                          color: AppTheme.getMatchTierColor(matchPercentage),
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${matchPercentage.toInt()}% Match',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.getMatchTierColor(matchPercentage),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Application number
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$applicationNumber/$totalApplications',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Applied date
                  Text(
                    _formatDate(appliedDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              if (location.isNotEmpty || workMode.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (location.isNotEmpty) ...[
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (location.isNotEmpty && workMode.isNotEmpty) ...[
                      SizedBox(width: 3.w),
                      Container(
                        width: 1,
                        height: 3.w,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      SizedBox(width: 3.w),
                    ],
                    if (workMode.isNotEmpty) ...[
                      CustomIconWidget(
                        iconName: 'work_outline',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        workMode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color badgeColor;
    Color textColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'applied':
        badgeColor = AppTheme.infoGoodMatch;
        textColor = Colors.white;
        iconData = Icons.send_outlined;
        break;
      case 'under review':
        badgeColor = AppTheme.warningOkayMatch;
        textColor = Colors.white;
        iconData = Icons.hourglass_empty_outlined;
        break;
      case 'interview scheduled':
        badgeColor = AppTheme.successGreatMatch;
        textColor = Colors.white;
        iconData = Icons.event_outlined;
        break;
      case 'rejected':
        badgeColor = AppTheme.error;
        textColor = Colors.white;
        iconData = Icons.close_outlined;
        break;
      case 'offer':
        badgeColor = AppTheme.successGreatMatch;
        textColor = Colors.white;
        iconData = Icons.celebration_outlined;
        break;
      default:
        badgeColor = AppTheme.neutralLowMatch;
        textColor = Colors.white;
        iconData = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconData.codePoint.toString(),
            color: textColor,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            status,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
