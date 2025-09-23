import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ExperienceItem {
  String jobTitle;
  String company;
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrentJob;
  String description;

  ExperienceItem({
    this.jobTitle = '',
    this.company = '',
    this.startDate,
    this.endDate,
    this.isCurrentJob = false,
    this.description = '',
  });

  String get duration {
    if (startDate == null) return '';

    final end = isCurrentJob ? DateTime.now() : (endDate ?? DateTime.now());
    final difference = end.difference(startDate!);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0 && months > 0) {
      return '$years yr $months mo';
    } else if (years > 0) {
      return '$years yr';
    } else if (months > 0) {
      return '$months mo';
    } else {
      return '< 1 mo';
    }
  }

  bool get isValid {
    return jobTitle.isNotEmpty &&
        company.isNotEmpty &&
        startDate != null &&
        (isCurrentJob || endDate != null);
  }
}

class ExperienceSectionWidget extends StatefulWidget {
  final List<ExperienceItem> experiences;
  final Function(List<ExperienceItem>) onExperiencesChanged;

  const ExperienceSectionWidget({
    super.key,
    required this.experiences,
    required this.onExperiencesChanged,
  });

  @override
  State<ExperienceSectionWidget> createState() =>
      _ExperienceSectionWidgetState();
}

class _ExperienceSectionWidgetState extends State<ExperienceSectionWidget> {
  void _addExperience() {
    final updatedExperiences = [...widget.experiences, ExperienceItem()];
    widget.onExperiencesChanged(updatedExperiences);
  }

  void _removeExperience(int index) {
    final updatedExperiences = [...widget.experiences];
    updatedExperiences.removeAt(index);
    widget.onExperiencesChanged(updatedExperiences);
  }

  void _updateExperience(int index, ExperienceItem experience) {
    final updatedExperiences = [...widget.experiences];
    updatedExperiences[index] = experience;
    widget.onExperiencesChanged(updatedExperiences);
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work Experience',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _addExperience,
              icon: CustomIconWidget(
                iconName: 'add',
                size: 18,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text(
                'Add',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          'Add your work experience to showcase your background',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),
        if (widget.experiences.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.experiences.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) => _buildExperienceCard(index),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'work_outline',
            size: 48,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.4),
          ),
          SizedBox(height: 2.h),
          Text(
            'No work experience added yet',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add your work experience to help employers understand your background',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: _addExperience,
            icon: CustomIconWidget(
              iconName: 'add',
              size: 18,
              color: Colors.white,
            ),
            label: Text('Add Experience'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(int index) {
    final experience = widget.experiences[index];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience ${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => _removeExperience(index),
                icon: CustomIconWidget(
                  iconName: 'delete_outline',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Job Title
          TextFormField(
            initialValue: experience.jobTitle,
            decoration: const InputDecoration(
              labelText: 'Job Title *',
              hintText: 'e.g. Software Developer',
            ),
            onChanged: (value) {
              experience.jobTitle = value;
              _updateExperience(index, experience);
            },
          ),
          SizedBox(height: 2.h),

          // Company
          TextFormField(
            initialValue: experience.company,
            decoration: const InputDecoration(
              labelText: 'Company *',
              hintText: 'e.g. Google',
            ),
            onChanged: (value) {
              experience.company = value;
              _updateExperience(index, experience);
            },
          ),
          SizedBox(height: 2.h),

          // Date Range
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date =
                        await _selectDate(context, experience.startDate);
                    if (date != null) {
                      experience.startDate = date;
                      _updateExperience(index, experience);
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          experience.startDate != null
                              ? _formatDate(experience.startDate)
                              : 'Start Date *',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: experience.startDate != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          size: 18,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: experience.isCurrentJob
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Present',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          final date =
                              await _selectDate(context, experience.endDate);
                          if (date != null) {
                            experience.endDate = date;
                            _updateExperience(index, experience);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                experience.endDate != null
                                    ? _formatDate(experience.endDate)
                                    : 'End Date *',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: experience.endDate != null
                                      ? AppTheme
                                          .lightTheme.colorScheme.onSurface
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                              CustomIconWidget(
                                iconName: 'calendar_today',
                                size: 18,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Current Job Checkbox
          Row(
            children: [
              Checkbox(
                value: experience.isCurrentJob,
                onChanged: (value) {
                  experience.isCurrentJob = value ?? false;
                  if (experience.isCurrentJob) {
                    experience.endDate = null;
                  }
                  _updateExperience(index, experience);
                },
              ),
              Text(
                'I currently work here',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Duration Display
          if (experience.startDate != null)
            Container(
              margin: EdgeInsets.only(top: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Duration: ${experience.duration}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}