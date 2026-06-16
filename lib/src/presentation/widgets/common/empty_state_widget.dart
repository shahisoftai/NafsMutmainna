import 'package:flutter/material.dart';
import 'package:nafsmutmainna/src/presentation/theme/colors.dart';
import 'package:nafsmutmainna/src/presentation/theme/typography.dart';

/// Empty state widget following Single Responsibility Principle
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h5.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}