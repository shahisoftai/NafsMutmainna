import 'package:flutter/material.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../theme/colors.dart';

/// Row showing a detected attribute with its Arabic name and definition.
class DetectedAttributeWidget extends StatelessWidget {
  final HeartAttribute attribute;
  final double score;
  const DetectedAttributeWidget({super.key, required this.attribute, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (attribute.nature == 'Positive' ? AppColors.primary : AppColors.nafsAmmarah)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${(score * 100).round()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: attribute.nature == 'Positive' ? AppColors.primary : AppColors.nafsAmmarah,
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
                  Text(
                    attribute.arabicName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attribute.definition,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
