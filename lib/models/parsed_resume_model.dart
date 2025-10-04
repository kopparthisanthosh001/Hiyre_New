class ParsedResumeModel {
  final PersonalInfo personalInfo;
  final List<WorkExperience> workExperiences;
  final List<Education> education;
  final List<String> skills;
  final List<String> certifications;
  final String? summary;
  final double confidenceScore;

  ParsedResumeModel({
    required this.personalInfo,
    required this.workExperiences,
    required this.education,
    required this.skills,
    required this.certifications,
    this.summary,
    required this.confidenceScore,
  });

  factory ParsedResumeModel.fromJson(Map<String, dynamic> json) {
    return ParsedResumeModel(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      workExperiences: (json['workExperiences'] as List<dynamic>?)
          ?.map((e) => WorkExperience.fromJson(e))
          .toList() ?? [],
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e))
          .toList() ?? [],
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      summary: json['summary'],
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'workExperiences': workExperiences.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
      'certifications': certifications,
      'summary': summary,
      'confidenceScore': confidenceScore,
    };
  }
}

class PersonalInfo {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? location;
  final String? linkedIn;
  final String? github;
  final String? portfolio;

  PersonalInfo({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.location,
    this.linkedIn,
    this.github,
    this.portfolio,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      linkedIn: json['linkedIn'],
      github: json['github'],
      portfolio: json['portfolio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedIn': linkedIn,
      'github': github,
      'portfolio': portfolio,
    };
  }
}

class WorkExperience {
  final String? jobTitle;
  final String? companyName;
  final String? location;
  final String? employmentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? responsibilities;
  final String? achievements;

  WorkExperience({
    this.jobTitle,
    this.companyName,
    this.location,
    this.employmentType,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.responsibilities,
    this.achievements,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      location: json['location'],
      employmentType: json['employmentType'] ?? 'full_time',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
      responsibilities: json['responsibilities'],
      achievements: json['achievements'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'companyName': companyName,
      'location': location,
      'employmentType': employmentType,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrent': isCurrent,
      'responsibilities': responsibilities,
      'achievements': achievements,
    };
  }
}

class Education {
  final String? degreeProgram;
  final String? fieldOfStudy;
  final String? institutionName;
  final String? location;
  final int? graduationYear;
  final double? gpa;
  final String? academicAchievements;
  final String? coursework;

  Education({
    this.degreeProgram,
    this.fieldOfStudy,
    this.institutionName,
    this.location,
    this.graduationYear,
    this.gpa,
    this.academicAchievements,
    this.coursework,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degreeProgram: json['degreeProgram'],
      fieldOfStudy: json['fieldOfStudy'],
      institutionName: json['institutionName'],
      location: json['location'],
      graduationYear: json['graduationYear'],
      gpa: json['gpa']?.toDouble(),
      academicAchievements: json['academicAchievements'],
      coursework: json['coursework'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degreeProgram': degreeProgram,
      'fieldOfStudy': fieldOfStudy,
      'institutionName': institutionName,
      'location': location,
      'graduationYear': graduationYear,
      'gpa': gpa,
      'academicAchievements': academicAchievements,
      'coursework': coursework,
    };
  }
}