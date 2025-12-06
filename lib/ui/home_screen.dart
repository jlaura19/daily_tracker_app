// lib/ui/home_screen.dart

import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/state/tracker_notifier.dart'; 
import 'package:daily_tracker_app/ui/dashboard_tab.dart'; 
import 'package:daily_tracker_app/ui/entry_tab.dart'; 
import 'package:daily_tracker_app/ui/daily_checklist_screen.dart'; // Checklist Import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_tracker_app/ui/schedule_screen.dart'; // ADD THIS IMPORT

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0; // Tracks the selected tab

  // Define the list of screens corresponding to the bottom navigation items
  final List<Widget> _tabs = [
    const DashboardTab(), // 0: Dashboard (Charts/Summary, Exercise Planner Link)
    const ScheduleScreen(),
    const EntryTab(),     // 1: Entry (Logging new data)
    const DailyChecklistScreen(), // 2: Habits (Daily Checklist)
  ];
  

  @override
  Widget build(BuildContext context) {
    // You can watch the main tracker state here if you need to react to global changes
    AsyncValue<List<TrackingEntry>> trackerState = ref.watch(trackerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Use IndexedStack to preserve the state of the tabs when switching
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // Set the color scheme to make the selected icon stand out
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // IMPORTANT: Use fixed type for >3 items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}