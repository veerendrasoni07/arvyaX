import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF345C78),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F6F8),
      useMaterial3: true,
    );
  }
}

