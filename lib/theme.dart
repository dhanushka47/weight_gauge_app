import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFDFDFD),
  primaryColor: const Color(0xFFF5B301), // Golden Yellow
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFF5B301),
    primary: const Color(0xFFF5B301),
    secondary: const Color(0xFF2BB673),
    background: const Color(0xFFFDFDFD),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5B301),
    foregroundColor: Colors.black,
    elevation: 2,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2BB673),
    foregroundColor: Colors.white,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE67E22),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);
