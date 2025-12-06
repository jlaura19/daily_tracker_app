// lib/models/checklist_model.dart
import 'package:daily_tracker_app/models/tracker_type.dart';

// Represents a repeatable daily task the user tracks
class DailyChecklistItem {
  final int? id;
  final String taskName;
  final String iconName; // e.g., 'bedtime', 'book'
  final int sortOrder;

  DailyChecklistItem({
    this.id,
    required this.taskName,
    required this.iconName,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'iconName': iconName,
      'sortOrder': sortOrder,
    };
  }
  
  factory DailyChecklistItem.fromMap(Map<String, dynamic> map) {
    return DailyChecklistItem(
      id: map['id'],
      taskName: map['taskName'],
      iconName: map['iconName'],
      sortOrder: map['sortOrder'],
    );
  }
}

// Represents a historic record of a completed task
class ChecklistHistory {
  final int? id;
  final int itemId; // Foreign key to DailyChecklistItem.id
  final DateTime completionDate;
  
  ChecklistHistory({
    this.id,
    required this.itemId,
    required this.completionDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'completionDate': completionDate.millisecondsSinceEpoch,
    };
  }
  
  factory ChecklistHistory.fromMap(Map<String, dynamic> map) {
    return ChecklistHistory(
      id: map['id'],
      itemId: map['itemId'],
      completionDate: DateTime.fromMillisecondsSinceEpoch(map['completionDate']),
    );
  }
}