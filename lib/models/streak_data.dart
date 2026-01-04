// lib/models/streak_data.dart

class StreakData {
  final int? id;
  final int habitId;
  final DateTime startDate;
  final DateTime? endDate;
  final int length;
  final bool isActive;

  StreakData({
    this.id,
    required this.habitId,
    required this.startDate,
    this.endDate,
    required this.length,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'length': length,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      id: map['id'],
      habitId: map['habit_id'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: map['end_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date']) 
          : null,
      length: map['length'],
      isActive: map['is_active'] == 1,
    );
  }

  StreakData copyWith({
    int? id,
    int? habitId,
    DateTime? startDate,
    DateTime? endDate,
    int? length,
    bool? isActive,
  }) {
    return StreakData(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      length: length ?? this.length,
      isActive: isActive ?? this.isActive,
    );
  }
}
