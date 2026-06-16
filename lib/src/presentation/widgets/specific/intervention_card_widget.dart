import 'package:flutter/material.dart';

import '../../../domain/entities/intervention_card.dart';
import '../../theme/colors.dart';

class InterventionCardWidget extends StatelessWidget {
  final InterventionCard card;
  final VoidCallback? onDone;
  final VoidCallback? onSkip;
  final VoidCallback? onTap;
  final bool done;
  const InterventionCardWidget({
    super.key,
    required this.card,
    this.onDone,
    this.onSkip,
    this.onTap,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(card.type);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card.title,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  if (card.subtitle.isNotEmpty)
                    Flexible(
                      child: Text(
                        card.subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 14, color: color.withValues(alpha: 0.5)),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              if (card.arabic.isNotEmpty)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    card.arabic,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.7,
                      color: AppColors.textPrimary,
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),
              if (card.translation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  card.translation,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (card.urdu.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.urdu,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                card.why,
                style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (onDone != null || onSkip != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSkip != null)
                      TextButton(
                        onPressed: onSkip,
                        child: Text(
                          'Skip',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    if (onDone != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: Icon(done ? Icons.check_circle : Icons.check_circle_outline, color: color, size: 18),
                        label: Text(done ? 'Done' : 'Mark done', style: TextStyle(fontSize: 12, color: color)),
                        onPressed: onDone,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
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
