import 'package:flutter/material.dart';
import 'package:nafsmutmainna/src/presentation/theme/colors.dart';
import 'package:nafsmutmainna/src/presentation/theme/typography.dart';
import 'package:nafsmutmainna/src/presentation/widgets/common/custom_button.dart';

/// Error widget following Single Responsibility Principle
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
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
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                onPressed: onRetry,
                width: 120,
              ),
            ],
          ],
        ),
      ),
    );
  }
}