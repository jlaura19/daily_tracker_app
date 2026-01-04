// lib/models/unified_habit.dart

import 'package:flutter/material.dart';

enum HabitType {
  checkbox('Checkbox'),
  measurable('Measurable'),
  avoid('Avoid'),
  timed('Timed');

  final String displayName;
  const HabitType(this.displayName);
}

enum HabitCategory {
  health('Health'),
  nutrition('Nutrition'),
  mind('Mind'),
  productivity('Productivity'),
  personal('Personal'),
  quit('Quit');

  final String displayName;
  const HabitCategory(this.displayName);
}

enum HabitFrequency {
  daily('Daily'),
  weekly('Weekly'),
  custom('Custom');

  final String displayName;
  const HabitFrequency(this.displayName);
}

class UnifiedHabit {
  final int? id;
  final String name;
  final HabitType type;
  final HabitCategory category;
  final HabitFrequency frequency;
  
  // For measurable habits
  final int? targetValue;
  final String? unit; // "glasses", "minutes", "km", etc.
  
  // Streaks & Stats
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  
  // Reminders
  final TimeOfDay? reminderTime;
  final List<int> reminderDays; // 1-7 for days of week (1=Monday)
  final bool reminderEnabled;
  
  // UI
  final String iconName;
  final int colorIndex;
  final int sortOrder;
  final DateTime createdAt;
  
  // Metadata
  final String? notes;
  final bool isArchived;

  UnifiedHabit({
    this.id,
    required this.name,
    required this.type,
    required this.category,
    this.frequency = HabitFrequency.daily,
    this.targetValue,
    this.unit,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.reminderTime,
    this.reminderDays = const [],
    this.reminderEnabled = false,
    this.iconName = 'check_circle',
    this.colorIndex = 0,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.notes,
    this.isArchived = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'frequency': frequency.name,
      'target_value': targetValue,
      'unit': unit,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
      'reminder_time': reminderTime != null 
          ? '${reminderTime!.hour}:${reminderTime!.minute}' 
          : null,
      'reminder_days': reminderDays.join(','),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'icon_name': iconName,
      'color_index': colorIndex,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'notes': notes,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  // Create from Map (database)
  factory UnifiedHabit.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminderTime;
    if (map['reminder_time'] != null) {
      final parts = (map['reminder_time'] as String).split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    List<int> reminderDays = [];
    if (map['reminder_days'] != null && (map['reminder_days'] as String).isNotEmpty) {
      reminderDays = (map['reminder_days'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }

    return UnifiedHabit(
      id: map['id'],
      name: map['name'],
      type: HabitType.values.firstWhere((e) => e.name == map['type']),
      category: HabitCategory.values.firstWhere((e) => e.name == map['category']),
      frequency: HabitFrequency.values.firstWhere((e) => e.name == map['frequency']),
      targetValue: map['target_value'],
      unit: map['unit'],
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      totalCompletions: map['total_completions'] ?? 0,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
      reminderEnabled: map['reminder_enabled'] == 1,
      iconName: map['icon_name'] ?? 'check_circle',
      colorIndex: map['color_index'] ?? 0,
      sortOrder: map['sort_order'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      notes: map['notes'],
      isArchived: map['is_archived'] == 1,
    );
  }

  // Copy with method for updates
  UnifiedHabit copyWith({
    int? id,
    String? name,
    HabitType? type,
    HabitCategory? category,
    HabitFrequency? frequency,
    int? targetValue,
    String? unit,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    TimeOfDay? reminderTime,
    List<int>? reminderDays,
    bool? reminderEnabled,
    String? iconName,
    int? colorIndex,
    int? sortOrder,
    DateTime? createdAt,
    String? notes,
    bool? isArchived,
  }) {
    return UnifiedHabit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      iconName: iconName ?? this.iconName,
      colorIndex: colorIndex ?? this.colorIndex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // Helper to get color from index
  Color getColor() {
    const colors = [
      Color(0xFFFF6B6B), // Red
      Color(0xFF4ECDC4), // Teal
      Color(0xFFFFE66D), // Yellow
      Color(0xFF95E1D3), // Mint
      Color(0xFFF38181), // Pink
      Color(0xFFAA96DA), // Purple
      Color(0xFFFCBF49), // Orange
      Color(0xFF06D6A0), // Green
    ];
    return colors[colorIndex % colors.length];
  }

  // Helper to get icon
  IconData getIcon() {
    const iconMap = {
      'check_circle': Icons.check_circle,
      'fitness_center': Icons.fitness_center,
      'local_drink': Icons.local_drink,
      'restaurant': Icons.restaurant,
      'book': Icons.book,
      'self_improvement': Icons.self_improvement,
      'bedtime': Icons.bedtime,
      'directions_run': Icons.directions_run,
      'water_drop': Icons.water_drop,
      'favorite': Icons.favorite,
      'psychology': Icons.psychology,
      'work': Icons.work,
      'school': Icons.school,
      'sports_soccer': Icons.sports_soccer,
      'local_hospital': Icons.local_hospital,
      'smoking_rooms': Icons.smoking_rooms,
      'no_drinks': Icons.no_drinks,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }
}
