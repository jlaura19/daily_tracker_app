// lib/models/habit_completion.dart

class HabitCompletion {
  final int? id;
  final int habitId;
  final DateTime completionDate;
  final int? value; // For measurable habits (e.g., 8 glasses, 30 minutes)
  final String? notes;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.completionDate,
    this.value,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completion_date': completionDate.millisecondsSinceEpoch,
      'value': value,
      'notes': notes,
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'],
      habitId: map['habit_id'],
      completionDate: DateTime.fromMillisecondsSinceEpoch(map['completion_date']),
      value: map['value'],
      notes: map['notes'],
    );
  }

  // Check if completion is for today
  bool isToday() {
    final now = DateTime.now();
    return completionDate.year == now.year &&
           completionDate.month == now.month &&
           completionDate.day == now.day;
  }

  // Check if completion is for a specific date
  bool isOnDate(DateTime date) {
    return completionDate.year == date.year &&
           completionDate.month == date.month &&
           completionDate.day == date.day;
  }
}
