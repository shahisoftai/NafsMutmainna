import 'package:flutter/material.dart';

import '../../../domain/entities/vector4.dart';
import '../../theme/colors.dart';
import 'nafs_station_reflections.dart';

/// "Your journey" card (Option B).
///
/// A 4-stop trail: Ammarah → Lawwamah → Mulhamah → Mutmainnah. The
/// user's current dominant station is highlighted. A 7-day heart-health
/// sparkline (height 28px) sits beneath the trail, painted directly to
/// keep this widget dependency-free.
class NafsJourneyCard extends StatelessWidget {
  final Vector4 vector;
  final NafsType dominant;
  final List<int> sparkline;

  const NafsJourneyCard({
    super.key,
    required this.vector,
    required this.dominant,
    this.sparkline = const [],
  });

  @override
  Widget build(BuildContext context) {
    final reflection = reflectionFor(dominant);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.explore_outlined,
                size: 18,
                color: _colorFor(dominant),
              ),
              const SizedBox(width: 6),
              const Text(
                'Your journey',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _JourneyTrail(dominant: dominant),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _colorFor(dominant).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: BoxDecoration(
                    color: _colorFor(dominant),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current station: ${reflection.label}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _colorFor(dominant),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reflection.reflection,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (sparkline.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SparklinePainter(
                  values: sparkline,
                  color: _colorFor(dominant),
                ),
              ),
            ),
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

class _JourneyTrail extends StatelessWidget {
  final NafsType dominant;
  const _JourneyTrail({required this.dominant});

  static const _stops = <(NafsType, String, Color)>[
    (NafsType.ammarah, 'Ammarah', AppColors.nafsAmmarah),
    (NafsType.lawwamah, 'Lawwamah', AppColors.nafsLawwamah),
    (NafsType.mulhamah, 'Mulhamah‡', AppColors.nafsMulhamah),
    (NafsType.mutmainnah, 'Mutmainnah', AppColors.secondary),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _stops.length; i++) ...[
          _StopDot(
            label: _stops[i].$2,
            color: _stops[i].$3,
            isDominant: _stops[i].$1 == dominant,
            isPast: _indexOf(dominant) > i,
          ),
          if (i < _stops.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: _indexOf(dominant) > i
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.surfaceVariant,
              ),
            ),
        ],
      ],
    );
  }

  int _indexOf(NafsType t) => _stops.indexWhere((s) => s.$1 == t);
}

class _StopDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDominant;
  final bool isPast;
  const _StopDot({
    required this.label,
    required this.color,
    required this.isDominant,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final size = isDominant ? 18.0 : 12.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDominant
                ? color
                : isPast
                    ? color.withValues(alpha: 0.45)
                    : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isDominant ? 11 : 10,
            fontWeight: isDominant ? FontWeight.w700 : FontWeight.w500,
            color: isDominant ? color : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;
  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    if (values.length == 1) {
      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, dot);
      return;
    }
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs();
    final stepX = size.width / (values.length - 1);

    // Baseline guide.
    final guide = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      guide,
    );

    // Area fill.
    final fillPath = Path()..moveTo(0, size.height);
    final strokePath = Path();
    for (var i = 0; i < values.length; i++) {
      final norm = range == 0 ? 0.5 : (values[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * (size.height - 4)) - 2;
      if (i == 0) {
        strokePath.moveTo(x, y);
      } else {
        strokePath.lineTo(x, y);
      }
      fillPath.lineTo(x, y);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fill);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(strokePath, stroke);

    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final norm = range == 0 ? 0.5 : (values[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * (size.height - 4)) - 2;
      canvas.drawCircle(Offset(x, y), 2.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) {
    return old.values != values || old.color != color;
  }
}
