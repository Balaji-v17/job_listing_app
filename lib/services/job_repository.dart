import '../models/job.dart';

/// Abstraction over "where jobs come from". This is what lets the app
/// swap between local mock data and a real network API without touching
/// any provider or UI code — only main.dart needs to change.
abstract class JobRepository {
  Future<List<Job>> fetchJobs();
}

class JobFetchException implements Exception {
  final String message;
  JobFetchException(this.message);

  @override
  String toString() => message;
}
