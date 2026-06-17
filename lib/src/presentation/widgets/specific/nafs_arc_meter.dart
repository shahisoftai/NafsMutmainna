import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/vector4.dart';
import '../../theme/colors.dart';
import 'nafs_station_reflections.dart';

/// Inspirational gradient-arc Nafs meter.
///
/// Full-width 180° arc with a smooth red → orange → green gradient
/// (Ammarah on the left → Mutmainnah on the right). A tapered meter arm
/// with a counter-weight, glowing tip and pivot screw points to the
/// composite position of the user's soul. Below the arc, a row of four
/// station names highlights the dominant one. The whole card is
/// tappable; pass [onTap] to navigate to the detail view.
///
/// Visual is purely additive to the design system — uses existing
/// [AppColors] for chrome and a small set of local gradient stops for
/// the arc. No new dependencies.
class NafsArcMeter extends StatelessWidget {
  final Vector4 vector;
  final NafsType dominant;
  final VoidCallback? onTap;

  const NafsArcMeter({
    super.key,
    required this.vector,
    required this.dominant,
    this.onTap,
  });

  /// Composite position of the soul on the 0..1 arc, where 0 = pure
  /// Ammarah and 1 = pure Mutmainnah. Weights 0, 1/3, 2/3, 1 place the
  /// four stations at evenly-spaced points along the arc. Result is
  /// normalised by the input's total so non-normalised vectors still
  /// resolve to a valid position in [0, 1].
  static double compositePosition(Vector4 v) {
    final s = v.ammarah + v.lawwamah + v.mulhamah + v.mutmainnah;
    if (s <= 0) return 0;
    final raw = (0.0 * v.ammarah +
            (1.0 / 3.0) * v.lawwamah +
            (2.0 / 3.0) * v.mulhamah +
            1.0 * v.mutmainnah) /
        s;
    return raw.clamp(0.0, 1.0);
  }

  /// Local arc gradient stops — independent of the wider app palette so
  /// the meter reads as a smooth "bad → good" red → green ramp.
  static const _gradientStops = <Color>[
    Color(0xFFE53935), // Ammarah — red
    Color(0xFFFB8C00), // Lawwamah — orange
    Color(0xFF66BB6A), // Mulhamah — green
    Color(0xFF2E7D32), // Mutmainnah — dark green
  ];

  /// Station label set used by the row beneath the arc.
  static const _stationLabels = <(NafsType, String)>[
    (NafsType.ammarah, 'Ammarah'),
    (NafsType.lawwamah, 'Lawwamah'),
    (NafsType.mulhamah, 'Mulhamah'),
    (NafsType.mutmainnah, 'Mutmainnah'),
  ];

  static Color _colorFor(NafsType t) {
    switch (t) {
      case NafsType.ammarah:
        return _gradientStops[0];
      case NafsType.lawwamah:
        return _gradientStops[1];
      case NafsType.mulhamah:
        return _gradientStops[2];
      case NafsType.mutmainnah:
        return _gradientStops[3];
    }
  }

  @override
  Widget build(BuildContext context) {
    final reflection = reflectionFor(dominant);
    final card = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Half-circle needs roughly 0.33× of the width in height (60% of
        // the original 0.55) for the arc + arm + pivot to fit cleanly.
        final arcHeight = (width * 0.33).clamp(72.0, 156.0);
        return Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nafs Meter',
                    style: TextStyle(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _colorFor(dominant).withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _colorFor(dominant).withValues(alpha: 0.65),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reflection.label,
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: width,
                height: arcHeight,
                child: CustomPaint(
                  painter: _ArcPainter(
                    position: compositePosition(vector),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Station labels row — left, centre, centre, right.
              Row(
                children: [
                  for (var i = 0; i < _stationLabels.length; i++)
                    Expanded(
                      child: Text(
                        _stationLabels[i].$2,
                        textAlign: switch (i) {
                          0 => TextAlign.left,
                          3 => TextAlign.right,
                          _ => TextAlign.center,
                        },
                        style: TextStyle(
                          color: _stationLabels[i].$1 == dominant
                              ? _colorFor(_stationLabels[i].$1)
                              : AppColors.textOnPrimary
                                  .withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: _stationLabels[i].$1 == dominant
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reflection.descriptor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 12,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.70),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.70),
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double position; // 0..1
  _ArcPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    // Pivot at bottom-centre.
    final centre = Offset(size.width / 2, size.height * 0.96);
    // Radius: half the width (minus a small margin) and constrained to
    // the available height.
    final radius =
        math.min(size.width / 2 - 6, size.height * 0.94).toDouble();
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Stroke thickness — a chunky 28% of the radius for a substantial
    // gauge look.
    final strokeW = radius * 0.28;
    final trackW = radius * 0.18;

    // 1) Track background (faint white) — the full 180° arc as a guide.
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    // 2) Gradient arc — smooth red → orange → green sweep.
    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        colors: NafsArcMeter._gradientStops,
        stops: [0.0, 0.33, 0.66, 1.0],
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        transform: GradientRotation(0),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, math.pi, math.pi, false, gradientPaint);

    // 3) Inner highlight on the arc — a slightly thinner white stroke
    //    along the top of the gradient gives a subtle "glass" sheen.
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(
        center: centre,
        radius: radius - strokeW * 0.32,
      ),
      math.pi + 0.05,
      math.pi - 0.10,
      false,
      sheenPaint,
    );

    // 4) Five tick marks at 0%, 25%, 50%, 75%, 100% — band boundaries.
    for (var i = 0; i <= 4; i++) {
      final t = i / 4.0;
      final angle = math.pi + (t * math.pi);
      final inner = radius - strokeW / 2 - 3;
      final outer = radius + strokeW / 2 + 3;
      final startPt = Offset(
        centre.dx + inner * math.cos(angle),
        centre.dy + inner * math.sin(angle),
      );
      final endPt = Offset(
        centre.dx + outer * math.cos(angle),
        centre.dy + outer * math.sin(angle),
      );
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: i == 0 || i == 4 ? 0.55 : 0.30)
        ..strokeWidth = i == 0 || i == 4 ? 2.0 : 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startPt, endPt, paint);
    }

    // 5) Meter arm (needle) — main line, counter-weight, tip, pivot.
    _drawArm(canvas, centre, radius, strokeW);
  }

  void _drawArm(Canvas canvas, Offset centre, double radius, double strokeW) {
    final needleAngle = math.pi + (position * math.pi);
    final tipDist = radius;
    final tipPt = Offset(
      centre.dx + tipDist * math.cos(needleAngle),
      centre.dy + tipDist * math.sin(needleAngle),
    );
    // Short counter-weight on the opposite side of the pivot.
    final tailDist = strokeW * 0.55;
    final tailPt = Offset(
      centre.dx - tailDist * math.cos(needleAngle),
      centre.dy - tailDist * math.sin(needleAngle),
    );

    // Soft drop shadow on the arm.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.40)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(
      Offset(tailPt.dx, tailPt.dy + 1.5),
      Offset(tipPt.dx, tipPt.dy + 1.5),
      shadow,
    );

    // Main arm body — bright white.
    final arm = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tailPt, tipPt, arm);

    // Tip: outer white halo + inner dark dot.
    final tipHalo = Paint()..color = Colors.white;
    canvas.drawCircle(tipPt, 7, tipHalo);
    final tipDot = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawCircle(tipPt, 3.2, tipDot);

    // Pivot screw — shadow disc + bright cap + centre.
    final pivotShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(centre.dx, centre.dy + 1), 9, pivotShadow);
    final pivotCap = Paint()..color = Colors.white;
    canvas.drawCircle(centre, 7, pivotCap);
    final pivotCenter =
        Paint()..color = AppColors.textOnPrimary.withValues(alpha: 0.4);
    canvas.drawCircle(centre, 3, pivotCenter);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.position != position;
}
