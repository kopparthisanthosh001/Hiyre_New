import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as path;

class ResumeParserService {
  static final ResumeParserService _instance = ResumeParserService._internal();
  factory ResumeParserService() => _instance;
  ResumeParserService._internal();

  static ResumeParserService get instance => _instance;

  Future<ParsedResumeData> parseResume(File resumeFile) async {
    try {
      // First, extract text from the resume
      String resumeText = await _extractTextFromFile(resumeFile);
      
      // For now, we'll use a local parsing method
      // In production, you would send this to a proper resume parsing API
      return await _parseResumeLocally(resumeText);
      
    } catch (e) {
      throw Exception('Failed to parse resume: ${e.toString()}');
    }
  }

  Future<String> _extractTextFromFile(File file) async {
    String extension = path.extension(file.path).toLowerCase();
    
    switch (extension) {
      case '.pdf':
        return await _extractTextFromPDF(file);
      case '.txt':
        return await file.readAsString();
      default:
        throw Exception('Unsupported file format: $extension');
    }
  }

  /// Extract text from PDF file using Syncfusion PDF
  Future<String> _extractTextFromPDF(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Create PDF text extractor to extract text
      PdfTextExtractor extractor = PdfTextExtractor(document);
      
      // Extract text from all pages
      String text = extractor.extractText();
      
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: ${e.toString()}');
    }
  }

  Future<ParsedResumeData> _parseResumeLocally(String resumeText) async {
    // This is a simplified local parsing implementation
    // In production, use a proper NLP service or API
    
    ParsedResumeData parsedData = ParsedResumeData();
    
    // Extract basic information using regex patterns
    parsedData.personalInfo = _extractPersonalInfo(resumeText);
    parsedData.workExperiences = _extractWorkExperience(resumeText);
    parsedData.education = _extractEducation(resumeText);
    parsedData.skills = _extractSkills(resumeText);
    parsedData.certifications = _extractCertifications(resumeText);
    
    return parsedData;
  }

  PersonalInfo _extractPersonalInfo(String text) {
    PersonalInfo info = PersonalInfo();
    
    // Extract email
    RegExp emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    Match? emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      info.email = emailMatch.group(0);
    }
    
    // Extract phone number
    RegExp phoneRegex = RegExp(r'(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}');
    Match? phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) {
      info.phone = phoneMatch.group(0);
    }
    
    // Extract name (first line that's not email/phone)
    List<String> lines = text.split('\n');
    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty && 
          !emailRegex.hasMatch(line) && 
          !phoneRegex.hasMatch(line) &&
          line.length > 2 && line.length < 50) {
        info.fullName = line;
        break;
      }
    }
    
    return info;
  }

  List<WorkExperience> _extractWorkExperience(String text) {
    List<WorkExperience> experiences = [];
    
    // Look for common work experience patterns
    RegExp workRegex = RegExp(
      r'(.*?)\s*(?:at|@)\s*(.*?)\s*(?:\n|\r\n?)(.*?)(?=\n\s*\n|\n.*?(?:at|@)|\Z)',
      multiLine: true,
      dotAll: true
    );
    
    Iterable<Match> matches = workRegex.allMatches(text);
    
    for (Match match in matches) {
      WorkExperience exp = WorkExperience();
      exp.jobTitle = match.group(1)?.trim() ?? '';
      exp.companyName = match.group(2)?.trim() ?? '';
      exp.description = match.group(3)?.trim() ?? '';
      
      if ((exp.jobTitle?.isNotEmpty ?? false) && (exp.companyName?.isNotEmpty ?? false)) {
        experiences.add(exp);
      }
    }
    
    return experiences;
  }

  List<Education> _extractEducation(String text) {
    List<Education> educationList = [];
    
    // Look for degree patterns
    RegExp degreeRegex = RegExp(
      r'(Bachelor|Master|PhD|B\.?S\.?|M\.?S\.?|B\.?A\.?|M\.?A\.?|B\.?Tech|M\.?Tech).*?(?:in|of)\s*(.*?)(?:from|at)\s*(.*?)(?:\n|$)',
      caseSensitive: false
    );
    
    Iterable<Match> matches = degreeRegex.allMatches(text);
    
    for (Match match in matches) {
      Education edu = Education();
      edu.degree = '${match.group(1)} in ${match.group(2)}'.trim();
      edu.institution = match.group(3)?.trim() ?? '';
      
      if ((edu.degree?.isNotEmpty ?? false) && (edu.institution?.isNotEmpty ?? false)) {
        educationList.add(edu);
      }
    }
    
    return educationList;
  }

  List<String> _extractSkills(String text) {
    List<String> skills = [];
    
    // Common technical skills
    List<String> commonSkills = [
      'JavaScript', 'Python', 'Java', 'C++', 'C#', 'PHP', 'Ruby', 'Swift', 'Kotlin',
      'React', 'Angular', 'Vue', 'Node.js', 'Express', 'Django', 'Flask', 'Spring',
      'HTML', 'CSS', 'SQL', 'MongoDB', 'PostgreSQL', 'MySQL', 'Redis',
      'AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes', 'Git', 'Jenkins',
      'Machine Learning', 'AI', 'Data Science', 'Analytics', 'Tableau', 'PowerBI'
    ];
    
    String lowerText = text.toLowerCase();
    
    for (String skill in commonSkills) {
      if (lowerText.contains(skill.toLowerCase())) {
        skills.add(skill);
      }
    }
    
    return skills;
  }

  List<String> _extractCertifications(String text) {
    List<String> certifications = [];
    
    // Look for certification patterns
    RegExp certRegex = RegExp(
      r'(certified?|certification|certificate).*?(?:\n|$)',
      caseSensitive: false
    );
    
    Iterable<Match> matches = certRegex.allMatches(text);
    
    for (Match match in matches) {
      String cert = match.group(0)?.trim() ?? '';
      if (cert.isNotEmpty && cert.length < 100) {
        certifications.add(cert);
      }
    }
    
    return certifications;
  }
}

// Data models for parsed resume information
class ParsedResumeData {
  PersonalInfo? personalInfo;
  List<WorkExperience>? workExperiences;
  List<Education>? education;
  List<String>? skills;
  List<String>? certifications;

  ParsedResumeData({
    this.personalInfo,
    this.workExperiences,
    this.education,
    this.skills,
    this.certifications,
  });
}

class PersonalInfo {
  String? fullName;
  String? email;
  String? phone;
  String? location;

  PersonalInfo({
    this.fullName,
    this.email,
    this.phone,
    this.location,
  });
}

class WorkExperience {
  String? jobTitle;
  String? companyName;
  String? startDate;
  String? endDate;
  String? description;
  bool? isCurrentJob;

  WorkExperience({
    this.jobTitle,
    this.companyName,
    this.startDate,
    this.endDate,
    this.description,
    this.isCurrentJob,
  });
}

class Education {
  String? degree;
  String? institution;
  String? fieldOfStudy;
  String? startDate;
  String? endDate;
  String? grade;

  Education({
    this.degree,
    this.institution,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
  });
}