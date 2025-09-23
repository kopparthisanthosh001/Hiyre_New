import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

import '../../../widgets/custom_bottom_bar.dart';

class SkillsCertificationsScreen extends StatefulWidget {
  const SkillsCertificationsScreen({super.key});

  @override
  State<SkillsCertificationsScreen> createState() => _SkillsCertificationsScreenState();
}

class _SkillsCertificationsScreenState extends State<SkillsCertificationsScreen> {
  final _skillController = TextEditingController();
  final _certificationController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  
  final List<String> _skills = [];
  final List<String> _certifications = [];
  
  String? _resumeFileName;
  String? _portfolioFileName;
  String? _coverLetterFileName;

  @override
  void dispose() {
    _skillController.dispose();
    _certificationController.dispose();
    _portfolioLinkController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _addCertification() {
    if (_certificationController.text.trim().isNotEmpty) {
      setState(() {
        _certifications.add(_certificationController.text.trim());
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  Future<void> _pickFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        switch (fileType) {
          case 'resume':
            _resumeFileName = result.files.single.name;
            break;
          case 'portfolio':
            _portfolioFileName = result.files.single.name;
            break;
          case 'coverLetter':
            _coverLetterFileName = result.files.single.name;
            break;
        }
      });
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _saveAndContinue() {
    // Navigate to main app or complete profile creation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
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
          'Skills & Certifications',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Section
                  _buildSectionTitle('Skills'),
                  Text(
                    'Add your key skills to get matched by recruiters.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Skills Input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillController,
                          decoration: InputDecoration(
                            hintText: 'e.g., JavaScript, Project Management',
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
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _addSkill,
                          icon: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Skills Tags
                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _skills.asMap().entries.map((entry) {
                        final index = entry.key;
                        final skill = entry.value;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFF4CAF50)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              GestureDetector(
                                onTap: () => _removeSkill(index),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  
                  SizedBox(height: 4.h),
                  
                  // Certifications Section
                  _buildSectionTitle('Certifications'),
                  Text(
                    'List any professional certifications you have.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Certifications Input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _certificationController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Google Project Management',
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
                          onSubmitted: (_) => _addCertification(),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _addCertification,
                          icon: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Certifications List
                  if (_certifications.isNotEmpty)
                    Column(
                      children: _certifications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final certification = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  certification,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeCertification(index),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  
                  SizedBox(height: 4.h),
                  
                  // Documents Section
                  _buildSectionTitle('Documents'),
                  
                  SizedBox(height: 2.h),
                  
                  // Resume Upload
                  _buildDocumentUpload(
                    title: 'Resume',
                    subtitle: 'Required',
                    fileName: _resumeFileName,
                    onTap: () => _pickFile('resume'),
                    isRequired: true,
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Portfolio Upload
                  _buildDocumentUpload(
                    title: 'Portfolio (Optional)',
                    subtitle: 'Paste a link to your online portfolio',
                    fileName: _portfolioFileName,
                    onTap: () => _pickFile('portfolio'),
                    isRequired: false,
                    showLinkInput: true,
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Cover Letter Upload
                  _buildDocumentUpload(
                    title: 'Cover Letter (Optional)',
                    subtitle: 'Click to upload or drag and drop\nPDF, DOC, DOCX only',
                    fileName: _coverLetterFileName,
                    onTap: () => _pickFile('coverLetter'),
                    isRequired: false,
                  ),
                  
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          
          // Bottom Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: _saveAndContinue,
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
                    'Save & Continue',
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
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
  
  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    String? fileName,
    required VoidCallback onTap,
    required bool isRequired,
    bool showLinkInput = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        
        if (showLinkInput) ..[
          TextFormField(
            controller: _portfolioLinkController,
            decoration: InputDecoration(
              hintText: 'Paste a link to your online portfolio',
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
          SizedBox(height: 2.h),
        ],
        
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file,
                  size: 40,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 1.h),
                if (fileName != null)
                  Text(
                    fileName,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4CAF50),
                    ),
                  )
                else
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}