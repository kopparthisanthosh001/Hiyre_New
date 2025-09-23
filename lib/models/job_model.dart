class JobModel {
  final String id;
  final String title;
  final String description;
  final CompanyModel company;
  final DomainModel? domain;
  final String employmentType;
  final String workMode;
  final String experienceLevel;
  final int? salaryMin;
  final int? salaryMax;
  final String? currency;
  final String? location;
  final String? requirements;
  final String? benefits;
  final DateTime? applicationDeadline;
  final String status;
  final String postedBy;
  final int viewsCount;
  final int applicationsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<JobSkillModel>? jobSkills;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    this.domain,
    required this.employmentType,
    required this.workMode,
    required this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    this.location,
    this.requirements,
    this.benefits,
    this.applicationDeadline,
    required this.status,
    required this.postedBy,
    required this.viewsCount,
    required this.applicationsCount,
    required this.createdAt,
    required this.updatedAt,
    this.jobSkills,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      company: json['companies'] != null 
          ? CompanyModel.fromJson(json['companies'] as Map<String, dynamic>)
          : CompanyModel(
              id: '', 
              name: 'Unknown Company', 
              logoUrl: null, 
              description: null,
              isVerified: false,
            ),
      domain: json['domains'] != null
          ? DomainModel.fromJson(json['domains'] as Map<String, dynamic>)
          : null,
      employmentType: json['employment_type'] as String? ?? 'full_time',
      workMode: json['work_mode'] as String? ?? 'hybrid',
      experienceLevel: json['experience_level'] as String? ?? 'mid',
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      currency: json['salary_range'] as String? ?? 'USD', // Use salary_range instead of currency
      location: json['location'] as String?,
      requirements: json['requirements'] as String?,
      benefits: json['benefits'] as String?,
      applicationDeadline: null, // This field doesn't exist in DB
      status: json['status'] as String? ?? 'active',
      postedBy: json['posted_by'] as String? ?? '',
      viewsCount: 0, // This field doesn't exist in DB
      applicationsCount: 0, // This field doesn't exist in DB
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      jobSkills: [], // This relationship doesn't exist yet
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company_id': company.id,
      'domain_id': domain?.id,
      'employment_type': employmentType,
      'work_mode': workMode,
      'experience_level': experienceLevel,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'location': location,
      'requirements': requirements,
      'benefits': benefits,
      'application_deadline': applicationDeadline?.toIso8601String(),
      'status': status,
      'posted_by': postedBy,
      'views_count': viewsCount,
      'applications_count': applicationsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedSalary {
    if (salaryMin == null && salaryMax == null) return 'Salary not disclosed';
    if (salaryMin != null && salaryMax != null) {
      return '\$${_formatNumber(salaryMin!)} - \$${_formatNumber(salaryMax!)}';
    }
    if (salaryMin != null) return '\$${_formatNumber(salaryMin!)}+';
    return '\$${_formatNumber(salaryMax!)}';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  String get employmentTypeFormatted {
    return employmentType.replaceAll('_', ' ').toUpperCase();
  }

  String get workModeFormatted {
    return workMode.replaceAll('_', ' ').toUpperCase();
  }

  String get experienceLevelFormatted {
    return experienceLevel.replaceAll('_', ' ').toUpperCase();
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String? industry;
  final String? size;
  final String? location;
  final int? foundedYear;
  final bool isVerified;

  CompanyModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.industry,
    this.size,
    this.location,
    this.foundedYear,
    required this.isVerified,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      industry: json['industry'] as String?,
      size: json['size'] as String?,
      location: json['location'] as String?,
      foundedYear: json['founded_year'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class DomainModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  DomainModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class JobSkillModel {
  final String jobId;
  final String skillId;
  final bool isRequired;
  final SkillModel? skill;

  JobSkillModel({
    required this.jobId,
    required this.skillId,
    required this.isRequired,
    this.skill,
  });

  factory JobSkillModel.fromJson(Map<String, dynamic> json) {
    return JobSkillModel(
      jobId: json['job_id'] as String,
      skillId: json['skill_id'] as String,
      isRequired: json['is_required'] as bool? ?? true,
      skill: json['skills'] != null
          ? SkillModel.fromJson(json['skills'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SkillModel {
  final String id;
  final String name;
  final String? category;

  SkillModel({
    required this.id,
    required this.name,
    this.category,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
    );
  }
}

class JobApplicationModel {
  final String id;
  final String jobId;
  final String applicantId;
  final String status;
  final String? coverLetter;
  final String? resumeUrl;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String? notes;
  final JobModel? job;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.status,
    this.coverLetter,
    this.resumeUrl,
    required this.appliedAt,
    required this.updatedAt,
    this.notes,
    this.job,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      applicantId: json['applicant_id'] as String,
      status: json['status'] as String,
      coverLetter: json['cover_letter'] as String?,
      resumeUrl: json['resume_url'] as String?,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      notes: json['notes'] as String?,
      job: json['jobs'] != null
          ? JobModel.fromJson(json['jobs'] as Map<String, dynamic>)
          : null,
    );
  }

  String get statusFormatted {
    return status.replaceAll('_', ' ').toUpperCase();
  }
}
