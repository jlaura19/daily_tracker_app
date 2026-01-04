// lib/ui/widgets/pastel_tracking_tile.dart

import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class PastelTrackingTile extends StatelessWidget {
  final TrackingEntry entry;

  const PastelTrackingTile({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Determine Color based on Type
    final themeColor = _getColorForType(entry.type);
    
    // 2. Format Time
    final timeString = DateFormat('h:mm a').format(entry.date);
    final dateString = DateFormat('MMM d').format(entry.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // --- Left Color Strip & Icon ---
            Container(
              width: 70,
              height: 80, // Fixed height for consistency
              color: themeColor.withValues(alpha: 0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getIconForType(entry.type), color: themeColor, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: themeColor.withValues(alpha: 0.8),
                    ),
                  )
                ],
              ),
            ),

            // --- Main Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.type.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ),
                        // Time
                        Text(
                          timeString,
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Entry Name
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Notes / Value
                    if (entry.value != null || (entry.notes != null && entry.notes!.isNotEmpty)) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatSubtitle(entry),
                        style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSubtitle(TrackingEntry entry) {
    final parts = <String>[];
    if (entry.value != null) parts.add('Value: ${entry.value}');
    if (entry.notes != null && entry.notes!.isNotEmpty) parts.add(entry.notes!);
    return parts.join(' • ');
  }

  Color _getColorForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Colors.orange;
      case TrackerType.meal: return const Color(0xFF5AB75A); // Green
      case TrackerType.fitness: return const Color(0xFFFF6B6B); // Red/Pink
      case TrackerType.focus: return const Color(0xFF8059FF); // Purple
      case TrackerType.sports: return const Color(0xFF00BCD4);
      case TrackerType.healthcare: return const Color(0xFFE91E63);
      case TrackerType.plan: return const Color(0xFF607D8B);
    }
  }

  IconData _getIconForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Icons.local_fire_department;
      case TrackerType.meal: return Icons.restaurant;
      case TrackerType.fitness: return Icons.fitness_center;
      case TrackerType.focus: return Icons.self_improvement;
      case TrackerType.sports: return Icons.sports_soccer;
      case TrackerType.healthcare: return Icons.local_hospital;
      case TrackerType.plan: return Icons.event_note;
    }
  }
}