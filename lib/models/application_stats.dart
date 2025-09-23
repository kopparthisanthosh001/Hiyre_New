class ApplicationStats {
  final int totalApplications;
  final int pendingApplications;
  final int interviewedApplications;
  final int offeredApplications;

  ApplicationStats({
    required this.totalApplications,
    required this.pendingApplications,
    required this.interviewedApplications,
    required this.offeredApplications,
  });

  factory ApplicationStats.fromJson(Map<String, dynamic> json) {
    return ApplicationStats(
      totalApplications: json['total_applications'] ?? 0,
      pendingApplications: json['pending_applications'] ?? 0,
      interviewedApplications: json['interviewed_applications'] ?? 0,
      offeredApplications: json['offered_applications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_applications': totalApplications,
      'pending_applications': pendingApplications,
      'interviewed_applications': interviewedApplications,
      'offered_applications': offeredApplications,
    };
  }

  // Default stats for when there's an error or no data
  static ApplicationStats defaultStats() {
    return ApplicationStats(
      totalApplications: 0,
      pendingApplications: 0,
      interviewedApplications: 0,
      offeredApplications: 0,
    );
  }
}