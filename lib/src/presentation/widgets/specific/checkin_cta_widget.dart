import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Big primary CTA button on the Home screen.
class CheckInCTAWidget extends StatelessWidget {
  final VoidCallback onTap;
  const CheckInCTAWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.favorite, color: AppColors.textOnPrimary),
        label: const Text(
          'How is your heart today?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}
