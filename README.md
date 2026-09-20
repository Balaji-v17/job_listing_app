# Job Listing App

A Flutter app to browse, search, and view job opportunities — built for the
Flutter Development Intern selection assignment.

## Features

- **Home / Jobs feed** — job cards with logo, title, company, location, job
  type and salary; live search, job-type filter chips, sort (newest /
  company A-Z / title A-Z), a results counter, and pull-to-refresh.
- **Pagination** — results load 6 at a time with a "Load more" control;
  pagination resets automatically whenever search/filter/sort changes.
- **Animations** — job cards fade and slide in with a subtle staggered
  entrance; logo images share a Hero transition into the details screen.
- **Job details** — full description, skills, experience, salary, and an
  Apply button that opens the listing URL externally.
- **Favorites** — heart icon on any card saves the job; a dedicated
  Favorites screen lists everything saved, persisted across app restarts.
- **Robust states** — loading, success, empty ("no results for your
  search"), and error (with retry) are all handled explicitly.
- **Material 3 UI** — responsive layout, reusable widgets, consistent
  spacing/typography, and a **dark mode** toggle (persisted).

## Getting started

```bash
flutter pub get
flutter analyze      # check for issues before running
flutter run
```

To build the release APK for submission:

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

To run the unit tests:

```bash
flutter test
```

> **Note:** this project was written outside a Flutter environment and has
> not been compiled or run on a device yet. Run `flutter analyze` and
> `flutter run` first thing — fix anything it flags before you rely on this
> for submission.

## Architecture

The app follows a simple layered structure so the UI never talks to a data
source directly:

```
lib/
├── main.dart                     # composition root: wires providers + theme
├── core/
│   ├── theme/app_theme.dart      # Material 3 light/dark ThemeData
│   └── utils/date_utils.dart     # "posted X days ago" formatting
├── models/
│   └── job.dart                  # Job entity + JSON (de)serialization
├── services/
│   ├── job_repository.dart       # JobRepository interface (the seam)
│   ├── mock_job_service.dart     # default: reads assets/mock_jobs.json
│   └── remote_job_service.dart   # bonus: live public API (see below)
├── providers/
│   ├── job_provider.dart         # list state: load/search/filter/sort
│   ├── favorites_provider.dart   # favorite IDs + SharedPreferences
│   └── theme_provider.dart       # dark mode + SharedPreferences
├── screens/
│   ├── home_screen.dart
│   ├── job_details_screen.dart
│   └── favorites_screen.dart
└── widgets/
    ├── job_card.dart
    ├── search_filter_bar.dart
    └── state_widgets.dart        # Loading / Empty / Error views
```

**Why this shape:** `JobRepository` is an abstract interface implemented by
both `MockJobService` and `RemoteJobService`. Screens never see either
implementation directly — they only depend on `JobProvider`, which depends
on the interface. That means the data source can be swapped in one line in
`main.dart` with no changes anywhere else, and the same shape makes unit
testing `JobProvider` possible with a fake repository (see `test/`).

State management uses **Provider** (`ChangeNotifier` + `MultiProvider`) —
simple, explicit, and easy to reason about for an app this size.

## Data source

The app ships with **local mock JSON** (`assets/mock_jobs.json`, 16 varied
listings) as the default data source, so it works fully offline and
deterministically for demoing every state (loading, results, empty search,
etc.).

A second implementation, `RemoteJobService`, is included and calls the free,
public [Arbeitnow job board API](https://www.arbeitnow.com/api/job-board-api)
(no API key required) to demonstrate a real network integration with error
handling. It isn't wired in by default because that API doesn't return
salary or logo data. To switch to it, change one line in `main.dart`:

```dart
final JobRepository jobRepository = RemoteJobService();
```

## Dependencies

| Package | Why |
|---|---|
| `provider` | State management |
| `http` | Networking for `RemoteJobService` |
| `shared_preferences` | Persisting favorites and theme choice |
| `url_launcher` | Opening the Apply link externally |
| `flutter_lints` | Standard lint rules (dev only) |

## Screenshots

_Add screenshots here after running the app — Home (list), search/filter in
action, Job Details, Favorites, and dark mode are the most useful ones to
include for the submission._

## Known limitations

- **Pagination is client-side** — the mock dataset is fetched in one request
  and paged locally (6 per page). `RemoteJobService` would need real
  page/offset query params to paginate a live backend efficiently.
- **No logo/salary from the live API** — Arbeitnow doesn't provide these, so
  `RemoteJobService` fills sensible defaults; the mock data source is used
  by default specifically to keep those fields meaningful.
- **Test coverage** covers `JobProvider` logic (search/filter/sort/pagination/
  error handling) and core `HomeScreen` states (loading/loaded/empty/search)
  — not exhaustive, but covers the app's main behavior.
- **CI** (`.github/workflows/flutter-ci.yml`) runs `flutter analyze` and
  `flutter test` on every push/PR to `main`.
