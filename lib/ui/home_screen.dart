import 'package:daily_tracker_app/ui/dashboard_tab.dart'; 
import 'package:daily_tracker_app/ui/schedule_screen.dart'; 
import 'package:daily_tracker_app/ui/entry_tab.dart';     
import 'package:daily_tracker_app/ui/daily_checklist_screen.dart';
import 'package:daily_tracker_app/ui/settings_screen.dart'; // Settings Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(), 
    const ScheduleScreen(),
    const EntryTab(),     
    const DailyChecklistScreen(),
    const SettingsScreen(), // NEW TAB
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}