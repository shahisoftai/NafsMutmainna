import 'package:flutter/material.dart';

/// Content model for a single onboarding flash card.
///
/// Each card has a headline, a short body of 3–4 lines, a primary icon
/// (large, centered), an accent icon (decorative, smaller, top-right),
/// and a gradient background that distinguishes the card visually.
@immutable
class OnboardingCardData {
  final String headline;
  final String body;
  final IconData icon;
  final IconData? accentIcon;
  final List<Color> gradientColors;
  final Color iconBackground;

  const OnboardingCardData({
    required this.headline,
    required this.body,
    required this.icon,
    required this.gradientColors,
    this.accentIcon,
    this.iconBackground = const Color(0x33FFFFFF),
  });
}

/// The 7 onboarding cards in display order.
///
/// Card progression: Welcome → Check-in → Heart Analysis →
/// Personal Prescription → Nafs Meter → 15-Day Journey → Heart Graph.
///
/// The visual identity of each card is anchored in a distinct gradient
/// drawn from the app's primary (deep green) and accent (gold) palette
/// to keep the flow calm but varied.
const List<OnboardingCardData> kOnboardingCards = [
  // Card 1 — Welcome
  OnboardingCardData(
    headline: 'Welcome to HeartOS',
    body:
        'Your privacy-first spiritual fitness companion.\n'
        'All your data stays on your device. No account. '
        'No tracking. No ads.\n'
        'Just you and your heart, working quietly together.',
    icon: Icons.favorite_outline,
    accentIcon: Icons.lock_outline,
    gradientColors: [Color(0xFF0D3D12), Color(0xFF1B5E20), Color(0xFF2E7D32)],
  ),

  // Card 2 — Daily Check-in
  OnboardingCardData(
    headline: 'Check In With Your Heart',
    body:
        'A 60-second daily check-in — the heart of HeartOS.\n\n'
        '1.  Pick the emotion you feel right now\n'
        '2.  Adjust how strongly you feel it\n'
        '3.  Add a note if you want (optional)',
    icon: Icons.edit_note_rounded,
    accentIcon: Icons.timer_outlined,
    gradientColors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A)],
  ),

  // Card 3 — Heart Analysis
  OnboardingCardData(
    headline: 'See What Your Heart Reveals',
    body:
        'After every check-in, HeartOS analyses 3–5 heart '
        'attributes active in you right now.\n\n'
        'You also see your current growth path through the '
        'four stations of the Nafs.\n'
        'The more you check in, the more accurate it becomes.',
    icon: Icons.insights_rounded,
    accentIcon: Icons.psychology_outlined,
    gradientColors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF26A69A)],
  ),

  // Card 4 — Personal Prescription
  OnboardingCardData(
    headline: 'A Prescription Just for You',
    body:
        'Based on the attributes we detect, we curate a daily '
        'prescription — each card is one of six types:\n\n'
        '📖  Quran     ✋  Hadith     🤲  Dua\n'
        '💎  Allah Names     🔁  Dhikr     ✅  Action\n\n'
        'Mark each as Done or Skip to refine tomorrow\'s prescription.',
    icon: Icons.medical_services_outlined,
    accentIcon: Icons.auto_awesome_outlined,
    gradientColors: [Color(0xFFFF8F00), Color(0xFFFFB300), Color(0xFFFFCA28)],
  ),

  // Card 5 — Nafs Meter
  OnboardingCardData(
    headline: 'Your Nafs Meter',
    body:
        'The four stations of the soul in Islam:\n\n'
        'Ammarah  →  Lawwamah  →  Mulhamah  →  Mutmainnah\n\n'
        'Your daily check-in moves the meter. Watch the trend — '
        'a quiet nudge toward peace, a warning when you drift.\n'
        'Think of it as a fitness tracker, but for your heart.',
    icon: Icons.speed_rounded,
    accentIcon: Icons.show_chart_rounded,
    gradientColors: [Color(0xFFE53935), Color(0xFFFB8C00), Color(0xFF43A047)],
  ),

  // Card 6 — 15-Day Journey
  OnboardingCardData(
    headline: 'Your 15-Day Journey',
    body:
        'Every check-in is saved to your private journey.\n\n'
        'See a trend of your last 15 days, discover the Allah Names '
        'guiding you most, and review day-by-day what surfaced.\n\n'
        'Tap any day to dive into the full picture.',
    icon: Icons.timeline_rounded,
    accentIcon: Icons.calendar_today_outlined,
    gradientColors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
  ),

  // Card 7 — Heart Graph
  OnboardingCardData(
    headline: 'The 8 Master Pathways',
    body:
        'All spiritual struggles follow one of 8 mapped pathways '
        '— from a challenging emotion to the soul at peace.\n\n'
        'Example:  Anger → Mercy\n'
        'Ghadab → Sabr → Hilm → Rifq → Rahmah\n\n'
        'HeartOS shows your current path and where it leads.',
    icon: Icons.account_tree_outlined,
    accentIcon: Icons.explore_outlined,
    gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
  ),
];
