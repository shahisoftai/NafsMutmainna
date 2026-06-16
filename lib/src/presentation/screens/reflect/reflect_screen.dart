import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/intervention_card.dart';
import '../../../domain/usecases/nafs/compute_daily_nafs.dart' show SubmitCheckinResult;
import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/specific/feedback_button_widget.dart';

class ReflectScreen extends ConsumerStatefulWidget {
  final SubmitCheckinResult result;
  const ReflectScreen({super.key, required this.result});

  @override
  ConsumerState<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends ConsumerState<ReflectScreen> {
  InterventionFeedback? _selected;
  bool _saving = false;

  String _dateOnly(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    debugPrint('[_save] START - _selected: $_selected, _saving: $_saving');
    if (_selected == null || _saving) {
      debugPrint('[_save] EARLY RETURN');
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(interventionHistoryRepositoryProvider);
      final checkinDateStr = _dateOnly(widget.result.checkin.date);
      debugPrint('[_save] checkinDateStr: $checkinDateStr');

      final recent = await repo.findRecent(1);
      debugPrint('[_save] findRecent returned ${recent.length} records');

      int feedbackCount = 0;
      for (final r in recent) {
        final recordDateStr = _dateOnly(r.date);
        if (recordDateStr == checkinDateStr && r.completed) {
          debugPrint('[_save] MATCH! Calling markFeedback for id=${r.id}');
          await ref.read(recordFeedbackProvider).call(r.id, _selected!);
          feedbackCount++;
        }
      }

      // Pre-load the home view model with fresh data BEFORE navigating.
      // The previous ref.invalidate() call reset the home view model state
      // to isLoading=true (the default), which caused the home screen to
      // show its LoadingIndicator spinner after navigation.
      // By calling load() directly, the home view model will be in a
      // fully-loaded state when HomeScreen mounts, so it renders content
      // directly without flashing a spinner.
      try {
        await ref.read(homeViewModelProvider.notifier).load();
        debugPrint('[_save] Home view model pre-loaded');
      } catch (e) {
        debugPrint('[_save] Home pre-load error (non-fatal): $e');
        // Non-fatal: home screen will still load on its own via initState
      }

      if (feedbackCount == 0) {
        debugPrint('[_save] feedbackCount=0');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No completed interventions found')),
          );
        }
      } else {
        debugPrint('[_save] Saved $feedbackCount feedbacks');
      }
    } catch (e, stack) {
      debugPrint('[_save] CATCH ERROR: $e');
      debugPrint('[_save] STACK: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (mounted) {
      debugPrint('[_save] Navigating to home...');
      context.go(AppRouter.home);
      debugPrint('[_save] After context.go call');
      
      // Reset saving flag immediately after navigation is scheduled
      // This ensures spinner is off even if widget rebuilds during transition
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How do you feel now?')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Reflecting on the prescription and emotions you just recorded will help refine your next check-in.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          for (final f in InterventionFeedback.values)
            FeedbackButtonWidget(
              feedback: f,
              onTap: () {
                if (!_saving) setState(() => _selected = f);
              },
              selected: _selected == f,
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_selected == null || _saving) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                      )
                    : const Text(
                        'Save and return',
                        style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
