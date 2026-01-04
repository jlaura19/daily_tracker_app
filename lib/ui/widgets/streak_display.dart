// lib/ui/widgets/streak_display.dart

import 'package:flutter/material.dart';

class StreakDisplay extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isCompact;

  const StreakDisplay({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView();
    }
    return _buildFullView(context);
  }

  Widget _buildCompactView() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getStreakEmoji(),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 4),
        Text(
          '$currentStreak',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }

  Widget _buildFullView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.1),
            const Color(0xFFFF8C42).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getStreakEmoji(),
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak Day Streak',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Longest: $longestStreak days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: 12),
            Text(
              _getMotivationalMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStreakEmoji() {
    if (currentStreak == 0) return '⭐';
    if (currentStreak < 7) return '🔥';
    if (currentStreak < 30) return '🔥🔥';
    if (currentStreak < 100) return '🔥🔥🔥';
    return '👑';
  }

  String _getMotivationalMessage() {
    if (currentStreak == 0) return "Start your journey today!";
    if (currentStreak == 1) return "Great start! Keep it up!";
    if (currentStreak < 7) return "You're building momentum!";
    if (currentStreak == 7) return "One week strong! Amazing!";
    if (currentStreak < 30) return "You're on fire! Keep going!";
    if (currentStreak == 30) return "One month! You're unstoppable!";
    if (currentStreak < 100) return "Legendary streak!";
    return "You're a habit master!";
  }
}
