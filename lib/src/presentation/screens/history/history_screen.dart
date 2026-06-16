import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/checkin.dart';
import '../../../domain/entities/nafs_history.dart';
import '../../../infrastructure/di/providers.dart';
import '../../theme/colors.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<NafsHistory> _history = const [];
  List<Checkin> _recent = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 30));
    final h = await ref.read(nafsHistoryRepositoryProvider).findBetween(start, today);
    final r = await ref.read(checkinRepositoryProvider).findBetween(start, today);
    if (!mounted) return;
    setState(() {
      _history = h;
      _recent = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('30-day Nafs trend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _history.length < 2
                      ? const Center(child: Text('Not enough data yet', style: TextStyle(color: AppColors.textSecondary)))
                      : _buildChart(),
                ),
                const SizedBox(height: 16),
                const Text('Recent check-ins',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No check-ins yet', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ..._recent.reversed.take(20).map((c) => _checkinTile(c)),
              ],
            ),
    );
  }

  Widget _buildChart() {
    final spots = <FlSpot>[];
    for (var i = 0; i < _history.length; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        _history[i].mutmainnah + _history[i].mulhamah,
      ));
    }
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
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
    );
  }

  Widget _checkinTile(Checkin c) {
    return FutureBuilder(
      future: ref.read(emotionRepositoryProvider).getById(c.emotionId),
      builder: (context, snap) {
        final name = snap.data?.name ?? 'Emotion #${c.emotionId}';
        return ListTile(
          leading: const Icon(Icons.favorite_outline, color: AppColors.primary),
          title: Text(name),
          subtitle: Text(
            '${DateFormat.yMMMd().add_jm().format(c.date)} • Intensity ${c.intensity}/10',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        );
      },
    );
  }
}
