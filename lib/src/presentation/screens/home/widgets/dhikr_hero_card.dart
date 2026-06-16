import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../utils/daily_dhikr_resolver.dart';

/// Hero card showing the single dhikr the user should focus on today.
class DhikrHeroCard extends StatelessWidget {
  final DhikrItem dhikr;
  final VoidCallback onCountTap;
  final VoidCallback? onOpenSheetTap;

  const DhikrHeroCard({
    super.key,
    required this.dhikr,
    required this.onCountTap,
    this.onOpenSheetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.spa, color: AppColors.textOnPrimary, size: 14),
              const SizedBox(width: 6),
              Text(
                "TODAY'S PRACTICE",
                style: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dhikr.sourceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              dhikr.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dhikr.transliteration,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (dhikr.meaning.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dhikr.meaning,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textOnPrimary.withValues(alpha: 0.80),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCountTap,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.textOnPrimary),
                  label: const Text(
                    'Count',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textOnPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (onOpenSheetTap != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onOpenSheetTap,
                  icon: const Icon(Icons.visibility_outlined,
                      size: 16, color: AppColors.textOnPrimary),
                  label: const Text(
                    'Reflect',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
