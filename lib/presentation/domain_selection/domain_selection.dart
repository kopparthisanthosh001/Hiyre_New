import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/domain_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/domain_card_widget.dart';

class DomainSelection extends StatefulWidget {
  const DomainSelection({super.key});

  @override
  State<DomainSelection> createState() => _DomainSelectionState();
}

class _DomainSelectionState extends State<DomainSelection> {
  final List<Map<String, dynamic>> _selectedDomains = [];
  bool _isLoading = false;
  final int _currentBottomNavIndex = 2;

  // Domain data matching actual database domains
  final List<Map<String, dynamic>> _allDomains = [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "Business",
      "icon": "business_center",
      "description": "Strategic planning and operations",
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440004",
      "title": "Marketing",
      "icon": "campaign",
      "description": "Digital marketing and advertising",
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "title": "Technology",
      "icon": "engineering",
      "description": "Software and technical development",
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "title": "Design",
      "icon": "palette",
      "description": "UI/UX and creative design",
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440005",
      "title": "Sales",
      "icon": "people",
      "description": "Sales and customer relations",
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440006",
      "title": "Finance",
      "icon": "science",
      "description": "Financial analysis and planning",
    },
  ];

  void _toggleDomainSelection(Map<String, dynamic> domain) {
    setState(() {
      final isSelected = _selectedDomains.any(
        (selected) => selected['id'] == domain['id'],
      );

      if (isSelected) {
        _selectedDomains.removeWhere(
          (selected) => selected['id'] == domain['id'],
        );
      } else {
        _selectedDomains.add(domain);
      }
    });
  }

  Future<void> _onNext() async {
    if (_selectedDomains.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get domain IDs from database based on selected domain titles
      final domainIds = await _getSelectedDomainIds();
      
      print('=== DEBUG: Domain Selection ===');
      print('Selected domain names: $_selectedDomains');
      print('Selected domain IDs: $domainIds');
      print('Domain IDs type: ${domainIds.runtimeType}');
      print('First domain ID: ${domainIds.isNotEmpty ? domainIds.first : 'none'}');

      // Try to save selected domains to user preferences (optional - don't fail if user not authenticated)
      try {
        await _saveUserDomainPreferences(domainIds);
        print('✅ User domain preferences saved successfully');
      } catch (prefError) {
        print('⚠️ Could not save user preferences (user not authenticated): $prefError');
        // Continue anyway - this is not critical for the app to function
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        print('🚀 Navigating to job swipe deck with domains: $domainIds');
        
        // Navigate to job swipe deck with selected domain IDs
        Navigator.pushNamed(
          context,
          '/job-swipe-deck',
          arguments: {'selectedDomainIds': domainIds},
        );
      }
    } catch (error) {
      print('❌ Critical error in domain selection: $error');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing domains: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveUserDomainPreferences(List<String> domainIds) async {
    try {
      await DomainService.instance.saveUserDomains(domainIds);
    } catch (error) {
      // Re-throw the error so we can handle it properly in _onNext
      throw Exception('Failed to save user domains: $error');
    }
  }

  Future<List<String>> _getSelectedDomainIds() async {
    try {
      final selectedIds =
          _selectedDomains.map((d) => d['id'] as String).toList();
      print('=== DEBUG: Domain Selection ===');
      print('Selected domain IDs: $selectedIds');
      
      return selectedIds;
    } catch (error) {
      // Fallback: return empty list if error occurs
      print('Error getting domain IDs: $error');
      return [];
    }
  }

  void _onBottomNavTap(int index) {
    // Navigate to the appropriate screen based on index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/job-swipe-deck');
        break;
      case 1:
        Navigator.pushNamed(context, '/applied-jobs');
        break;
      case 2:
        // Already on domain selection, do nothing
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Curved background elements
          _buildCurvedBackgrounds(),

          // Main content
          SafeArea(
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
                            'Job Domains',
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

                // Title and subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    children: [
                      Text(
                        'What type of job are you looking for?',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Select the domains that best match your interests and skills.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Domain cards in 2-column grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 3.h,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _allDomains.length,
                      itemBuilder: (context, index) {
                        final domain = _allDomains[index];
                        final isSelected = _selectedDomains.any(
                          (selected) => selected['id'] == domain['id'],
                        );

                        return DomainCardWidget(
                          domain: domain,
                          isSelected: isSelected,
                          onTap: () => _toggleDomainSelection(domain),
                        );
                      },
                    ),
                  ),
                ),

                // Next button
                Padding(
                  padding: EdgeInsets.all(6.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton(
                      onPressed:
                          _selectedDomains.isNotEmpty && !_isLoading
                              ? _onNext
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
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Text(
                                'Next',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
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
        currentIndex: 2, // Domain selection tab
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildCurvedBackgrounds() {
    return Stack(
      children: [
        // Top curved background
        Positioned(
          top: -15.h,
          right: -20.w,
          child: Container(
            width: 60.w,
            height: 30.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  const Color(0xFF4CAF50).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40.w),
            ),
          ),
        ),
        // Bottom curved background
        Positioned(
          bottom: -10.h,
          left: -25.w,
          child: Container(
            width: 70.w,
            height: 35.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFC107).withValues(alpha: 0.1),
                  const Color(0xFFFFC107).withValues(alpha: 0.05),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(45.w),
            ),
          ),
        ),
      ],
    );
  }
}
