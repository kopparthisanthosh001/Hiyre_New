import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/resume_parser_service.dart';
import './widgets/experience_section_widget.dart';
import './widgets/preferences_section_widget.dart';
import './widgets/profile_photo_widget.dart';
import './widgets/resume_upload_widget.dart';
import './widgets/skills_input_widget.dart';
import '../job_swipe_deck/widgets/signup_modal.dart';

class ProfileCreation extends StatefulWidget {
  const ProfileCreation({super.key});

  @override
  State<ProfileCreation> createState() => _ProfileCreationState();
}

class _ProfileCreationState extends State<ProfileCreation>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentStep = 0;
  bool _isLoading = false;
  bool _fromSignup = false;

  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  XFile? _profilePhoto;
  List<String> _selectedSkills = [];
  List<ExperienceItem> _experiences = [];
  List<String> _preferredRoles = [];
  List<String> _preferredLocations = [];
  Set<WorkMode> _workModes = {WorkMode.remote};
  double _minSalary = 300000;
  double _maxSalary = 1500000;
  bool _remoteWork = true;
  PlatformFile? _resumeFile;
  ParsedResumeData? _parsedResumeData;
  List<String>? _selectedDomainIds;

  List<String> get _stepTitles {
    if (_fromSignup) {
      // When coming from resume upload, exclude the resume step
      return [
        'Personal Info',
        'Skills',
        'Experience',
        'Preferences',
      ];
    }
    return [
      'Personal Info',
      'Skills',
      'Experience',
      'Preferences',
      'Resume',
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: _stepTitles.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentStep = _tabController.index;
        });
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if parsed resume data was passed as arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // Handle different argument types
    if (args is ParsedResumeData && _parsedResumeData == null) {
      _parsedResumeData = args;
      _populateFieldsFromResumeData();
    } else if (args is Map<String, dynamic>) {
      // Handle navigation from signup flow
      final initialTab = args['initialTab'] as int?;
      final fromSignup = args['fromSignup'] as bool? ?? false;
      final selectedDomainIds = args['selectedDomainIds'] as List<String>?;
      
      // Set the _fromSignup flag
      _fromSignup = fromSignup;
      _selectedDomainIds = selectedDomainIds;
      
      if (initialTab != null && fromSignup) {
        // Navigate to the specified tab (Preferences tab = index 3)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentStep = initialTab == 1 ? 3 : initialTab; // Map preferences tab correctly
          });
          _tabController.animateTo(_currentStep);
          _pageController.animateToPage(
            _currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    }
  }

  void _populateFieldsFromResumeData() {
    if (_parsedResumeData?.personalInfo != null) {
      final personalInfo = _parsedResumeData!.personalInfo!;
      
      // Split full name into first and last name
      if (personalInfo.fullName != null) {
        final nameParts = personalInfo.fullName!.split(' ');
        if (nameParts.isNotEmpty) {
          _firstNameController.text = nameParts.first;
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.sublist(1).join(' ');
          }
        }
      }
      
      // Populate other fields
      if (personalInfo.email != null) {
        _emailController.text = personalInfo.email!;
      }
      if (personalInfo.phone != null) {
        _phoneController.text = personalInfo.phone!;
      }
      
      // Generate bio from parsed data
      _bioController.text = _generateBioFromParsedData(_parsedResumeData!);
    }
    
    // Populate skills
    if (_parsedResumeData?.skills != null) {
      _selectedSkills = List.from(_parsedResumeData!.skills!);
    }
    
    // Populate experiences
    if (_parsedResumeData?.workExperiences != null) {
      _experiences = _parsedResumeData!.workExperiences!.map((exp) => 
        ExperienceItem(
          jobTitle: exp.jobTitle ?? '',
          company: exp.companyName ?? '',
          startDate: exp.startDate != null ? DateTime.tryParse(exp.startDate!) : null,
          endDate: exp.endDate != null ? DateTime.tryParse(exp.endDate!) : null,
          isCurrentJob: exp.isCurrentJob ?? false,
          description: exp.description ?? '',
        )
      ).toList();
    }
    
    setState(() {});
  }

  String _generateBioFromParsedData(ParsedResumeData parsedData) {
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

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0: // Personal Info
        return _firstNameController.text.trim().isNotEmpty &&
               _lastNameController.text.trim().isNotEmpty &&
               _emailController.text.trim().isNotEmpty;
      case 1: // Skills & Certifications
        return _selectedSkills.isNotEmpty;
      case 2: // Work Experience - Optional but can be pre-filled from resume
        return true;
      case 3: // Preferences
        return _preferredRoles.isNotEmpty && _preferredLocations.isNotEmpty;
      case 4: // Resume Upload
        return true; // Resume is optional
      default:
        return false;
    }
  }

  double get _completionPercentage {
    int validSteps = 0;
    for (int i = 0; i <= _currentStep; i++) {
      if (_isStepValid(i)) validSteps++;
    }
    return validSteps / _stepTitles.length;
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _tabController.animateTo(_currentStep);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _tabController.animateTo(_currentStep);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    // Check if this is a post-signup preferences flow
    if (_fromSignup) {
      await _completePostSignupPreferences();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account with Supabase Auth
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final email = _emailController.text.trim();
      
      // For demo purposes, use a default password or generate one
      // In a real app, you'd collect this from the user during signup
      const defaultPassword = 'TempPassword123!';
      
      final authResponse = await AuthService.instance.signUp(
        email: email,
        password: defaultPassword,
        fullName: fullName,
        role: 'job_seeker',
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      );
      
      if (authResponse.user != null) {
        // User created successfully, now create profile data
        await ProfileService.instance.createUserProfile(
          userId: authResponse.user!.id,
          email: email,
          fullName: fullName,
          role: 'job_seeker',
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          location: _preferredLocations.isNotEmpty ? _preferredLocations.first : null,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          skills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
        );
        
        // If we have parsed resume data, save work experience and education
        if (_parsedResumeData != null) {
          await _saveResumeData(authResponse.user!.id);
        }
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile created successfully! Welcome to Hiyre!',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          // Navigate to job swipe deck with domain filtering
          Navigator.pushReplacementNamed(
            context, 
            '/job-swipe-deck',
            arguments: {
              'selectedDomainIds': _selectedDomainIds,
            },
          );
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create profile: $error',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completePostSignupPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService.instance.currentUser;
      
      // If user is not authenticated, show signup modal first
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        await _showSignupModal();
        return;
      }

      // Validate that preferences are selected
      if (_preferredRoles.isEmpty || _preferredLocations.isEmpty) {
        throw Exception('Please select at least one preferred role and location');
      }

      // Update user preferences
      final Map<String, dynamic> updates = {};
      
      // Add preferred locations
      if (_preferredLocations.isNotEmpty) {
        updates['location'] = _preferredLocations.first;
      }
      
      // Add preferred roles (from skills selection)
      if (_selectedSkills.isNotEmpty) {
        updates['skills'] = _selectedSkills;
      }
      
      // Add work mode preference (you might need to add this field to your preferences tab)
      // For now, we'll use a default or you can add this field later
      
      // Add salary expectation (you might need to add this field to your preferences tab)
      // For now, we'll use a default or you can add this field later

      if (updates.isNotEmpty) {
        await AuthService.instance.updateUserProfile(updates: updates);
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Preferences updated! Finding jobs that match your profile...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Navigate to job swipe deck with filtered jobs
        Navigator.pushReplacementNamed(
          context, 
          '/job-swipe-deck',
          arguments: {
            'selectedDomainIds': _selectedDomainIds,
          },
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update preferences: $error',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveAndExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Save Progress?',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Your progress will be saved and you can continue later.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/domain-selection');
            },
            child: Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _currentStep > 0 ? _previousStep : null,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _currentStep > 0
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back_ios',
                size: 20,
                color: _currentStep > 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.3),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Create Profile',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of ${_stepTitles.length}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _saveAndExit,
            child: Text(
              'Save & Exit',
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_completionPercentage * 100).toInt()}% Complete',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Text(
                _stepTitles[_currentStep],
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: _completionPercentage,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabs: _stepTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isValid = _isStepValid(index);

          return Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid && index < _currentStep) ...[
                    CustomIconWidget(
                      iconName: 'check_circle',
                      size: 16,
                      color: index == _currentStep
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 1.w),
                  ],
                  Text(title),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    List<Widget> children = [
      _buildPersonalInfoStep(),
      _buildSkillsStep(),
      _buildExperienceStep(),
      _buildPreferencesStep(),
    ];
    
    // Only add resume step if not coming from signup
    if (!_fromSignup) {
      children.add(_buildResumeStep());
    }
    
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentStep = index;
        });
        _tabController.animateTo(index);
      },
      children: children,
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Let\'s start with your basic information',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),

          // Profile Photo
          Center(
            child: ProfilePhotoWidget(
              initialPhoto: _profilePhoto,
              onPhotoSelected: (photo) {
                setState(() {
                  _profilePhoto = photo;
                });
              },
            ),
          ),
          SizedBox(height: 4.h),

          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter your first name',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter your last name',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email address',
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              prefixText: '+91 ',
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Bio
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Professional Bio',
              hintText: 'Tell us about yourself and your career goals...',
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add skills that showcase your expertise',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          SkillsInputWidget(
            selectedSkills: _selectedSkills,
            onSkillsChanged: (skills) {
              setState(() {
                _selectedSkills = skills;
              });
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Experience',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Share your professional journey',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          ExperienceSectionWidget(
            experiences: _experiences,
            onExperiencesChanged: (experiences) {
              setState(() {
                _experiences = experiences;
              });
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Preferences',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tell us what you\'re looking for',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          PreferencesSectionWidget(
            preferredRoles: _preferredRoles,
            preferredLocations: _preferredLocations,
            workModes: _workModes,
            minSalary: _minSalary,
            maxSalary: _maxSalary,
            remoteWork: _remoteWork,
            onPreferredRolesChanged: (roles) {
              setState(() {
                _preferredRoles = roles;
              });
            },
            onPreferredLocationsChanged: (locations) {
              setState(() {
                _preferredLocations = locations;
              });
            },
            onWorkModesChanged: (modes) {
              setState(() {
                _workModes = modes;
              });
            },
            onSalaryRangeChanged: (min, max) {
              setState(() {
                _minSalary = min;
                _maxSalary = max;
              });
            },
            onRemoteWorkChanged: (remote) {
              setState(() {
                _remoteWork = remote;
              });
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildResumeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Resume',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add your resume to complete your profile',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          ResumeUploadWidget(
            selectedFile: _resumeFile,
            onFileSelected: (file) {
              setState(() {
                _resumeFile = file;
              });
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text('Previous'),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 4.w),
            Expanded(
              flex: _currentStep > 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isStepValid(_currentStep) ? _nextStep : null),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == _stepTitles.length - 1
                            ? 'Complete Profile'
                            : 'Continue',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveResumeData(String userId) async {
    if (_parsedResumeData == null) return;
    
    try {
      // Save work experiences
      if (_parsedResumeData!.workExperiences?.isNotEmpty ?? false) {
        for (WorkExperience exp in _parsedResumeData!.workExperiences!) {
          if (exp.jobTitle != null && exp.companyName != null) {
            await ProfileService.instance.addWorkExperience(
              jobTitle: exp.jobTitle!,
              companyName: exp.companyName!,
              location: '',
              employmentType: 'full_time',
              startDate: DateTime.now(),
              endDate: null,
              currentlyWorking: exp.isCurrentJob ?? false,
              responsibilities: exp.description ?? '',
            );
          }
        }
      }
      
      // Save education
      if (_parsedResumeData!.education?.isNotEmpty ?? false) {
        for (Education edu in _parsedResumeData!.education!) {
          if (edu.degree != null && edu.institution != null) {
            await ProfileService.instance.addEducation(
              degree: edu.degree!,
              fieldOfStudy: edu.fieldOfStudy ?? '',
              institution: edu.institution!,
              location: '',
              graduationYear: DateTime.now().year.toString(),
              achievements: '',
            );
          }
        }
      }
      
      // Save certifications
      if (_parsedResumeData!.certifications?.isNotEmpty ?? false) {
        for (String cert in _parsedResumeData!.certifications!) {
          await ProfileService.instance.addCertification(
            name: cert,
            issuingOrganization: 'Unknown',
            issueDate: DateTime.now().toString(),
          );
        }
      }
    } catch (e) {
      print('Error saving resume data: $e');
      // Don't throw error as this is supplementary data
    }
  }

  Future<void> _showSignupModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SignupModal(
        jobTitle: 'your preferred roles',
        companyName: 'companies in your domain',
        onSignupSuccess: () {
          // After successful signup, continue with preferences completion
          _completePostSignupPreferences();
        },
      ),
    );
    
    // If user dismissed the modal without signing up, they can't proceed
    if (result != true) {
      // Optionally show a message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign up to continue and see job recommendations',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}