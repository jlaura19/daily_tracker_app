// lib/state/tracker_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/state/checklist_notifier.dart'; // Import checklist provider for combined status
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. Tracker Notifier (Manages all tracking entries) ---
class TrackerNotifier extends StateNotifier<AsyncValue<List<TrackingEntry>>> {
  TrackerNotifier() : super(const AsyncValue.loading()) {
    _loadEntries();
  }

  final dbHelper = DatabaseHelper();

  Future<void> _loadEntries() async {
    try {
      final entries = await dbHelper.getEntries();
      state = AsyncValue.data(entries); 
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEntry(TrackingEntry entry) async {
    try {
      await dbHelper.insertEntry(entry);
      await _loadEntries(); 
    } catch (e) {
      await _loadEntries(); 
    }
  }
}

// 2. Define the main provider globally (Plan B)
final trackerNotifierProvider = StateNotifierProvider<TrackerNotifier, AsyncValue<List<TrackingEntry>>>(
  (ref) {
    return TrackerNotifier();
  },
);

// --- 3. Weekly Summary Provider (Manages data for charts) ---

// Define the type for our summary map: {TrackerType: Count}
typedef TrackerSummary = Map<TrackerType, int>;

// Provider to fetch the 7-day consistency summary (used by ConsistencyBarChart)
final weeklySummaryProvider = FutureProvider<TrackerSummary>((ref) async {
  final dbHelper = DatabaseHelper();
  
  // Define the date range (Last 7 days, including today)
  final now = DateTime.now();
  final sevenDaysAgo = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 6));
  
  // Fetch the raw summary data from the database
  final rawSummary = await dbHelper.getSummaryByDateRange(sevenDaysAgo, now);

  // Convert raw List<Map> into the required TrackerSummary map
  final TrackerSummary summaryMap = {};
  for (var row in rawSummary) {
    // Map the string 'type' back to the enum value
    final type = TrackerType.values.byName(row['type'] as String);
    final count = row['count'] as int;
    summaryMap[type] = count;
  }
  
  return summaryMap;
});


// --- 4. Daily Checklist Status Provider (Used by Dashboard Card) ---

// Provider to get the Checklist completion status for today: {total: X, completed: Y}
final dailyChecklistStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  // Watch/read providers that hold the raw data
  final allItemsAsync = ref.watch(checklistItemProvider);
  final completedAsync = ref.watch(completedTasksTodayProvider);

  // Return loading state if the dependencies aren't ready
  if (allItemsAsync.isLoading || completedAsync.isLoading) {
    // Use an initial map for a more graceful loading/error state in the UI
    return {'total': 0, 'completed': 0};
  }
  
  final allItems = allItemsAsync.value ?? [];
  final completed = completedAsync.value ?? [];

  return {
    'total': allItems.length,
    'completed': completed.length,
  };
});