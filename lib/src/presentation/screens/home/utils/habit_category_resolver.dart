import 'package:flutter/material.dart';

/// The signature of a habit category → icon/color mapping.
///
/// Single Responsibility: a habit's *category string* is opaque to the
/// presentation layer; this resolver turns it into a visual asset.
class HabitCategoryStyle {
  final IconData icon;
  final Color color;
  const HabitCategoryStyle({required this.icon, required this.color});
}

/// Pure helper that maps a habit category string to a (icon, color) pair.
///
/// The mapping is the single source of truth so the strip, the pill, and any
/// future habit surface stay in sync.
class HabitCategoryResolver {
  const HabitCategoryResolver();

  HabitCategoryStyle resolve(String category) {
    switch (category.toLowerCase().trim()) {
      case 'prayer':
        return const HabitCategoryStyle(
          icon: Icons.mosque,
          color: Color(0xFF1B5E20), // AppColors.primary
        );
      case 'quran':
        return const HabitCategoryStyle(
          icon: Icons.menu_book,
          color: Color(0xFF43A047), // AppColors.nafsMutmainna
        );
      case 'dhikr':
        return const HabitCategoryStyle(
          icon: Icons.spa,
          color: Color(0xFF00695C), // AppColors.secondary
        );
      case 'charity':
        return const HabitCategoryStyle(
          icon: Icons.volunteer_activism,
          color: Color(0xFFFFB300), // AppColors.accent
        );
      case 'exercise':
        return const HabitCategoryStyle(
          icon: Icons.directions_run,
          color: Color(0xFF4CAF50), // AppColors.primaryLight
        );
      case 'other':
      default:
        return const HabitCategoryStyle(
          icon: Icons.task_alt,
          color: Color(0xFF757575), // AppColors.textSecondary
        );
    }
  }
}
