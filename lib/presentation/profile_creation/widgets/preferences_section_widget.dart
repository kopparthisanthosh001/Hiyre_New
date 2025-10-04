import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

enum WorkMode { remote, hybrid, onsite }

class PreferencesSectionWidget extends StatefulWidget {
  final List<String> preferredRoles;
  final List<String> preferredLocations;
  final Set<WorkMode> workModes;
  final double minSalary;
  final double maxSalary;
  final bool remoteWork;
  final Function(List<String>) onPreferredRolesChanged;
  final Function(List<String>) onPreferredLocationsChanged;
  final Function(Set<WorkMode>) onWorkModesChanged;
  final Function(double, double) onSalaryRangeChanged;
  final Function(bool) onRemoteWorkChanged;

  const PreferencesSectionWidget({
    super.key,
    required this.preferredRoles,
    required this.preferredLocations,
    required this.workModes,
    required this.minSalary,
    required this.maxSalary,
    required this.remoteWork,
    required this.onPreferredRolesChanged,
    required this.onPreferredLocationsChanged,
    required this.onWorkModesChanged,
    required this.onSalaryRangeChanged,
    required this.onRemoteWorkChanged,
  });

  @override
  State<PreferencesSectionWidget> createState() =>
      _PreferencesSectionWidgetState();
}

class _PreferencesSectionWidgetState extends State<PreferencesSectionWidget> {
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> _popularRoles = [
    'Software Developer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Mobile Developer',
    'Flutter Developer',
    'React Developer',
    'Node.js Developer',
    'UI/UX Designer',
    'Product Designer',
    'Graphic Designer',
    'Web Designer',
    'Product Manager',
    'Project Manager',
    'Business Analyst',
    'Data Analyst',
    'Data Scientist',
    'Machine Learning Engineer',
    'DevOps Engineer',
    'QA Engineer',
    'Digital Marketing Manager',
    'Content Writer',
    'SEO Specialist',
    'Social Media Manager',
    'Sales Executive',
    'Business Development Manager',
    'Customer Success Manager',
    'HR Manager',
    'Finance Manager',
    'Operations Manager',
    'Marketing Manager',
  ];

  final List<String> _majorCities = [
    'Mumbai',
    'Delhi NCR',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Pune',
    'Kolkata',
  ];

  String _formatSalary(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  void _showRoleSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildSelectionSheet(
          title: 'Select Preferred Roles',
          items: _popularRoles,
          selectedItems: widget.preferredRoles,
          onSelectionChanged: widget.onPreferredRolesChanged,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showLocationSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildSelectionSheet(
          title: 'Select Preferred Locations',
          items: _majorCities,
          selectedItems: widget.preferredLocations,
          onSelectionChanged: widget.onPreferredLocationsChanged,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Widget _buildSelectionSheet({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    required ScrollController scrollController,
  }) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        // Create a local copy of selected items for immediate UI updates
        List<String> localSelectedItems = List.from(selectedItems);
        
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = localSelectedItems.contains(item);

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: InkWell(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              localSelectedItems.remove(item);
                            } else {
                              localSelectedItems.add(item);
                            }
                            // Update parent state immediately
                            onSelectionChanged(List.from(localSelectedItems));
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.lightTheme.colorScheme.primary
                                        : AppTheme.lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.lightTheme.colorScheme.primary,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Preferences',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Help us find the perfect job matches for you',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 3.h),

        // Preferred Roles
        Text(
          'Preferred Roles *',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showRoleSelection,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                Expanded(
                  child: Text(
                    widget.preferredRoles.isEmpty
                        ? 'Select preferred roles'
                        : widget.preferredRoles.length == 1
                            ? widget.preferredRoles.first
                            : '${widget.preferredRoles.length} roles selected',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: widget.preferredRoles.isEmpty
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6)
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        if (widget.preferredRoles.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.preferredRoles
                .map((role) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        role,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],

        SizedBox(height: 3.h),

        // Work Mode Selection
        Text(
          'Work Mode *',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: WorkMode.values.map((mode) {
              final isSelected = widget.workModes.contains(mode);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final updatedModes = Set<WorkMode>.from(widget.workModes);
                    if (isSelected) {
                      updatedModes.remove(mode);
                    } else {
                      updatedModes.add(mode);
                    }
                    widget.onWorkModesChanged(updatedModes);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        mode.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 3.h),

        // Preferred Locations
        Text(
          'Preferred Locations',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showLocationSelection,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                Expanded(
                  child: Text(
                    widget.preferredLocations.isEmpty
                        ? 'Select preferred locations'
                        : widget.preferredLocations.length == 1
                            ? widget.preferredLocations.first
                            : '${widget.preferredLocations.length} locations selected',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: widget.preferredLocations.isEmpty
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6)
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        if (widget.preferredLocations.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.preferredLocations
                .map((location) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],

        SizedBox(height: 3.h),

        // Salary Expectations
        Text(
          'Salary Expectations (Annual)',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min: ${_formatSalary(widget.minSalary)}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Max: ${_formatSalary(widget.maxSalary)}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              RangeSlider(
                values: RangeValues(widget.minSalary, widget.maxSalary),
                min: 100000,
                max: 10000000,
                divisions: 99,
                labels: RangeLabels(
                  _formatSalary(widget.minSalary),
                  _formatSalary(widget.maxSalary),
                ),
                onChanged: (values) {
                  widget.onSalaryRangeChanged(values.start, values.end);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}