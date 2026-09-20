import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/job_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'services/job_repository.dart';
import 'services/mock_job_service.dart';
import 'screens/home_screen.dart';
import 'services/remote_job_service.dart';

void main() {
  runApp(const JobListingApp());
}

class JobListingApp extends StatelessWidget {
  const JobListingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Default data source is local mock JSON — reliable with no network
    // dependency. To demo live data instead, swap this line for:
    //   final JobRepository jobRepository = RemoteJobService();
    final JobRepository jobRepository = RemoteJobService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider(jobRepository)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Job Listing App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
