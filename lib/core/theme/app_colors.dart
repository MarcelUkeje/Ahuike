import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Trust Teal/Blue palette for Hospital app
  static const primary = Color(0xFF0F766E); // Teal 600
  static const primaryLight = Color(0xFF14B8A6); // Teal 500
  static const primaryContainer = Color(0xFFCCFBF1); // Teal 50
  
  static const secondary = Color(0xFF3B82F6); // Blue 500
  static const warning = Color(0xFFF59E0B);
  
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  
  static const outline = Color(0xFFE2E8F0); // Slate 200
  static const error = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
