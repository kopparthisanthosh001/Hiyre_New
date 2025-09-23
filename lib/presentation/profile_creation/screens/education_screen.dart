import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_bottom_bar.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _degreeController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _institutionController = TextEditingController();
  final _locationController = TextEditingController();
  final _achievementsController = TextEditingController();
  
  String? _graduationYear;
  
  final List<String> _years = List.generate(
    DateTime.now().year - 1950 + 10,
    (index) => (1950 + index).toString(),
  ).reversed.toList();
  
  final List<Map<String, dynamic>> _educations = [];

  @override
  void dispose() {
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _institutionController.dispose();
    _locationController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }

  void _addEducation() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _educations.add({
          'degree': _degreeController.text,
          'fieldOfStudy': _fieldOfStudyController.text,
          'institution': _institutionController.text,
          'location': _locationController.text,
          'graduationYear': _graduationYear,
          'achievements': _achievementsController.text,
        });
      });
      _clearForm();
    }
  }
  
  void _clearForm() {
    _degreeController.clear();
    _fieldOfStudyController.clear();
    _institutionController.clear();
    _locationController.clear();
    _achievementsController.clear();
    setState(() {
      _graduationYear = null;
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _goNext() {
    Navigator.pushNamed(context, '/profile-creation/skills-certifications');
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
          'Education',
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
                    // Degree/Program
                    _buildInputField(
                      label: 'Degree/Program',
                      controller: _degreeController,
                      hintText: 'e.g., Bachelor of Science',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Degree/Program is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Field of Study
                    _buildInputField(
                      label: 'Field of Study',
                      controller: _fieldOfStudyController,
                      hintText: 'e.g., Computer Science',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Field of study is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Institution Name
                    _buildInputField(
                      label: 'Institution Name',
                      controller: _institutionController,
                      hintText: 'e.g., Stanford University',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Institution name is required';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Location
                    _buildInputField(
                      label: 'Location',
                      controller: _locationController,
                      hintText: 'e.g., Stanford, CA',
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Graduation Year
                    _buildGraduationYearDropdown(),
                    
                    SizedBox(height: 3.h),
                    
                    // Academic Achievements/Coursework
                    _buildTextAreaField(
                      label: 'Academic Achievements/Coursework (Optional)',
                      controller: _achievementsController,
                      hintText: 'e.g., Dean\'s List, Relevant Projects',
                      maxLines: 4,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Add Another Education Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addEducation,
                        icon: Icon(Icons.add, color: Color(0xFF4CAF50)),
                        label: Text(
                          'Add Another Education',
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
                    
                    // Education List
                    if (_educations.isNotEmpty) ..[
                      Text(
                        'Added Education',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ..._educations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final edu = entry.value;
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
                                      edu['degree'],
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
                                        _educations.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                edu['fieldOfStudy'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                edu['institution'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (edu['graduationYear'] != null)
                                Text(
                                  'Graduated: ${edu['graduationYear']}',
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
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
  
  Widget _buildGraduationYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Graduation Year',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: _graduationYear,
          decoration: InputDecoration(
            hintText: 'e.g., 2024',
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
          items: _years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(
                year,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _graduationYear = value;
            });
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Graduation year is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}