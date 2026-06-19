import 'package:flutter/material.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../../domain/services/tazkiya_copy.dart';
import '../../theme/colors.dart';

/// Muhasabah prompts (RI-5.2) + Cause-Whisper (RI-3.5) shown on Reflect.
///
/// Per al-Muhasibi's al-Ri'aya and the hadith "حاسبوا أنفسكم قبل أن تحاسبوا"
/// (Tirmidhi 2459, hasan), every reflection must:
/// 1. Present a rotating muhasabah question (so the user examines
///    intention, signs of Allah, and the source of whispers).
/// 2. Show a cause-whisper anchored to the dominant Cause_Type of the
///    detected attributes — Nafsi/Shaytani/Hawi/Mixed — so the user can
///    take the appropriate protective dhikr.
class ReflectPromptsCard extends StatelessWidget {
  /// The detected attributes for this check-in. Used to derive the
  /// dominant cause-type for the cause-whisper.
  final List<({int attributeId, double score, String role})> detectedAttributes;

  /// Resolver for attribute names (to look up Cause_Type).
  final Future<HeartAttribute?> Function(int attributeId) resolveAttribute;

  const ReflectPromptsCard({
    super.key,
    required this.detectedAttributes,
    required this.resolveAttribute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Muhasabah'),
          const SizedBox(height: 8),
          Text(
            _pickMuhasabah(),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (detectedAttributes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionLabel('Cause-Whisper'),
            const SizedBox(height: 8),
            _causeWhisper(),
          ],
        ],
      ),
    );
  }

  /// Picks a deterministic-but-rotating muhasabah prompt.
  String _pickMuhasabah() {
    final prompts = TazkiyaCopy.muhasabahPromptsEn;
    final idx = DateTime.now().day % prompts.length;
    return prompts[idx];
  }

  /// Derives the dominant Cause_Type from the detected attributes
  /// and shows the matching protective dhikr.
  Widget _causeWhisper() {
    return FutureBuilder<List<HeartAttribute?>>(
      future: Future.wait(
        detectedAttributes.map((d) => resolveAttribute(d.attributeId)),
      ),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final attrs = snap.data!.whereType<HeartAttribute>().toList();
        if (attrs.isEmpty) return const SizedBox.shrink();
        final counts = <CauseType, int>{};
        for (final a in attrs) {
          counts[a.causeType] = (counts[a.causeType] ?? 0) + 1;
        }
        final dominant = counts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
        final protection = dominant.protectiveDhikr;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Dominant cause: ${dominant.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                protection,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.primary,
      ),
    );
  }
}