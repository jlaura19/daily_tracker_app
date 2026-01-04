// lib/models/tracker_type.dart

enum TrackerType {
  activity('Activity'),
  meal('Meal'),
  fitness('Fitness'),
  focus('Focus'),
  sports('Sports'),
  healthcare('Healthcare'),
  plan('Plan');

  final String displayName;
  const TrackerType(this.displayName);
}