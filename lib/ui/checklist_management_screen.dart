// lib/ui/checklist_management_screen.dart

import 'package:daily_tracker_app/models/checklist_model.dart';
import 'package:daily_tracker_app/state/checklist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistManagementScreen extends ConsumerWidget {
  const ChecklistManagementScreen({super.key});

  // --- Dialog to Add Item ---
  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Daily Habit'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Task Name (e.g., Drink 8 glasses of water)'),
              validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newItem = DailyChecklistItem(
                    taskName: nameController.text,
                    iconName: 'check', // Simple default icon
                    sortOrder: 0, 
                  );
                  ref.read(checklistItemProvider.notifier).addItem(newItem);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(checklistItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Daily Habits'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading habits: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Add your first daily habit using the + button!'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.check_box_outline_blank), // Placeholder icon
                title: Text(item.taskName),
                trailing: const Icon(Icons.drag_handle), // Placeholder for future reordering
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}