import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import 'job_repository.dart';

/// Fetches live listings from the public Arbeitnow job board API
/// (https://www.arbeitnow.com/api/job-board-api — free, no API key required).
///
/// Not wired in by default (see main.dart), because Arbeitnow doesn't provide
/// salary or company logo data, so those fields are filled with sensible
/// defaults below. Swap it in for MockJobService in main.dart to demo a real
/// network integration:
///   final JobRepository jobRepository = RemoteJobService();
class RemoteJobService implements JobRepository {
  static const _endpoint = 'https://www.arbeitnow.com/api/job-board-api';

  @override
  Future<List<Job>> fetchJobs() async {
    late final http.Response response;
    try {
      response =
          await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
    } catch (_) {
      throw JobFetchException(
        'Unable to reach the job server. Please check your connection.',
      );
    }

    if (response.statusCode != 200) {
      throw JobFetchException('Server error (${response.statusCode}).');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> results = body['data'] as List<dynamic>? ?? [];

    return results.map((item) {
      final map = item as Map<String, dynamic>;
      final tags = (map['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final types = (map['job_types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final location = map['location']?.toString() ?? '';

      return Job(
        id: (map['slug'] ?? map['url'] ?? DateTime.now().microsecondsSinceEpoch)
            .toString(),
        title: map['title']?.toString() ?? 'Untitled role',
        company: map['company_name']?.toString() ?? 'Unknown company',
        logoUrl: '',
        location: location.isNotEmpty
            ? location
            : (map['remote'] == true ? 'Remote' : 'Not specified'),
        jobType: types.isNotEmpty ? types.first : 'Full-time',
        salary: 'Not disclosed',
        description:
            (map['description']?.toString() ?? '').replaceAll(RegExp(r'<[^>]*>'), ''),
        skills: tags,
        experience: 'Not specified',
        postedDate: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (map['created_at'] as num).toInt() * 1000)
            : DateTime.now(),
        applyUrl: map['url']?.toString() ?? '',
      );
    }).toList();
  }
}
