// lib/ui/focus_setup_screen.dart

import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/ui/workout_runner_screen.dart';
import 'package:flutter/material.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  int _selectedMinutes = 25;
  String _focusLabel = "Deep Work";

  final List<int> _durations = [15, 25, 30, 45, 60, 90];
  final List<String> _labels = ["Reading", "Studying", "Deep Work", "Meditation"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Mode", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Duration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _durations.map((min) {
                final isSelected = _selectedMinutes == min;
                return ChoiceChip(
                  label: Text("$min min"),
                  selected: isSelected,
                  selectedColor: const Color(0xFF8059FF),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _selectedMinutes = min),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text("Select Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _labels.map((label) {
                final isSelected = _focusLabel == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: const Color(0xFF8059FF),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _focusLabel = label),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("START FOCUS SESSION", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8059FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // Reuse the Workout Runner but with a single "Focus" exercise
                  final focusSession = [
                    Exercise(name: _focusLabel, defaultDurationSeconds: _selectedMinutes * 60, sortOrder: 0)
                  ];
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutRunnerScreen(workoutList: focusSession),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}