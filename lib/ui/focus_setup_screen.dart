// lib/ui/focus_setup_screen.dart

import 'package:daily_tracker_app/models/exercise_models.dart';
import 'package:daily_tracker_app/ui/workout_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TimerMode { countdown, stopwatch, interval }

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  TimerMode _timerMode = TimerMode.countdown;
  int _selectedMinutes = 25;
  int _customMinutes = 25;
  String _focusLabel = "Deep Work";

  // Interval mode settings
  int _workMinutes = 25;
  int _breakMinutes = 5;
  String _selectedInterval = "Pomodoro";

  final List<int> _durations = [15, 25, 30, 45, 60, 90];
  final List<String> _labels = ["Reading", "Studying", "Deep Work", "Meditation", "Coding", "Writing"];

  final Map<String, Map<String, int>> _intervalPresets = {
    "Pomodoro": {"work": 25, "break": 5},
    "Deep Work": {"work": 50, "break": 10},
    "Short Sprint": {"work": 15, "break": 3},
    "Ultra Focus": {"work": 90, "break": 15},
  };

  void _showCustomTimeDialog() {
    final TextEditingController controller = TextEditingController(text: _customMinutes.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Duration'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            border: OutlineInputBorder(),
            suffixText: 'min',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 25;
              setState(() {
                _customMinutes = value.clamp(1, 180);
                _selectedMinutes = _customMinutes;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _startFocusSession() {
    List<Exercise> sessionExercises;

    switch (_timerMode) {
      case TimerMode.countdown:
        sessionExercises = [
          Exercise(
            name: _focusLabel,
            defaultDurationSeconds: _selectedMinutes * 60,
            sortOrder: 0,
          )
        ];
        break;

      case TimerMode.stopwatch:
        // Use a very long duration for stopwatch mode (24 hours)
        sessionExercises = [
          Exercise(
            name: "$_focusLabel (Stopwatch)",
            defaultDurationSeconds: 86400, // 24 hours
            sortOrder: 0,
          )
        ];
        break;

      case TimerMode.interval:
        // Create alternating work/break intervals (3 cycles)
        sessionExercises = [];
        for (int i = 0; i < 3; i++) {
          sessionExercises.add(
            Exercise(
              name: "$_focusLabel - Work ${i + 1}",
              defaultDurationSeconds: _workMinutes * 60,
              sortOrder: i * 2,
            ),
          );
          sessionExercises.add(
            Exercise(
              name: "Break ${i + 1}",
              defaultDurationSeconds: _breakMinutes * 60,
              sortOrder: i * 2 + 1,
            ),
          );
        }
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutRunnerScreen(workoutList: sessionExercises),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Mode", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Mode Selection
            const Text("Timer Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SegmentedButton<TimerMode>(
              segments: const [
                ButtonSegment(
                  value: TimerMode.countdown,
                  label: Text('Countdown'),
                  icon: Icon(Icons.timer),
                ),
                ButtonSegment(
                  value: TimerMode.stopwatch,
                  label: Text('Stopwatch'),
                  icon: Icon(Icons.timer_outlined),
                ),
                ButtonSegment(
                  value: TimerMode.interval,
                  label: Text('Interval'),
                  icon: Icon(Icons.repeat),
                ),
              ],
              selected: {_timerMode},
              onSelectionChanged: (Set<TimerMode> newSelection) {
                setState(() => _timerMode = newSelection.first);
              },
            ),
            const SizedBox(height: 32),

            // Countdown Mode Settings
            if (_timerMode == TimerMode.countdown) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Duration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _showCustomTimeDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Custom'),
                  ),
                ],
              ),
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
                }).toList()
                  ..add(
                    ChoiceChip(
                      label: Text("$_customMinutes min"),
                      selected: _selectedMinutes == _customMinutes && !_durations.contains(_customMinutes),
                      selectedColor: const Color(0xFF8059FF),
                      labelStyle: TextStyle(
                        color: (_selectedMinutes == _customMinutes && !_durations.contains(_customMinutes))
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSelected: (val) => setState(() => _selectedMinutes = _customMinutes),
                    ),
                  ),
              ),
            ],

            // Stopwatch Mode Info
            if (_timerMode == TimerMode.stopwatch) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stopwatch mode counts up from zero. Stop manually when done.',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Interval Mode Settings
            if (_timerMode == TimerMode.interval) ...[
              const Text("Interval Preset", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _intervalPresets.keys.map((preset) {
                  final isSelected = _selectedInterval == preset;
                  return ChoiceChip(
                    label: Text(preset),
                    selected: isSelected,
                    selectedColor: const Color(0xFF8059FF),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (val) {
                      setState(() {
                        _selectedInterval = preset;
                        _workMinutes = _intervalPresets[preset]!['work']!;
                        _breakMinutes = _intervalPresets[preset]!['break']!;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Work Duration", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "$_workMinutes min",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Break Duration", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.coffee, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "$_breakMinutes min",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '3 cycles: Work → Break → Work → Break → Work → Break',
                  style: TextStyle(color: Colors.purple.shade900, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Activity Selection (for all modes)
            const Text("Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: Text(
                  _timerMode == TimerMode.stopwatch
                      ? "START STOPWATCH"
                      : _timerMode == TimerMode.interval
                          ? "START INTERVAL SESSION"
                          : "START FOCUS SESSION",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8059FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _startFocusSession,
              ),
            ),
          ],
        ),
      ),
    );
  }
}