import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class MasterPathwayCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String path;
  final VoidCallback onTap;
  const MasterPathwayCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  path,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
