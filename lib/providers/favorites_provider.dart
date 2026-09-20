import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _prefsKey = 'favorite_job_ids';

  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = (prefs.getStringList(_prefsKey) ?? []).toSet();
    notifyListeners();
  }

  bool isFavorite(String jobId) => _favoriteIds.contains(jobId);

  Future<void> toggle(String jobId) async {
    if (_favoriteIds.contains(jobId)) {
      _favoriteIds.remove(jobId);
    } else {
      _favoriteIds.add(jobId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favoriteIds.toList());
  }
}
