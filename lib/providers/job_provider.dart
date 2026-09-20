import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/job_repository.dart';

enum JobLoadState { initial, loading, loaded, empty, error }

enum JobSort { newest, companyAZ, titleAZ }

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;

  JobProvider(this._repository);

  static const int _pageSize = 6;

  List<Job> _allJobs = [];
  List<Job> _visibleJobs = [];
  int _visibleCount = _pageSize;
  JobLoadState _state = JobLoadState.initial;
  String _errorMessage = '';
  String _query = '';
  String? _typeFilter;
  JobSort _sort = JobSort.newest;

  /// The current page of filtered, sorted jobs (see [loadMore]).
  List<Job> get jobs => _visibleJobs.take(_visibleCount).toList();

  /// How many jobs match the current search/filter, across all pages.
  int get totalCount => _visibleJobs.length;

  /// Whether there are more matching jobs beyond the current page.
  bool get hasMore => _visibleCount < _visibleJobs.length;

  /// The full unfiltered set — used by the Favorites screen to resolve
  /// favorited job IDs regardless of the current search/filter on Home.
  List<Job> get allJobs => _allJobs;

  JobLoadState get state => _state;
  String get errorMessage => _errorMessage;
  String? get typeFilter => _typeFilter;
  JobSort get sort => _sort;

  // Added helper function to clean and unify job type strings
  String _normalizeJobType(String type) {
    if (type.isEmpty) return type;
    final lowerClean = type.toLowerCase().replaceAll('-', ' ').trim();
    if (lowerClean.isEmpty) return lowerClean;
    return lowerClean[0].toUpperCase() + lowerClean.substring(1);
  }

  List<String> get availableJobTypes {
    // Apply normalization here so the UI only gets clean, distinct categories
    final types = _allJobs.map((j) => _normalizeJobType(j.jobType)).toSet().toList();
    types.sort();
    return types;
  }

  Future<void> loadJobs() async {
    _state = JobLoadState.loading;
    notifyListeners();
    try {
      final jobs = await _repository.fetchJobs();
      _allJobs = jobs;
      _applyFilters();
    } catch (e) {
      _state = JobLoadState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() => loadJobs();

  /// Reveals the next page of already-filtered results.
  void loadMore() {
    if (!hasMore) return;
    final next = _visibleCount + _pageSize;
    _visibleCount = next > _visibleJobs.length ? _visibleJobs.length : next;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    _applyFilters();
  }

  void filterByType(String? type) {
    _typeFilter = type;
    _applyFilters();
  }

  void setSort(JobSort sort) {
    _sort = sort;
    _applyFilters();
  }

  void _applyFilters() {
    final q = _query.trim().toLowerCase();

    var results = _allJobs.where((job) {
      final matchesQuery = q.isEmpty ||
          job.title.toLowerCase().contains(q) ||
          job.company.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q);
      
      // Apply normalization here so filtering matches the cleaned UI chips
      final matchesType = _typeFilter == null || _normalizeJobType(job.jobType) == _typeFilter;
      
      return matchesQuery && matchesType;
    }).toList();

    switch (_sort) {
      case JobSort.newest:
        results.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        break;
      case JobSort.companyAZ:
        results.sort(
            (a, b) => a.company.toLowerCase().compareTo(b.company.toLowerCase()));
        break;
      case JobSort.titleAZ:
        results.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    _visibleJobs = results;
    _visibleCount = _pageSize; // any change to search/filter/sort restarts pagination
    _state = results.isEmpty ? JobLoadState.empty : JobLoadState.loaded;
    notifyListeners();
  }
}