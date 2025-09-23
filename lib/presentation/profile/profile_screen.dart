import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  List<String> _userSkills = [];
  List<String> _userDomains = [];
  Map<String, dynamic>? _userPreferences;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        // User not logged in, show mock profile
        _userProfile = {
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'phone': '+91 98765 43210',
          'bio': 'Passionate Flutter developer with 4+ years of experience in mobile app development.',
          'experience_level': 'senior',
          'location': 'Mumbai, India',
        };
        _userSkills = ['Flutter', 'Dart', 'Firebase', 'Mobile Development', 'UI/UX Design'];
        _userDomains = ['Technology', 'Mobile Development'];
        _userPreferences = {
          'preferred_work_modes': ['remote', 'hybrid'],
          'preferred_employment_types': ['full_time'],
          'preferred_locations': ['Mumbai', 'Bangalore', 'Remote'],
          'min_salary': 800000,
          'max_salary': 1500000,
        };
      } else {
        // Load actual user profile from database
        _userProfile = await ProfileService.instance.getUserProfile();
        // Load additional profile data...
      }
    } catch (error) {
      print('Error loading user profile: $error');
      // Show mock profile on error
      _userProfile = {
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john.doe@example.com',
        'phone': '+91 98765 43210',
        'bio': 'Passionate Flutter developer with 4+ years of experience.',
        'experience_level': 'senior',
        'location': 'Mumbai, India',
      };
      _userSkills = ['Flutter', 'Dart', 'Firebase', 'Mobile Development'];
      _userDomains = ['Technology'];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Profile',
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.green.shade600),
            onPressed: () {
              Navigator.pushNamed(context, '/profile-creation');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(theme),
                  SizedBox(height: 3.h),

                  // Skills Section
                  _buildSkillsSection(theme),
                  SizedBox(height: 3.h),

                  // Preferences Section
                  _buildPreferencesSection(theme),
                  SizedBox(height: 3.h),

                  // Statistics Section
                  _buildStatisticsSection(theme),
                  SizedBox(height: 3.h),

                  // Settings Section
                  _buildSettingsSection(theme),
                  SizedBox(height: 10.h), // Bottom padding for navigation
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Profile tab (correct index)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/job-swipe-deck');
              break;
            case 1:
              Navigator.pushNamed(context, '/applied-jobs');
              break;
            case 2:
              // Already on profile
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          // Profile Photo
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            child: Icon(
              Icons.person,
              size: 10.w,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),

          // Name
          Text(
            '${_userProfile?['first_name'] ?? 'John'} ${_userProfile?['last_name'] ?? 'Doe'}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: 0.5.h),

          // Email
          Text(
            _userProfile?['email'] ?? 'john.doe@example.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.green.shade700,
            ),
          ),
          SizedBox(height: 1.h),

          // Location & Experience
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.green.shade600),
              SizedBox(width: 1.w),
              Text(
                _userProfile?['location'] ?? 'Mumbai, India',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade600,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(Icons.work, size: 16, color: Colors.green.shade600),
              SizedBox(width: 1.w),
              Text(
                '${_userProfile?['experience_level'] ?? 'Senior'} Level',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Bio
          if (_userProfile?['bio'] != null)
            Text(
              _userProfile!['bio'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _userSkills
              .map((skill) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      skill,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Preferences',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 1.5.h),
        
        // Work Mode
        _buildPreferenceItem(
          theme,
          'Work Mode',
          (_userPreferences?['preferred_work_modes'] as List?)?.join(', ') ?? 'Remote, Hybrid',
          Icons.work_outline,
        ),
        SizedBox(height: 1.h),
        
        // Employment Type
        _buildPreferenceItem(
          theme,
          'Employment Type',
          (_userPreferences?['preferred_employment_types'] as List?)?.join(', ') ?? 'Full-time',
          Icons.schedule,
        ),
        SizedBox(height: 1.h),
        
        // Salary Range
        _buildPreferenceItem(
          theme,
          'Salary Range',
          '₹${(_userPreferences?['min_salary'] ?? 800000) ~/ 1000}k - ₹${(_userPreferences?['max_salary'] ?? 1500000) ~/ 1000}k',
          Icons.currency_rupee,
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade600, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(theme, '24', 'Jobs Applied', Icons.work),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(theme, '156', 'Jobs Viewed', Icons.visibility),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(theme, '8', 'Interviews', Icons.event),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green.shade600, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 1.5.h),
        
        _buildSettingItem(theme, 'Edit Profile', Icons.edit, () {
          Navigator.pushNamed(context, '/profile-creation');
        }),
        _buildSettingItem(theme, 'Notification Settings', Icons.notifications, () {}),
        _buildSettingItem(theme, 'Privacy Settings', Icons.privacy_tip, () {}),
        _buildSettingItem(theme, 'Help & Support', Icons.help, () {}),
        _buildSettingItem(theme, 'Sign Out', Icons.logout, () {
          _showSignOutDialog();
        }, isDestructive: true),
      ],
    );
  }

  Widget _buildSettingItem(ThemeData theme, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red.shade600 : Colors.green.shade600,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDestructive ? Colors.red.shade600 : Colors.green.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red.shade400 : Colors.green.shade400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDestructive ? Colors.red.shade50 : Colors.green.shade50,
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle sign out
              Navigator.pushReplacementNamed(context, '/authentication');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}