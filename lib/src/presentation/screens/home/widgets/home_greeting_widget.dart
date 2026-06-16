import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../utils/greeting_helper.dart';

/// Personalized, time-aware greeting with Hijri + Gregorian date.
///
/// Composition (top-to-bottom):
/// 1. Arabic greeting (السلام عليكم + optional name)
/// 2. English time-of-day + Hijri + Gregorian date
///
/// The Nafs Meter is the primary visual on the home page; this greeting
/// sits above it as a brief human welcome.
class HomeGreetingWidget extends StatelessWidget {
  final String? displayName;
  final DateTime now;
  final VoidCallback? onAddNameTap;

  const HomeGreetingWidget({
    super.key,
    required this.displayName,
    required this.now,
    this.onAddNameTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = (displayName != null) && displayName!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              hasName
                  ? '${GreetingHelper.arabicGreeting}, ${displayName!.trim()}'
                  : GreetingHelper.arabicGreeting,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${GreetingHelper.timeOfDayGreeting(now)} · '
            '${GreetingHelper.hijriDate(now)} · '
            '${GreetingHelper.gregorianDate(now)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (!hasName && onAddNameTap != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: onAddNameTap,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Text(
                  'Add your name →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
