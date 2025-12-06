// lib/ui/widgets/consistency_bar_chart.dart

import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/state/tracker_notifier.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsistencyBarChart extends ConsumerWidget {
  const ConsistencyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the summary provider, which asynchronously fetches the 7-day count
    final summaryAsync = ref.watch(weeklySummaryProvider);

    return summaryAsync.when(
      loading: () => const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 250,
        child: Center(child: Text('Error loading chart: $err')),
      ),
      data: (summaryMap) {
        // If the map is empty, there is no data to show.
        if (summaryMap.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: Text('Log entries to see consistency chart!')),
          );
        }
        
        // --- Data Preparation ---
        double maxCount = 0;
        final List<BarChartGroupData> barGroups = [];
        
        // Use a list of types to ensure consistent order for the bars
        final types = TrackerType.values; 

        for (int i = 0; i < types.length; i++) {
          final type = types[i];
          // Get the count for the type, default to 0
          final count = summaryMap[type] ?? 0;
          
          if (count > maxCount) {
            maxCount = count.toDouble();
          }

          barGroups.add(BarChartGroupData(
            x: i, // X-axis index
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: _getColorForType(type, context),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ));
        }

        // Ensure maxCount is at least 5 for better chart scaling if all counts are low
        if (maxCount < 5) maxCount = 5;

        // --- Chart Widget ---
        return Padding(
          padding: const EdgeInsets.only(top: 8, right: 16, left: 8),
          child: SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount * 1.2, // Give space above the tallest bar
                barTouchData: BarTouchData(enabled: false), 
                titlesData: _getTitlesData(types), // X-axis titles
                borderData: FlBorderData(show: false), 
                gridData: const FlGridData(show: false), 
                barGroups: barGroups,
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Helper to assign a specific color based on the tracker type
  Color _getColorForType(TrackerType type, BuildContext context) {
    return switch (type) {
      TrackerType.activity => Colors.orange,
      TrackerType.meal => Colors.green,
      TrackerType.fitness => Colors.red,
      TrackerType.focus => Colors.blue,
    };
  }
  
  // Helper to set the X-axis titles (labels under the bars)
  FlTitlesData _getTitlesData(List<TrackerType> types) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            // Display the short name of the type on the x-axis (e.g., 'Activity' -> 'Activity')
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                types[value.toInt()].displayName.split(' ').first,
                style: const TextStyle(
                  color: Color(0xff7589a2),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      // Hide top and right titles for cleaner look
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 30),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}