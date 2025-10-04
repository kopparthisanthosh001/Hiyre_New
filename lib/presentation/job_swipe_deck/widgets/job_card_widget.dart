import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JobCardWidget extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final VoidCallback? onTap;

  const JobCardWidget({
    super.key,
    required this.jobData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final matchPercentage =
        (jobData['matchPercentage'] as num?)?.toDouble() ?? 0.0;
    final matchColor = AppTheme.getMatchTierColor(matchPercentage);
    final matchText = AppTheme.getMatchTierText(matchPercentage);
    final matchReason =
        jobData['matchReason'] as String? ?? jobData['match_reason'] as String? ?? 'Good match for your profile';

    // Get top skills from job data
    final topSkills = (jobData['topSkills'] as List?)?.cast<String>() ??
        (jobData['skills'] as List?)?.cast<String>().take(3).toList() ??
        [];

    // Determine if this is a small screen
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth < 400 ? 88.w : 90.w,
        height: isSmallScreen ? 68.h : 75.h, // Reduced height to prevent overflow
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          // Changed to green color theme as requested
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade100.withValues(alpha: 0.6),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with company logo and match badge
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 3.w : 4.w),
              child: Row(
                children: [
                  // Company logo
                  Container(
                    width: isSmallScreen ? 10.w : 12.w,
                    height: isSmallScreen ? 10.w : 12.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200.withValues(alpha: 0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageWidget(
                        imageUrl: jobData['companyLogo'] as String? ?? '',
                        width: isSmallScreen ? 10.w : 12.w,
                        height: isSmallScreen ? 10.w : 12.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Match percentage badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: matchColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${matchPercentage.toInt()}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Job details - Use Flexible instead of Expanded to prevent overflow
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3.w : 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job title
                    Text(
                      jobData['title'] as String? ?? 'Job Title',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                        fontSize: isSmallScreen ? 18 : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 0.3.h : 0.5.h),

                    // Company name
                    Text(
                      jobData['companyName'] as String? ?? 'Company Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 0.8.h : 1.5.h),

                    // SALARY SECTION - Compact design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 2.5.w : 3.w),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 1.w : 1.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomIconWidget(
                              iconName: 'currency_rupee',
                              color: Colors.white,
                              size: isSmallScreen ? 16 : 20,
                            ),
                          ),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salary Range',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 11 : null,
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  jobData['salary'] as String? ??
                                      'Not disclosed',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 12 : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 0.8.h : 1.5.h),

                    // LOCATION SECTION - Compact design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 2.5.w : 3.w),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 1.w : 1.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white,
                              size: isSmallScreen ? 16 : 20,
                            ),
                          ),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 11 : null,
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  jobData['location'] as String? ??
                                      'Not specified',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 12 : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 0.8.h : 1.5.h),

                    // Experience and Work Mode - Compact row layout
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 2.w : 2.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Experience',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 10 : null,
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  jobData['experience'] as String? ??
                                      'Not specified',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 11 : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 2.w : 2.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Work Mode',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 10 : null,
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  jobData['workMode'] as String? ??
                                      jobData['work_mode'] as String? ??
                                      'remote',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 11 : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 0.8.h : 1.5.h),

                    // Match reason - Compact design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 2.5.w : 3.w),
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: matchColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isSmallScreen ? 0.8.w : 1.w),
                                decoration: BoxDecoration(
                                  color: matchColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'psychology',
                                  color: Colors.white,
                                  size: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  'Why this matches you',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: matchColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 11 : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            matchReason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: matchColor,
                              fontSize: isSmallScreen ? 10 : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Match tier badge - Compact
                    SizedBox(height: isSmallScreen ? 0.5.h : 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: matchColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        matchText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: matchColor,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 10 : null,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 0.8.h : 1.5.h),

                    // Skills chips - condensed view (only show on larger screens or limit to 3)
                    if (jobData['skills'] != null && (!isSmallScreen || topSkills.isNotEmpty))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Skills',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 11 : null,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Wrap(
                            spacing: 1.5.w,
                            runSpacing: 0.5.h,
                            children:
                                ((jobData['skills'] as List?)?.take(isSmallScreen ? 3 : 5) ?? [])
                                    .map<Widget>((skill) => Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.green.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            skill.toString(),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: isSmallScreen ? 9 : null,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 0.5.h : 1.h),

                    // Swipe up hint - Only show on larger screens
                    if (!isSmallScreen)
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade200.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'keyboard_arrow_up',
                                color: Colors.green.shade700,
                                size: 18,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Swipe up for more details',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Bottom padding
                    SizedBox(height: isSmallScreen ? 0.5.h : 1.h),
                  ],
                ),
              ),
            ),

            // Bottom padding
            SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),
          ],
        ),
      ),
    );
  }
}
