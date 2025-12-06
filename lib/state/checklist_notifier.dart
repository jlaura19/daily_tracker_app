// lib/state/checklist_notifier.dart

import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Notifier to manage the list of repeatable tasks
class ChecklistItemNotifier extends StateNotifier<AsyncValue<List<DailyChecklistItem>>> {
  ChecklistItemNotifier() : super(const AsyncValue.loading()) {
    _loadItems();
  }

  final dbHelper = DatabaseHelper();

  Future<void> _loadItems() async {
    try {
      final items = await dbHelper.getChecklistItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(DailyChecklistItem item) async {
    try {
      await dbHelper.insertChecklistItem(item);
      await _loadItems();
    } catch (e) {
      // Handle error
    }
  }
  
  // A deletion function would typically go here, but we'll focus on creation for now.
}

final checklistItemProvider = StateNotifierProvider<ChecklistItemNotifier, AsyncValue<List<DailyChecklistItem>>>(
  (ref) => ChecklistItemNotifier(),
);

// 2. Provider to manage completed tasks for TODAY
final completedTasksTodayProvider = FutureProvider<List<ChecklistHistory>>((ref) async {
  final dbHelper = DatabaseHelper();
  // We use watch to automatically refresh this provider when an item is marked complete
  // (We'll trigger this refresh using ref.refresh in the UI)
  
  return await dbHelper.getCompletedTasksToday();
});

final fullHabitHistoryProvider = FutureProvider<Map<int, List<DateTime>>>((ref) async {
  final dbHelper = DatabaseHelper();
  final historyList = await dbHelper.getAllChecklistHistory();
  
  final Map<int, List<DateTime>> grouped = {};
  for (var h in historyList) {
    if (!grouped.containsKey(h.itemId)) {
      grouped[h.itemId] = [];
    }
    grouped[h.itemId]!.add(h.completionDate);
  }
  return grouped;
});