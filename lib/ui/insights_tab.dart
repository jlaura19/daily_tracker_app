// lib/ui/insights_tab.dart

import 'package:daily_tracker_app/ui/reports_screen.dart';
import 'package:daily_tracker_app/ui/schedule_screen.dart';
import 'package:flutter/material.dart';

class InsightsTab extends StatefulWidget {
  const InsightsTab({super.key});

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).hintColor,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Reports',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Schedule',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReportsScreen(), // Existing reports with heatmaps
          ScheduleScreen(), // Existing schedule/calendar view
        ],
      ),
    );
  }
}
