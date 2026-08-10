import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/vector4.dart';
import '../../theme/colors.dart';
import '../../viewmodels/journey_view_model.dart';
import '../home/utils/daily_dhikr_resolver.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});
  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(journeyViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journeyViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your 15-Day Journey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? Center(
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            : _buildBody(state.data),
      ),
    );
  }

  Widget _buildBody(JourneyData data) {
    if (data.days.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Your journey will appear here after your first check-in.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NafsTrendCard(trend: data.trend),
        const SizedBox(height: 16),
        _NamesFrequencySection(frequency: data.nameFrequency),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Day-by-Day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...data.days.reversed.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _JourneyDayCard(day: day),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _NafsTrendCard extends StatelessWidget {
  final NafsTrendData trend;

  const _NafsTrendCard({required this.trend});

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
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NafsTrendPainter extends CustomPainter {
  final List<int> scores;
  final Color lineColor;

  _NafsTrendPainter({required this.scores, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final padded = List<int>.filled(scores.length, 0);
    for (var i = 0; i < scores.length; i++) {
      padded[i] = scores[i];
    }

    const maxV = 100.0;
    const minV = 0.0;
    final range = maxV - minV;
    final stepX = size.width / (padded.length - 1);

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

    final strokePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, strokePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < padded.length; i++) {
      final norm = (padded[i] - minV) / range;
      final x = i * stepX;
      final y = size.height - (norm * size.height);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

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

class _NamesFrequencySection extends StatelessWidget {
  final Map<String, int> frequency;

  const _NamesFrequencySection({required this.frequency});

  @override
  Widget build(BuildContext context) {
    if (frequency.isEmpty) return const SizedBox.shrink();

    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Allah Names surfaced',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.take(10).map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${e.key} ×${e.value}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _JourneyDayCard extends StatelessWidget {
  final JourneyDay day;

  const _JourneyDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM').format(day.date);
    final isToday = _isToday(day.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.surfaceVariant,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isToday ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _NafsBadge(nafs: day.dominantNafs),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _scoreColor(day.positiveScore).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${day.positiveScore}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(day.positiveScore),
                  ),
                ),
              ),
            ],
          ),
          if (!day.hasCheckin) ...[
            const SizedBox(height: 6),
            const Text(
              'No check-in',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (day.dhikrItems.isEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'Checked in',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ] else ...[
            const SizedBox(height: 8),
            ...day.dhikrItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.arabic,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.transliteration} · from ${item.emotionName}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '×${item.intensity}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    if (item.meaning.isNotEmpty)
                      Text(
                        item.meaning,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.secondary;
    if (score >= 60) return AppColors.nafsMulhamah;
    if (score >= 30) return AppColors.nafsLawwamah;
    return AppColors.nafsAmmarah;
  }
}

class _NafsBadge extends StatelessWidget {
  final NafsType nafs;

  const _NafsBadge({required this.nafs});

  @override
  Widget build(BuildContext context) {
    final emoji = switch (nafs) {
      NafsType.ammarah => '😔',
      NafsType.lawwamah => '⚡',
      NafsType.mulhamah => '✨',
      NafsType.mutmainnah => '🌿',
    };
    final color = switch (nafs) {
      NafsType.ammarah => AppColors.nafsAmmarah,
      NafsType.lawwamah => AppColors.nafsLawwamah,
      NafsType.mulhamah => AppColors.nafsMulhamah,
      NafsType.mutmainnah => AppColors.nafsMutmainna,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            nafs.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
