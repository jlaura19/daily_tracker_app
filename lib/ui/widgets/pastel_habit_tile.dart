// lib/ui/widgets/pastel_habit_tile.dart

import 'package:flutter/material.dart';

class PastelHabitTile extends StatelessWidget {
  final Color color;
  final String title;
  final String currentValue;
  final String targetValue;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PastelHabitTile({
    required this.color,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), // Light background color
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.4), // Slightly darker border
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Left side: Title and Progress Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with colored chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress text
                    Text(
                      '$currentValue / $targetValue',
                      style: TextStyle(
                        color: color, // FIXED: Removed .shade700
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right side: Trailing Widget
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}