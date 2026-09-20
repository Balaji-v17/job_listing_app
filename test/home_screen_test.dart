import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:job_listing_app/models/job.dart';
import 'package:job_listing_app/providers/favorites_provider.dart';
import 'package:job_listing_app/providers/job_provider.dart';
import 'package:job_listing_app/providers/theme_provider.dart';
import 'package:job_listing_app/screens/home_screen.dart';
import 'package:job_listing_app/services/job_repository.dart';

class _FakeRepo implements JobRepository {
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
        skills: const ['Flutter'],
        experience: 'Fresher',
        postedDate: DateTime(2026, 9, 1),
        applyUrl: '',
      ),
    ];
  }
}

class _EmptyRepo implements JobRepository {
  @override
  Future<List<Job>> fetchJobs() async => [];
}

Widget _wrap(JobRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => JobProvider(repo)),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('shows loading placeholders, then the fetched job',
      (tester) async {
    await tester.pumpWidget(_wrap(_FakeRepo()));

    // Right after the first frame, the fetch hasn't resolved yet.
    expect(find.text('Flutter Developer'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Flutter Developer'), findsOneWidget);
  });

  testWidgets('shows the empty state when the repository has no jobs',
      (tester) async {
    await tester.pumpWidget(_wrap(_EmptyRepo()));
    await tester.pumpAndSettle();

    expect(find.text('No jobs found'), findsOneWidget);
  });

  testWidgets('typing a non-matching search shows the empty state',
      (tester) async {
    await tester.pumpWidget(_wrap(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Developer'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nonexistent role');
    await tester.pumpAndSettle();

    expect(find.text('Flutter Developer'), findsNothing);
    expect(find.text('No jobs found'), findsOneWidget);
  });
}
