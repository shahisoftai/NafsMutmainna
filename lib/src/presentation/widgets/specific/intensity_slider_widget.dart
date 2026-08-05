import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class IntensitySliderWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const IntensitySliderWidget({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = _intensityLabel(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Intensity', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            Text(
              '$value / 10  ·  $label',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$value · $label',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('😌 Mild', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('😟 Moderate', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('😰 Severe', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  static String _intensityLabel(int v) {
    if (v <= 3) return 'Mild';
    if (v <= 6) return 'Moderate';
    if (v <= 8) return 'Strong';
    return 'Severe';
  }
}
