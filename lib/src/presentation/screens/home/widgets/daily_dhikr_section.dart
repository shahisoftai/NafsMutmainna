import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/colors.dart';
import '../../../viewmodels/daily_dhikr_view_model.dart';
import '../../../navigation/app_router.dart';
import '../utils/daily_dhikr_resolver.dart';
import 'dhikr_hero_card.dart';
import 'empty_state_widget.dart';
import 'dhikr_counter_sheet.dart';
import 'dhikr_timeline_sheet.dart';

/// "Your Daily Dhikr" section on the home page.
///
/// Two-tier layout:
/// 1. Today's practice (hero card)
/// 2. 15-day aggregated Allah Names (prominent dual-language cards)
class DailyDhikrSection extends ConsumerStatefulWidget {
  const DailyDhikrSection({super.key});

  @override
  ConsumerState<DailyDhikrSection> createState() => _DailyDhikrSectionState();
}

class _DailyDhikrSectionState extends ConsumerState<DailyDhikrSection> {
  @override
  void initState() {
    super.initState();
    // The DailyDhikrViewModel auto-loads in its constructor, so the first
    // mount triggers load() automatically. No explicit call needed here.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyDhikrViewModelProvider);
    final dhikr = state.dhikr;

    if (state.isLoading && !dhikr.hasAnyCheckins && dhikr.today == null) {
      return const _SectionHeader(
        title: 'Your Daily Dhikr',
        subtitle: '',
      );
    }

    // Empty state: no check-in ever + no today.
    if (dhikr.today == null && !dhikr.hasAnyCheckins) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(title: 'Your Daily Dhikr', subtitle: ''),
          const SizedBox(height: 8),
          const EmptyStateWidget(
            icon: Icons.spa_outlined,
            title: 'Your dhikr journey begins with your first check-in',
            subtitle:
                'After your first check-in, we will surface today\'s practice and the Names guiding you.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: 'Your Daily Dhikr', subtitle: ''),
        const SizedBox(height: 8),
        if (dhikr.today != null) ...[
          DhikrHeroCard(
            dhikr: dhikr.today!,
            onCountTap: () => _openCounterSheet(context, dhikr.today!),
            onOpenSheetTap: () => _openTimelineSheet(
              context,
              title: "Today's practice",
              arabic: dhikr.today!.arabic,
              transliteration: dhikr.today!.transliteration,
              meaning: dhikr.today!.meaning,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (dhikr.history.isNotEmpty) ...[
          const _SubsectionHeader(
            text: 'From your last 15 days',
          ),
          const SizedBox(height: 8),
          if (dhikr.nafsTrend.hasEnoughData ||
              dhikr.nafsTrend.dailyScores.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NafsTrendChart(trend: dhikr.nafsTrend),
            ),
          ...dhikr.history.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AllahNameCard(
                item: item,
                onTap: () => _openTimelineSheet(
                  context,
                  title: item.transliteration.isNotEmpty
                      ? item.transliteration
                      : 'Allah Name',
                  arabic: item.arabic,
                  transliteration: item.transliteration,
                  meaning:
                      'Suggested ${item.timesSuggested}× in 15 days · last via ${item.lastEmotionContext}',
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRouter.journey),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See full 15-day journey →',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          const Text(
            'Your 15-day pattern will build as you check in.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _openCounterSheet(BuildContext context, DhikrItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DhikrCounterSheet(item: item),
    );
  }

  void _openTimelineSheet(
    BuildContext context, {
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DhikrTimelineSheet(
        title: title,
        arabic: arabic,
        transliteration: transliteration,
        meaning: meaning,
      ),
    );
  }
}

/// A prominent card displaying an Allah Name with both Arabic and English.
class _AllahNameCard extends StatelessWidget {
  final DhikrHistoryItem item;
  final VoidCallback onTap;

  const _AllahNameCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.primaryLight.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.transliteration,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          item.arabic,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.timesSuggested}×',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'via ${item.lastEmotionContext}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _SubsectionHeader extends StatelessWidget {
  final String text;
  const _SubsectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// 15-day Nafs trend chart showing movement toward Mutmainnah (positive)
/// or Ammarah (negative).
class _NafsTrendChart extends StatelessWidget {
  final NafsTrendData trend;

  const _NafsTrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend.direction == NafsTrendDirection.up;
    final isDown = trend.direction == NafsTrendDirection.down;
    final trendColor = isUp
        ? AppColors.nafsMutmainna
        : isDown
            ? AppColors.nafsAmmarah
            : AppColors.textSecondary;
    final trendLabel = isUp
        ? 'Moving toward peace'
        : isDown
            ? 'Drifting away'
            : 'Holding steady';
    final trendIcon = isUp
        ? Icons.trending_up
        : isDown
            ? Icons.trending_down
            : Icons.trending_flat;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 16, color: trendColor),
              const SizedBox(width: 6),
              const Text(
                'Nafs trend',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 12, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.deltaPercent > 0 ? '+' : ''}${trend.deltaPercent}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size.infinite,
              painter: _NafsTrendPainter(
                scores: trend.dailyScores,
                lineColor: trendColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trendLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
              const Text(
                '15 days',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the Nafs trend line chart.
class _NafsTrendPainter extends CustomPainter {
  final List<int> scores;
  final Color lineColor;

  _NafsTrendPainter({required this.scores, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    // Pad to 15 days if fewer
    final padded = List<int>.filled(15, 0);
    final offset = 15 - scores.length;
    for (var i = 0; i < scores.length; i++) {
      padded[offset + i] = scores[i];
    }

    final maxV = 100.0;
    final minV = 0.0;
    final range = maxV - minV;
    final stepX = size.width / (padded.length - 1);

    // Draw fill area under the line
    final fillPath = Path();
    final linePath = Path();

    for (var i = 0; i < padded.length; i++) {
      final norm = (padded[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * size.height);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final strokePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, strokePaint);

    // Draw dots for actual data points
    final dotPaint = Paint()..color = lineColor;
    for (var i = offset; i < padded.length; i++) {
      final norm = (padded[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * size.height);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    // Highlight the last point
    final lastNorm = (padded.last - minV) / range;
    final lastX = (padded.length - 1) * stepX;
    final lastY = size.height - (lastNorm * size.height);
    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()..color = lineColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(Offset(lastX, lastY), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _NafsTrendPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.lineColor != lineColor;
  }
}
