import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../screens/home/utils/nafs_trend_helper.dart';

/// 0-100 score with a coloured band.
///
/// Optional [trend] shows a small ▲/▼/→ chip with the delta. Optional [tip]
/// shows a one-line actionable tip tied to the score band. Both are
/// backward-compatible: pass `null` to hide them.
class HeartHealthScoreWidget extends StatelessWidget {
  final int score;
  final NafsTrend? trend;
  final String? tip;

  const HeartHealthScoreWidget({
    super.key,
    required this.score,
    this.trend,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(score);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Text(
                  '/100',
                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Heart Health',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (trend != null && trend!.direction != NafsTrendDirection.flat)
                      _trendChip(trend!),
                  ],
                ),
                Text(
                  _label(score),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _description(score),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                if (tip != null && tip!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tip!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendChip(NafsTrend t) {
    final isUp = t.direction == NafsTrendDirection.up;
    final isDown = t.direction == NafsTrendDirection.down;
    final arrow = isUp ? '▲' : isDown ? '▼' : '→';
    final sign = isUp ? '+' : isDown ? '' : '';
    final color = isUp
        ? AppColors.success
        : isDown
            ? AppColors.error
            : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$arrow $sign${t.deltaPercent}% (7d)',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _label(int s) {
    if (s >= 80) return 'Excellent';
    if (s >= 60) return 'Strong';
    if (s >= 40) return 'Growing';
    if (s >= 20) return 'Awakening';
    return 'Just starting';
  }

  String _description(int s) {
    if (s >= 80) return 'Mutmainnah — inner peace and trust in Allah';
    if (s >= 60) return 'Mulhamah — walking the inspired path';
    if (s >= 40) return 'Lawwamah — conscience is alive';
    if (s >= 20) return 'Lawwamah — turning back, beginning to awaken';
    return 'Ammarah — heedlessness of the heart';
  }

  /// One-line actionable tip per band. Tied to the Nafs station so the user
  /// always sees what *one concrete thing* moves them toward Mutmainnah.
  String tipFor(int s) {
    if (s >= 80) return 'Mutmainnah — inner peace and trust in Allah.';
    if (s >= 60) return 'Mulhamah — walking the inspired path.';
    if (s >= 40) return 'Lawwamah — conscience is alive. Keep going.';
    if (s >= 20) return 'Awakening. Try a 5-min Quran reflection.';
    return 'Ammarah — heedlessness. Start with one small dhikr.';
  }

  Color _colorFor(int s) {
    if (s >= 80) return AppColors.secondary;
    if (s >= 60) return AppColors.nafsMulhamah;
    if (s >= 40) return AppColors.nafsLawwamah;
    if (s >= 20) return AppColors.accent;
    return AppColors.nafsAmmarah;
  }
}
