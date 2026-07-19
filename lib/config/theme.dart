import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.blue.shade700,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Color(0xFF1A1A1A),
      background: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white70),
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}