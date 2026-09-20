import 'package:flutter_test/flutter_test.dart';
import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/providers/job_provider.dart';
import 'package:job_listing_app/services/job_repository.dart';

class FakeJobRepository implements JobRepository {
  @override
  Future<List<Job>> fetchJobs() async {
    return [
      Job(
        id: '1',
        title: 'Flutter Developer',
        company: 'Acme',
        logoUrl: '',
        location: 'Bengaluru',
        jobType: 'Full-time',
        salary: '₹40,000/month',
        description: 'Build apps',
        skills: const ['Flutter', 'Dart'],
        experience: 'Fresher',
        postedDate: DateTime(2026, 9, 1),
        applyUrl: '',
      ),
      Job(
        id: '2',
        title: 'Backend Intern',
        company: 'Beta Corp',
        logoUrl: '',
        location: 'Remote',
        jobType: 'Internship',
        salary: '₹15,000/month',
        description: 'Build APIs',
        skills: const ['Python', 'FastAPI'],
        experience: '0-1 years',
        postedDate: DateTime(2026, 9, 10),
        applyUrl: '',
      ),
    ];
  }
}

class EmptyJobRepository implements JobRepository {
  @override
  Future<List<Job>> fetchJobs() async => [];
}

class FailingJobRepository implements JobRepository {
  @override
  Future<List<Job>> fetchJobs() async {
    throw JobFetchException('network down');
  }
}

void main() {
  group('JobProvider', () {
    test('loads jobs and exposes them sorted newest first by default', () async {
      final provider = JobProvider(FakeJobRepository());
      await provider.loadJobs();

      expect(provider.state, JobLoadState.loaded);
      expect(provider.jobs.length, 2);
      expect(provider.jobs.first.id, '2'); // posted later
    });

    test('search filters by title, company and location', () async {
      final provider = JobProvider(FakeJobRepository());
      await provider.loadJobs();

      provider.search('flutter');
      expect(provider.jobs.length, 1);
      expect(provider.jobs.first.id, '1');
    });

    test('filtering by job type narrows results', () async {
      final provider = JobProvider(FakeJobRepository());
      await provider.loadJobs();

      provider.filterByType('Internship');
      expect(provider.jobs.length, 1);
      expect(provider.jobs.first.company, 'Beta Corp');
    });

    test('no matches produces empty state', () async {
      final provider = JobProvider(FakeJobRepository());
      await provider.loadJobs();

      provider.search('doesnotexist');
      expect(provider.state, JobLoadState.empty);
      expect(provider.jobs, isEmpty);
    });

    test('empty repository produces empty state', () async {
      final provider = JobProvider(EmptyJobRepository());
      await provider.loadJobs();

      expect(provider.state, JobLoadState.empty);
    });

    test('repository failure produces error state with message', () async {
      final provider = JobProvider(FailingJobRepository());
      await provider.loadJobs();

      expect(provider.state, JobLoadState.error);
      expect(provider.errorMessage, contains('network down'));
    });
  });
}
