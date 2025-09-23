import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_bottom_bar.dart';

class WorkExperienceScreen extends StatefulWidget {
  const WorkExperienceScreen({super.key});

  @override
  State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  
  String? _selectedEmploymentType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _currentlyWorking = false;
  
  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
    'Internship',
  ];
  
  final List<Map<String, dynamic>> _experiences = [];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }

  void _addExperience() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _experiences.add({
          'jobTitle': _jobTitleController.text,
          'companyName': _companyNameController.text,
          'location': _locationController.text,
          'employmentType': _selectedEmploymentType,
          'startDate': _startDate,
          'endDate': _currentlyWorking ? null : _endDate,
          'currentlyWorking': _currentlyWorking,
          'responsibilities': _responsibilitiesController.text,
        });
      });
      _clearForm();
    }
  }
  
  void _clearForm() {
    _jobTitleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _responsibilitiesController.clear();
    setState(() {
      _selectedEmploymentType = null;
      _startDate = null;
      _endDate = null;
      _currentlyWorking = false;
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _goNext() {
    Navigator.pushNamed(context, '/profile-creation/education');
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: _goBack,
        ),
        title: Text(
          'Work Experience',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title
                    _buildInputField(
                      label: 'Job Title',
                      controller: _jobTitleController,
                      hintText: 'e.g., Software Engineer',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Job title is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Company Name
                    _buildInputField(
                      label: 'Company Name',
                      controller: _companyNameController,
                      hintText: 'e.g., Tech Solutions Inc.',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Company name is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Location
                    _buildInputField(
                      label: 'Location',
                      controller: _locationController,
                      hintText: 'e.g., San Francisco, CA',
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Employment Type
                    _buildEmploymentTypeDropdown(),
                    
                    SizedBox(height: 3.h),
                    
                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Start Date',
                            date: _startDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildDateField(
                            label: 'End Date',
                            date: _endDate,
                            onTap: _currentlyWorking ? null : () => _selectDate(context, false),
                            enabled: !_currentlyWorking,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 2.h),
                    
                    // Currently Working Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _currentlyWorking,
                          onChanged: (value) {
                            setState(() {
                              _currentlyWorking = value ?? false;
                              if (_currentlyWorking) {
                                _endDate = null;
                              }
                            });
                          },
                          activeColor: Color(0xFF4CAF50),
                        ),
                        Text(
                          'I currently work here',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Responsibilities/Achievements
                    _buildTextAreaField(
                      label: 'Responsibilities/Achievements',
                      controller: _responsibilitiesController,
                      hintText: 'Describe your role and accomplishments',
                      maxLines: 5,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Add Another Experience Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addExperience,
                        icon: Icon(Icons.add, color: Color(0xFF4CAF50)),
                        label: Text(
                          'Add another experience',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF4CAF50), style: BorderStyle.solid, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Experience List
                    if (_experiences.isNotEmpty) ..[
                      Text(
                        'Added Experiences',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ..._experiences.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exp = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      exp['jobTitle'],
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _experiences.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                exp['companyName'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (exp['location']?.isNotEmpty ?? false)
                                Text(
                                  exp['location'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Navigation
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _goNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Profile tab
      ),
    );
  }
  
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4CAF50)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4CAF50)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmploymentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employment Type',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedEmploymentType,
          decoration: InputDecoration(
            hintText: 'Select Type',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4CAF50)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
          items: _employmentTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEmploymentType = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[50] : Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null 
                    ? '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
                    : '-------',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: date != null ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}