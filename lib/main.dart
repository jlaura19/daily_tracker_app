// lib/main.dart (Update the ThemeData section)

import 'package:daily_tracker_app/ui/home_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the primary color constants based on the theme
const Color primaryColor = Color(0xFF8059FF); // Deep Purple/Indigo
const Color secondaryColor = Color(0xFF5AB75A); // Green for checks/success
const Color backgroundColor = Color(0xFFF5F5F5); // Very light, off-white background

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Tracker',
      theme: ThemeData(
        // Set Primary Colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: backgroundColor,
          surface: Colors.white,
        ),
        
        // Use Material 3 features
        useMaterial3: true,
        
        // Define Scaffold background color to match the theme
        scaffoldBackgroundColor: backgroundColor,

        // Style AppBar to be flat (no shadow) and match the colors
        appBarTheme: const AppBarTheme(
          color: backgroundColor, // Background color for the AppBar area
          elevation: 0, // Flat design
          surfaceTintColor: Colors.transparent, // Remove default tint effect
          titleTextStyle: TextStyle(
            color: Color(0xFF333333), 
            fontSize: 22, 
            fontWeight: FontWeight.bold
          ),
        ),

        // Style the Floating Action Button to use primary color
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        
        // Style the Bottom Navigation Bar for a clean, flat look
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          elevation: 8, // Slight shadow at the bottom
        ),
      ),
      home: const HomeScreen(), 
    );
  }
}