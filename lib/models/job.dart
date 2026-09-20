class Job {
  final String id;
  final String title;
  final String company;
  final String logoUrl;
  final String location;
  final String jobType;
  final String salary;
  final String description;
  final List<String> skills;
  final String experience;
  final DateTime postedDate;
  final String applyUrl;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.logoUrl,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.description,
    required this.skills,
    required this.experience,
    required this.postedDate,
    required this.applyUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      logoUrl: (json['logoUrl'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      jobType: (json['jobType'] ?? 'Full-time').toString(),
      salary: (json['salary'] ?? 'Not disclosed').toString(),
      description: (json['description'] ?? '').toString(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      experience: (json['experience'] ?? 'Fresher').toString(),
      postedDate:
          DateTime.tryParse(json['postedDate']?.toString() ?? '') ??
              DateTime.now(),
      applyUrl: (json['applyUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'logoUrl': logoUrl,
      'location': location,
      'jobType': jobType,
      'salary': salary,
      'description': description,
      'skills': skills,
      'experience': experience,
      'postedDate': postedDate.toIso8601String(),
      'applyUrl': applyUrl,
    };
  }
}
