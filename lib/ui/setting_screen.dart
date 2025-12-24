// lib/ui/settings_screen.dart

import 'package:daily_tracker_app/state/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDarkMode = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // Blends with background
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- 1. Profile Header ---
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Placeholder Image
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 16),
                Text("Jane Doe", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("jane.doe@example.com", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // --- 2. Appearance Section ---
          _buildSectionHeader("Appearance"),
          
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (val) => notifier.toggleTheme(val),
          ),

          // Font Size Slider
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text("Font Size"),
            subtitle: Slider(
              value: settings.textScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: "${(settings.textScale * 100).toInt()}%",
              onChanged: (val) => notifier.setTextScale(val),
            ),
          ),

          // Font Style Selector
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text("Font Style"),
            trailing: DropdownButton<String>(
              value: settings.fontFamily, // Null means default
              hint: const Text("Default"),
              underline: const SizedBox(), // Remove line
              onChanged: (val) => notifier.setFontFamily(val),
              items: const [
                DropdownMenuItem(value: null, child: Text("Default")),
                DropdownMenuItem(value: "Serif", child: Text("Serif")),
                DropdownMenuItem(value: "Monospace", child: Text("Monospace")),
                // Add Google Fonts names here if you add the package later
              ],
            ),
          ),

          const Divider(),

          // --- 3. App Settings ---
          _buildSectionHeader("General"),
          
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Daily reminders"),
            secondary: const Icon(Icons.notifications_active),
            value: true, // Connect to a provider if you want to save this state
            onChanged: (val) {
              // Toggle logic here
            },
          ),

          const Divider(),

          // --- 4. Account Actions ---
          _buildSectionHeader("Account"),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Sign Out?"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        // Perform sign out
                        notifier.signOut();
                        Navigator.pop(context);
                      },
                      child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            trailing: const Text("v1.0.0"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}