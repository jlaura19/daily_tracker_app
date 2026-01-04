// lib/state/streak_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/habit_completion.dart';
import 'package:daily_tracker_app/services/streak_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for checking if a habit's streak is at risk
final streakAtRiskProvider = FutureProvider.family<bool, int>((ref, habitId) async {
  final db = DatabaseHelper();
  final completions = await db.getHabitCompletions(habitId);
  return StreakService.isStreakAtRisk(completions);
});

// Provider for habit completion rate
final completionRateProvider = FutureProvider.family<double, ({int habitId, int days})>((ref, params) async {
  final db = DatabaseHelper();
  final completions = await db.getHabitCompletions(params.habitId);
  return StreakService.calculateCompletionRate(completions, params.days);
});

// Provider for overall streak stats
final overallStreakStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = DatabaseHelper();
  final habits = await db.getAllUnifiedHabits();
  
  int totalActiveStreaks = 0;
  int longestStreak = 0;
  int habitsAtRisk = 0;

  for (final habit in habits) {
    if (habit.currentStreak > 0) {
      totalActiveStreaks++;
      if (habit.currentStreak > longestStreak) {
        longestStreak = habit.currentStreak;
      }
    }

    final completions = await db.getHabitCompletions(habit.id!);
    if (StreakService.isStreakAtRisk(completions)) {
      habitsAtRisk++;
    }
  }

  return {
    'totalActiveStreaks': totalActiveStreaks,
    'longestStreak': longestStreak,
    'habitsAtRisk': habitsAtRisk,
  };
});

class StreakNotifier extends StateNotifier<Map<int, List<HabitCompletion>>> {
  StreakNotifier() : super({});

  final _db = DatabaseHelper();

  Future<void> loadCompletions(int habitId) async {
    try {
      final completions = await _db.getHabitCompletions(habitId);
      state = {...state, habitId: completions};
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadAllCompletions(List<int> habitIds) async {
    try {
      final Map<int, List<HabitCompletion>> newState = {};
      for (final habitId in habitIds) {
        final completions = await _db.getHabitCompletions(habitId);
        newState[habitId] = completions;
      }
      state = newState;
    } catch (e) {
      // Handle error
    }
  }

  int getCurrentStreak(int habitId) {
    final completions = state[habitId] ?? [];
    return StreakService.calculateCurrentStreak(completions);
  }

  int getLongestStreak(int habitId) {
    final completions = state[habitId] ?? [];
    return StreakService.calculateLongestStreak(completions);
  }

  bool isStreakAtRisk(int habitId) {
    final completions = state[habitId] ?? [];
    return StreakService.isStreakAtRisk(completions);
  }

  String getStreakEmoji(int habitId) {
    final streak = getCurrentStreak(habitId);
    return StreakService.getStreakEmoji(streak);
  }
}

final streakNotifierProvider = StateNotifierProvider<StreakNotifier, Map<int, List<HabitCompletion>>>((ref) {
  return StreakNotifier();
});
