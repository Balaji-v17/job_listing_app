import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/job.dart';
import 'job_repository.dart';

/// Loads job listings from a bundled local JSON file (assets/mock_jobs.json).
/// This is the default data source for the app. It simulates a network
/// delay so loading states are visible, and can optionally simulate a
/// failure (see [simulateError]) to exercise the error UI.
///
/// To use live data instead, swap this for [RemoteJobService] in main.dart:
///   final JobRepository jobRepository = RemoteJobService();
class MockJobService implements JobRepository {
  final Duration simulatedDelay;
  final bool simulateError;

  MockJobService({
    this.simulatedDelay = const Duration(milliseconds: 900),
    this.simulateError = false,
  });

  @override
  Future<List<Job>> fetchJobs() async {
    await Future.delayed(simulatedDelay);

    if (simulateError) {
      throw JobFetchException(
        'Unable to load jobs. Please check your connection and try again.',
      );
    }

    final raw = await rootBundle.loadString('assets/mock_jobs.json');
    final List<dynamic> data = json.decode(raw) as List<dynamic>;
    return data
        .map((item) => Job.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
