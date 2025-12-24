// lib/state/step_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

// Simple class to hold step data
class StepData {
  final int steps;
  final String status; // walking, stopped, etc.
  final bool isError;

  StepData({this.steps = 0, this.status = 'Stopped', this.isError = false});
}

class StepNotifier extends StateNotifier<StepData> {
  StepNotifier() : super(StepData()) {
    initPlatformState();
  }

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  void initPlatformState() async {
    // 1. Request Permission
    if (await Permission.activityRecognition.request().isGranted) {
      _startListening();
    } else {
      // Handle permission denied
      state = StepData(isError: true, status: "Permission Denied");
    }
  }

  void _startListening() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    // Listen to status (Walking/Stopped)
    _pedestrianStatusStream.listen(
      (status) {
        state = StepData(steps: state.steps, status: status.status);
      },
      onError: (error) {
        state = StepData(steps: state.steps, status: "Unknown", isError: true);
      },
    );

    // Listen to steps
    _stepCountStream.listen(
      (event) {
        // Pedometer returns cumulative steps since last boot. 
        // For a daily counter, you'd usually store the initial value at start of day.
        // For simplicity in this MVP, we display the raw sensor value.
        state = StepData(steps: event.steps, status: state.status);
      },
      onError: (error) {
        state = StepData(steps: 0, status: "Sensor Error", isError: true);
      },
    );
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepData>((ref) {
  return StepNotifier();
});