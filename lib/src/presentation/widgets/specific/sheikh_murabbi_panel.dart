import 'package:flutter/material.dart';

import '../../../domain/services/tazkiya_copy.dart';
import '../../theme/colors.dart';

/// Sheikh/Murabbi gentle reminder (RI-3.3) shown on the Pathways screen.
///
/// Per the hadith "الرَّجُلُ عَلَى دِينِ خَلِيلِهِ" (Abu Dawud 4033),
/// classical tazkiya requires a living teacher. The panel makes this clear
/// without being intrusive — the app is a companion, not a replacement.
class SheikhMurabbiPanel extends StatelessWidget {
  const SheikhMurabbiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                TazkiyaCopy.sheikhPanelTitleEn,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            TazkiyaCopy.sheikhPanelBodyEn,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              TazkiyaCopy.sheikhPanelHadithRef,
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Suluk (spiritual-journey) framing header for the Pathways screen (RI-5.6).
class SulukPathwaysHeader extends StatelessWidget {
  const SulukPathwaysHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TazkiyaCopy.sulukPathwaysTitleEn,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            TazkiyaCopy.sulukPathwaysIntroEn,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}