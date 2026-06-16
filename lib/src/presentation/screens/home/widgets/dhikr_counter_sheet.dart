import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../utils/daily_dhikr_resolver.dart';

/// Bottom sheet: tap-to-count dhikr counter. Long-press to reset.
///
/// In-memory only for the session — persistence is out of scope for v1
/// (per the implementation plan).
class DhikrCounterSheet extends StatefulWidget {
  final DhikrItem item;
  const DhikrCounterSheet({super.key, required this.item});

  @override
  State<DhikrCounterSheet> createState() => _DhikrCounterSheetState();
}

class _DhikrCounterSheetState extends State<DhikrCounterSheet> {
  int _count = 0;

  void _increment() {
    HapticFeedback.selectionClick();
    setState(() => _count += 1);
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dhikr Counter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                widget.item.arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.transliteration,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _increment,
              onLongPress: _reset,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_count',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      widget.item.sourceLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap to count · long-press to reset',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
