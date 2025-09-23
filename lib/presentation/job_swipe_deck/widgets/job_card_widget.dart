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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width < 400 ? 88.w : 90.w,
        height: MediaQuery.of(context).size.height < 700 ? 70.h : 78.h,
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
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Company logo
                  Container(
                    width: 12.w,
                    height: 12.w,
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
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Match percentage badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                          size: 16,
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

            // Job details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job title
                    Text(
                      jobData['title'] as String? ?? 'Job Title',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 0.5.h : 1.h),

                    // Company name
                    Text(
                      jobData['companyName'] as String? ?? 'Company Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),

                    // SALARY SECTION - More prominent display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
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
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomIconWidget(
                              iconName: 'currency_rupee',
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salary Range',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  jobData['salary'] as String? ??
                                      'Not disclosed',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),

                    // LOCATION SECTION - More prominent display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
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
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  jobData['location'] as String? ??
                                      'Not specified',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),

                    // EXPERIENCE & WORK MODE
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(2.5.w),
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
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  jobData['experience'] as String? ??
                                      'Not specified',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(2.5.w),
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
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  jobData['workMode'] as String? ??
                                      'Not specified',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),

                    // Match reason - Why this job matches
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
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
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: matchColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'psychology',
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Why this matches you',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: matchColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            matchReason,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 0.8.h : 1.5.h),

                    // Match tier text
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: matchColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        matchText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: matchColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 1.h : 2.h),

                    // Skills chips - condensed view
                    if (jobData['skills'] != null)
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required Skills',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Wrap(
                              spacing: 2.w,
                              runSpacing: 1.h,
                              children:
                                  ((jobData['skills'] as List?)?.take(5) ?? [])
                                      .map<Widget>((skill) => Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.5.w,
                                              vertical: 0.8.h,
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
                                              ),
                                            ),
                                          ))
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 0.5.h : 1.h),

                    // Swipe up hint
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: MediaQuery.of(context).size.height < 700 ? 0.5.h : 1.h),
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
                              size: 20,
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
