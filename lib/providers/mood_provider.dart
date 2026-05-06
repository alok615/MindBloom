import 'package:flutter/material.dart';
import 'package:mind_bloom/database/db_helper.dart';
import 'package:mind_bloom/models/mood_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class MoodProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<MoodEntry> _entries = [];
  bool _isLoading = false;

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  MoodEntry? get todayEntry {
    final today = AppDateUtils.today();
    try {
      return _entries.firstWhere((e) => AppDateUtils.isSameDay(e.date, today));
    } catch (_) {
      return null;
    }
  }

  double get averageMood {
    if (_entries.isEmpty) return 0;
    final recent = _entries.take(7).toList();
    return recent.fold<int>(0, (sum, e) => sum + e.mood) / recent.length;
  }

  Map<int, int> get moodDistribution {
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final recent = _entries.take(30).toList();
    for (final entry in recent) {
      dist[entry.mood] = (dist[entry.mood] ?? 0) + 1;
    }
    return dist;
  }

  List<MoodEntry> get thisWeekEntries {
    final days = AppDateUtils.lastNDays(7);
    return _entries.where((e) {
      return days.any((d) => AppDateUtils.isSameDay(e.date, d));
    }).toList();
  }

  MoodEntry? getMoodForDate(DateTime date) {
    try {
      return _entries.firstWhere((e) => AppDateUtils.isSameDay(e.date, date));
    } catch (_) {
      return null;
    }
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    final maps = await _db.getMoodEntries();
    _entries = maps.map((m) => MoodEntry.fromMap(m)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(MoodEntry entry) async {
    // Check if today already has a mood entry — if so, update it
    final existing = todayEntry;
    if (existing != null && AppDateUtils.isSameDay(entry.date, existing.date)) {
      await _db.updateMoodEntry(existing.id!, entry.toMap());
      final idx = _entries.indexWhere((e) => e.id == existing.id);
      if (idx != -1) {
        _entries[idx] = entry.copyWith(id: existing.id);
      }
    } else {
      final id = await _db.insertMoodEntry(entry.toMap());
      _entries.insert(0, entry.copyWith(id: id));
    }
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteMoodEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
