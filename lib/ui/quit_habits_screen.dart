// lib/ui/quit_habits_screen.dart

import 'package:daily_tracker_app/state/quit_habit_notifier.dart';
import 'package:daily_tracker_app/ui/widgets/quit_habit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuitHabitsScreen extends ConsumerWidget {
  const QuitHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(quitHabitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quit Bad Habits', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("No habits being tracked.", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return QuitHabitTile(
                habit: habit,
                onReset: () {
                  // Show confirmation dialog before resetting
                  _showResetDialog(context, ref, habit);
                },
                onDelete: () {
                  ref.read(quitHabitProvider.notifier).deleteHabit(habit.id!);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        label: const Text("Track Habit"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFA01A33), // Deep Red
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    int selectedColor = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("What do you want to quit?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "e.g., Smoking, Fast Food"),
              ),
              const SizedBox(height: 20),
              const Text("Choose Color Style:"),
              const SizedBox(height: 10),
              // Simple Color Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => selectedColor = index, // Note: In a real app use StatefulBuilder for immediate visual feedback
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _getThemeColor(index),
                    ),
                  );
                }),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(quitHabitProvider.notifier).addQuitHabit(controller.text, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text("Start Tracking"),
            )
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, dynamic habit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Timer?"),
        content: const Text("This will reset your progress to zero. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(quitHabitProvider.notifier).resetHabit(habit);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
  
  Color _getThemeColor(int index) {
      const colors = [
        Color(0xFFA01A33), Color(0xFF1F4E5F), Color(0xFF2E3A59), Color(0xFF8B5E3C), Color(0xFF4A6FA5),
      ];
      return colors[index % colors.length];
  }
}