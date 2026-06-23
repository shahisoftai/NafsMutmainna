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

class _ReflectionText {
  final String english;
  final String urdu;
  final String arabic;
  const _ReflectionText({
    required this.english,
    required this.urdu,
    required this.arabic,
  });
}

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});
  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  static const _negativeReflection = _ReflectionText(
    english: '''Take a moment to deeply reflect upon the emotion you have selected. Consider what triggered this feeling and how it may be affecting your heart and mind right now. As you study the content below, ask yourself: *What steps can I take to overcome this emotion? What habits, thoughts, or actions can I change to bring peace to my heart?* Let this reflection guide you toward healing and growth.''',
    urdu: '''اپنے جذبات پر غور کریں — کیا کچھ ایسا ہے جو اس احساس کو جنم دے رہا ہے؟ اس کے اثرات کو سمجھیں اور پوچھیں: میں اس جذبات سے کیسے نکل سکتا ہوں؟ کون سی عادات، خیالات یا اعمال میں تبدیلی لا سکتا ہوں تاکہ دل کو سکون ملے؟ یہ غور و فکر آپ کو شفا اور ترقی کی طرف رہنمائی کرے گا۔''',
    arabic: '''تأمل بعمق في الحالة التي اخترتها — ما الذي أثار هذا الشعور في قلبك؟ افهم تأثيراته واسأل نفسك: كيف يمكنني التغلب على هذا الشعور؟ ما العادات والأفكار والأفعال التي يمكنني تغييرها لنيل الطمأنينة؟ ليكن هذا التأمل دليلك نحو الشفاء والنمو الروحي.''',
  );

  static const _positiveReflection = _ReflectionText(
    english: '''Pause and appreciate the positive emotion you are feeling. Reflect on what brought this feeling into your heart and how it enriches your life. As you engage with the content below, consider: *How can I nurture and strengthen this emotion? What habits, thoughts, or actions can I practice more often to sustain and deepen this positivity?* Let this reflection help you grow in gratitude and spiritual balance.''',
    urdu: '''مثبت جذبات کا لمس کریں اور ان کی قدر کریں — یہ احساس آپ کے دل میں کیسے آیا؟ اس کی زندگی میں کیا اہمیت ہے؟ اب پوچھیں: میں اس کیسے مضبوط کر سکتا ہوں؟ کون سی عادات، خیالات یا اعمال کو اکثر کر سکتا ہوں تاکہ یہ مثبت احساس برقرار رہے اور گہرا ہو؟ یہ غور و فکر آپ کو شکرگزاری اور روحانی توازن کی طرف بڑھائے گا۔''',
    arabic: '''قدّر الشعور الإيجابي الذي ينبض به قلبك — ما الذي جلبه إليك؟ وما دوره في حياتك؟ الآن اسأل نفسك: كيف يمكنني تعزيز هذا الشعور وصونه؟ ما العادات والأفكار والأفعال التي يمكنني ممارستها أكثر للحفاظ على هذا الإيجابية وتعميقها؟ ليكن هذا التأمل سببًا في شكرك وتوازنك الروحي.''',
  );

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

  Future<bool> _showReflectionDialog(String category) async {
    final isNegative = category == 'Negative';
    final text = isNegative ? _negativeReflection : _positiveReflection;
    final headerColor = isNegative ? Colors.red.shade700 : Colors.green.shade700;
    final bgColor = isNegative
        ? Colors.red.withValues(alpha: 0.06)
        : Colors.green.withValues(alpha: 0.06);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isNegative ? 'Negative Emotion' : 'Positive Emotion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _langBlock('English', text.english, headerColor),
                const SizedBox(height: 12),
                _langBlock('اردو', text.urdu, headerColor),
                const SizedBox(height: 12),
                _langBlock('العربية', text.arabic, headerColor),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Widget _langBlock(String lang, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final s = ref.read(checkinViewModelProvider);
    final primary = s.primary;
    if (primary == null || _submitting) return;

    final confirmed = await _showReflectionDialog(primary.category);
    if (!confirmed || !mounted) return;

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
          : SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom + 16),
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
          ),
    );
  }
}
