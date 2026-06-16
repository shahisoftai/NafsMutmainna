import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../viewmodels/home_habits_view_model.dart';
import 'empty_state_widget.dart';
import 'habit_pill.dart';

/// "Today's anchors" strip on the home page.
///
/// Horizontal scrollable row of `HabitPill`s with a header and progress
/// indicator. Falls back to an `EmptyStateWidget` when the user has no habits.
class TodayHabitsStrip extends ConsumerStatefulWidget {
  final VoidCallback onManageTap;
  const TodayHabitsStrip({super.key, required this.onManageTap});

  @override
  ConsumerState<TodayHabitsStrip> createState() => _TodayHabitsStripState();
}

class _TodayHabitsStripState extends ConsumerState<TodayHabitsStrip> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeHabitsViewModelProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeHabitsViewModelProvider);
    if (state.isLoading && state.habits.isEmpty) {
      return const _HabitsHeader(title: "Today's anchors", trailing: '');
    }
    if (state.habits.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HabitsHeader(title: "Today's anchors", trailing: ''),
          const SizedBox(height: 8),
          EmptyStateWidget(
            icon: Icons.checklist_rtl,
            title: 'Add your first training anchor',
            subtitle: 'Prayer, Quran, Dhikr — the daily reps of Nafs work.',
            ctaLabel: 'Manage habits',
            onCtaTap: widget.onManageTap,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HabitsHeader(
          title: "Today's anchors",
          trailing: '${state.doneCount}/${state.totalCount} done',
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.habits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final h = state.habits[i];
              return HabitPill(
                habit: h,
                onTap: () =>
                    ref.read(homeHabitsViewModelProvider.notifier).toggle(h),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onManageTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Manage habits →',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitsHeader extends StatelessWidget {
  final String title;
  final String trailing;
  const _HabitsHeader({required this.title, required this.trailing});

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
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
