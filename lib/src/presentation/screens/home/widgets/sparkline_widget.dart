import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

/// Tiny inline sparkline for a series of integer values.
///
/// Uses a `CustomPainter` so we don't pay the `fl_chart` bundle weight for a
/// single 32px-tall chart. Pure presentation; all math is in the resolver.
class SparklineWidget extends StatelessWidget {
  final List<int> values;
  final Color lineColor;
  final double height;
  final double width;

  const SparklineWidget({
    super.key,
    required this.values,
    this.lineColor = AppColors.textOnPrimary,
    this.height = 28,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: lineColor,
        ),
      ),
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
      // Single point: draw a small dot in the middle.
      final dot = Paint()..color = color.withValues(alpha: 0.9);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        2,
        dot,
      );
      return;
    }

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs();
    final stepX = size.width / (values.length - 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final norm = range == 0 ? 0.5 : (values[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final norm = range == 0 ? 0.5 : (values[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * size.height);
      canvas.drawCircle(Offset(x, y), 2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
