// lib/ui/workout_starter_screen.dart

import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/state/exercise_notifier.dart';
import 'package:daily_tracker_app/ui/workout_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Local StateProvider to hold the list of exercises selected for the current session
final selectedWorkoutExercisesProvider = StateProvider<List<Exercise>>((ref) => []);

class WorkoutStarterScreen extends ConsumerWidget {
  const WorkoutStarterScreen({super.key});

  // Quick add exercise dialog
  void _showQuickAddExerciseDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController durationController = TextEditingController(text: '30');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Push-ups',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'sec',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              final durationText = durationController.text.trim();
              final duration = int.tryParse(durationText) ?? 30;
              
              if (name.isNotEmpty) {
                // Create new exercise
                final newExercise = Exercise(
                  name: name,
                  defaultDurationSeconds: duration,
                  sortOrder: 0,
                );
                await ref.read(exerciseNotifierProvider.notifier).addExercise(newExercise);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created exercise: $name'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get all available exercises
    final availableExercisesAsync = ref.watch(exerciseNotifierProvider);
    // 2. Get the currently selected exercises for this session
    final selectedExercises = ref.watch(selectedWorkoutExercisesProvider);

    // Filter out exercises that have already been selected
    final selectableExercises = availableExercisesAsync.valueOrNull
        ?.where((ex) => !selectedExercises.contains(ex))
        .toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build & Start Workout'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Workout List ---
          Expanded(
            child: selectedExercises.isEmpty
                ? const Center(child: Text('Add exercises below to start a workout!'))
                : ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      ref.read(selectedWorkoutExercisesProvider.notifier).update((state) {
                        final items = List<Exercise>.from(state);
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = items.removeAt(oldIndex);
                        items.insert(newIndex, item);
                        return items;
                      });
                    },
                    children: selectedExercises.map((exercise) {
                      return ListTile(
                        key: ValueKey(exercise.id),
                        leading: const Icon(Icons.drag_handle),
                        title: Text(exercise.name),
                        subtitle: Text('${exercise.defaultDurationSeconds}s'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            // Remove from selected list
                            ref.read(selectedWorkoutExercisesProvider.notifier).update(
                                (state) => state.where((ex) => ex.id != exercise.id).toList());
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
          
          const Divider(),

          // --- Selection/Available Exercises ---
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Available Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 100,
            child: availableExercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading exercises: $err')),
              data: (_) {
                if (selectableExercises.isEmpty) {
                  return const Center(child: Text('No exercises left to add.'));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = selectableExercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: Text(exercise.name),
                        avatar: const Icon(Icons.add),
                        onPressed: () {
                          // Add exercise to the selected list
                          ref.read(selectedWorkoutExercisesProvider.notifier).update((state) => [...state, exercise]);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // --- Start Button ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: selectedExercises.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WorkoutRunnerScreen(workoutList: selectedExercises),
                      ));
                      // Important: Reset the temporary selected list after starting
                      ref.read(selectedWorkoutExercisesProvider.notifier).state = [];
                    },
              icon: const Icon(Icons.timer),
              label: Text('START WORKOUT (${selectedExercises.length} items)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddExerciseDialog(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Exercise'),
      ),
    );
  }
}