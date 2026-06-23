import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../../domain/usecases/nafs/compute_daily_nafs.dart' show SubmitCheckinResult;
import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../widgets/specific/detected_attribute_widget.dart';
import '../../widgets/specific/growth_path_strip.dart';

class InsightScreen extends ConsumerStatefulWidget {
  final SubmitCheckinResult result;
  const InsightScreen({super.key, required this.result});

  @override
  ConsumerState<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends ConsumerState<InsightScreen> {
  List<HeartAttribute> _growthPath = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final attrs = ref.read(attributeRepositoryProvider);
    if (widget.result.detected.isNotEmpty) {
      final first = await attrs.getById(widget.result.detected.first.attributeId);
      if (first != null) {
        _growthPath = await ref.read(growthPathProvider).call(first.id);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return Scaffold(
      appBar: AppBar(title: const Text('Heart Analysis')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom + 16),
              children: [
                if (result.detected.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No attributes detected.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Detected attributes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  for (final d in result.detected.take(5))
                    FutureBuilder<HeartAttribute?>(
                      future: ref.read(attributeRepositoryProvider).getById(d.attributeId),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data == null) return const SizedBox.shrink();
                        return DetectedAttributeWidget(attribute: snap.data!, score: d.score);
                      },
                    ),
                ],
                if (_growthPath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Growth path',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  GrowthPathStrip(path: _growthPath),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        AppRouter.intervention,
                        extra: result,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Show me what to do',
                        style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
