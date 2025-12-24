// lib/models/tracking_entry.dart

import 'tracker_type.dart';

class TrackingEntry {
  final int? id;
  final DateTime date; // Acts as Start Time
  final int? endTime;  // NEW: End Time (milliseconds since epoch)
  final TrackerType type;
  final String name;
  final String? notes;
  final int? value;
  final bool isCompleted;
  final bool isReminderOn; // NEW
  final String repeat;     // NEW: "Never", "Daily", etc.

  TrackingEntry({
    this.id,
    required this.date,
    this.endTime,
    required this.type,
    required this.name,
    this.notes,
    this.value,
    this.isCompleted = false,
    this.isReminderOn = false,
    this.repeat = 'Never',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'endTime': endTime,
      'type': type.name,
      'name': name,
      'notes': notes,
      'value': value,
      'isCompleted': isCompleted ? 1 : 0,
      'isReminderOn': isReminderOn ? 1 : 0,
      'repeat': repeat,
    };
  }

  factory TrackingEntry.fromMap(Map<String, dynamic> map) {
    return TrackingEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      endTime: map['endTime'],
      type: TrackerType.values.byName(map['type']),
      name: map['name'],
      notes: map['notes'],
      value: map['value'],
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      isReminderOn: (map['isReminderOn'] ?? 0) == 1,
      repeat: map['repeat'] ?? 'Never',
    );
  }

  TrackingEntry copyWith({
    int? id,
    DateTime? date,
    int? endTime,
    TrackerType? type,
    String? name,
    String? notes,
    int? value,
    bool? isCompleted,
    bool? isReminderOn,
    String? repeat,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      isReminderOn: isReminderOn ?? this.isReminderOn,
      repeat: repeat ?? this.repeat,
    );
  }
}