// lib/state/unified_habit_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/habit_completion.dart';
import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/services/gamification_service.dart';
import 'package:daily_tracker_app/services/streak_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for all unified habits
final unifiedHabitProvider = StateNotifierProvider<UnifiedHabitNotifier, AsyncValue<List<UnifiedHabit>>>((ref) {
  return UnifiedHabitNotifier();
});

// Provider for habit completions map (habitId -> completions)
final habitCompletionsProvider = FutureProvider.family<List<HabitCompletion>, int>((ref, habitId) async {
  final db = DatabaseHelper();
  return await db.getHabitCompletions(habitId);
});

// Provider for today's completions
final todayCompletionsProvider = FutureProvider<List<HabitCompletion>>((ref) async {
  final db = DatabaseHelper();
  return await db.getTodayCompletions();
});

class UnifiedHabitNotifier extends StateNotifier<AsyncValue<List<UnifiedHabit>>> {
  UnifiedHabitNotifier() : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final _db = DatabaseHelper();

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _db.getAllUnifiedHabits();
      state = AsyncValue.data(habits);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addHabit(UnifiedHabit habit) async {
    try {
      await _db.insertUnifiedHabit(habit);
      await loadHabits();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> updateHabit(UnifiedHabit habit) async {
    try {
      await _db.updateUnifiedHabit(habit);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _db.deleteUnifiedHabit(id);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeHabit(UnifiedHabit habit, {int? value}) async {
    try {
      // Create completion record
      final completion = HabitCompletion(
        habitId: habit.id!,
        completionDate: DateTime.now(),
        value: value,
      );
      await _db.insertHabitCompletion(completion);

      // Get all completions for this habit
      final completions = await _db.getHabitCompletions(habit.id!);

      // Update streaks
      final currentStreak = StreakService.calculateCurrentStreak(completions);
      final longestStreak = StreakService.calculateLongestStreak(completions);

      // Update habit with new stats
      final updatedHabit = habit.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak > habit.longestStreak ? longestStreak : habit.longestStreak,
        totalCompletions: habit.totalCompletions + 1,
      );

      await _db.updateUnifiedHabit(updatedHabit);

      // Reload habits
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uncompleteHabit(int habitId, DateTime date) async {
    try {
      // Find and delete the completion for this date
      final completions = await _db.getHabitCompletions(habitId);
      final completion = completions.firstWhere(
        (c) => c.isOnDate(date),
        orElse: () => throw Exception('Completion not found'),
      );

      if (completion.id != null) {
        await _db.deleteHabitCompletion(completion.id!);
      }

      // Recalculate streaks
      final habit = await _db.getUnifiedHabitById(habitId);
      if (habit != null) {
        final updatedCompletions = await _db.getHabitCompletions(habitId);
        final currentStreak = StreakService.calculateCurrentStreak(updatedCompletions);
        final longestStreak = StreakService.calculateLongestStreak(updatedCompletions);

        final updatedHabit = habit.copyWith(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          totalCompletions: habit.totalCompletions - 1,
        );

        await _db.updateUnifiedHabit(updatedHabit);
      }

      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  // Check if habit is completed today
  Future<bool> isCompletedToday(int habitId) async {
    final completions = await _db.getHabitCompletions(habitId);
    return completions.any((c) => c.isToday());
  }

  // Get today's completion value (for measurable habits)
  Future<int?> getTodayValue(int habitId) async {
    final completions = await _db.getHabitCompletions(habitId);
    final todayCompletion = completions.firstWhere(
      (c) => c.isToday(),
      orElse: () => HabitCompletion(habitId: habitId, completionDate: DateTime.now()),
    );
    return todayCompletion.value;
  }
}
