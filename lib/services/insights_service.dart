// lib/services/insights_service.dart

import 'package:daily_tracker_app/models/habit_completion.dart';
import 'package:daily_tracker_app/models/unified_habit.dart';

class InsightsService {
  // Generate weekly summary
  static String generateWeeklySummary(
    List<UnifiedHabit> habits,
    Map<int, List<HabitCompletion>> completionsMap,
  ) {
    int totalCompletions = 0;
    int totalPossible = habits.length * 7;

    for (final habit in habits) {
      final completions = completionsMap[habit.id] ?? [];
      final weekCompletions = completions.where((c) {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return c.completionDate.isAfter(weekAgo);
      }).length;
      totalCompletions += weekCompletions;
    }

    final percentage = totalPossible > 0 
        ? ((totalCompletions / totalPossible) * 100).toInt() 
        : 0;

    if (percentage >= 90) return "Amazing week! You completed $percentage% of your habits! 🌟";
    if (percentage >= 70) return "Great week! You completed $percentage% of your habits! 💪";
    if (percentage >= 50) return "Good effort! You completed $percentage% of your habits. Keep going! 🎯";
    return "You completed $percentage% of your habits this week. Let's aim higher! 🚀";
  }

  // Find best day of week
  static String findBestDay(Map<int, List<HabitCompletion>> completionsMap) {
    final dayCompletions = <int, int>{};
    
    for (final completions in completionsMap.values) {
      for (final completion in completions) {
        final dayOfWeek = completion.completionDate.weekday;
        dayCompletions[dayOfWeek] = (dayCompletions[dayOfWeek] ?? 0) + 1;
      }
    }

    if (dayCompletions.isEmpty) return "Not enough data yet. Keep tracking!";

    final bestDay = dayCompletions.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    ).key;

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return "You're most consistent on ${dayNames[bestDay - 1]}s! 📅";
  }

  // Find worst day of week
  static String findWorstDay(Map<int, List<HabitCompletion>> completionsMap) {
    final dayCompletions = <int, int>{};
    
    for (final completions in completionsMap.values) {
      for (final completion in completions) {
        final dayOfWeek = completion.completionDate.weekday;
        dayCompletions[dayOfWeek] = (dayCompletions[dayOfWeek] ?? 0) + 1;
      }
    }

    if (dayCompletions.isEmpty) return "";

    final worstDay = dayCompletions.entries.reduce((a, b) => 
      a.value < b.value ? a : b
    ).key;

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return "${dayNames[worstDay - 1]}s need more attention 💡";
  }

  // Find best time of day
  static String findBestTimeOfDay(Map<int, List<HabitCompletion>> completionsMap) {
    final hourCompletions = <int, int>{};
    
    for (final completions in completionsMap.values) {
      for (final completion in completions) {
        final hour = completion.completionDate.hour;
        hourCompletions[hour] = (hourCompletions[hour] ?? 0) + 1;
      }
    }

    if (hourCompletions.isEmpty) return "";

    final bestHour = hourCompletions.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    ).key;

    String timeOfDay;
    if (bestHour < 12) {
      timeOfDay = "morning";
    } else if (bestHour < 17) {
      timeOfDay = "afternoon";
    } else {
      timeOfDay = "evening";
    }

    return "You're most productive in the $timeOfDay ⏰";
  }

  // Generate personalized tips
  static List<String> generateTips(
    List<UnifiedHabit> habits,
    Map<int, List<HabitCompletion>> completionsMap,
  ) {
    final tips = <String>[];

    // Check for habits with low completion rate
    for (final habit in habits) {
      final completions = completionsMap[habit.id] ?? [];
      if (completions.length < 3 && habit.createdAt.isBefore(
        DateTime.now().subtract(const Duration(days: 7))
      )) {
        tips.add("Try setting a reminder for '${habit.name}' to build consistency");
      }
    }

    // Check for streaks at risk
    for (final habit in habits) {
      final completions = completionsMap[habit.id] ?? [];
      if (habit.currentStreak > 7) {
        final today = DateTime.now();
        final hasToday = completions.any((c) =>
          c.completionDate.year == today.year &&
          c.completionDate.month == today.month &&
          c.completionDate.day == today.day
        );
        if (!hasToday) {
          tips.add("Don't break your ${habit.currentStreak}-day streak for '${habit.name}'! 🔥");
        }
      }
    }

    // Suggest habit stacking
    if (habits.length >= 2) {
      tips.add("Try habit stacking: Do one habit right after another!");
    }

    // Encourage variety
    final categories = habits.map((h) => h.category).toSet();
    if (categories.length == 1) {
      tips.add("Consider adding habits from different categories for balanced growth");
    }

    return tips.take(3).toList(); // Return top 3 tips
  }

  // Calculate category distribution
  static Map<HabitCategory, int> getCategoryDistribution(List<UnifiedHabit> habits) {
    final distribution = <HabitCategory, int>{};
    for (final habit in habits) {
      distribution[habit.category] = (distribution[habit.category] ?? 0) + 1;
    }
    return distribution;
  }

  // Get completion trend (improving, declining, stable)
  static String getCompletionTrend(Map<int, List<HabitCompletion>> completionsMap) {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    int lastWeekCount = 0;
    int previousWeekCount = 0;

    for (final completions in completionsMap.values) {
      lastWeekCount += completions.where((c) => 
        c.completionDate.isAfter(lastWeek)
      ).length;
      
      previousWeekCount += completions.where((c) => 
        c.completionDate.isAfter(twoWeeksAgo) && c.completionDate.isBefore(lastWeek)
      ).length;
    }

    if (previousWeekCount == 0) return "Keep building your habits! 🌱";
    
    final change = ((lastWeekCount - previousWeekCount) / previousWeekCount * 100).toInt();
    
    if (change > 10) return "You're improving! $change% more completions than last week 📈";
    if (change < -10) return "Let's get back on track! $change% fewer completions than last week 📉";
    return "You're maintaining consistency! 🎯";
  }
}
