import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../../domain/entities/vector4.dart';
import '../../screens/home/utils/nafs_trend_helper.dart';
import '../../screens/home/widgets/sparkline_widget.dart';

/// The 4-segment Nafs arc meter (Ammarah, Lawwamah, Mulhamah, Mutmainnah).
///
/// Optional [trend] adds a small ▲/▼/→ chip and [sparkline] adds a tiny
/// 7-day chart at the bottom. Both are backward-compatible: pass `null` to
/// hide them (preserving the original visual).
class NafsMeterWidget extends StatelessWidget {
  final Vector4 vector;
  final NafsType dominant;
  final double size;
  final NafsTrend? trend;
  final List<int>? sparkline;

  const NafsMeterWidget({
    super.key,
    required this.vector,
    required this.dominant,
    this.size = 220,
    this.trend,
    this.sparkline,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final meterWidth = screenWidth - 32;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: Container(
        width: meterWidth,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nafs Meter',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trend != null && trend!.direction != NafsTrendDirection.flat) ...[
                      _trendChip(trend!),
                      const SizedBox(width: 8),
                    ],
                    _dominantBadge(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            _segmentBar(NafsType.ammarah, vector.ammarah, AppColors.nafsAmmarah),
            _segmentBar(NafsType.lawwamah, vector.lawwamah, AppColors.nafsLawwamah),
            _segmentBar(NafsType.mulhamah, vector.mulhamah, AppColors.nafsMulhamah),
            _segmentBar(NafsType.mutmainnah, vector.mutmainnah, AppColors.secondary),
            if (sparkline != null && sparkline!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: SparklineWidget(
                  values: sparkline!,
                  width: meterWidth - 60,
                  height: 22,
                  lineColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segmentBar(NafsType type, double value, Color color) {
    final isDominant = dominant == type;
    final label = type.label;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 13,
                fontWeight: isDominant ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDominant ? color : color.withValues(alpha: 0.65),
                ),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 13,
                fontWeight: isDominant ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dominantBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _labelFor(dominant),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _trendChip(NafsTrend t) {
    final isUp = t.direction == NafsTrendDirection.up;
    final isDown = t.direction == NafsTrendDirection.down;
    final arrow = isUp ? '▲' : isDown ? '▼' : '→';
    final sign = isUp ? '+' : isDown ? '' : '';
    final color = isUp
        ? const Color(0xFFB9F6CA)
        : isDown
            ? const Color(0xFFFFCDD2)
            : const Color(0xFFE0E0E0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$arrow $sign${t.deltaPercent}%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _labelFor(NafsType t) => t.label;
}
