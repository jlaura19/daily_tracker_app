// lib/ui/exercise_management_screen.dart

import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/state/exercise_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseManagementScreen extends ConsumerWidget {
  const ExerciseManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the exercise list state
    final exercisesAsync = ref.watch(exerciseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exercises'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(
              child: Text('No exercises defined yet. Add one!'),
            );
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExerciseListTile(exercise: exercise);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExerciseDialog(context, ref), // Call the standalone function
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget to display an individual exercise tile
class ExerciseListTile extends ConsumerWidget {
  final Exercise exercise;
  const ExerciseListTile({required this.exercise, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(exercise.name),
      subtitle: Text('${exercise.defaultDurationSeconds} seconds'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // FIX: Call the standalone function for editing
              showAddExerciseDialog(context, ref, exercise);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Confirm deletion
              if (exercise.id != null) {
                ref.read(exerciseNotifierProvider.notifier).deleteExercise(exercise.id!);
              }
            },
          ),
        ],
      ),
    );
  }
}


// --- Standalone Dialog Function (FIX for 'notifier' error) ---
// This function is outside the main widget and can be called easily by its children.
void showAddExerciseDialog(BuildContext context, WidgetRef ref, [Exercise? exerciseToEdit]) {
  final isEditing = exerciseToEdit != null;
  final nameController = TextEditingController(text: exerciseToEdit?.name);
  final durationController = TextEditingController(
      text: isEditing ? exerciseToEdit!.defaultDurationSeconds.toString() : '');
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Exercise' : 'Add New Exercise'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Default Duration (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value!) == null || int.parse(value) <= 0
                    ? 'Enter a valid duration'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newExercise = Exercise(
                  id: exerciseToEdit?.id, // ID is used if editing
                  name: nameController.text,
                  defaultDurationSeconds: int.parse(durationController.text),
                  // Note: Since we don't have a plan table, we just use a placeholder sort order.
                  sortOrder: exerciseToEdit?.sortOrder ?? 0, 
                );
                
                // Add or replace the exercise using the notifier
                ref.read(exerciseNotifierProvider.notifier).addExercise(newExercise);

                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}