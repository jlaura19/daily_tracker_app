// lib/models/quit_habit.dart

class QuitHabit {
  final int? id;
  final String title;
  final DateTime quitDate;
  final int colorIndex; // To save the color choice
  final int resetCount; // Track how many times user relapsed

  QuitHabit({
    this.id,
    required this.title,
    required this.quitDate,
    required this.colorIndex,
    this.resetCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'quitDate': quitDate.millisecondsSinceEpoch,
      'colorIndex': colorIndex,
      'resetCount': resetCount,
    };
  }

  factory QuitHabit.fromMap(Map<String, dynamic> map) {
    return QuitHabit(
      id: map['id'],
      title: map['title'],
      quitDate: DateTime.fromMillisecondsSinceEpoch(map['quitDate']),
      colorIndex: map['colorIndex'],
      resetCount: map['resetCount'] ?? 0,
    );
  }
}