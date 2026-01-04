// lib/ui/schedule_screen.dart

import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/state/tracker_notifier.dart';
import 'package:daily_tracker_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();


  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackerState = ref.watch(trackerNotifierProvider);
    final monthYear = DateFormat('MMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme Background
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Top Bar (Menu, Title, Options) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: const Icon(Icons.view_week, color: Colors.white),
                      onPressed: () {
                        // Logic to change view (Day, Week, etc)
                      },
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text("Schedule", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Icon(Icons.list, color: Colors.white),
                ],
              ),
            ),

            // --- 2. Date Navigation & View Selector ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Month/Year Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                    child: Text(monthYear, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  // Nav Buttons
                  Container(
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => _changeDate(-1),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: Colors.grey[800],
                          child: const Text("Today", style: TextStyle(color: Colors.white)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () => _changeDate(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // --- 3. Week Header (M T W T F S S) ---
            _buildWeekHeader(),

            // --- 4. The Grid ---
            Expanded(
              child: trackerState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                data: (allEntries) {
                  // Filter for Selected Date
                  final dayEntries = allEntries.where((e) {
                    return e.date.year == _selectedDate.year && 
                           e.date.month == _selectedDate.month && 
                           e.date.day == _selectedDate.day;
                  }).toList();

                  return _DarkEventsTimeline(
                    entries: dayEntries,
                    onToggle: (id, status) async {
                       await DatabaseHelper().toggleEntryCompletion(id, status);
                       ref.invalidate(trackerNotifierProvider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // --- FAB to Add Event ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _AddEventModal(selectedDate: _selectedDate),
          );
        },
      ),
    );
  }

  Widget _buildWeekHeader() {
    // A simplified visual header
    final days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
    // logic to align this with real dates would go here
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (index) {
          final isSelected = index == 4; // Mocking 'Friday' as selected
          return Column(
            children: [
              Text(days[index], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey[800] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// --- The Timeline Grid (Dark Mode) ---
class _DarkEventsTimeline extends StatelessWidget {
  final List<TrackingEntry> entries;
  final Function(int, bool) onToggle;
  final double hourHeight = 60.0;

  const _DarkEventsTimeline({required this.entries, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: hourHeight * 24,
        child: Stack(
          children: [
            // 1. Grid Lines & Times
            Column(
              children: List.generate(24, (index) {
                return SizedBox(
                  height: hourHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50, 
                        child: Text(
                          "$index:00", 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)
                        )
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey[900]!, width: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // 2. Event Blocks
            ...entries.map((entry) {
              final startHour = entry.date.hour + (entry.date.minute / 60.0);
              // Calculate duration from endTime if exists, else default 1 hour
              double durationHours = 1.0;
              if (entry.endTime != null) {
                final end = DateTime.fromMillisecondsSinceEpoch(entry.endTime!);
                final diff = end.difference(entry.date).inMinutes;
                durationHours = diff / 60.0;
              }
              
              return Positioned(
                top: startHour * hourHeight,
                left: 60, 
                right: 10,
                height: (durationHours * hourHeight).clamp(30.0, 500.0), // Min height 30
                child: GestureDetector(
                  onTap: () => onToggle(entry.id!, entry.isCompleted), // Tap to toggle complete
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entry.isCompleted ? Colors.grey[850] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: _getColorForType(entry.type), 
                          width: 4
                        )
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
                          )
                        ),
                        if (entry.value != null) 
                          Text("Target: ${entry.value}", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // 3. Current Time Line
            _CurrentTimeLine(hourHeight: hourHeight),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Colors.orange;
      case TrackerType.meal: return Colors.green;
      case TrackerType.fitness: return Colors.redAccent;
      case TrackerType.focus: return Colors.purpleAccent;
      case TrackerType.sports: return const Color(0xFF00BCD4);
      case TrackerType.healthcare: return const Color(0xFFE91E63);
    }
  }
}

class _CurrentTimeLine extends StatelessWidget {
  final double hourHeight;
  const _CurrentTimeLine({required this.hourHeight});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final top = (now.hour + (now.minute / 60.0)) * hourHeight;
    return Positioned(
      top: top, left: 50, right: 0,
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.white),
          Expanded(child: Container(height: 1, color: Colors.white)),
        ],
      ),
    );
  }
}

// --- Add Event Modal (Matches the Screenshot) ---
class _AddEventModal extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const _AddEventModal({required this.selectedDate});

  @override
  ConsumerState<_AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends ConsumerState<_AddEventModal> {
  TrackerType _selectedType = TrackerType.activity;
  String _habitName = "";
  bool _isReminderOn = true;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _repeats = "Never";

  @override
  void initState() {
    super.initState();
    _endTime = _startTime.replacing(hour: _startTime.hour + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark Grey Background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              const Text("New Event", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.save_outlined, color: Colors.white)), // Placeholder icon
            ],
          ),
          const SizedBox(height: 20),

          // Habit Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TrackerType>(
                value: _selectedType,
                dropdownColor: Colors.grey[850],
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: TrackerType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                )).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          // Name Input
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[850],
              hintText: "Enter Habit Name",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (val) => _habitName = val,
          ),

          const SizedBox(height: 20),
          
          // Reminder Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Reminder", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Switch(
                value: _isReminderOn,
                onChanged: (val) => setState(() => _isReminderOn = val),
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.purpleAccent,
              )
            ],
          ),

          const Divider(color: Colors.grey),

          // Time Pickers
          _buildTimeRow("Start", _startTime, (t) => setState(() => _startTime = t)),
          _buildTimeRow("End", _endTime, (t) => setState(() => _endTime = t)),

          const SizedBox(height: 20),
          
          // Repeat Dropdown (Visual only for now)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Repeats", style: TextStyle(color: Colors.white)),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _repeats,
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: ["Never", "Daily", "Weekly"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => _repeats = val!),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: const Text("Save"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay time, Function(TimeOfDay) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label Date", style: const TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: time);
              if (t != null) onSelect(t);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
              child: Text(
                "${widget.selectedDate.day}/${widget.selectedDate.month}   ${time.format(context)}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _saveEvent() {
    if (_habitName.isEmpty) return;

    // Create DateTime objects from TimeOfDay
    final startDateTime = DateTime(
      widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,
      _startTime.hour, _startTime.minute
    );
    
    final endDateTime = DateTime(
      widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,
      _endTime.hour, _endTime.minute
    );

    final entry = TrackingEntry(
      date: startDateTime,
      endTime: endDateTime.millisecondsSinceEpoch,
      type: _selectedType,
      name: _habitName,
      isCompleted: false,
      isReminderOn: _isReminderOn,
      repeat: _repeats,
    );

    ref.read(trackerNotifierProvider.notifier).addEntry(entry);
    Navigator.pop(context);
  }
}