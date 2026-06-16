import 'package:flutter/material.dart';

import '../../../domain/entities/domain.dart';
import '../../theme/colors.dart';

class DomainBadgeWidget extends StatelessWidget {
  final Domain domain;
  const DomainBadgeWidget({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            domain.name,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
