import 'package:flutter/material.dart';

import '../../../domain/services/tazkiya_copy.dart';
import '../../theme/colors.dart';

/// Tazkiya-safe disclaimer (RI-4.7) shown at the top of the Intervention screen.
///
/// Per Ibn al-Qayyim: "Every remedy is general unless specified; every soul's
/// state is specific." The disclaimer is non-intrusive but always visible.
class InterventionDisclaimerBanner extends StatelessWidget {
  /// Whether the user has dismissed the disclaimer this session.
  final bool dismissed;
  final VoidCallback? onDismiss;

  const InterventionDisclaimerBanner({
    super.key,
    this.dismissed = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (dismissed) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              TazkiyaCopy.interventionDisclaimerEn,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: AppColors.textSecondary,
              tooltip: 'Dismiss',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}