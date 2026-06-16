import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class IntensitySliderWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const IntensitySliderWidget({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Intensity', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            Text(
              '$value / 10',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
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
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
