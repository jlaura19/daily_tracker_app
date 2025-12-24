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
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text("User Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("user@example.com", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Appearance Section
          _buildSectionHeader("Appearance"),
          
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (val) => notifier.toggleTheme(val),
          ),

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

          const Divider(),

          // General Section
          _buildSectionHeader("General"),
          
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Daily reminders"),
            secondary: const Icon(Icons.notifications_active),
            value: true, 
            onChanged: (val) {},
          ),

          const Divider(),

          // Account Actions
          _buildSectionHeader("Account"),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
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