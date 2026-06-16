import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../utils/daily_dhikr_resolver.dart';

/// Compact pill showing one Allah Name from the 15-day history.
class DhikrHistoryPill extends StatelessWidget {
  final DhikrHistoryItem item;
  final VoidCallback onTap;

  const DhikrHistoryPill({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            item.arabic,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
