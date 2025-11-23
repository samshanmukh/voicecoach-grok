import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/workout_provider.dart';
import 'screens/splash_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - app works without it)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase not configured - app will work without leaderboard features');
    print('Error: $e');
  }

  runApp(const VoiceCoachApp());
}

class VoiceCoachApp extends StatelessWidget {
  const VoiceCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: MaterialApp(
        title: 'VoiceCoach by Grok',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFC8FF00), // Lime green
            secondary: const Color(0xFFC8FF00),
            surface: const Color(0xFF1A1A1A), // Dark background
            background: const Color(0xFF0F0F0F), // Darker background
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          cardTheme: CardThemeData(
            color: const Color(0xFF2A2A2A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
