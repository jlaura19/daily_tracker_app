import 'package:daily_tracker_app/state/step_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthStepsCard extends ConsumerWidget {
  const HealthStepsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepData = ref.watch(stepProvider);
    final color = const Color(0xFF4DB6AC);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_walk, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps Today', 
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)
                ),
                const SizedBox(height: 4),
                Text(
                  stepData.isError ? "Unavailable" : '${stepData.steps}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  stepData.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          if (!stepData.isError)
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: (stepData.steps / 10000).clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    strokeWidth: 5,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
