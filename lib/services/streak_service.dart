// lib/services/streak_service.dart

import 'package:daily_tracker_app/models/habit_completion.dart';
import 'package:daily_tracker_app/models/streak_data.dart';

class StreakService {
  // Calculate current streak from completions
  static int calculateCurrentStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;

    // Sort by date descending
    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Normalize to start of day
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (final completion in sorted) {
      final completionDay = DateTime(
        completion.completionDate.year,
        completion.completionDate.month,
        completion.completionDate.day,
      );

      // Check if completion is on the expected date
      if (completionDay.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (completionDay.isBefore(checkDate)) {
        // Gap in streak
        break;
      }
    }

    return streak;
  }

  // Calculate longest streak from completions
  static int calculateLongestStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;

    // Sort by date ascending
    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final completion in sorted) {
      final completionDay = DateTime(
        completion.completionDate.year,
        completion.completionDate.month,
        completion.completionDate.day,
      );

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = completionDay.difference(lastDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
        } else {
          longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
          currentStreak = 1;
        }
      }

      lastDate = completionDay;
    }

    return currentStreak > longestStreak ? currentStreak : longestStreak;
  }

  // Check if streak is at risk (not completed today)
  static bool isStreakAtRisk(List<HabitCompletion> completions) {
    if (completions.isEmpty) return false;

    final today = DateTime.now();
    final hasCompletionToday = completions.any((c) => 
      c.completionDate.year == today.year &&
      c.completionDate.month == today.month &&
      c.completionDate.day == today.day
    );

    return !hasCompletionToday && calculateCurrentStreak(completions) > 0;
  }

  // Get all streak periods
  static List<StreakData> calculateAllStreaks(int habitId, List<HabitCompletion> completions) {
    if (completions.isEmpty) return [];

    final streaks = <StreakData>[];
    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    DateTime? streakStart;
    DateTime? lastDate;
    int streakLength = 0;

    for (final completion in sorted) {
      final completionDay = DateTime(
        completion.completionDate.year,
        completion.completionDate.month,
        completion.completionDate.day,
      );

      if (lastDate == null) {
        streakStart = completionDay;
        streakLength = 1;
      } else {
        final daysDiff = completionDay.difference(lastDate).inDays;
        if (daysDiff == 1) {
          streakLength++;
        } else {
          // End current streak
          if (streakStart != null) {
            streaks.add(StreakData(
              habitId: habitId,
              startDate: streakStart,
              endDate: lastDate,
              length: streakLength,
              isActive: false,
            ));
          }
          streakStart = completionDay;
          streakLength = 1;
        }
      }

      lastDate = completionDay;
    }

    // Add final streak
    if (streakStart != null && lastDate != null) {
      final now = DateTime.now();
      final isActive = lastDate.year == now.year &&
                      lastDate.month == now.month &&
                      lastDate.day == now.day;
      
      streaks.add(StreakData(
        habitId: habitId,
        startDate: streakStart,
        endDate: isActive ? null : lastDate,
        length: streakLength,
        isActive: isActive,
      ));
    }

    return streaks;
  }

  // Get streak emoji based on length
  static String getStreakEmoji(int streak) {
    if (streak == 0) return '⭐';
    if (streak < 7) return '🔥';
    if (streak < 30) return '🔥🔥';
    if (streak < 100) return '🔥🔥🔥';
    return '👑';
  }

  // Calculate completion rate for a period
  static double calculateCompletionRate(
    List<HabitCompletion> completions,
    int daysPeriod,
  ) {
    if (daysPeriod == 0) return 0.0;
    
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysPeriod));
    
    final completionsInPeriod = completions.where((c) =>
      c.completionDate.isAfter(startDate)
    ).length;

    return (completionsInPeriod / daysPeriod).clamp(0.0, 1.0);
  }
}
