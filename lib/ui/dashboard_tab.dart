// lib/ui/dashboard_tab.dart

import 'package:daily_tracker_app/state/tracker_notifier.dart'; 
import 'package:daily_tracker_app/ui/widgets/consistency_bar_chart.dart';
import 'package:daily_tracker_app/ui/widgets/consistency_bar_chart.dart';
import 'package:daily_tracker_app/ui/workout_starter_screen.dart';
import 'package:daily_tracker_app/ui/quit_habits_screen.dart'; 
import 'package:daily_tracker_app/ui/reports_screen.dart'; 
import 'package:daily_tracker_app/ui/focus_setup_screen.dart'; // <--- NEW IMPORT
import 'package:daily_tracker_app/ui/widgets/pastel_tracking_tile.dart'; 
import 'package:flutter/material.dart';
import 'package:daily_tracker_app/state/step_notifier.dart'; // <--- ADD THIS
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerState = ref.watch(trackerNotifierProvider);

    return trackerState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (entries) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Daily Habits Summary ---
              const ChecklistStatusCard(),
              // --- 2. Health Steps (NEW)
              const HealthStepsCard(),
              
              // --- 3. Action Buttons (2x2 Grid) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Row 1: Workout & Focus
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.timer,
                            color: Colors.pinkAccent,
                            title: "Workout",
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WorkoutStarterScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.self_improvement, // Zen/Focus Icon
                            color: Colors.purpleAccent,
                            title: "Focus Mode",
                            onTap: () => Navigator.of(context).push(
                              // Navigate to the Focus Setup Screen
                              MaterialPageRoute(builder: (_) => const FocusSetupScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Exercises & Quit Bad
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.checklist,
                            color: Colors.blueAccent,
                            title: "Checklist",
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ChecklistStatusCard()), // Placeholder or use correct screen
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.block,
                            color: Colors.redAccent,
                            title: "Quit Bad",
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QuitHabitsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // --- 3. Consistency Chart ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '7-Day Consistency',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.of(context).push(MaterialPageRoute(
                           builder: (context) => const ReportsScreen()
                         ));
                      },
                      child: const Text("View Reports"),
                    ),
                  ],
                ),
              ),
              const ConsistencyBarChart(),
              
              // --- 4. Recent Entries List ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    Icon(Icons.history, color: Colors.grey[400]),
                  ],
                ),
              ),
              
              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.post_add, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          "No entries yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length > 10 ? 10 : entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return PastelTrackingTile(entry: entry);
                  },
                ),
                
              const SizedBox(height: 40), 
            ],
          ),
        );
      },
    );
  }
}

// Helper Widget for the Action Buttons
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title, 
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ChecklistStatusCard extends ConsumerWidget {
  const ChecklistStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(dailyChecklistStatusProvider);
    
    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (status) {
        final total = status['total']!;
        final completed = status.containsKey('completed') ? status['completed']! : 0;
        final percentage = total > 0 ? (completed / total) : 0.0;
        
        if (total == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Goals', 
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(percentage * 100).toInt()}% Completed',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total habits done',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        strokeWidth: 6,
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 24),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class HealthStepsCard extends ConsumerWidget {
  const HealthStepsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepData = ref.watch(stepProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        // Teal/Mint color like the screenshot
        color: const Color(0xFF4DB6AC), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DB6AC).withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  stepData.status, // Walking or Stopped
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          // Circular Progress (Target: 10,000 steps)
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