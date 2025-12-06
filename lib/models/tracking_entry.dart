// lib/models/tracking_entry.dart

import 'tracker_type.dart';

class TrackingEntry {
  final int? id;
  final DateTime date;
  final TrackerType type;
  final String name;
  final String? notes;
  final int? value;
  final bool isCompleted; // <--- NEW FIELD

  TrackingEntry({
    this.id,
    required this.date,
    required this.type,
    required this.name,
    this.notes,
    this.value,
    this.isCompleted = false, // <--- Default to false
  });

  // Convert to Map for Database (Store bool as Integer 0 or 1)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'name': name,
      'notes': notes,
      'value': value,
      'isCompleted': isCompleted ? 1 : 0, // <--- Convert Bool to Int
    };
  }

  // Convert from Database Map to Object
  factory TrackingEntry.fromMap(Map<String, dynamic> map) {
    return TrackingEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: TrackerType.values.byName(map['type']),
      name: map['name'],
      notes: map['notes'],
      value: map['value'],
      // If the column is null (old data), default to false (0)
      isCompleted: (map['isCompleted'] ?? 0) == 1, 
    );
  }

  // Helper to clone object with updates
  TrackingEntry copyWith({
    int? id,
    DateTime? date,
    TrackerType? type,
    String? name,
    String? notes,
    int? value,
    bool? isCompleted, // <--- Add to copyWith
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}