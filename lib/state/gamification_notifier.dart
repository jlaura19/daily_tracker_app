// lib/state/gamification_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/models/user_stats.dart';
import 'package:daily_tracker_app/services/gamification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for user stats
final userStatsProvider = StateNotifierProvider<GamificationNotifier, AsyncValue<UserStats>>((ref) {
  return GamificationNotifier();
});

class GamificationNotifier extends StateNotifier<AsyncValue<UserStats>> {
  GamificationNotifier() : super(const AsyncValue.loading()) {
    loadStats();
  }

  final _db = DatabaseHelper();

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _db.getUserStats();
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Achievement>> awardXP(UnifiedHabit habit, {bool isOnStreak = false}) async {
    try {
      final currentStats = await _db.getUserStats();
      
      // Calculate XP for this completion
      final xp = GamificationService.calculateXP(habit, isOnStreak: isOnStreak);
      final newTotalXP = currentStats.totalXP + xp;
      
      // Calculate new level
      final newLevel = GamificationService.calculateLevel(newTotalXP);
      
      // Check for new achievements
      final newAchievements = GamificationService.checkNewAchievements(
        habit,
        currentStats,
        habit.totalCompletions,
      );

      // Update stats
      final updatedStats = currentStats.copyWith(
        totalXP: newTotalXP,
        currentLevel: newLevel,
        achievements: [...currentStats.achievements, ...newAchievements],
        lastUpdated: DateTime.now(),
      );

      await _db.updateUserStats(updatedStats);
      state = AsyncValue.data(updatedStats);

      // Return new achievements for celebration
      return newAchievements;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetStats() async {
    try {
      final resetStats = UserStats(
        id: 1,
        totalXP: 0,
        currentLevel: 1,
        achievements: [],
        lastUpdated: DateTime.now(),
      );
      await _db.updateUserStats(resetStats);
      state = AsyncValue.data(resetStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Get motivational message based on current stats
  String getMotivationalMessage() {
    return state.maybeWhen(
      data: (stats) {
        if (stats.currentLevel < 5) return "You're just getting started! Keep going! 🌱";
        if (stats.currentLevel < 10) return "You're building great habits! 💪";
        if (stats.currentLevel < 20) return "You're a habit hero! 🌟";
        return "You're a legend! Keep inspiring! 👑";
      },
      orElse: () => "Start your journey today! 🚀",
    );
  }
}
