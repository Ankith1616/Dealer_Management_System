import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings (Outfit)
  static TextStyle get h1 => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
  );
  
  static TextStyle get h2 => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static TextStyle get h3 => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h4 => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get h5 => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Body Text (Inter)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
