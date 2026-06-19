import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import 'onboarding_data.dart';

/// A single, full-screen onboarding flash card.
///
/// Visuals:
/// - A vertical gradient background unique per card.
/// - A large primary icon floating in a soft glass-style circle near the top.
/// - A small accent icon in the top-right corner (decorative).
/// - A bold headline.
/// - A short body of 3–6 lines.
/// - A subtle geometric Islamic pattern in the bottom-right corner
///   (drawn as a CustomPainter) to anchor the Islamic aesthetic.
class OnboardingCard extends StatelessWidget {
  final OnboardingCardData data;
  final int index;
  final int total;

  const OnboardingCard({
    super.key,
    required this.data,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative geometric pattern (bottom-right)
            Positioned(
              right: -40,
              bottom: -40,
              child: Opacity(
                opacity: 0.10,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _IslamicStarPainter(),
                ),
              ),
            ),
            // Decorative geometric pattern (top-left, mirrored)
            Positioned(
              left: -30,
              top: -30,
              child: Opacity(
                opacity: 0.08,
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _IslamicStarPainter(),
                ),
              ),
            ),
            // Main content — scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar — step counter on left, accent icon on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${index + 1} of $total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (data.accentIcon != null)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data.accentIcon,
                            size: 18,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Primary icon
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: data.iconBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        size: 72,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Headline
                  Text(
                    data.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOnPrimary,
                      height: 1.2,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Body
                  Text(
                    data.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple 8-pointed Islamic-style star drawn as a CustomPainter.
///
/// Used as a faint decorative watermark in card corners. The geometry
/// is two overlapping squares — the classic Islamic 8-point star — which
/// is a recognizable Islamic motif that doesn't depend on emoji or
/// external assets.
class _IslamicStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // First square (rotated 0°)
    final square1 = Path()
      ..moveTo(cx - r, cy - r)
      ..lineTo(cx + r, cy - r)
      ..lineTo(cx + r, cy + r)
      ..lineTo(cx - r, cy + r)
      ..close();
    canvas.drawPath(square1, paint);

    // Second square (rotated 45°)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(0.7853981633974483); // π/4
    final square2 = Path()
      ..moveTo(-r, -r)
      ..lineTo(r, -r)
      ..lineTo(r, r)
      ..lineTo(-r, r)
      ..close();
    canvas.drawPath(square2, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
