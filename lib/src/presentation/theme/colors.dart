import 'package:flutter/material.dart';

/// App color palette following Single Responsibility Principle
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF0D3D12);

  // Secondary colors
  static const Color secondary = Color(0xFF00695C);
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color secondaryDark = Color(0xFF004D40);

  // Accent colors
  static const Color accent = Color(0xFFFFB300);
  static const Color accentLight = Color(0xFFFFCA28);
  static const Color accentDark = Color(0xFFFF8F00);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Nafs type colors
  static const Color nafsAmmarah = Color(0xFFE53935);
  static const Color nafsLawwamah = Color(0xFFFB8C00);
  static const Color nafsMulhamah = Color(0xFF658A65);
  static const Color nafsMutmainna = Color(0xFF43A047);

  // Emotion colors
  static const Color emotionHappy = Color(0xFF4CAF50);
  static const Color emotionCalm = Color(0xFF2196F3);
  static const Color emotionAnxious = Color(0xFFFF9800);
  static const Color emotionSad = Color(0xFF9C27B0);
  static const Color emotionAngry = Color(0xFFF44336);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
}