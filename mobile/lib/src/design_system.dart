import 'package:flutter/material.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1264D9);
const Color coolGray = Color(0xFFF6F8FB);
const Color green = Color(0xFF16825D);
const Color amber = Color(0xFFFFB020);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: coolGray,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.light,
        surface: Colors.white,
      ).copyWith(
        primary: blue,
        onPrimary: Colors.white,
        secondary: amber,
        error: const Color(0xFFB42318),
      ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: navy,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: navy,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: navy,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF243B53)),
    bodyMedium: TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF486581)),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
);
