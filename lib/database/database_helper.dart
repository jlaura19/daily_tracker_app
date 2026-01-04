// lib/database/database_helper.dart

import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/models/quit_habit.dart';
import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/models/habit_completion.dart';
import 'package:daily_tracker_app/models/streak_data.dart';
import 'package:daily_tracker_app/models/user_stats.dart';
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
      version: 2, // Incremented for new schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // SQL to create ALL tables
  Future _onCreate(Database db, int version) async {
    // 1. Tracking Entries Table (Updated for Schedule features)
    await db.execute('''
      CREATE TABLE tracking_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER,
        endTime INTEGER,
        type TEXT,
        name TEXT,
        notes TEXT,
        value INTEGER,
        isCompleted INTEGER DEFAULT 0,
        isReminderOn INTEGER DEFAULT 0,
        repeat TEXT
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

    // NEW: 6. Unified Habits Table
    await db.execute('''
      CREATE TABLE unified_habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        target_value INTEGER,
        unit TEXT,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        total_completions INTEGER DEFAULT 0,
        reminder_time TEXT,
        reminder_days TEXT,
        reminder_enabled INTEGER DEFAULT 0,
        icon_name TEXT,
        color_index INTEGER,
        sort_order INTEGER,
        created_at INTEGER NOT NULL,
        notes TEXT,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    // NEW: 7. Habit Completions Table
    await db.execute('''
      CREATE TABLE habit_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completion_date INTEGER NOT NULL,
        value INTEGER,
        notes TEXT,
        FOREIGN KEY(habit_id) REFERENCES unified_habits(id) ON DELETE CASCADE
      )
    ''');

    // NEW: 8. User Stats Table
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY,
        total_xp INTEGER DEFAULT 0,
        current_level INTEGER DEFAULT 1,
        achievements TEXT,
        last_updated INTEGER
      )
    ''');

    // NEW: 9. Streaks Table
    await db.execute('''
      CREATE TABLE streaks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        length INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY(habit_id) REFERENCES unified_habits(id) ON DELETE CASCADE
      )
    ''');

    // Initialize user stats
    await db.insert('user_stats', {
      'id': 1,
      'total_xp': 0,
      'current_level': 1,
      'achievements': '[]',
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Migration from v1 to v2
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for unified habits system
      await db.execute('''
        CREATE TABLE unified_habits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          frequency TEXT NOT NULL,
          target_value INTEGER,
          unit TEXT,
          current_streak INTEGER DEFAULT 0,
          longest_streak INTEGER DEFAULT 0,
          total_completions INTEGER DEFAULT 0,
          reminder_time TEXT,
          reminder_days TEXT,
          reminder_enabled INTEGER DEFAULT 0,
          icon_name TEXT,
          color_index INTEGER,
          sort_order INTEGER,
          created_at INTEGER NOT NULL,
          notes TEXT,
          is_archived INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE habit_completions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          completion_date INTEGER NOT NULL,
          value INTEGER,
          notes TEXT,
          FOREIGN KEY(habit_id) REFERENCES unified_habits(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE user_stats (
          id INTEGER PRIMARY KEY,
          total_xp INTEGER DEFAULT 0,
          current_level INTEGER DEFAULT 1,
          achievements TEXT,
          last_updated INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE streaks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          start_date INTEGER NOT NULL,
          end_date INTEGER,
          length INTEGER NOT NULL,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY(habit_id) REFERENCES unified_habits(id) ON DELETE CASCADE
        )
      ''');

      // Initialize user stats
      await db.insert('user_stats', {
        'id': 1,
        'total_xp': 0,
        'current_level': 1,
        'achievements': '[]',
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      });
    }
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

  // Toggle completion for Schedule Screen checkboxes
  Future<void> toggleEntryCompletion(int id, bool currentStatus) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE tracking_entries SET isCompleted = ? WHERE id = ?',
      [currentStatus ? 0 : 1, id],
    );
  }
  
  // For the Consistency Chart
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

  // Get full history for the Reports Heatmap
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

  // --- UNIFIED HABITS CRUD ---
  Future<int> insertUnifiedHabit(UnifiedHabit habit) async {
    final db = await database;
    return await db.insert('unified_habits', habit.toMap());
  }

  Future<List<UnifiedHabit>> getAllUnifiedHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unified_habits',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => UnifiedHabit.fromMap(maps[i]));
  }

  Future<UnifiedHabit?> getUnifiedHabitById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'unified_habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UnifiedHabit.fromMap(maps.first);
  }

  Future<int> updateUnifiedHabit(UnifiedHabit habit) async {
    final db = await database;
    return await db.update(
      'unified_habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteUnifiedHabit(int id) async {
    final db = await database;
    return await db.delete('unified_habits', where: 'id = ?', whereArgs: [id]);
  }

  // --- HABIT COMPLETIONS CRUD ---
  Future<int> insertHabitCompletion(HabitCompletion completion) async {
    final db = await database;
    return await db.insert('habit_completions', completion.toMap());
  }

  Future<List<HabitCompletion>> getHabitCompletions(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completion_date DESC',
    );
    return List.generate(maps.length, (i) => HabitCompletion.fromMap(maps[i]));
  }

  Future<List<HabitCompletion>> getTodayCompletions() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'completion_date >= ? AND completion_date <= ?',
      whereArgs: [startOfDay, endOfDay],
    );
    return List.generate(maps.length, (i) => HabitCompletion.fromMap(maps[i]));
  }

  Future<int> deleteHabitCompletion(int id) async {
    final db = await database;
    return await db.delete('habit_completions', where: 'id = ?', whereArgs: [id]);
  }

  // --- USER STATS CRUD ---
  Future<UserStats> getUserStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_stats',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isEmpty) {
      await db.insert('user_stats', {
        'id': 1,
        'total_xp': 0,
        'current_level': 1,
        'achievements': '[]',
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      });
      return UserStats();
    }
    return UserStats.fromMap(maps.first);
  }

  Future<int> updateUserStats(UserStats stats) async {
    final db = await database;
    return await db.update(
      'user_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}