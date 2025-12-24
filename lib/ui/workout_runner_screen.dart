// lib/ui/workout_runner_screen.dart

import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/state/workout_timer_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutRunnerScreen extends ConsumerWidget {
  final List<Exercise> workoutList;
  const WorkoutRunnerScreen({required this.workoutList, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the timer state
    final workoutState = ref.watch(workoutTimerProvider(workoutList));
    final workoutNotifier = ref.read(workoutTimerProvider(workoutList).notifier);

    // Helper to format time (MM:SS)
    String formatTime(int totalSeconds) {
      final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    // Calculate progress for the circular indicator
    double progress = 0.0;
    if (workoutState.currentExercise != null && !workoutState.isFinished) {
      final total = workoutState.currentExercise!.defaultDurationSeconds;
      final current = workoutState.timeRemaining;
      progress = total > 0 ? (current / total) : 0.0;
    }

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background like image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout Session',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. Current Exercise Chip ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F5), // Light greyish purple
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Current Focus", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  if (workoutState.currentExercise != null)
                    Text(
                      workoutState.currentExercise!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // --- 2. The Big Circular Timer ---
            Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle (Light)
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 20,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
                  ),
                ),
                // Progress Circle (Primary Color)
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 20,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
                // Time Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(workoutState.timeRemaining),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                             workoutState.isFinished 
                             ? "Done" 
                             : "${(progress * 100).toInt()}%",
                             style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),

            const Spacer(),

            // --- 3. Control Buttons (Stop / Pause) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  // Stop Button (Grey Box)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                         workoutNotifier.resetWorkout();
                         Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stop, color: Colors.black54),
                            SizedBox(width: 8),
                            Text("Stop", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Pause/Resume Button (Dark/Primary Box)
                  Expanded(
                    flex: 2, // Takes up more space
                    child: InkWell(
                      onTap: workoutState.isFinished
                          ? null
                          : workoutState.isPaused
                              ? workoutNotifier.startWorkout
                              : workoutNotifier.pauseWorkout,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222), // Dark button like image
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              workoutState.isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              workoutState.isPaused ? "Resume" : "Pause",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- 4. Upcoming Exercises List ---
            Container(
              height: 150, // Fixed height area for the list
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -5),
                    blurRadius: 20,
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                    child: Text("Up Next", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: workoutState.workout.length,
                      itemBuilder: (context, index) {
                        final exercise = workoutState.workout[index];
                        final isCurrent = index == workoutState.currentExerciseIndex;
                        final isPast = index < workoutState.currentExerciseIndex;
                        
                        // Hide past exercises or grey them out
                        if (isPast) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                isCurrent ? Icons.play_circle_fill : Icons.circle_outlined,
                                size: 16,
                                color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent ? Colors.black : Colors.grey,
                                  fontSize: 16
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${exercise.defaultDurationSeconds}s",
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}