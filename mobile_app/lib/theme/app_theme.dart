import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zepeto-inspired App Theme
/// Cute, colorful, and playful design
class AppTheme {
  // Primary Colors - Cute and vibrant
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryPurple = Color(0xFF9D6BFF);
  static const Color primaryBlue = Color(0xFF6BB6FF);
  
  // Secondary Colors - Pastels
  static const Color pastelPink = Color(0xFFFFB3D9);
  static const Color pastelPurple = Color(0xFFD4B3FF);
  static const Color pastelBlue = Color(0xFFB3D9FF);
  static const Color pastelYellow = Color(0xFFFFF3B3);
  static const Color pastelGreen = Color(0xFFB3FFD9);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color black = Color(0xFF212121);
  
  // Mood Colors
  static const Color moodHappy = Color(0xFFFFD93D);
  static const Color moodExcited = Color(0xFFFF6B6B);
  static const Color moodCalm = Color(0xFF6BCB77);
  static const Color moodSad = Color(0xFF4D96FF);
  static const Color moodNeutral = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryPink,
        secondary: primaryPurple,
        tertiary: primaryBlue,
        surface: white,
        surfaceContainerHighest: lightGray,
        onPrimary: white,
        onSecondary: white,
        onSurface: black,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: black,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: white,
        foregroundColor: black,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 8,
        backgroundColor: white,
        indicatorColor: pastelPink,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryPink,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: darkGray,
          );
        }),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: primaryPink,
          foregroundColor: white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  // Gradient backgrounds for different moods
  static LinearGradient get happyGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelYellow, pastelPink],
  );
  
  static LinearGradient get excitedGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, primaryPurple],
  );
  
  static LinearGradient get calmGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelBlue, pastelGreen],
  );
  
  static LinearGradient get sadGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelBlue, pastelPurple],
  );
  
  static LinearGradient get neutralGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGray, mediumGray],
  );
  
  // Get gradient based on mood score
  static LinearGradient getMoodGradient(int mood) {
    if (mood >= 80) return happyGradient;
    if (mood >= 60) return excitedGradient;
    if (mood >= 40) return calmGradient;
    if (mood >= 20) return sadGradient;
    return neutralGradient;
  }
  
  // Get mood color based on score
  static Color getMoodColor(int mood) {
    if (mood >= 80) return moodHappy;
    if (mood >= 60) return moodExcited;
    if (mood >= 40) return moodCalm;
    if (mood >= 20) return moodSad;
    return moodNeutral;
  }
}

