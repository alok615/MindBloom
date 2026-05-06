import 'package:flutter/material.dart';
import 'package:mind_bloom/database/db_helper.dart';
import 'package:mind_bloom/models/sleep_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class SleepProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<SleepEntry> _entries = [];
  bool _isLoading = false;

  List<SleepEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  SleepEntry? get todayEntry {
    final today = AppDateUtils.today();
    try {
      return _entries.firstWhere((e) => AppDateUtils.isSameDay(e.date, today));
    } catch (_) {
      return null;
    }
  }

  double get averageSleepHours {
    if (_entries.isEmpty) return 0;
    final recent = _entries.take(7).toList();
    final totalMinutes =
        recent.fold<int>(0, (sum, e) => sum + e.duration.inMinutes);
    return totalMinutes / recent.length / 60;
  }

  double get averageQuality {
    if (_entries.isEmpty) return 0;
    final recent = _entries.take(7).toList();
    return recent.fold<int>(0, (sum, e) => sum + e.quality) / recent.length;
  }

  List<SleepEntry> get thisWeekEntries {
    final days = AppDateUtils.lastNDays(7);
    return _entries.where((e) {
      return days.any((d) => AppDateUtils.isSameDay(e.date, d));
    }).toList();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    final maps = await _db.getSleepEntries();
    _entries = maps.map((m) => SleepEntry.fromMap(m)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(SleepEntry entry) async {
    final id = await _db.insertSleepEntry(entry.toMap());
    _entries.insert(0, entry.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteSleepEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
