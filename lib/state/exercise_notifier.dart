// lib/state/exercise_notifier.dart
import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defines the Exercise Notifier (Similar to TrackerNotifier)
class ExerciseNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  ExerciseNotifier() : super(const AsyncValue.loading()) {
    _loadExercises();
  }

  final dbHelper = DatabaseHelper();

  Future<void> _loadExercises() async {
    try {
      final exercises = await dbHelper.getAllExercises();
      state = AsyncValue.data(exercises);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    try {
      await dbHelper.insertExercise(exercise);
      await _loadExercises(); // Refresh the list
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await dbHelper.deleteExercise(id);
      await _loadExercises(); // Refresh the list
    } catch (e) {
      // Handle error
    }
  }
}

final exerciseNotifierProvider = StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>(
  (ref) => ExerciseNotifier(),
);

// A simple provider to hold the duration for the currently active timer in a workout
final currentTimerDurationProvider = StateProvider<int>((ref) => 0); // Seconds