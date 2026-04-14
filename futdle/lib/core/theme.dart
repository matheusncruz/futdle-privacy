import 'package:flutter/material.dart';

const Color kGreen = Color(0xFF1a472a);
const Color kGreenLight = Color(0xFF22c55e);
const Color kYellow = Color(0xFFEAB308);
const Color kRed = Color(0xFFEF4444);
const Color kBackground = Color(0xFF111827);
const Color kSurface = Color(0xFF1F2937);
const Color kTextPrimary = Color(0xFFF9FAFB);
const Color kTextSecondary = Color(0xFF9CA3AF);

final ThemeData futdleTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.dark(
    primary: kGreen,
    secondary: kGreenLight,
    surface: kSurface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBackground,
    foregroundColor: kTextPrimary,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: kTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: kTextPrimary, fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGreen,
      foregroundColor: kTextPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: kTextSecondary),
  ),
);
