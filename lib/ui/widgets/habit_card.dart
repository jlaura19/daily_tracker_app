// lib/ui/widgets/habit_card.dart

import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final UnifiedHabit habit;
  final bool isCompleted;
  final int? currentValue;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.currentValue,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = habit.getColor();
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? color : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon & Checkbox
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? color.withOpacity(0.2) 
                    : Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : habit.getIcon(),
                color: isCompleted ? color : Colors.grey[400],
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Habit Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted 
                        ? Colors.grey[400] 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCategoryChip(color),
                      if (habit.currentStreak > 0) ...[
                        const SizedBox(width: 8),
                        _buildStreakChip(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Progress/Value
            if (habit.type == HabitType.measurable) ...[
              const SizedBox(width: 12),
              _buildProgressIndicator(color),
            ] else ...[
              const SizedBox(width: 12),
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? color : Colors.grey[300],
                size: 32,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        habit.category.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStreakChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.orange, size: 12),
          const SizedBox(width: 4),
          Text(
            '${habit.currentStreak} DAY STREAK',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Color color) {
    final value = currentValue ?? 0;
    final target = habit.targetValue ?? 1;
    final progress = (value / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 4,
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '/ $target ${habit.unit ?? ''}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
