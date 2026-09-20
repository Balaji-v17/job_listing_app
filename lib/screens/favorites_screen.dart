import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/job_card.dart';
import '../widgets/state_widgets.dart';
import 'job_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final favorites = context.watch<FavoritesProvider>();

    final List<Job> favoriteJobs = jobProvider.allJobs
        .where((job) => favorites.isFavorite(job.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteJobs.isEmpty
          ? const EmptyState(
              title: 'No favorites yet',
              message: 'Tap the heart icon on a job to save it here.',
              icon: Icons.favorite_border_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final job = favoriteJobs[index];
                return FadeSlideIn(
                  key: ValueKey('fav-anim-${job.id}'),
                  index: index,
                  child: JobCard(
                    job: job,
                    isFavorite: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                    ),
                    onFavoriteTap: () =>
                        context.read<FavoritesProvider>().toggle(job.id),
                  ),
                );
              },
            ),
    );
  }
}
