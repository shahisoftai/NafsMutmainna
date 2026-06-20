import 'package:flutter/material.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../theme/colors.dart';

/// Full-bilingual card for a detected attribute on the Heart Analysis screen.
///
/// Layout (mirrors the emotion pill on the Check-in screen):
///   - Score badge on the left (48x48, colour-coded by nature)
///   - English name on top (14pt, w600, nature colour)
///   - Arabic · Urdu bilingual line (12pt, secondary)
///   - English definition below (12pt, **textPrimary** — readable)
///   - Optional Urdu definition (12pt, secondary)
///   - Tap → show full bottom-sheet with the rest of the attribute detail
///     (Quran, Hadith, dua, daily action) so the list stays scannable.
class DetectedAttributeWidget extends StatelessWidget {
  final HeartAttribute attribute;
  final double score;
  const DetectedAttributeWidget({super.key, required this.attribute, required this.score});

  @override
  Widget build(BuildContext context) {
    final natureColor = attribute.nature == 'Positive' ? AppColors.primary : AppColors.nafsAmmarah;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(context, natureColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: natureColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${(score * 100).round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: natureColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attribute.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _bilingualLine(),
                    const SizedBox(height: 6),
                    Text(
                      attribute.definition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Arabic + Urdu on a single Row; ambient Directionality flips the order
  /// when the app locale is Urdu or Arabic, just like the emotion pill.
  Widget _bilingualLine() {
    final hasArabic = attribute.arabicName.trim().isNotEmpty;
    final hasUrdu = (attribute.urduName ?? '').trim().isNotEmpty;
    if (!hasArabic && !hasUrdu) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasArabic)
          Text(
            attribute.arabicName,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.2),
          ),
        if (hasArabic && hasUrdu)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                height: 1.2,
              ),
            ),
          ),
        if (hasUrdu)
          Text(
            attribute.urduName!,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.2),
          ),
      ],
    );
  }

  /// Opens a bottom-sheet with the full attribute detail (definition, Quran,
  /// Hadith, dua, daily action). Keeps the list compact by default.
  void _showDetails(BuildContext context, Color natureColor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                attribute.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: natureColor),
              ),
              const SizedBox(height: 4),
              _bilingualLine(),
              const SizedBox(height: 16),
              _section('Definition', attribute.definition),
              if (attribute.oppositeTrait.isNotEmpty)
                _section('Opposite', '${attribute.oppositeTrait}  ·  ${attribute.oppositeArabic}'),
              if (attribute.quranArabic.isNotEmpty) ...[
                _section('Quran (${attribute.quranReference})',
                    '${attribute.quranArabic}\n\n${attribute.quranEnglish}\n\n${attribute.quranUrdu}'),
              ],
              if (attribute.hadithArabic.isNotEmpty)
                _section('Hadith (${attribute.hadithReference})',
                    '${attribute.hadithArabic}\n\n${attribute.hadithUrdu}'),
              if (attribute.dailyAction.isNotEmpty)
                _section('Daily Action', attribute.dailyAction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
