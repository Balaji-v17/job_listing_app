/// Formats a DateTime as a short "time ago" label for job cards,
/// e.g. "Posted today", "Posted 3 days ago", "Posted 2 weeks ago".
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inDays <= 0) return 'Posted today';
  if (diff.inDays == 1) return 'Posted yesterday';
  if (diff.inDays < 7) return 'Posted ${diff.inDays} days ago';

  final weeks = (diff.inDays / 7).floor();
  if (weeks == 1) return 'Posted 1 week ago';
  if (weeks < 5) return 'Posted $weeks weeks ago';

  final months = (diff.inDays / 30).floor();
  return months <= 1 ? 'Posted 1 month ago' : 'Posted $months months ago';
}
