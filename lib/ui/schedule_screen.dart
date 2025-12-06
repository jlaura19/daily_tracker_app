// lib/ui/schedule_screen.dart

import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/state/tracker_notifier.dart';
import 'package:daily_tracker_app/database/database_helper.dart'; // Import DB Helper
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackerState = ref.watch(trackerNotifierProvider);
    final dateStr = DateFormat('MMM d, yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.black), 
            onPressed: () => setState(() => _selectedDate = DateTime.now()),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Date Navigation Header ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16), 
                  onPressed: () => _changeDate(-1),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16), 
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),
          
          // --- Timeline ---
          Expanded(
            child: trackerState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allEntries) {
                // Filter for SELECTED DATE
                final dayEntries = allEntries.where((e) {
                  return e.date.year == _selectedDate.year && 
                         e.date.month == _selectedDate.month && 
                         e.date.day == _selectedDate.day;
                }).toList();

                if (dayEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No activities planned."),
                        TextButton(
                          onPressed: () {
                             // Logic to add activity for specific date could go here
                             // For now, user uses "Log Entry" tab
                          }, 
                          child: const Text("Go to 'Log' tab to add items")
                        )
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimeLabelsColumn(),
                      Expanded(
                        child: _EventsTimeline(
                          entries: dayEntries, 
                          // Pass function to handle checkbox toggle
                          onToggle: (id, currentStatus) async {
                             await DatabaseHelper().toggleEntryCompletion(id, currentStatus);
                             // Refresh list
                             ref.refresh(trackerNotifierProvider);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ... _TimeLabelsColumn class remains the same ...
class _TimeLabelsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(18, (index) {
        final hour = index + 6; 
        final timeStr = DateFormat('h a').format(DateTime(2022, 1, 1, hour));
        return Container(
          height: 80, 
          alignment: Alignment.topCenter,
          width: 60,
          child: Text(timeStr, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
        );
      }),
    );
  }
}

class _EventsTimeline extends StatelessWidget {
  final List<TrackingEntry> entries;
  final Function(int, bool) onToggle;
  
  final double hourHeight = 80.0;
  final int startHour = 6; 

  const _EventsTimeline({required this.entries, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final totalHeight = hourHeight * 18; 

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Grid Lines
          Column(
            children: List.generate(18, (index) => Container(
                height: hourHeight,
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1))),
            )),
          ),
          // Activity Blocks
          ...entries.map((entry) {
            final entryHour = entry.date.hour;
            final entryMin = entry.date.minute;
            if (entryHour < startHour) return const SizedBox.shrink();

            final double topOffset = ((entryHour - startHour) * hourHeight) + ((entryMin / 60) * hourHeight);
            final durationMins = (entry.value != null && entry.value! > 0) ? entry.value! : 60; 
            final double blockHeight = (durationMins / 60) * hourHeight;

            return Positioned(
              top: topOffset, left: 10, right: 10,
              height: blockHeight > 40 ? blockHeight : 40,
              child: _ScheduleBlock(entry: entry, onToggle: onToggle),
            );
          }),
        ],
      ),
    );
  }
}

class _ScheduleBlock extends StatelessWidget {
  final TrackingEntry entry;
  final Function(int, bool) onToggle;

  const _ScheduleBlock({required this.entry, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(entry.type);
    // Use the isCompleted field (ensure you updated your model!)
    // If you haven't updated model yet, this line will error. 
    // Assuming boolean isCompleted exists:
    final bool isDone = entry.isCompleted; 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey[300] : color.withOpacity(0.2), // Grey out if done
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isDone ? Colors.grey : color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    color: isDone ? Colors.grey : color.withOpacity(1.0),
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('h:mm a').format(entry.date),
                   style: TextStyle(color: isDone ? Colors.grey : color.withOpacity(0.8), fontSize: 10),
                )
              ],
            ),
          ),
          // CHECKBOX FOR COMPLETION
          Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: isDone,
              activeColor: Colors.grey,
              onChanged: (val) {
                if (entry.id != null) onToggle(entry.id!, isDone);
              },
            ),
          )
        ],
      ),
    );
  }
  
  Color _getColorForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Colors.orange;
      case TrackerType.meal: return const Color(0xFF5AB75A);
      case TrackerType.fitness: return const Color(0xFFFF6B6B);
      case TrackerType.focus: return const Color(0xFF8059FF);
    }
  }
}