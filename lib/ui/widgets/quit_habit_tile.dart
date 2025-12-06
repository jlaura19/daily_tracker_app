// lib/ui/widgets/quit_habit_tile.dart

import 'dart:async';
import 'package:daily_tracker_app/models/quit_habit.dart';
import 'package:flutter/material.dart';

class QuitHabitTile extends StatefulWidget {
  final QuitHabit habit;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const QuitHabitTile({
    required this.habit,
    required this.onReset,
    required this.onDelete,
    super.key,
  });

  @override
  State<QuitHabitTile> createState() => _QuitHabitTileState();
}

class _QuitHabitTileState extends State<QuitHabitTile> {
  late Timer _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update every second for that "live" feel
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _duration = DateTime.now().difference(widget.habit.quitDate);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Determine color based on saved index
  Color _getThemeColor(int index) {
    const colors = [
      Color(0xFFA01A33), // Dark Red
      Color(0xFF1F4E5F), // Dark Teal
      Color(0xFF2E3A59), // Dark Navy
      Color(0xFF8B5E3C), // Brown
      Color(0xFF4A6FA5), // Muted Blue
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getThemeColor(widget.habit.colorIndex);
    
    // Calculate display strings
    final days = _duration.inDays;
    final hours = _duration.inHours % 24;
    final mins = _duration.inMinutes % 60;
    final secs = _duration.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Add a subtle border or shadow
        boxShadow: [
          BoxShadow(
             color: Colors.grey.withOpacity(0.1),
             blurRadius: 5,
             offset: const Offset(0, 2),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Colored Block
            Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              color: color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     widget.habit.title,
                     style: const TextStyle(
                       color: Colors.white, 
                       fontWeight: FontWeight.bold,
                       fontSize: 14,
                     ),
                     maxLines: 2,
                   ),
                   const SizedBox(height: 8),
                   // Reset icon button
                   InkWell(
                     onTap: widget.onReset,
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.2),
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.refresh, color: Colors.white, size: 16),
                     ),
                   )
                ],
              ),
            ),
            
            // Right Timer Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Major Time (Days)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$days", 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)
                          ),
                          const TextSpan(
                            text: "d ", 
                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                            text: "$hours", 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)
                          ),
                          const TextSpan(
                            text: "h ", 
                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)
                          ),
                        ]
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Minor Time (Mins, Secs)
                    Text(
                      "${mins}m, ${secs}s",
                      style: const TextStyle(
                        fontSize: 14, 
                        color: Colors.grey,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    if (widget.habit.resetCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${widget.habit.resetCount} resets",
                          style: TextStyle(fontSize: 10, color: Colors.red[300]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Delete Option (Long press or Icon)
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}