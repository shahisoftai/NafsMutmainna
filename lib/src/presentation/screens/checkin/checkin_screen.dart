import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/checkin.dart';
import '../../../infrastructure/di/providers.dart';
import '../../../presentation/navigation/app_router.dart';
import '../../../presentation/theme/colors.dart';
import '../../../presentation/viewmodels/checkin_view_model.dart';
import '../../../presentation/viewmodels/home_view_model.dart';
import '../../../presentation/viewmodels/daily_dhikr_view_model.dart';
import '../../../presentation/widgets/specific/emotion_picker_widget.dart';
import '../../../presentation/widgets/specific/intensity_slider_widget.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});
  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(checkinViewModelProvider.notifier).load());
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = ref.read(checkinViewModelProvider);
    final primary = s.primary;
    if (primary == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final checkin = Checkin(
        id: 0,
        date: DateTime.now(),
        emotionId: primary.id,
        intensity: s.intensity,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      final result = await ref.read(submitCheckinProvider).call(checkin);
      if (!mounted) return;
      // Reload the HomeViewModel so the meter updates on the next visit.
      ref.invalidate(homeViewModelProvider);
      // Reload the DailyDhikrViewModel so the Allah Names section and the
      // 15-day journey link appear immediately after the first (or any)
      // check-in, without requiring an app restart.
      ref.invalidate(dailyDhikrViewModelProvider);
      context.pushReplacement(
        AppRouter.insight,
        extra: result,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save check-in: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkinViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('How do you feel?')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Pick the primary emotion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                EmotionPickerWidget(
                  emotions: state.emotions,
                  selected: state.primary,
                  onSelected: (e) => ref.read(checkinViewModelProvider.notifier).selectPrimary(e),
                ),
                const SizedBox(height: 12),
                IntensitySliderWidget(
                  value: state.intensity,
                  onChanged: (v) => ref.read(checkinViewModelProvider.notifier).setIntensity(v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.primary == null || _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                          )
                        : const Text('Continue', style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}
