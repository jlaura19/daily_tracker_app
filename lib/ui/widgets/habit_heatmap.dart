// lib/ui/widgets/habit_heatmap.dart

import 'package:flutter/material.dart';

class HabitHeatmap extends StatelessWidget {
  final Color color;
  final List<DateTime> completionDates;

  const HabitHeatmap({
    required this.color,
    required this.completionDates,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Generate the last 60 days to show in the grid
    final now = DateTime.now();
    final days = List.generate(60, (index) {
      return now.subtract(Duration(days: 59 - index));
    });

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((date) {
        final isCompleted = _isCompletedOnDate(date);
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            // Filled color if completed, faint color if not
            color: isCompleted ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  bool _isCompletedOnDate(DateTime date) {
    // Check if any completion date matches this day
    return completionDates.any((completed) =>
        completed.year == date.year &&
        completed.month == date.month &&
        completed.day == date.day);
  }
}