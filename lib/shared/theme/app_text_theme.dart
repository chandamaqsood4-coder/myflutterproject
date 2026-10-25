import 'package:flutter/material.dart';

// Global text theme used across the app (Inter font)
final TextTheme appTextTheme = const TextTheme(
  headlineSmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ), // page title
  titleMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ), // dialog title
  bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 14), // subtitle, buttons
  bodyMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
  ), // table, nav, dialog body
  labelSmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
  ), // badges
);

const TextStyle skuStyle = TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11);
