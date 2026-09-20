import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/job_card.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/state_widgets.dart';
import 'job_details_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Next Role'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            SearchFilterBar(
              controller: _searchController,
              jobTypes: jobProvider.availableJobTypes,
              selectedType: jobProvider.typeFilter,
              sort: jobProvider.sort,
              onSearchChanged: (value) => context.read<JobProvider>().search(value),
              onTypeChanged: (type) => context.read<JobProvider>().filterByType(type),
              onSortChanged: (sort) => context.read<JobProvider>().setSort(sort),
            ),
            if (jobProvider.state == JobLoadState.loaded)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Showing ${jobProvider.jobs.length} of ${jobProvider.totalCount} jobs',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<JobProvider>().refresh(),
                child: _buildBody(jobProvider, favorites),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(JobProvider jobProvider, FavoritesProvider favorites) {
    switch (jobProvider.state) {
      case JobLoadState.initial:
      case JobLoadState.loading:
        return const LoadingState();

      case JobLoadState.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 420,
              child: ErrorState(
                message: jobProvider.errorMessage,
                onRetry: () => jobProvider.loadJobs(),
              ),
            ),
          ],
        );

      case JobLoadState.empty:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 420, child: EmptyState()),
          ],
        );

      case JobLoadState.loaded:
        final jobs = jobProvider.jobs;
        final showLoadMore = jobProvider.hasMore;
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: jobs.length + (showLoadMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= jobs.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<JobProvider>().loadMore(),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Load more jobs'),
                  ),
                ),
              );
            }
            final job = jobs[index];
            return FadeSlideIn(
              key: ValueKey('anim-${job.id}'),
              index: index,
              child: JobCard(
                job: job,
                isFavorite: favorites.isFavorite(job.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                ),
                onFavoriteTap: () => context.read<FavoritesProvider>().toggle(job.id),
              ),
            );
          },
        );
    }
  }
}
