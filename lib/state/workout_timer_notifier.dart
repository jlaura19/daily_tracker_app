// lib/state/workout_timer_notifier.dart

import 'dart:async';
import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents the state of the workout
class WorkoutState {
  final List<Exercise> workout;
  final int currentExerciseIndex;
  final int timeRemaining;
  final bool isPaused;
  final bool isFinished;

  WorkoutState({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.timeRemaining = 0,
    this.isPaused = true,
    this.isFinished = false,
  });

  // Helper to get the current exercise
  Exercise? get currentExercise => 
      (currentExerciseIndex >= 0 && currentExerciseIndex < workout.length)
      ? workout[currentExerciseIndex]
      : null;

  WorkoutState copyWith({
    List<Exercise>? workout,
    int? currentExerciseIndex,
    int? timeRemaining,
    bool? isPaused,
    bool? isFinished,
  }) {
    return WorkoutState(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isPaused: isPaused ?? this.isPaused,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}


class WorkoutTimerNotifier extends StateNotifier<WorkoutState> {
  Timer? _timer;

  WorkoutTimerNotifier(List<Exercise> initialWorkout)
      : super(WorkoutState(
            workout: initialWorkout,
            timeRemaining: initialWorkout.isNotEmpty
                ? initialWorkout.first.defaultDurationSeconds
                : 0));
  
  // --- Timer Control ---

  void startWorkout() {
    if (state.isFinished) return;
    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  void pauseWorkout() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }
  
  void resetWorkout() {
    _timer?.cancel();
    state = WorkoutState(
        workout: state.workout,
        timeRemaining: state.workout.isNotEmpty ? state.workout.first.defaultDurationSeconds : 0,
        currentExerciseIndex: 0,
        isPaused: true,
        isFinished: false,
    );
  }
  
  void _startTimer() {
    _timer?.cancel();
    
    // Timer ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPaused || state.isFinished) {
        timer.cancel();
        return;
      }
      
      if (state.timeRemaining > 0) {
        // Decrease time
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time's up, move to the next exercise
        _moveToNextExercise();
      }
    });
  }

  // --- Session Navigation ---
  
  void _moveToNextExercise() {
    final nextIndex = state.currentExerciseIndex + 1;
    
    if (nextIndex < state.workout.length) {
      // Move to the next exercise
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        timeRemaining: state.workout[nextIndex].defaultDurationSeconds,
        isPaused: true, // Auto-pause between exercises
      );
      // Wait for user to press start again
    } else {
      // Workout finished
      _timer?.cancel();
      state = state.copyWith(isFinished: true, isPaused: false, timeRemaining: 0);
    }
  }

  // --- Editing ---
  
  // Allows the user to edit the duration of the current exercise mid-workout
  void editCurrentDuration(int newDurationSeconds) {
    if (!state.isFinished && newDurationSeconds > 0) {
      state = state.copyWith(timeRemaining: newDurationSeconds);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Factory to create the WorkoutTimerNotifier with an initial list
final workoutTimerProvider = StateNotifierProvider.family<WorkoutTimerNotifier, WorkoutState, List<Exercise>>(
  (ref, initialWorkout) {
    return WorkoutTimerNotifier(initialWorkout);
  },
);