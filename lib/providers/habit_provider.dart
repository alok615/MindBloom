import 'package:flutter/material.dart';
import 'package:mind_bloom/database/db_helper.dart';
import 'package:mind_bloom/models/habit.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class HabitProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Habit> _habits = [];
  Map<int, List<HabitLog>> _logs = {};
  Set<int> _todayCompleted = {};
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  int get todayCompletedCount => _todayCompleted.length;
  int get totalHabits => _habits.length;

  bool isCompletedToday(int habitId) => _todayCompleted.contains(habitId);

  int getStreak(int habitId) {
    final logs = _logs[habitId] ?? [];
    if (logs.isEmpty) return 0;

    int streak = 0;
    var checkDate = AppDateUtils.today();

    for (int i = 0; i < 365; i++) {
      final dateKey = AppDateUtils.dateKey(checkDate);
      final hasLog = logs.any((l) => AppDateUtils.dateKey(l.date) == dateKey);
      if (hasLog) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  List<bool> getWeekStatus(int habitId) {
    final days = AppDateUtils.lastNDays(7).reversed.toList();
    final logs = _logs[habitId] ?? [];
    return days.map((day) {
      final dateKey = AppDateUtils.dateKey(day);
      return logs.any((l) => AppDateUtils.dateKey(l.date) == dateKey);
    }).toList();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final habitMaps = await _db.getHabits();
    _habits = habitMaps.map((m) => Habit.fromMap(m)).toList();

    _logs = {};
    for (final habit in _habits) {
      final logMaps = await _db.getHabitLogs(habit.id!);
      _logs[habit.id!] = logMaps.map((m) => HabitLog.fromMap(m)).toList();
    }

    final todayKey = AppDateUtils.dateKey(AppDateUtils.today());
    final todayLogs = await _db.getAllHabitLogsForDate(todayKey);
    _todayCompleted = todayLogs.map((l) => l['habit_id'] as int).toSet();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    final id = await _db.insertHabit(habit.toMap());
    _habits.add(habit.copyWith(id: id));
    _logs[id] = [];
    notifyListeners();
  }

  Future<void> deleteHabit(int id) async {
    await _db.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    _logs.remove(id);
    _todayCompleted.remove(id);
    notifyListeners();
  }

  Future<void> toggleToday(int habitId) async {
    final todayKey = AppDateUtils.dateKey(AppDateUtils.today());
    await _db.toggleHabitLog(habitId, todayKey);

    if (_todayCompleted.contains(habitId)) {
      _todayCompleted.remove(habitId);
      _logs[habitId]?.removeWhere(
          (l) => AppDateUtils.dateKey(l.date) == todayKey);
    } else {
      _todayCompleted.add(habitId);
      _logs[habitId]?.insert(
          0, HabitLog(habitId: habitId, date: AppDateUtils.today()));
    }
    notifyListeners();
  }
}
