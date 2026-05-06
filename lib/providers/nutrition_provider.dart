import 'package:flutter/material.dart';
import 'package:mind_bloom/database/db_helper.dart';
import 'package:mind_bloom/models/meal_entry.dart';
import 'package:mind_bloom/models/water_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class NutritionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<MealEntry> _meals = [];
  int _todayWaterGlasses = 0;
  bool _isLoading = false;

  static const int waterGoal = 8;

  List<MealEntry> get meals => _meals;
  int get todayWaterGlasses => _todayWaterGlasses;
  bool get isLoading => _isLoading;

  List<MealEntry> get todayMeals {
    final today = AppDateUtils.today();
    return _meals.where((m) => AppDateUtils.isSameDay(m.date, today)).toList();
  }

  int get todayCalories {
    return todayMeals.fold<int>(0, (sum, m) => sum + (m.calories ?? 0));
  }

  int get todayMealCount => todayMeals.length;

  double get waterProgress => _todayWaterGlasses / waterGoal;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final mealMaps = await _db.getMealEntries();
    _meals = mealMaps.map((m) => MealEntry.fromMap(m)).toList();

    final todayKey = AppDateUtils.dateKey(AppDateUtils.today());
    _todayWaterGlasses = await _db.getWaterGlasses(todayKey);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeal(MealEntry meal) async {
    final id = await _db.insertMealEntry(meal.toMap());
    _meals.insert(0, meal.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteMeal(int id) async {
    await _db.deleteMealEntry(id);
    _meals.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> addWaterGlass() async {
    _todayWaterGlasses++;
    final todayKey = AppDateUtils.dateKey(AppDateUtils.today());
    await _db.setWaterGlasses(todayKey, _todayWaterGlasses);
    notifyListeners();
  }

  Future<void> removeWaterGlass() async {
    if (_todayWaterGlasses > 0) {
      _todayWaterGlasses--;
      final todayKey = AppDateUtils.dateKey(AppDateUtils.today());
      await _db.setWaterGlasses(todayKey, _todayWaterGlasses);
      notifyListeners();
    }
  }
}
