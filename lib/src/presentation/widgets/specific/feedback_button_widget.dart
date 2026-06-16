import 'package:flutter/material.dart';

import '../../../domain/entities/intervention_card.dart';
import '../../theme/colors.dart';

class FeedbackButtonWidget extends StatelessWidget {
  final InterventionFeedback feedback;
  final VoidCallback onTap;
  final bool selected;
  const FeedbackButtonWidget({
    super.key,
    required this.feedback,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (feedback) {
      InterventionFeedback.muchBetter => AppColors.nafsMutmainna,
      InterventionFeedback.better => AppColors.primaryLight,
      InterventionFeedback.same => AppColors.accent,
      InterventionFeedback.worse => AppColors.nafsAmmarah,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? color : color.withValues(alpha: 0.10),
            foregroundColor: selected ? AppColors.textOnPrimary : color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            elevation: 0,
          ),
          child: Text(
            feedback.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
