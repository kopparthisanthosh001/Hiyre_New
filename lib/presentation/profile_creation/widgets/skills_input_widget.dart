import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class SkillsInputWidget extends StatefulWidget {
  final List<String> selectedSkills;
  final Function(List<String>) onSkillsChanged;

  const SkillsInputWidget({
    super.key,
    required this.selectedSkills,
    required this.onSkillsChanged,
  });

  @override
  State<SkillsInputWidget> createState() => _SkillsInputWidgetState();
}

class _SkillsInputWidgetState extends State<SkillsInputWidget> {
  final TextEditingController _skillController = TextEditingController();
  final FocusNode _skillFocusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  final List<String> _popularSkills = [
    'Flutter',
    'Dart',
    'React',
    'JavaScript',
    'Python',
    'Java',
    'Swift',
    'Kotlin',
    'Node.js',
    'Express.js',
    'MongoDB',
    'PostgreSQL',
    'MySQL',
    'Firebase',
    'AWS',
    'Azure',
    'Google Cloud',
    'Docker',
    'Kubernetes',
    'Git',
    'HTML',
    'CSS',
    'TypeScript',
    'Angular',
    'Vue.js',
    'React Native',
    'iOS Development',
    'Android Development',
    'Web Development',
    'Mobile Development',
    'UI/UX Design',
    'Figma',
    'Adobe XD',
    'Photoshop',
    'Illustrator',
    'Project Management',
    'Agile',
    'Scrum',
    'Leadership',
    'Communication',
    'Problem Solving',
    'Team Collaboration',
    'Critical Thinking',
    'Data Analysis',
    'Machine Learning',
    'AI',
    'Deep Learning',
    'DevOps',
    'CI/CD',
    'Testing',
    'Quality Assurance',
    'Automation',
    'Digital Marketing',
    'SEO',
    'Content Writing',
    'Social Media Marketing',
    'Sales',
    'Customer Service',
    'Business Development',
    'Strategy',
  ];

  @override
  void initState() {
    super.initState();
    _skillFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _skillController.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_skillFocusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSkillTextChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredSuggestions = _popularSkills.take(10).toList();
        _showSuggestions = true;
      } else {
        _filteredSuggestions = _popularSkills
            .where((skill) =>
                skill.toLowerCase().contains(value.toLowerCase()) &&
                !widget.selectedSkills.contains(skill))
            .take(8)
            .toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty;
      }
    });
  }

  void _addSkill(String skill) {
    if (skill.trim().isNotEmpty &&
        !widget.selectedSkills.contains(skill.trim())) {
      final updatedSkills = [...widget.selectedSkills, skill.trim()];
      widget.onSkillsChanged(updatedSkills);
      _skillController.clear();
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
    }
  }

  void _removeSkill(String skill) {
    final updatedSkills =
        widget.selectedSkills.where((s) => s != skill).toList();
    widget.onSkillsChanged(updatedSkills);
  }

  void _onSubmitted(String value) {
    _addSkill(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills *',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Add your technical and soft skills',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),

        // Skills input field
        TextFormField(
          controller: _skillController,
          focusNode: _skillFocusNode,
          decoration: InputDecoration(
            hintText: 'Type a skill and press Enter',
            suffixIcon: _skillController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _addSkill(_skillController.text),
                    icon: CustomIconWidget(
                      iconName: 'add',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          onChanged: _onSkillTextChanged,
          onFieldSubmitted: _onSubmitted,
          onTap: () {
            if (_skillController.text.isEmpty) {
              setState(() {
                _filteredSuggestions = _popularSkills.take(10).toList();
                _showSuggestions = true;
              });
            }
          },
        ),

        // Suggestions dropdown
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 25.h),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: _filteredSuggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final skill = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => _addSkill(skill),
                );
              },
            ),
          ),

        SizedBox(height: 2.h),

        // Selected skills chips
        if (widget.selectedSkills.isNotEmpty) ...[
          Text(
            'Selected Skills (${widget.selectedSkills.length})',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.selectedSkills
                .map((skill) => _buildSkillChip(skill))
                .toList(),
          ),
        ],

        // Popular skills section
        if (widget.selectedSkills.isEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            'Popular Skills',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _popularSkills
                .take(12)
                .map((skill) => _buildSuggestionChip(skill))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: CustomIconWidget(
              iconName: 'close',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String skill) {
    return GestureDetector(
      onTap: () => _addSkill(skill),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'add',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}