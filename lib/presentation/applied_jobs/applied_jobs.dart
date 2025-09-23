import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../services/job_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../chat/chat_screen.dart';

class AppliedJobs extends StatefulWidget {
  const AppliedJobs({super.key});

  @override
  State<AppliedJobs> createState() => _AppliedJobsState();
}

class _AppliedJobsState extends State<AppliedJobs>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _allApplications = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isSearching = false;
  
  final List<String> _filterOptions = ['All', 'Applied', 'Pending', 'Interview'];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final applications = await JobService.instance.getUserApplications();
      
      setState(() {
        _allApplications = applications.map((app) => {
          'id': app['id'],
          'jobTitle': app['jobs']['title'] ?? 'Unknown Position',
          'companyName': app['jobs']['companies']['name'] ?? 'Unknown Company',
          'companyLogo': app['jobs']['companies']['logo_url'],
          'status': _mapStatus(app['status']),
          'appliedDate': DateTime.parse(app['applied_at']),
          'location': app['jobs']['location'] ?? 'Remote',
          'employmentType': app['jobs']['employment_type'] ?? 'full_time',
          'workMode': app['jobs']['work_mode'] ?? 'remote',
          'salaryMin': app['jobs']['salary_min'],
          'salaryMax': app['jobs']['salary_max'],
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading applications: $error');
      setState(() {
        _allApplications = [];
        _isLoading = false;
      });
    }
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'applied':
        return 'Applied';
      case 'interviewed':
        return 'Interview';
      case 'offered':
        return 'Interview';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Applied';
    }
  }

  List<Map<String, dynamic>> get _filteredApplications {
    List<Map<String, dynamic>> filtered = _allApplications;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((app) => app['status'] == _selectedFilter)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        final jobTitle = (app['jobTitle'] as String).toLowerCase();
        final companyName = (app['companyName'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return jobTitle.contains(query) || companyName.contains(query);
      }).toList();
    }

    // Sort by applied date (newest first)
    filtered.sort((a, b) => (b['appliedDate'] as DateTime)
        .compareTo(a['appliedDate'] as DateTime));

    return filtered;
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadApplications();
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    HapticFeedback.lightImpact();
  }

  void _handleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Applied':
        return Colors.green;
      case 'Interview':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _openChat(Map<String, dynamic> application) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          applicationId: application['id']?.toString() ?? '',
          jobTitle: application['jobTitle'] ?? 'Job Application',
          companyName: application['companyName'] ?? 'Company',
          companyLogo: application['companyLogo'],
        ),
      ),
    );
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Application Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job info
                    Row(
                      children: [
                        Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: application['companyLogo'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    application['companyLogo'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.business,
                                        color: Colors.grey[400],
                                        size: 8.w,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.business,
                                  color: Colors.grey[400],
                                  size: 8.w,
                                ),
                        ),
                        
                        SizedBox(width: 4.w),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application['jobTitle'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                application['companyName'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(application['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  application['status'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(application['status']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Application info
                    _buildDetailRow('Applied Date', _formatDate(application['appliedDate']?.toString() ?? '')),
                    _buildDetailRow('Location', application['location']),
                    _buildDetailRow('Application ID', application['id']?.toString() ?? 'N/A'),
                    
                    if (application['notes'] != null && application['notes'].isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          application['notes'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredApplications = _filteredApplications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isSearching ? _buildSearchAppBar() : _buildMainAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count
            if (!_isSearching)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  'My Applications (Total: ${_allApplications.length})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ),

            // Search bar
            if (!_isSearching)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search applications...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.tune, color: Colors.grey[500]),
                        onPressed: () {},
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),

            SizedBox(height: 2.h),

            // Filter chips
            SizedBox(
              height: 6.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  final count = filter == 'All' 
                      ? _allApplications.length
                      : _allApplications.where((app) => app['status'] == filter).length;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: FilterChip(
                      label: Text('$filter($count)'),
                      selected: isSelected,
                      onSelected: (selected) => _handleFilterChanged(filter),
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.green[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green[700] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.green : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 2.h),

            // Applications list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : filteredApplications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          itemCount: filteredApplications.length,
                          itemBuilder: (context, index) {
                            final application = filteredApplications[index];
                            return _buildJobCard(application);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/job-swipe-deck');
              break;
            case 1:
              // Already on applied jobs
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildMainAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: Text(
        'Applied Jobs',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: _handleSearch,
        icon: Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search applications...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        style: TextStyle(color: Colors.black),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            icon: Icon(Icons.clear, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> application) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Company logo placeholder
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: application['companyLogo'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          application['companyLogo'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business,
                              color: Colors.grey[400],
                              size: 6.w,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: Colors.grey[400],
                        size: 6.w,
                      ),
              ),
              
              SizedBox(width: 3.w),
              
              // Job details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            application['jobTitle'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(application['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            application['status'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(application['status']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 0.5.h),
                    
                    Text(
                      application['companyName'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 1.h),
                    
                    // Application details
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 4.w,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          application['location'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.access_time,
                          size: 4.w,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 1.w),
                        Text(
                           _formatDate(application['appliedDate']?.toString() ?? ''),
                           style: TextStyle(
                             fontSize: 12.sp,
                             color: Colors.grey[600],
                           ),
                         ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 2.h),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _openChat(application);
                  },
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 4.w,
                    color: Colors.green,
                  ),
                  label: Text(
                    'Chat with HR',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  ),
                ),
              ),
              
              SizedBox(width: 3.w),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _viewApplicationDetails(application);
                  },
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 4.w,
                    color: Colors.white,
                  ),
                  label: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 20.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All'
                  ? 'No applications found'
                  : 'No applications yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All'
                  ? 'Try adjusting your search or filters'
                  : 'Start applying to jobs to see them here',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && _selectedFilter == 'All') ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/job-swipe-deck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Applying',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
