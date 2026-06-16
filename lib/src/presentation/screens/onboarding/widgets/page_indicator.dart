import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

/// Animated dot indicator for the onboarding PageView.
///
/// Renders [total] dots. The dot at [currentIndex] is wider and
/// opaque (active). The others are small and translucent (inactive).
/// A smooth [AnimatedContainer] animates the width/colour transition
/// when the page changes.
class PageIndicator extends StatelessWidget {
  final int total;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.total,
    required this.currentIndex,
    this.activeColor = AppColors.textOnPrimary,
    this.inactiveColor = const Color(0x66FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
