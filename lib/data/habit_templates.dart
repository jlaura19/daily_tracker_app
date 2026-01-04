// lib/data/habit_templates.dart

import 'package:daily_tracker_app/models/unified_habit.dart';

class HabitTemplates {
  static final List<UnifiedHabit> templates = [
    // Health Templates
    UnifiedHabit(
      name: 'Drink 8 glasses of water',
      type: HabitType.measurable,
      category: HabitCategory.health,
      targetValue: 8,
      unit: 'glasses',
      iconName: 'water_drop',
      colorIndex: 0,
    ),
    UnifiedHabit(
      name: 'Exercise for 30 minutes',
      type: HabitType.timed,
      category: HabitCategory.health,
      targetValue: 30,
      unit: 'minutes',
      iconName: 'fitness_center',
      colorIndex: 0,
    ),
    UnifiedHabit(
      name: 'Get 8 hours of sleep',
      type: HabitType.checkbox,
      category: HabitCategory.health,
      iconName: 'bedtime',
      colorIndex: 0,
    ),
    UnifiedHabit(
      name: 'Take vitamins',
      type: HabitType.checkbox,
      category: HabitCategory.health,
      iconName: 'medication',
      colorIndex: 0,
    ),
    
    // Nutrition Templates
    UnifiedHabit(
      name: 'Eat 5 servings of fruits/vegetables',
      type: HabitType.measurable,
      category: HabitCategory.nutrition,
      targetValue: 5,
      unit: 'servings',
      iconName: 'restaurant',
      colorIndex: 1,
    ),
    UnifiedHabit(
      name: 'No junk food',
      type: HabitType.avoid,
      category: HabitCategory.quit,
      iconName: 'no_food',
      colorIndex: 5,
    ),
    UnifiedHabit(
      name: 'Cook a healthy meal',
      type: HabitType.checkbox,
      category: HabitCategory.nutrition,
      iconName: 'restaurant_menu',
      colorIndex: 1,
    ),
    
    // Mind Templates
    UnifiedHabit(
      name: 'Meditate for 10 minutes',
      type: HabitType.timed,
      category: HabitCategory.mind,
      targetValue: 10,
      unit: 'minutes',
      iconName: 'self_improvement',
      colorIndex: 2,
    ),
    UnifiedHabit(
      name: 'Read for 30 minutes',
      type: HabitType.timed,
      category: HabitCategory.mind,
      targetValue: 30,
      unit: 'minutes',
      iconName: 'menu_book',
      colorIndex: 2,
    ),
    UnifiedHabit(
      name: 'Practice gratitude',
      type: HabitType.checkbox,
      category: HabitCategory.mind,
      iconName: 'favorite',
      colorIndex: 2,
    ),
    UnifiedHabit(
      name: 'Journal',
      type: HabitType.checkbox,
      category: HabitCategory.mind,
      iconName: 'edit_note',
      colorIndex: 2,
    ),
    
    // Productivity Templates
    UnifiedHabit(
      name: 'No phone first hour after waking',
      type: HabitType.checkbox,
      category: HabitCategory.productivity,
      iconName: 'phone_disabled',
      colorIndex: 3,
    ),
    UnifiedHabit(
      name: 'Plan tomorrow today',
      type: HabitType.checkbox,
      category: HabitCategory.productivity,
      iconName: 'event_note',
      colorIndex: 3,
    ),
    UnifiedHabit(
      name: 'Deep work session',
      type: HabitType.timed,
      category: HabitCategory.productivity,
      targetValue: 90,
      unit: 'minutes',
      iconName: 'work',
      colorIndex: 3,
    ),
    
    // Personal Templates
    UnifiedHabit(
      name: 'Make bed',
      type: HabitType.checkbox,
      category: HabitCategory.personal,
      iconName: 'bed',
      colorIndex: 4,
    ),
    UnifiedHabit(
      name: 'Practice a skill',
      type: HabitType.timed,
      category: HabitCategory.personal,
      targetValue: 30,
      unit: 'minutes',
      iconName: 'psychology',
      colorIndex: 4,
    ),
    UnifiedHabit(
      name: 'Connect with a friend',
      type: HabitType.checkbox,
      category: HabitCategory.personal,
      iconName: 'people',
      colorIndex: 4,
    ),
    
    // Quit Templates
    UnifiedHabit(
      name: 'No smoking',
      type: HabitType.avoid,
      category: HabitCategory.quit,
      iconName: 'smoke_free',
      colorIndex: 5,
    ),
    UnifiedHabit(
      name: 'No alcohol',
      type: HabitType.avoid,
      category: HabitCategory.quit,
      iconName: 'no_drinks',
      colorIndex: 5,
    ),
    UnifiedHabit(
      name: 'No social media',
      type: HabitType.avoid,
      category: HabitCategory.quit,
      iconName: 'phone_disabled',
      colorIndex: 5,
    ),
  ];

  static List<UnifiedHabit> getTemplatesByCategory(HabitCategory category) {
    return templates.where((t) => t.category == category).toList();
  }

  static List<UnifiedHabit> getPopularTemplates() {
    return [
      templates[0], // Water
      templates[1], // Exercise
      templates[7], // Meditate
      templates[8], // Read
      templates[15], // Make bed
    ];
  }
}
