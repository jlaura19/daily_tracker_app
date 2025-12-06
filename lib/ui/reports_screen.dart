// lib/ui/reports_screen.dart

import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:daily_tracker_app/state/checklist_notifier.dart';
import 'package:daily_tracker_app/ui/widgets/habit_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(checklistItemProvider);
    final historyAsync = ref.watch(fullHabitHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Reports', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. Filter Tabs (Visual Only for now) ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab('Week', false),
                  _buildTab('Month', false),
                  _buildTab('Year', true), // Selected
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. Habit List ---
            habitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text("Error: $err"),
              data: (habits) {
                return historyAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                  data: (historyMap) {
                    if (habits.isEmpty) return const Text("No habits to report on.");
                    
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        final dates = historyMap[habit.id] ?? [];
                        final color = _getColorForIndex(index);
                        
                        // Calculate simple consistency % (of last 60 days)
                        // Note: Real apps calculate this more precisely based on start date
                        final count = dates.length; 
                        // Just a placeholder stat for "consistency"
                        final percentage = (count > 0) ? (count / 60 * 100).clamp(0, 100).toInt() : 0; 

                        return _buildReportCard(habit, dates, color, percentage);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(DailyChecklistItem habit, List<DateTime> dates, Color color, int percentage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                 Icon(Icons.check_circle, color: color, size: 18),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     habit.taskName,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                     maxLines: 1, overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 Text(
                   "$percentage%",
                   style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                 ),
              ],
            ),
          ),
          // Heatmap Grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: HabitHeatmap(color: color, completionDates: dates),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [Colors.blue, Colors.red, Colors.purple, Colors.teal, Colors.orange, Colors.indigo];
    return colors[index % colors.length];
  }
}