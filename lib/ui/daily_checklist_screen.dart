// lib/ui/daily_checklist_screen.dart

import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:daily_tracker_app/state/checklist_notifier.dart';
import 'package:daily_tracker_app/ui/checklist_management_screen.dart'; // CRITICAL: Fixes missing type error
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_tracker_app/ui/widgets/pastel_habit_tile.dart'; // Used for the visual theme

class DailyChecklistScreen extends ConsumerWidget {
  const DailyChecklistScreen({super.key});

  // Function to handle task completion
  void _toggleTaskCompletion(BuildContext context, WidgetRef ref, DailyChecklistItem item, bool isCompleted) async {
    if (!isCompleted) {
      // Mark as complete: Insert a new history record
      final historyEntry = ChecklistHistory(
        itemId: item.id!,
        completionDate: DateTime.now(),
      );
      // Directly access the database helper through the notifier instance
      await ref.read(checklistItemProvider.notifier).dbHelper.insertChecklistHistory(historyEntry);
      
      // Crucial: Manually refresh the completedTasksTodayProvider to update the UI
      ref.invalidate(completedTasksTodayProvider);
    }
    // Note: Deletion/unchecking logic is simplified/omitted for this version.
  }
  
  // Helper to find out if an item is in the list of completed tasks today
  bool _isTaskCompletedToday(DailyChecklistItem item, List<ChecklistHistory> completed) {
    // Requires the item to have an ID to check history
    if (item.id == null) return false;
    return completed.any((history) => history.itemId == item.id);
  }

  // Helper to cycle through colors for visual variety (like in the image)
  Color _getColorForIndex(int index) {
    const colors = [
      Colors.pink,
      Colors.blue,
      Colors.red,
      Colors.teal,
      Colors.purple,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the list of available tasks
    final itemsAsync = ref.watch(checklistItemProvider);
    // 2. Watch the list of tasks completed today
    final completedAsync = ref.watch(completedTasksTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits'),
        // Use secondary color for the habit screen accent
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              // FIX: Removed 'const' keyword and fixed the missing import (now at the top)
              builder: (context) => ChecklistManagementScreen(), 
            )),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading habits: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No daily habits set up. Tap the settings icon to add some!'));
          }

          // Combine both async data states
          return completedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading history: $err')),
            data: (completedToday) {
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isCompleted = _isTaskCompletedToday(item, completedToday);
                  
                  return PastelHabitTile(
                    color: _getColorForIndex(index), // Use color cycling helper
                    title: item.taskName,
                    currentValue: isCompleted ? '1' : '0', // Shows 1/1 if completed
                    targetValue: '1', 
                    onTap: () {
                      if (item.id != null) {
                        _toggleTaskCompletion(context, ref, item, isCompleted);
                      }
                    },
                    // Trailing icon based on status
                    trailing: isCompleted
                        ? const Icon(Icons.check_circle_outline, color: Colors.green, size: 30)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 30),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}