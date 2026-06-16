import '../../../../domain/entities/vector4.dart';

/// What kind of deep action the home is recommending.
enum NextActionKind {
  checkin,
  intervention,
  habits,
  reflect,
}

/// Contextual "what should the user do right now?" card content.
///
/// Pure value type — the resolver that builds it is also pure (see below).
class NextAction {
  final String emoji;
  final String title;
  final String subtitle;
  final NextActionKind kind;
  final String deepLink;

  const NextAction({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.deepLink,
  });
}

/// Counters used by the next-action resolver to decide which rule fires.
class HabitStatusCount {
  final int done;
  final int total;
  const HabitStatusCount(this.done, this.total);
}

/// Pure resolver for the contextual Next Action card.
///
/// Rules fire in priority order; first match wins. Keeping the resolver pure
/// (no I/O, no BuildContext) means the rule set is trivially unit-testable.
class NextActionResolver {
  const NextActionResolver();

  // Standard deep link route names. Kept as constants so the screen doesn't
  // need to know about AppRouter. The actual router is injected at the
  // screen layer.
  static const String linkCheckin = 'checkin';
  static const String linkIntervention = 'intervention';
  static const String linkHabits = 'habits';
  static const String linkHistory = 'history';

  NextAction resolve({
    required NafsType dominant,
    required DateTime? lastCheckin,
    required int positiveStreak,
    required HabitStatusCount habits,
    required DateTime now,
  }) {
    final lastCheckinStale =
        lastCheckin == null || _daysSince(lastCheckin, now) >= 1;

    // 1. No check-in today AND dominant is Ammarah → Istighfar break.
    //    Ammarah = heedlessness; the user needs to be called back.
    if (lastCheckinStale && dominant == NafsType.ammarah) {
      return const NextAction(
        emoji: '📿',
        title: 'A moment of stillness',
        subtitle: 'Try a 2-minute Istighfar break',
        kind: NextActionKind.intervention,
        deepLink: linkIntervention,
      );
    }

    // 2. No check-in in > 24h (any dominant).
    if (lastCheckinStale) {
      return const NextAction(
        emoji: '🕊',
        title: "It's been a while",
        subtitle: 'How is your heart now?',
        kind: NextActionKind.checkin,
        deepLink: linkCheckin,
      );
    }

    // 3. Streak ≥ 7 → reflect (consolidate the gains).
    if (positiveStreak >= 7) {
      return NextAction(
        emoji: '💭',
        title: '$positiveStreak-day streak',
        subtitle: 'Reflect on what is working',
        kind: NextActionKind.reflect,
        deepLink: linkHistory,
      );
    }

    // 4. Habits < 50% done and after midday → anchor the day.
    if (habits.total > 0 &&
        habits.done / habits.total < 0.5 &&
        now.hour >= 12) {
      return NextAction(
        emoji: '✅',
        title: 'Anchor your day',
        subtitle: '${habits.done}/${habits.total} habits complete',
        kind: NextActionKind.habits,
        deepLink: linkHabits,
      );
    }

    // 5. Default → check-in.
    return const NextAction(
      emoji: '🕊',
      title: 'Begin check-in',
      subtitle: 'A few breaths, a moment of honesty',
      kind: NextActionKind.checkin,
      deepLink: linkCheckin,
    );
  }

  static int _daysSince(DateTime past, DateTime now) {
    final p = DateTime(past.year, past.month, past.day);
    final n = DateTime(now.year, now.month, now.day);
    return n.difference(p).inDays;
  }
}
