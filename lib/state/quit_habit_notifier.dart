// lib/state/quit_habit_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/quit_habit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuitHabitNotifier extends StateNotifier<AsyncValue<List<QuitHabit>>> {
  QuitHabitNotifier() : super(const AsyncValue.loading()) {
    _loadHabits();
  }

  final dbHelper = DatabaseHelper();

  Future<void> _loadHabits() async {
    try {
      final habits = await dbHelper.getQuitHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addQuitHabit(String title, int colorIndex) async {
    final habit = QuitHabit(
      title: title,
      quitDate: DateTime.now(),
      colorIndex: colorIndex,
    );
    await dbHelper.insertQuitHabit(habit);
    _loadHabits();
  }

  Future<void> resetHabit(QuitHabit habit) async {
    // Reset the date to NOW and increment reset count
    final updated = QuitHabit(
      id: habit.id,
      title: habit.title,
      quitDate: DateTime.now(),
      colorIndex: habit.colorIndex,
      resetCount: habit.resetCount + 1,
    );
    await dbHelper.updateQuitHabit(updated);
    _loadHabits();
  }
  
  Future<void> deleteHabit(int id) async {
    await dbHelper.deleteQuitHabit(id);
    _loadHabits();
  }
}

final quitHabitProvider = StateNotifierProvider<QuitHabitNotifier, AsyncValue<List<QuitHabit>>>(
  (ref) => QuitHabitNotifier(),
);