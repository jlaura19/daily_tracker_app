// lib/ui/today_tab.dart

import 'package:daily_tracker_app/models/unified_habit.dart';
import 'package:daily_tracker_app/state/unified_habit_notifier.dart';
import 'package:daily_tracker_app/state/gamification_notifier.dart';
import 'package:daily_tracker_app/state/streak_notifier.dart';
import 'package:daily_tracker_app/ui/focus_setup_screen.dart';
import 'package:daily_tracker_app/ui/habit_detail_screen.dart';
import 'package:daily_tracker_app/ui/workout_starter_screen.dart';
import 'package:daily_tracker_app/ui/widgets/habit_card.dart';
import 'package:daily_tracker_app/ui/widgets/streak_display.dart';
import 'package:daily_tracker_app/ui/widgets/health_steps_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Wire up with actual providers once created
    final now = DateTime.now();
    final greeting = _getGreeting();
    final dayName = _getDayName(now.weekday);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Reload habits and stats
            await ref.read(unifiedHabitProvider.notifier).loadHabits();
            await ref.read(userStatsProvider.notifier).loadStats();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dayName, ${_formatDate(now)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        // Streak Badge
                        ref.watch(overallStreakStatsProvider).when(
                              data: (streakStats) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${streakStats['longestStreak'] ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Completion Progress Card (New replacing old Stats Row)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ref.watch(unifiedHabitProvider).when(
                      data: (habits) {
                        return FutureBuilder<List<bool>>(
                          future: Future.wait(habits.map((h) => ref.read(unifiedHabitProvider.notifier).isCompletedToday(h.id!))),
                          builder: (context, snapshot) {
                            final completions = snapshot.data ?? [];
                            final completedCount = completions.where((c) => c).length;
                            final totalCount = habits.length;
                            final percentage = totalCount > 0 ? (completedCount / totalCount) : 0.0;

                            return Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Colors.grey[200],
                                        strokeWidth: 6,
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                    Text(
                                      '${(percentage * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Daily Completion',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '$completedCount of $totalCount habits done',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Error loading progress'),
                    ),
              ),
            ),

            // Health Steps Card
            const SliverToBoxAdapter(
              child: HealthStepsCard(),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Habits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Habits List - Real Data
            ref.watch(unifiedHabitProvider).when(
              data: (habits) {
                if (habits.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first habit to get started!',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habits[index];
                      return FutureBuilder<bool>(
                        future: ref.read(unifiedHabitProvider.notifier).isCompletedToday(habit.id!),
                        builder: (context, snapshot) {
                          final isCompleted = snapshot.data ?? false;
                          return HabitCard(
                            habit: habit,
                            isCompleted: isCompleted,
                            onTap: () async {
                              if (isCompleted) {
                                // Uncomplete
                                await ref.read(unifiedHabitProvider.notifier)
                                    .uncompleteHabit(habit.id!, DateTime.now());
                              } else {
                                // Complete
                                await ref.read(unifiedHabitProvider.notifier)
                                    .completeHabit(habit);
                                
                                // Awake XP and check for achievements
                                await ref.read(userStatsProvider.notifier)
                                    .awardXP(habit, isOnStreak: habit.currentStreak > 0);
                                
                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✅ ${habit.name} completed! +${10 + (habit.currentStreak > 0 ? 5 : 0)} XP'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            onLongPress: () {
                              // Navigate to habit detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HabitDetailScreen(habit: habit),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    childCount: habits.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'Focus Session',
                            Icons.self_improvement,
                            const Color(0xFF8059FF),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FocusSetupScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'Workout',
                            Icons.fitness_center,
                            const Color(0xFFFF6B6B),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WorkoutStarterScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'Quit Habits',
                            Icons.block,
                            const Color(0xFFFF5252),
                            () => Navigator.pushNamed(context, '/quit_habits'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            'All Habits',
                            Icons.list,
                            const Color(0xFF4CAF50),
                            () => Navigator.pushNamed(context, '/unified_habits'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    HabitType selectedType = HabitType.checkbox;
    HabitCategory selectedCategory = HabitCategory.personal;
    int? targetValue;
    String? unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Drink 8 glasses of water',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: HabitType.values.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedCategory = category);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final habit = UnifiedHabit(
                    name: name,
                    type: selectedType,
                    category: selectedCategory,
                    targetValue: targetValue,
                    unit: unit,
                    colorIndex: selectedCategory.index,
                    iconName: _getDefaultIcon(selectedCategory),
                  );
                  
                  try {
                    await ref.read(unifiedHabitProvider.notifier).addHabit(habit);
                    // Force refresh to ensure UI updates
                    await ref.read(unifiedHabitProvider.notifier).loadHabits();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Created habit: $name'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating habit: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'fitness_center';
      case HabitCategory.nutrition:
        return 'restaurant';
      case HabitCategory.mind:
        return 'psychology';
      case HabitCategory.productivity:
        return 'work';
      case HabitCategory.personal:
        return 'check_circle';
      case HabitCategory.quit:
        return 'no_drinks';
    }
  }

  Widget _buildStatItem(String label, String value, String suffix, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              suffix,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
