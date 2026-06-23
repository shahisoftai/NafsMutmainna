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
    final q = _query.toLowerCase();
    final filtered = _query.isEmpty
        ? widget.emotions
        : widget.emotions.where((e) {
            final urdu = (e.urduName ?? '').toLowerCase();
            return e.name.toLowerCase().contains(q) ||
                e.arabicName.contains(_query) ||
                urdu.contains(q) ||
                e.keywords.toLowerCase().contains(q);
          }).toList();
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
        InteractiveViewer(
          constrained: false,
          minScale: 1.0,
          maxScale: 3.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (negative.isNotEmpty) _section('Negative', negative),
              if (positive.isNotEmpty) _section('Positive', positive),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Emotion> items) {
    final isNegative = title == 'Negative';
    final bgColor = isNegative
        ? Colors.red.withValues(alpha: 0.06)
        : Colors.green.withValues(alpha: 0.06);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((e) => _chip(e)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact 2-line bilingual pill: English name on top, Arabic + Urdu
  /// beneath in a smaller secondary colour. The bilingual line uses a Row
  /// (not Directionality) so the ambient text direction (en/ur/ar) flips
  /// the order naturally when the user switches app locale.
  Widget _chip(Emotion e) {
    final isSelected = widget.selected?.id == e.id;
    final color = e.category == 'Negative' ? AppColors.nafsAmmarah : AppColors.primary;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => widget.onSelected(e),
      selectedColor: color.withValues(alpha: 0.15),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: isSelected ? color : AppColors.surfaceVariant),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e.name,
            style: TextStyle(
              color: isSelected ? color : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
              fontSize: 12,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          _bilingualLine(e, isSelected: isSelected, color: color),
        ],
      ),
    );
  }

  Widget _bilingualLine(Emotion e, {required bool isSelected, required Color color}) {
    final hasArabic = e.arabicName.trim().isNotEmpty;
    final hasUrdu = (e.urduName ?? '').trim().isNotEmpty;
    if (!hasArabic && !hasUrdu) return const SizedBox.shrink();
    final secondary = isSelected
        ? color.withValues(alpha: 0.85)
        : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasArabic)
          Text(
            e.arabicName,
            style: TextStyle(color: secondary, fontSize: 11, height: 1.15),
          ),
        if (hasArabic && hasUrdu)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 11,
                height: 1.15,
              ),
            ),
          ),
        if (hasUrdu)
          Text(
            e.urduName!,
            style: TextStyle(color: secondary, fontSize: 11, height: 1.15),
          ),
      ],
    );
  }
}
