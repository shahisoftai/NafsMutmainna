import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../utils/daily_dhikr_resolver.dart';

/// Bottom sheet: tap-to-count dhikr counter. Long-press to reset.
///
/// In-memory only for the session — persistence is out of scope for v1
/// (per the implementation plan).
class DhikrCounterSheet extends StatefulWidget {
  final DhikrItem item;
  const DhikrCounterSheet({super.key, required this.item});

  @override
  State<DhikrCounterSheet> createState() => _DhikrCounterSheetState();
}

class _DhikrCounterSheetState extends State<DhikrCounterSheet> {
  int _count = 0;

  bool get _hasTarget =>
      widget.item.target != null && widget.item.target! > 0;

  int get _target => widget.item.target ?? 0;

  int get _remaining {
    if (!_hasTarget) return 0;
    final r = _target - _count;
    return r < 0 ? 0 : r;
  }

  double get _progress {
    if (!_hasTarget) return 0;
    return (_count / _target).clamp(0.0, 1.0);
  }

  bool get _isComplete => _hasTarget && _count >= _target;

  void _increment() {
    HapticFeedback.selectionClick();
    if (_isComplete) {
      // Tiny nudge so the user feels the celebration tap, but don't go past
      // the target — we silently cap so the displayed number stays correct.
      setState(() {});
      return;
    }
    setState(() => _count += 1);
    if (_isComplete) {
      HapticFeedback.heavyImpact();
    }
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dhikr Counter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                widget.item.arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.transliteration,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _CounterDial(
              count: _count,
              target: _hasTarget ? _target : null,
              progress: _progress,
              isComplete: _isComplete,
              sourceLabel: widget.item.sourceLabel,
              onTap: _increment,
              onLongPress: _reset,
            ),
            const SizedBox(height: 12),
            if (_hasTarget) ...[
              _RemainingLine(
                remaining: _remaining,
                isComplete: _isComplete,
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Tap to count · long-press to reset',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular counter that optionally renders a progress arc and "X / Y"
/// caption when a [target] is set.
class _CounterDial extends StatelessWidget {
  final int count;
  final int? target;
  final double progress;
  final bool isComplete;
  final String sourceLabel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CounterDial({
    required this.count,
    required this.target,
    required this.progress,
    required this.isComplete,
    required this.sourceLabel,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final showProgress = target != null;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                      height: 1.0,
                    ),
                  ),
                  if (showProgress) ...[
                    const SizedBox(height: 2),
                    Text(
                      'of $target',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      sourceLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isComplete)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact status line shown beneath the dial when a target is set.
class _RemainingLine extends StatelessWidget {
  final int remaining;
  final bool isComplete;

  const _RemainingLine({required this.remaining, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final color = isComplete ? AppColors.success : AppColors.textSecondary;
    final label = isComplete
        ? "Today's target complete — mashaAllah"
        : '$remaining left today';
    final icon = isComplete ? Icons.check_circle_outline : Icons.timelapse;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
