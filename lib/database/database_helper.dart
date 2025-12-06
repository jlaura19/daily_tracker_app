// lib/database/database_helper.dart

import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/models/quit_habit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'daily_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // SQL to create the tables
  Future _onCreate(Database db, int version) async {
    // 1. Tracking Entries Table (Updated with isCompleted)
    await db.execute('''
      CREATE TABLE tracking_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER,
        type TEXT,
        name TEXT,
        notes TEXT,
        value INTEGER,
        isCompleted INTEGER DEFAULT 0 
      )
    ''');
    
    // 2. Daily Checklist Items Table
    await db.execute('''
      CREATE TABLE checklist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskName TEXT NOT NULL,
        iconName TEXT,
        sortOrder INTEGER,
        reminderTime TEXT
      )
    ''');
    
    // 3. Checklist History Table
    await db.execute('''
      CREATE TABLE checklist_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER,
        completionDate INTEGER,
        FOREIGN KEY(itemId) REFERENCES checklist_items(id)
      )
    ''');
    
    // 4. Exercises Table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        defaultDurationSeconds INTEGER,
        sortOrder INTEGER
      )
    ''');

    // 5. Quit Habits Table
    await db.execute('''
      CREATE TABLE quit_habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        quitDate INTEGER,
        colorIndex INTEGER,
        resetCount INTEGER
      )
    ''');
  }

  // --- Tracking Entry CRUD ---
  Future<int> insertEntry(TrackingEntry entry) async {
    final db = await database;
    return await db.insert('tracking_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TrackingEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tracking_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TrackingEntry.fromMap(maps[i]));
  }

  // NEW: Toggle completion for Schedule Screen
  Future<void> toggleEntryCompletion(int id, bool currentStatus) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE tracking_entries SET isCompleted = ? WHERE id = ?',
      [currentStatus ? 0 : 1, id],
    );
  }
  
  Future<List<Map<String, dynamic>>> getSummaryByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    return await db.rawQuery('''
      SELECT type, COUNT(id) as count
      FROM tracking_entries
      WHERE date >= $startMs AND date <= $endMs
      GROUP BY type
    ''');
  }

  // --- Checklist CRUD ---
  Future<int> insertChecklistItem(DailyChecklistItem item) async {
    final db = await database;
    return await db.insert('checklist_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<DailyChecklistItem>> getChecklistItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checklist_items', orderBy: 'sortOrder ASC');
    return List.generate(maps.length, (i) => DailyChecklistItem.fromMap(maps[i]));
  }
  
  Future<int> insertChecklistHistory(ChecklistHistory history) async {
    final db = await database;
    return await db.insert('checklist_history', history.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<ChecklistHistory>> getCompletedTasksToday() async {
      final db = await database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM checklist_history 
        WHERE completionDate >= $startOfDay
      ''');
      return List.generate(maps.length, (i) => ChecklistHistory.fromMap(maps[i]));
  }

  Future<List<ChecklistHistory>> getAllChecklistHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checklist_history');
    return List.generate(maps.length, (i) => ChecklistHistory.fromMap(maps[i]));
  }

  // --- Exercise CRUD ---
  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises', orderBy: 'sortOrder ASC');
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }
  
  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // --- Quit Habit CRUD ---
  Future<int> insertQuitHabit(QuitHabit habit) async {
    final db = await database;
    return await db.insert('quit_habits', habit.toMap());
  }

  Future<List<QuitHabit>> getQuitHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('quit_habits');
    return List.generate(maps.length, (i) => QuitHabit.fromMap(maps[i]));
  }

  Future<int> updateQuitHabit(QuitHabit habit) async {
    final db = await database;
    return await db.update('quit_habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }
  
  Future<int> deleteQuitHabit(int id) async {
    final db = await database;
    return await db.delete('quit_habits', where: 'id = ?', whereArgs: [id]);
  }
}