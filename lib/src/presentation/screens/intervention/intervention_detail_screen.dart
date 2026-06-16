import 'package:flutter/material.dart';

import '../../../domain/entities/intervention_card.dart';
import '../../theme/colors.dart';

class InterventionDetailScreen extends StatelessWidget {
  final InterventionCard card;
  const InterventionDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(card.type);
    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  card.title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (card.subtitle.isNotEmpty) ...[
              Center(
                child: Text(
                  card.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (card.arabic.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        card.arabic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.8,
                          color: AppColors.textPrimary,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    if (card.urdu.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        card.urdu,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (card.translation.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.translation,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Why this matters',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.why,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailRow('Type', card.title),
                  if (card.attributeId > 0) _detailRow('Attribute ID', '${card.attributeId}'),
                  _detailRow('Emotion ID', '${card.emotionId}'),
                  _detailRow('Relevance Score', '${(card.score * 100).round()}%'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _colorFor(InterventionType t) {
    switch (t) {
      case InterventionType.quran:
        return AppColors.primary;
      case InterventionType.hadith:
        return AppColors.secondary;
      case InterventionType.dua:
        return AppColors.accent;
      case InterventionType.allahNames:
        return AppColors.primaryDark;
      case InterventionType.dhikr:
        return AppColors.nafsMutmainna;
      case InterventionType.action:
        return AppColors.nafsLawwamah;
    }
  }
}
