import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/workout_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VoiceCoachApp());
}

class VoiceCoachApp extends StatelessWidget {
  const VoiceCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(),
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
          cardTheme: CardTheme(
            color: const Color(0xFF2A2A2A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
