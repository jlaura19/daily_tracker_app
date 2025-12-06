// lib/ui/entry_tab.dart

import 'package:daily_tracker_app/models/tracker_type.dart';
import 'package:daily_tracker_app/models/tracking_entry.dart';
import 'package:daily_tracker_app/state/tracker_notifier.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntryTab extends ConsumerStatefulWidget {
  const EntryTab({super.key});

  @override
  ConsumerState<EntryTab> createState() => _EntryTabState();
}

class _EntryTabState extends ConsumerState<EntryTab> {
  final _formKey = GlobalKey<FormState>();

  TrackerType _selectedType = TrackerType.activity;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final newEntry = TrackingEntry(
        date: DateTime.now(),
        type: _selectedType,
        name: _nameController.text.trim(),
        value: int.tryParse(_valueController.text.trim()),
        notes: _notesController.text.trim().isNotEmpty 
               ? _notesController.text.trim() 
               : null,
        isCompleted: false, // Default to not completed
      );

      ref.read(trackerNotifierProvider.notifier).addEntry(newEntry);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged ${_selectedType.displayName} entry!'),
          backgroundColor: _getColorForType(_selectedType),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _resetForm();
    }
  }
  
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _valueController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "What did you do?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 20),
            
            // --- 1. Colorful Category Grid (The new look) ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: TrackerType.values.length,
              itemBuilder: (context, index) {
                final type = TrackerType.values[index];
                final isSelected = _selectedType == type;
                final color = _getColorForType(type);

                return InkWell(
                  onTap: () => setState(() => _selectedType = type),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForType(type),
                          color: isSelected ? Colors.white : color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // --- 2. Input Fields (Soft Style) ---
            _buildLabel("Name / Title"),
            _buildTextField(
              controller: _nameController,
              hint: "e.g., Healthy Salad",
              icon: Icons.edit,
            ),
            const SizedBox(height: 20),

            _buildLabel("Value (Optional)"),
            _buildTextField(
              controller: _valueController,
              hint: "e.g., 500 (calories) or 30 (mins)",
              icon: Icons.numbers,
              isNumber: true,
            ),
            const SizedBox(height: 20),
            
            _buildLabel("Notes (Optional)"),
            _buildTextField(
              controller: _notesController,
              hint: "Add details...",
              icon: Icons.sticky_note_2,
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // --- 3. Big Action Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'LOG ENTRY',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (!isNumber && maxLines == 1 && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Color _getColorForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Colors.orange;
      case TrackerType.meal: return const Color(0xFF5AB75A);
      case TrackerType.fitness: return const Color(0xFFFF6B6B);
      case TrackerType.focus: return const Color(0xFF8059FF);
    }
  }

  IconData _getIconForType(TrackerType type) {
    switch (type) {
      case TrackerType.activity: return Icons.local_fire_department;
      case TrackerType.meal: return Icons.restaurant;
      case TrackerType.fitness: return Icons.fitness_center;
      case TrackerType.focus: return Icons.self_improvement;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}