import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mindbloom.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sleep_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        bed_time TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        quality INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood INTEGER NOT NULL,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        description TEXT NOT NULL,
        calories INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE water_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        glasses INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');
  }

  // ──────────────────────── Sleep ────────────────────────

  Future<int> insertSleepEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('sleep_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getSleepEntries({int limit = 30}) async {
    final db = await database;
    return await db.query('sleep_entries', orderBy: 'date DESC', limit: limit);
  }

  Future<int> deleteSleepEntry(int id) async {
    final db = await database;
    return await db.delete('sleep_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ──────────────────────── Mood ────────────────────────

  Future<int> insertMoodEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('mood_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getMoodEntries({int limit = 60}) async {
    final db = await database;
    return await db.query('mood_entries', orderBy: 'date DESC', limit: limit);
  }

  Future<int> deleteMoodEntry(int id) async {
    final db = await database;
    return await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateMoodEntry(int id, Map<String, dynamic> entry) async {
    final db = await database;
    return await db.update('mood_entries', entry, where: 'id = ?', whereArgs: [id]);
  }

  // ──────────────────────── Meals ────────────────────────

  Future<int> insertMealEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('meal_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getMealEntries({int limit = 30}) async {
    final db = await database;
    return await db.query('meal_entries', orderBy: 'date DESC', limit: limit);
  }

  Future<int> deleteMealEntry(int id) async {
    final db = await database;
    return await db.delete('meal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ──────────────────────── Water ────────────────────────

  Future<void> setWaterGlasses(String dateKey, int glasses) async {
    final db = await database;
    await db.insert(
      'water_entries',
      {'date': dateKey, 'glasses': glasses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getWaterGlasses(String dateKey) async {
    final db = await database;
    final results = await db.query(
      'water_entries',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    if (results.isEmpty) return 0;
    return results.first['glasses'] as int;
  }

  Future<List<Map<String, dynamic>>> getWaterHistory({int limit = 7}) async {
    final db = await database;
    return await db.query('water_entries', orderBy: 'date DESC', limit: limit);
  }

  // ──────────────────────── Habits ────────────────────────

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    return await db.query('habits', orderBy: 'created_at ASC');
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleHabitLog(int habitId, String dateKey) async {
    final db = await database;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateKey],
    );
    if (existing.isEmpty) {
      await db.insert('habit_logs', {'habit_id': habitId, 'date': dateKey});
    } else {
      await db.delete(
        'habit_logs',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, dateKey],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(int habitId,
      {int limit = 60}) async {
    final db = await database;
    return await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getAllHabitLogsForDate(
      String dateKey) async {
    final db = await database;
    return await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
  }
}
