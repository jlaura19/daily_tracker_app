import 'package:daily_tracker_app/ui/home_screen.dart';
import 'package:daily_tracker_app/ui/quit_habits_screen.dart';
import 'package:daily_tracker_app/ui/unified_habits_screen.dart';
import 'package:daily_tracker_app/services/notification_service.dart';
import 'package:daily_tracker_app/state/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Tracker',
      
      themeMode: settings.themeMode,
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8059FF), brightness: Brightness.light),
        useMaterial3: true,
        fontFamily: settings.fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F5F5), surfaceTintColor: Colors.transparent),
      ),
      
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8059FF), brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: settings.fontFamily,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), surfaceTintColor: Colors.transparent),
      ),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child!,
        );
      },

      home: const HomeScreen(),
      routes: {
        '/quit_habits': (context) => const QuitHabitsScreen(),
        '/unified_habits': (context) => const UnifiedHabitsScreen(),
      },
    );
  }
}