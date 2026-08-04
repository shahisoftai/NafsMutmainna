import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/specific/nafs_arc_meter.dart';
import '../../widgets/specific/nafs_journey_card.dart';
import '../../widgets/specific/nafs_weekly_ring.dart';
import '../../widgets/specific/nafs_meter.dart';

/// Detailed Nafs view — opened when the user taps the arc meter on Home.
///
/// Four sections, top to bottom:
///   1. Today (gradient arc — same visual as the home card, larger).
///   2. Detailed breakdown (the original 4-bar meter, preserved).
///   3. Your journey (4-stop trail with reflection + 7-day sparkline).
///   4. 7-day progress (fl_chart pie ring + heart-health line chart).
///
/// State is sourced from the existing [homeViewModelProvider] — no new
/// providers, no DB access, no logic duplication.
class NafsDetailScreen extends ConsumerStatefulWidget {
  const NafsDetailScreen({super.key});

  @override
  ConsumerState<NafsDetailScreen> createState() => _NafsDetailScreenState();
}

class _NafsDetailScreenState extends ConsumerState<NafsDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Mirror the InsightScreen pattern — if the home VM hasn't been
    // populated yet, force a load so the detail page has fresh data.
    Future.microtask(() {
      if (!mounted) return;
      final state = ref.read(homeViewModelProvider);
      if (!state.hasLoaded && !state.isLoading) {
        ref.read(homeViewModelProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    if (state.isLoading && !state.hasLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nafs detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nafs detail')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeViewModelProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _section(
              title: 'Today',
              subtitle: 'Where your heart stands right now.',
              child: NafsArcMeter(
                vector: state.meter,
                dominant: state.dominant,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              title: 'Detailed breakdown',
              subtitle: 'Percentage share of each station.',
              child: NafsMeterWidget(
                vector: state.meter,
                dominant: state.dominant,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              title: 'Your journey',
              subtitle: 'Ammarah → Lawwamah → Mulhamah → Mutmainnah.',
              child: NafsJourneyCard(
                vector: state.meter,
                dominant: state.dominant,
                sparkline: state.sparkline,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              title: '7-day progress',
              subtitle: 'Distribution and heart-health trajectory.',
              child: NafsWeeklyRing(
                vector: state.weeklyMeter,
                dominant: state.weeklyMeter.dominant,
                heartHealthScore: state.weeklyHeartHealthScore,
                trend: state.trend,
              ),
            ),
            if (state.sparkline.length >= 2) ...[
              const SizedBox(height: 16),
              _section(
                title: 'Heart-health over the last 7 days',
                subtitle: 'Higher means closer to Mutmainnah.',
                child: _TrendLineCard(values: state.sparkline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _TrendLineCard extends StatelessWidget {
  final List<int> values;
  const _TrendLineCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.surfaceVariant,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 25,
                  getTitlesWidget: (value, _) {
                    if (value == 0 || value == 100 || value == 50) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= values.length) {
                      return const SizedBox.shrink();
                    }
                    // Show "d-6", "d-3", "today" labels.
                    final label = i == values.length - 1
                        ? 'today'
                        : 'd-${values.length - 1 - i}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i].toDouble()),
                ],
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
