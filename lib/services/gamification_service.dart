// lib/services/gamification_service.dart

import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/models/user_stats.dart';

class GamificationService {
  // XP calculation
  static int calculateXP(UnifiedHabit habit, {bool isOnStreak = false}) {
    int baseXP = 10;
    
    // Bonus for streak
    if (isOnStreak && habit.currentStreak > 0) {
      baseXP = (baseXP * 1.5).toInt();
    }
    
    // Bonus for long streaks
    if (habit.currentStreak >= 7) baseXP += 5;
    if (habit.currentStreak >= 30) baseXP += 10;
    if (habit.currentStreak >= 100) baseXP += 20;
    
    // Bonus for habit type (harder habits = more XP)
    switch (habit.type) {
      case HabitType.measurable:
        baseXP += 2;
        break;
      case HabitType.timed:
        baseXP += 3;
        break;
      case HabitType.avoid:
        baseXP += 5; // Hardest to maintain
        break;
      default:
        break;
    }
    
    return baseXP;
  }

  // Calculate level from total XP
  static int calculateLevel(int totalXP) {
    return (totalXP / 100).floor() + 1;
  }

  // Calculate XP needed for next level
  static int xpForLevel(int level) {
    return level * 100;
  }

  // Check for new achievements
  static List<Achievement> checkNewAchievements(
    UnifiedHabit habit,
    UserStats currentStats,
    int totalHabitsCompleted,
  ) {
    final newAchievements = <Achievement>[];
    final now = DateTime.now();

    // First Step - Complete first habit
    if (totalHabitsCompleted == 1 && 
        !_hasAchievement(currentStats, 'first_step')) {
      newAchievements.add(Achievement(
        id: 'first_step',
        name: 'First Step',
        description: 'Complete your first habit',
        iconName: 'emoji_events',
        unlockedAt: now,
      ));
    }

    // Week Warrior - 7 day streak
    if (habit.currentStreak == 7 && 
        !_hasAchievement(currentStats, 'week_warrior')) {
      newAchievements.add(Achievement(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        iconName: 'local_fire_department',
        unlockedAt: now,
      ));
    }

    // Month Master - 30 day streak
    if (habit.currentStreak == 30 && 
        !_hasAchievement(currentStats, 'month_master')) {
      newAchievements.add(Achievement(
        id: 'month_master',
        name: 'Month Master',
        description: 'Maintain a 30-day streak',
        iconName: 'military_tech',
        unlockedAt: now,
      ));
    }

    // Century Club - 100 total completions
    if (habit.totalCompletions == 100 && 
        !_hasAchievement(currentStats, 'century_club')) {
      newAchievements.add(Achievement(
        id: 'century_club',
        name: 'Century Club',
        description: 'Complete a habit 100 times',
        iconName: 'workspace_premium',
        unlockedAt: now,
      ));
    }

    // Level milestones
    if (currentStats.currentLevel == 5 && 
        !_hasAchievement(currentStats, 'level_5')) {
      newAchievements.add(Achievement(
        id: 'level_5',
        name: 'Rising Star',
        description: 'Reach level 5',
        iconName: 'star',
        unlockedAt: now,
      ));
    }

    if (currentStats.currentLevel == 10 && 
        !_hasAchievement(currentStats, 'level_10')) {
      newAchievements.add(Achievement(
        id: 'level_10',
        name: 'Habit Hero',
        description: 'Reach level 10',
        iconName: 'stars',
        unlockedAt: now,
      ));
    }

    return newAchievements;
  }

  static bool _hasAchievement(UserStats stats, String achievementId) {
    return stats.achievements.any((a) => a.id == achievementId);
  }

  // Get motivational message based on streak
  static String getMotivationalMessage(int streak) {
    if (streak == 0) return "Start your journey today! 🌟";
    if (streak == 1) return "Great start! Keep it up! 💪";
    if (streak < 7) return "You're building momentum! 🚀";
    if (streak == 7) return "One week strong! Amazing! 🔥";
    if (streak < 30) return "You're on fire! Keep going! 🎯";
    if (streak == 30) return "One month! You're unstoppable! 🏆";
    if (streak < 100) return "Legendary streak! 👑";
    return "You're a habit master! 🌟✨";
  }

  // Get celebration level (for animation intensity)
  static int getCelebrationLevel(int streak) {
    if (streak >= 100) return 3; // Epic celebration
    if (streak >= 30) return 2;  // Big celebration
    if (streak >= 7) return 2;   // Big celebration
    return 1; // Normal celebration
  }
}
