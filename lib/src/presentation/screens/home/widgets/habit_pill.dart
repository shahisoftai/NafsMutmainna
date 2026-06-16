import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../viewmodels/home_habits_view_model.dart';

/// Single tappable habit pill used inside the Today's Habits strip.
class HabitPill extends StatelessWidget {
  final HabitWithStatus habit;
  final VoidCallback onTap;

  const HabitPill({
    super.key,
    required this.habit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final isDone = habit.completedToday;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDone ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? color.withValues(alpha: 0.5) : AppColors.surfaceVariant,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  habit.icon,
                  color: isDone ? color : AppColors.textSecondary,
                  size: 22,
                ),
                if (isDone)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.textOnPrimary,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              habit.habit.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
