// lib/models/exercise_models.dart

// Represents an individual exercise within a workout plan
class Exercise {
  final int? id;
  final String name;
  final int defaultDurationSeconds; // e.g., 60 seconds
  final int sortOrder;

  Exercise({
    this.id,
    required this.name,
    required this.defaultDurationSeconds,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'defaultDurationSeconds': defaultDurationSeconds,
      'sortOrder': sortOrder,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      defaultDurationSeconds: map['defaultDurationSeconds'],
      sortOrder: map['sortOrder'],
    );
  }
}

// Represents a full workout created for a specific day
class WorkoutPlan {
  final int? id;
  final String name;
  final String dayOfWeek; // e.g., 'Monday', 'Tuesday'
  final List<Exercise> exercises; // List of exercises for this plan

  WorkoutPlan({
    this.id,
    required this.name,
    required this.dayOfWeek,
    required this.exercises,
  });
  
  // NOTE: Storing the list of exercises requires serialization (e.g., JSON) in SQLite. 
  // For simplicity, we'll manage this relationship outside the main table initially 
  // and simplify the database structure later if needed. For now, focus on the Exercise table.
}