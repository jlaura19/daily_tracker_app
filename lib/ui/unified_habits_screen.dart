// lib/ui/unified_habits_screen.dart

import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/state/unified_habit_notifier.dart';
import 'package:daily_tracker_app/ui/habit_detail_screen.dart';
import 'package:daily_tracker_app/ui/widgets/habit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnifiedHabitsScreen extends ConsumerWidget {
  const UnifiedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(unifiedHabitProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return FutureBuilder<bool>(
                future: ref.read(unifiedHabitProvider.notifier).isCompletedToday(habit.id!),
                builder: (context, snapshot) {
                  final isCompleted = snapshot.data ?? false;
                  return HabitCard(
                    habit: habit,
                    isCompleted: isCompleted,
                    onTap: () async {
                      if (isCompleted) {
                        await ref.read(unifiedHabitProvider.notifier)
                            .uncompleteHabit(habit.id!, DateTime.now());
                      } else {
                        await ref.read(unifiedHabitProvider.notifier)
                            .completeHabit(habit);
                      }
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HabitDetailScreen(habit: habit),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Habits Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start building better habits today!\nTap the button below to create your first habit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddHabitDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create First Habit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    HabitType selectedType = HabitType.checkbox;
    HabitCategory selectedCategory = HabitCategory.personal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Drink 8 glasses of water',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: HabitType.values.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedCategory = category);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final habit = UnifiedHabit(
                    name: name,
                    type: selectedType,
                    category: selectedCategory,
                    colorIndex: selectedCategory.index,
                    iconName: _getDefaultIcon(selectedCategory),
                  );
                  
                  try {
                    await ref.read(unifiedHabitProvider.notifier).addHabit(habit);
                    await ref.read(unifiedHabitProvider.notifier).loadHabits();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Created habit: $name'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating habit: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'fitness_center';
      case HabitCategory.nutrition:
        return 'restaurant';
      case HabitCategory.mind:
        return 'psychology';
      case HabitCategory.productivity:
        return 'work';
      case HabitCategory.personal:
        return 'check_circle';
      case HabitCategory.quit:
        return 'no_drinks';
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Habits'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            const Text(
              'By Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...HabitCategory.values.map((category) => ListTile(
              title: Text(category.displayName),
              onTap: () => Navigator.pop(context),
            )),
          ],
        ),
      ),
    );
  }
}
