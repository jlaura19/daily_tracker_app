// lib/ui/widgets/level_progress.dart

import 'package:flutter/material.dart';

class LevelProgress extends StatelessWidget {
  final int currentLevel;
  final int totalXP;
  final bool isCompact;

  const LevelProgress({
    super.key,
    required this.currentLevel,
    required this.totalXP,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final xpForNextLevel = currentLevel * 100;
    final xpProgress = totalXP % 100;
    final progressPercentage = xpProgress / xpForNextLevel;

    if (isCompact) {
      return _buildCompactView(xpProgress, xpForNextLevel);
    }
    return _buildFullView(context, xpProgress, xpForNextLevel, progressPercentage);
  }

  Widget _buildCompactView(int xpProgress, int xpForNextLevel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.stars, color: Color(0xFFFFD700), size: 20),
        const SizedBox(width: 4),
        Text(
          'Lv $currentLevel',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildFullView(
    BuildContext context,
    int xpProgress,
    int xpForNextLevel,
    double progressPercentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.1),
            const Color(0xFFFFA500).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Color(0xFFFFD700),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $currentLevel',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        '$xpProgress / $xpForNextLevel XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLevelTitle(),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle() {
    if (currentLevel < 5) return 'Beginner - Keep building!';
    if (currentLevel < 10) return 'Rising Star - You\'re doing great!';
    if (currentLevel < 20) return 'Habit Hero - Impressive progress!';
    if (currentLevel < 50) return 'Master - You\'re unstoppable!';
    return 'Legend - You\'re an inspiration!';
  }
}
