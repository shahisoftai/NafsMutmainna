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
  double _scale = 1.0;

  static const double _scaleMin = 1.0;
  static const double _scaleMax = 1.6;
  static const double _scaleStep = 0.1;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _bumpScale(bool up) {
    setState(() {
      final next = up ? _scale + _scaleStep : _scale - _scaleStep;
      _scale = next.clamp(_scaleMin, _scaleMax);
    });
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
        Row(
          children: [
            Expanded(
              child: TextField(
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
            ),
            const SizedBox(width: 8),
            _FontSizeControls(
              scale: _scale,
              onDecrease: () => _bumpScale(false),
              onIncrease: () => _bumpScale(true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_scale)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (negative.isEmpty && positive.isEmpty)
                _NoResultsState(query: _query)
              else ...[
                if (negative.isNotEmpty) _section('Negative', negative),
                if (positive.isNotEmpty) _section('Positive', positive),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Emotion> items) {
    final isNegative = title == 'Negative';
    final bgColor = isNegative
        ? Colors.red.withValues(alpha: 0.10)
        : Colors.green.withValues(alpha: 0.10);
    final headerColor = isNegative ? Colors.red.shade800 : Colors.green.shade800;
    final borderColor = isNegative
        ? Colors.red.withValues(alpha: 0.25)
        : Colors.green.withValues(alpha: 0.25);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: headerColor,
                fontWeight: FontWeight.w700,
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
          Flexible(
            child: Text(
              e.arabicName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondary, fontSize: 12, height: 1.2),
            ),
          ),
        if (hasArabic && hasUrdu)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ),
        if (hasUrdu)
          Flexible(
            child: Text(
              e.urduName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondary, fontSize: 12, height: 1.2),
            ),
          ),
      ],
    );
  }
}

class _FontSizeControls extends StatelessWidget {
  final double scale;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _FontSizeControls({
    required this.scale,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = scale > _EmotionPickerWidgetState._scaleMin + 0.001;
    final canIncrease = scale < _EmotionPickerWidgetState._scaleMax - 0.001;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease text size',
            onPressed: canDecrease ? onDecrease : null,
            icon: const Text(
              'A-',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.textSecondary.withValues(alpha: 0.2),
          ),
          IconButton(
            tooltip: 'Increase text size',
            onPressed: canIncrease ? onIncrease : null,
            icon: const Text(
              'A+',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            'No emotions match "$query"',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Try the English name, an Arabic / Urdu word, or a related feeling like "sad", "anxious", "happy".',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
