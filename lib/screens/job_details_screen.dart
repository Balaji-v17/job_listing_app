import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';
import '../providers/favorites_provider.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  // Added helper function to clean HTML tags and entities
  String _cleanDescription(String htmlString) {
    if (htmlString.isEmpty) return 'No description provided.';
    String unescaped = htmlString
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&');
    
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return unescaped.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(job.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () => context.read<FavoritesProvider>().toggle(job.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'logo-${job.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: job.logoUrl.isNotEmpty
                      ? Image.network(
                          job.logoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallback(scheme),
                        )
                      : _fallback(scheme),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(context, Icons.place_outlined, job.location),
              _infoChip(context, Icons.work_outline_rounded, job.jobType),
              _infoChip(context, Icons.trending_up_rounded, job.experience),
            ],
          ),
          const SizedBox(height: 18),
          _sectionCard(
            context,
            title: 'Compensation',
            child: Text(
              job.salary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            context,
            title: 'Job description',
            child: Text(
              // Applied the cleaning function here
              _cleanDescription(job.description),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionCard(
              context,
              title: 'Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    job.skills.map((skill) => Chip(label: Text(skill))).toList(),
              ),
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => _apply(context),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Apply Now'),
        ),
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final url = job.applyUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application link available for this job.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    final launched =
        uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the application link.')),
      );
    }
  }

  Widget _fallback(ColorScheme scheme) {
    final initial = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';
    return Container(
      width: 64,
      height: 64,
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.outline),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}