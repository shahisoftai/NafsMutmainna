import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/vector4.dart';
import '../../screens/home/utils/nafs_trend_helper.dart';
import '../../theme/colors.dart';
import 'nafs_station_reflections.dart';

/// "7-day progress" ring (Option C).
///
/// A 4-sector `fl_chart` `PieChart` whose sectors match the four
/// stations, with a hollow centre showing the dominant station name and
/// the heart-health score. An optional small trend chip appears beneath.
class NafsWeeklyRing extends StatelessWidget {
  final Vector4 vector;
  final NafsType dominant;
  final NafsTrend? trend;
  final int heartHealthScore;
  final double size;

  const NafsWeeklyRing({
    super.key,
    required this.vector,
    required this.dominant,
    required this.heartHealthScore,
    this.trend,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final reflection = reflectionFor(dominant);
    final v = vector.normalised;
    final sectors = <_Sector>[
      _Sector(NafsType.ammarah, 'Ammarah', v.ammarah, AppColors.nafsAmmarah),
      _Sector(
        NafsType.lawwamah,
        'Lawwamah',
        v.lawwamah,
        AppColors.nafsLawwamah,
      ),
      _Sector(
        NafsType.mulhamah,
        'Mulhamah‡',
        v.mulhamah,
        AppColors.nafsMulhamah,
      ),
      _Sector(
        NafsType.mutmainnah,
        'Mutmainnah',
        v.mutmainnah,
        AppColors.secondary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.donut_small_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                '7-day progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: size * 0.30,
                    startDegreeOffset: -90,
                    sections: [
                      for (final s in sectors)
                        PieChartSectionData(
                          value: s.value <= 0 ? 0.0001 : s.value,
                          color: s.color,
                          title: '',
                          radius: size * 0.18,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                _CenterLabel(
                  station: reflection.label,
                  score: heartHealthScore,
                  color: _colorFor(dominant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Legend(sectors: sectors, dominant: dominant),
          if (trend != null && trend!.direction != NafsTrendDirection.flat) ...[
            const SizedBox(height: 12),
            _TrendChip(trend: trend!),
          ],
        ],
      ),
    );
  }

  static Color _colorFor(NafsType t) {
    switch (t) {
      case NafsType.ammarah:
        return AppColors.nafsAmmarah;
      case NafsType.lawwamah:
        return AppColors.nafsLawwamah;
      case NafsType.mulhamah:
        return AppColors.nafsMulhamah;
      case NafsType.mutmainnah:
        return AppColors.secondary;
    }
  }
}

class _Sector {
  final NafsType type;
  final String label;
  final double value;
  final Color color;
  _Sector(this.type, this.label, this.value, this.color);
}

class _CenterLabel extends StatelessWidget {
  final String station;
  final int score;
  final Color color;
  const _CenterLabel({
    required this.station,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          station,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const Text(
          'heart health',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final List<_Sector> sectors;
  final NafsType dominant;
  const _Legend({required this.sectors, required this.dominant});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final s in sectors)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                  border: s.type == dominant
                      ? Border.all(
                          color: AppColors.textPrimary,
                          width: 1.5,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${s.label} ${(s.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: s.type == dominant
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: s.type == dominant
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TrendChip extends StatelessWidget {
  final NafsTrend trend;
  const _TrendChip({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend.direction == NafsTrendDirection.up;
    final isDown = trend.direction == NafsTrendDirection.down;
    final arrow = isUp ? '▲' : isDown ? '▼' : '→';
    final sign = isUp ? '+' : '';
    final color = isUp
        ? AppColors.success
        : isDown
            ? AppColors.error
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        '$arrow $sign${trend.deltaPercent}% vs yesterday',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
