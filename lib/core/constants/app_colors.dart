import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Deep Indigo)
  static const Color primary = Color(0xFF3949AB);
  static const Color primaryLight = Color(0xFF6F74DD);
  static const Color primaryDark = Color(0xFF00227B);

  // Secondary Palette (Warm Amber)
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFC046);
  static const Color secondaryDark = Color(0xFFC56000);

  // Accent Palette (Teal)
  static const Color accent = Color(0xFF00695C);
  static const Color accentLight = Color(0xFF439889);
  
  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Cards
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  
  // States
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const List<Color> gradientPrimary = [Color(0xFF1A237E), Color(0xFF3949AB)];
  static const List<Color> gradientSecondary = [Color(0xFFFF8F00), Color(0xFFFFB300)];
  static const List<Color> gradientAccent = [Color(0xFF004D40), Color(0xFF00897B)];

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Interior Wall': Color(0xFFE1BEE7), // Soft purple
    'Exterior Wall': Color(0xFFB3E5FC), // Soft blue
    'Primer': Color(0xFFF5F5F5), // Light gray
    'Enamel': Color(0xFFFFE082), // Soft amber
    'Distemper': Color(0xFFC8E6C9), // Soft green
    'Texture': Color(0xFFD7CCC8), // Soft brown
    'Wood Finish': Color(0xFFFFCCBC), // Soft orange
    'Waterproofing': Color(0xFFBBDEFB), // Blue
  };
}
