import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/intervention_card.dart';
import '../../../domain/entities/intervention_history.dart';
import '../../../domain/usecases/nafs/compute_daily_nafs.dart' show SubmitCheckinResult;
import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../widgets/specific/intervention_card_widget.dart';
import '../../widgets/specific/intervention_disclaimer_banner.dart';

class InterventionScreen extends ConsumerStatefulWidget {
  final SubmitCheckinResult result;
  const InterventionScreen({super.key, required this.result});

  @override
  ConsumerState<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends ConsumerState<InterventionScreen> {
  final Set<int> _done = {};
  final Set<int> _skipped = {};
  final Map<int, int> _recordIds = {};

  Future<void> _markDone(InterventionCard card) async {
    if (_done.contains(card.hashCode)) return;
    try {
      final repo = ref.read(interventionHistoryRepositoryProvider);
      final id = await repo.insert(InterventionHistory(
        id: 0,
        date: widget.result.checkin.date,
        emotionId: card.emotionId,
        attributeId: card.attributeId,
        interventionType: card.type,
        completed: true,
      ));
      if (mounted) {
        setState(() {
          _done.add(card.hashCode);
          _recordIds[card.hashCode] = id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _markSkip(InterventionCard card) async {
    if (_skipped.contains(card.hashCode)) return;
    try {
      final repo = ref.read(interventionHistoryRepositoryProvider);
      await repo.insert(InterventionHistory(
        id: 0,
        date: widget.result.checkin.date,
        emotionId: card.emotionId,
        attributeId: card.attributeId,
        interventionType: card.type,
        completed: false,
      ));
      if (mounted) {
        setState(() => _skipped.add(card.hashCode));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record skip: $e')),
        );
      }
    }
  }

  void _openDetail(InterventionCard card) {
    context.push(
      AppRouter.interventionDetail,
      extra: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Prescription')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // RI-4.7: Tazkiya-safe disclaimer — every remedy is general;
          // consult a qualified scholar for treatment specific to your state.
          const InterventionDisclaimerBanner(),
          for (final card in widget.result.cards)
            InterventionCardWidget(
              card: card,
              done: _done.contains(card.hashCode),
              onDone: _done.contains(card.hashCode) ? null : () => _markDone(card),
              onSkip: _skipped.contains(card.hashCode) ? null : () => _markSkip(card),
              onTap: () => _openDetail(card),
            ),
          if (widget.result.cards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No interventions available right now.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRouter.reflect,
                  extra: widget.result,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'How did this make you feel?',
                  style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
