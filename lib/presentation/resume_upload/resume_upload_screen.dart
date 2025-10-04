import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/resume_parser_service.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../profile_creation/widgets/resume_upload_widget.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _isParsingResume = false;
  List<String>? _selectedDomainIds;

  @override
  void initState() {
    super.initState();
    // Get selected domains from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _selectedDomainIds = args?['selectedDomainIds'] as List<String>?;
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Future<void> _uploadAndParseResume() async {
    if (_selectedFile == null) {
      _showToast('Please select a resume file first');
      return;
    }

    setState(() {
      _isUploading = true;
      _isParsingResume = true;
    });

    try {
      // Convert PlatformFile to File for parsing
      final file = File(_selectedFile!.path!);
      
      // Parse the resume
      final parsedData = await ResumeParserService.instance.parseResume(file);
      
      // Get current user
      final currentUser = AuthService.instance.currentUser;
      if (currentUser != null) {
        // Update user profile with parsed data (don't create new - user already exists)
        final fullName = parsedData.personalInfo?.fullName ?? 'User';
        await ProfileService.instance.updatePersonalInfo(
          fullName: fullName,
          email: parsedData.personalInfo?.email ?? currentUser.email ?? '',
          phone: parsedData.personalInfo?.phone ?? '',
          location: parsedData.personalInfo?.location ?? '',
          industry: 'General', // Default industry
        );
        
        // Update bio separately if available
        final bio = _generateBioFromParsedData(parsedData);
        if (bio.isNotEmpty) {
          await AuthService.instance.updateUserProfile(
            updates: {
              'bio': bio,
            },
          );
        }
        
        _showToast('Resume uploaded and profile updated successfully! 🎉');
      } else {
        _showToast('Resume parsed successfully! 🎉');
      }

      // Wait a moment for user to see the success message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Navigate to profile creation with preferences tab
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/profile-creation',
          arguments: {
            'fromSignup': true,
            'initialTab': 3, // Preferences tab
            'selectedDomainIds': _selectedDomainIds,
          },
        );
      }
    } catch (error) {
      print('Error uploading/parsing resume: $error');
      _showToast('Failed to process resume: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isParsingResume = false;
        });
      }
    }
  }

  String _generateBioFromParsedData(ParsedResumeData parsedData) {
    // Generate a bio from parsed resume data
    List<String> bioParts = [];
    
    if (parsedData.workExperiences?.isNotEmpty ?? false) {
      final latestJob = parsedData.workExperiences!.first;
      if (latestJob.jobTitle?.isNotEmpty ?? false) {
        bioParts.add('${latestJob.jobTitle}');
      }
      if (latestJob.companyName?.isNotEmpty ?? false) {
        bioParts.add('at ${latestJob.companyName}');
      }
    }
    
    if (parsedData.skills?.isNotEmpty ?? false) {
      final topSkills = parsedData.skills!.take(3).join(', ');
      bioParts.add('Skilled in $topSkills');
    }
    
    if (parsedData.education?.isNotEmpty ?? false) {
       final education = parsedData.education!.first;
       if (education.degree?.isNotEmpty ?? false) {
         bioParts.add('${education.degree}');
       }
     }
    
    return bioParts.join('. ').trim();
  }

  String _determineExperienceLevel(int yearsOfExperience) {
    if (yearsOfExperience == 0) return 'entry';
    if (yearsOfExperience <= 2) return 'junior';
    if (yearsOfExperience <= 5) return 'mid';
    return 'senior';
  }

  Future<void> _skipResumeUpload() async {
    // Navigate to profile creation with preferences tab
    Navigator.pushReplacementNamed(
      context,
      '/profile-creation',
      arguments: {
        'fromSignup': true,
        'initialTab': 3, // Preferences tab
        'selectedDomainIds': _selectedDomainIds,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                        size: 5.w,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Upload Resume',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w), // Balance the back button
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 4.h),

                    // Title and subtitle
                    Text(
                      'Upload Your Resume',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Upload your resume to automatically fill your profile and get personalized job recommendations.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    // Resume upload widget
                    ResumeUploadWidget(
                      selectedFile: _selectedFile,
                      onFileSelected: (file) {
                        setState(() {
                          _selectedFile = file;
                        });
                      },
                    ),

                    SizedBox(height: 6.h),

                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: _selectedFile != null && !_isUploading
                            ? _uploadAndParseResume
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: colorScheme.onSurface
                              .withValues(alpha: 0.12),
                        ),
                        child: _isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 5.w,
                                    height: 5.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    _isParsingResume ? 'Parsing Resume...' : 'Uploading...',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Upload & Continue',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Skip button
                    TextButton(
                      onPressed: !_isUploading ? _skipResumeUpload : null,
                      child: Text(
                        'Skip for now',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}