import 'package:flutter/material.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../theme/colors.dart';

/// Horizontal chain of attribute chips showing the user's growth path.
class GrowthPathStrip extends StatelessWidget {
  final List<HeartAttribute> path;
  const GrowthPathStrip({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: path.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
        itemBuilder: (context, i) {
          final attr = path[i];
          return Container(
            width: 130,
            height: 70,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    attr.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: i == 0 ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    attr.arabicName,
                    style: TextStyle(
                      fontSize: 12,
                      color: i == 0 ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
