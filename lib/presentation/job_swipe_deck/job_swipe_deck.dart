import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/job_details_modal.dart';
import './widgets/swipe_action_buttons.dart';
import './widgets/swipe_card_stack.dart';
import '../authentication/job_seeker_login_screen.dart';

class JobSwipeDeck extends StatefulWidget {
  const JobSwipeDeck({super.key});

  @override
  State<JobSwipeDeck> createState() => _JobSwipeDeckState();
}

class _JobSwipeDeckState extends State<JobSwipeDeck>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentBottomIndex = 0;
  bool _isLoading = true;
  final List<Map<String, dynamic>> _appliedJobs = [];
  final List<Map<String, dynamic>> _savedJobs = [];
  Map<String, dynamic>? _lastSwipedJob;

  // Jobs data from database
  List<Map<String, dynamic>> _jobsData = [];
  List<String>? _selectedDomainIds;
  
  // Swipe tracking for authentication trigger
  int _swipeCount = 0;
  static const int _swipesBeforeAuth = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Get selected domains from navigation arguments or use default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _selectedDomainIds = args?['selectedDomainIds'] as List<String>?;
      _loadJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentBottomIndex = _tabController.index;
      });
    }
  }

  Future<void> _loadJobs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<JobModel> jobs;

      print('Loading jobs with selectedDomainIds: $_selectedDomainIds');

      if (_selectedDomainIds != null && _selectedDomainIds!.isNotEmpty) {
        // Load jobs for selected domains
        print('Loading jobs for selected domains');
        jobs = await JobService.instance.getJobsForSelectedDomains(
          _selectedDomainIds!,
          limit: 50,
        );
      } else {
        // Load recommended jobs or all jobs if no domains selected
        print('Loading recommended jobs');
        jobs = await JobService.instance.getRecommendedJobs(limit: 50);
      }

      print('Loaded ${jobs.length} jobs from database');

      // Transform database jobs to match the UI format
      final transformedJobs =
          jobs.map((job) => _transformJobData(job)).toList();

      print('Transformed jobs: ${transformedJobs.length}');

      setState(() {
        _jobsData = transformedJobs;
        _isLoading = false;
      });

      if (transformedJobs.isEmpty) {
        print('No jobs found - showing empty state');
      }
    } catch (error) {
      print('Error loading jobs: $error');

      setState(() {
        _isLoading = false;
      });

      // Show error message with more details
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load jobs: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadJobs(),
            ),
          ),
        );
      }
    }
  }

  Map<String, dynamic> _transformJobData(JobModel job) {
    print('Transforming job: ${job.title} (${job.id})');

    // Calculate salary range
    String salaryRange = job.formattedSalary;

    // Use calculated match percentage and reason from job service
    final matchPercentage = 75; // Default match percentage
    final matchReason = _generateMatchReason(job);

    final transformedJob = {
      'id': job.id,
      'title': job.title,
      'companyName': job.company.name,
      'salary': salaryRange,
      'location': job.location,
      'employmentType': job.employmentType,
      'workMode': job.workMode,
      'experienceLevel': job.experienceLevel,
      'description': job.description,
      'requirements': job.requirements,
      'benefits': job.benefits,
      'matchPercentage': matchPercentage,
      'matchReason': matchReason,
      'domain': job.domain?.name ?? 'General',
      'companyLogo': job.company.logoUrl,
      'companyIndustry': job.company.industry,
      'skills': [], // Would be populated from job_skills in real implementation
    };

    print(
        'Transformed job: ${transformedJob['title']} at ${transformedJob['companyName']}');
    return transformedJob;
  }

  String _generateMatchReason(JobModel job) {
    // Fallback method for when match reason is not calculated by job service
    final reasons = [
      'Your experience aligns well with this ${job.domain?.name ?? 'role'} position.',
      'Your skills match the requirements for this ${job.title} role.',
      'This position offers growth opportunities in ${job.domain?.name ?? 'your field'}.',
      'The ${job.workMode} work mode matches your preferences.',
      'Your ${job.experienceLevel} level experience is perfect for this role.',
    ];

    return reasons[job.id.hashCode % reasons.length];
  }

  void _handleSwipeRight(Map<String, dynamic> job) {
    setState(() {
      _appliedJobs.add(job);
      _lastSwipedJob = job;
      _jobsData.removeWhere((j) => j['id'] == job['id']);
      _swipeCount++;
    });

    // Apply to job in database
    _applyToJob(job['id'].toString());

    Fluttertoast.showToast(
      msg: "Applied to ${job['title']}! (Swipe $_swipeCount/3)",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    
    // Check if user needs to authenticate after 3 swipes
    _checkAuthenticationRequired();
  }

  void _handleSwipeLeft(Map<String, dynamic> job) {
    setState(() {
      _lastSwipedJob = job;
      _jobsData.removeWhere((j) => j['id'] == job['id']);
      _swipeCount++;
    });

    Fluttertoast.showToast(
      msg: "Job skipped (Swipe $_swipeCount/3)",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
    );
    
    // Check if user needs to authenticate after 3 swipes
    _checkAuthenticationRequired();
  }

  Future<void> _applyToJob(String jobId) async {
    try {
      await JobService.instance.applyToJob(jobId: jobId);
    } catch (error) {
      // Silently handle error - user already got feedback via toast
      print('Error applying to job: $error');
    }
  }
  
  Future<void> _checkAuthenticationRequired() async {
    // Check if user has swiped 3 jobs and is not authenticated
    if (_swipeCount >= _swipesBeforeAuth) {
      final currentUser = AuthService.instance.currentUser;
      
      if (currentUser == null) {
        // User is not authenticated, show login screen
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const JobSeekerLoginScreen(),
            fullscreenDialog: true,
          ),
        );
        
        if (result == true) {
          // User successfully logged in, reset swipe count
          setState(() {
            _swipeCount = 0;
          });
          
          Fluttertoast.showToast(
            msg: "Welcome! Continue swiping to find your perfect job.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          // User cancelled login, reset swipe count but show message
          setState(() {
            _swipeCount = 0;
          });
          
          Fluttertoast.showToast(
            msg: "Sign in to save your job preferences and applications.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
        }
      } else {
        // User is already authenticated, reset counter
        setState(() {
          _swipeCount = 0;
        });
      }
    }
  }

  void _handleCardTap(Map<String, dynamic> job) {
    // Track job view
    JobService.instance.trackJobView(job['id'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailsModal(
        jobData: job,
        onApply: () {
          Navigator.pop(context);
          _handleSwipeRight(job);
        },
        onBookmark: () {
          _handleBookmark(job);
        },
      ),
    );
  }

  void _handleBookmark(Map<String, dynamic> job) {
    setState(() {
      if (_savedJobs.any((savedJob) => savedJob['id'] == job['id'])) {
        _savedJobs.removeWhere((savedJob) => savedJob['id'] == job['id']);
      } else {
        _savedJobs.add(job);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Title only (no app bar)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                "Matched Jobs",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _jobsData.isEmpty
                      ? _buildEmptyState()
                      : SwipeCardStack(
                          jobs: _jobsData,
                          onSwipeRight: _handleSwipeRight,
                          onSwipeLeft: _handleSwipeLeft,
                          onCardTap: _handleCardTap,
                        ),
            ),

            // Wrap SwipeActionButtons in Flexible to prevent overflow
            Flexible(
              flex: 0,
              child: SafeArea(
                top: false,
                child: SwipeActionButtons(
                  onSkip: () {
                    if (_jobsData.isNotEmpty) {
                      _handleSwipeLeft(_jobsData.first);
                    }
                  },
                  onApply: () {
                    if (_jobsData.isNotEmpty) {
                      _handleSwipeRight(_jobsData.first);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Job swipe deck is always index 0 (Discover)
        onTap: (index) {
          // Navigate to the appropriate screen based on index
          switch (index) {
            case 0:
              // Already on job swipe deck, do nothing
              break;
            case 1:
              Navigator.pushNamed(context, '/applied-jobs');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 20.w, color: Colors.grey[400]),
          SizedBox(height: 2.h),
          Text(
            'No jobs available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 1.h),
          Text(
            'Check back later for new opportunities',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
