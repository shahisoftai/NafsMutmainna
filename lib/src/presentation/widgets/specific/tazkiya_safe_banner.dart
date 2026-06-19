import 'package:flutter/material.dart';

import '../../../domain/services/tazkiya_copy.dart';
import '../../theme/colors.dart';

/// Tazkiya-safe banner shown beneath the Nafs Meter on Home.
///
/// Per RI-5.1 (Scholar Audit Remediation Plan §5.1):
/// "Every screen that shows the meter must carry the tazkiya-safe banner."
/// The meter reflects patterns, not the soul's reality (Ghazali, Ihya' 3.13).
///
/// Dismissable per session, but resurfaces on cold start so the user never
/// forgets the framing.
class TazkiyaSafeBanner extends StatelessWidget {
  /// True while the user has dismissed the banner this session.
  final bool dismissed;

  /// Called when the user taps the dismiss icon.
  final VoidCallback? onDismiss;

  const TazkiyaSafeBanner({
    super.key,
    this.dismissed = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (dismissed) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TazkiyaCopy.meterBannerTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TazkiyaCopy.meterBannerBodyEn,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}