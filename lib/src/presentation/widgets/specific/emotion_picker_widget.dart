import 'package:flutter/material.dart';

import '../../../domain/entities/emotion.dart';
import '../../theme/colors.dart';

/// Searchable typeahead for the 50 emotions, grouped by Category.
class EmotionPickerWidget extends StatefulWidget {
  final List<Emotion> emotions;
  final Emotion? selected;
  final ValueChanged<Emotion> onSelected;
  const EmotionPickerWidget({
    super.key,
    required this.emotions,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<EmotionPickerWidget> createState() => _EmotionPickerWidgetState();
}

class _EmotionPickerWidgetState extends State<EmotionPickerWidget> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.emotions
        : widget.emotions
            .where((e) =>
                e.name.toLowerCase().contains(_query.toLowerCase()) ||
                e.arabicName.contains(_query) ||
                e.keywords.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    final negative = filtered.where((e) => e.category == 'Negative').toList();
    final positive = filtered.where((e) => e.category == 'Positive').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search emotions...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        if (negative.isNotEmpty) _section('Negative', negative),
        if (positive.isNotEmpty) _section('Positive', positive),
      ],
    );
  }

  Widget _section(String title, List<Emotion> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((e) => _chip(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(Emotion e) {
    final isSelected = widget.selected?.id == e.id;
    final color = e.category == 'Negative' ? AppColors.nafsAmmarah : AppColors.primary;
    return ChoiceChip(
      label: Text(e.name),
      selected: isSelected,
      onSelected: (_) => widget.onSelected(e),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? color : AppColors.surfaceVariant),
    );
  }
}
