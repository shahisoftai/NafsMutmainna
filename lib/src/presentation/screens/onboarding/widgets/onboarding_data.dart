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

/// The 8 onboarding cards in display order.
///
/// Card progression: Spiritual Concept (Cards 1-2) → App Features (Cards 3-8)
///
/// Cards 1-2 introduce the Nafs journey: from Nafs-e-Ammara (the commanding soul)
/// to Nafs-e-Mutmainna (the tranquil soul) — the spiritual foundation of the app.
///
/// Cards 3-8 explain the app features that support this journey:
/// Check-in → Heart Analysis → Nafs Meter → Prescription → Journey → Pathways.
///
/// The visual identity of each card is anchored in a distinct gradient
/// to keep the flow calm but varied.
const List<OnboardingCardData> kOnboardingCards = [
  // Card 1 — The Hidden Battle
  OnboardingCardData(
    headline: 'The Battle Within',
    body:
        'Every day, a war rages inside you — between your soul seeking peace\n'
        'and whispers pulling you toward darkness.\n\n'
        'Pride. Envy. Anger. Greed. Laziness.\n\n'
        'These negative traits are the fingerprints of Nafs-e-Ammara —\n'
        'the soul commanded by desire — and the gateway through which\n'
        'Shaytan influences you.\n\n'
        'The good news? You have the power to change.',
    icon: Icons.shield_outlined,
    accentIcon: Icons.whatshot_outlined,
    gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  ),

  // Card 2 — Nafs Mutmainna Awaits
  OnboardingCardData(
    headline: 'Nafs Mutmainna Awaits',
    body:
        '"O soul in complete rest and satisfaction!\n'
        'Return to your Lord, well-pleased and well-pleasing!\n'
        'Enter among My servants!\n'
        'Enter My Paradise!"\n\n'
        '— Surah Al-Fajr (89:27-30)\n\n'
        'This is your destination. A soul at peace. A soul beloved to Allah.\n'
        'A soul worthy of Paradise.\n\n'
        'This app is your companion on that journey.',
    icon: Icons.mosque_outlined,
    accentIcon: Icons.auto_awesome_outlined,
    gradientColors: [Color(0xFF0D3D12), Color(0xFF1B5E20), Color(0xFFD4AF37)],
  ),

  // Card 3 — Daily Check-in
  OnboardingCardData(
    headline: 'Check In With Your Heart',
    body:
        'A 60-second daily check-in — the heart of your transformation.\n\n'
        '1.  Pick the emotion you feel right now\n'
        '2.  Adjust how strongly you feel it\n'
        '3.  Add a note if you want (optional)\n\n'
        'This simple act builds self-awareness — the first step toward\n'
        'changing what you notice inside yourself.',
    icon: Icons.edit_note_rounded,
    accentIcon: Icons.timer_outlined,
    gradientColors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A)],
  ),

  // Card 4 — Heart Analysis
  OnboardingCardData(
    headline: 'See What Your Heart Reveals',
    body:
        'After every check-in, HeartOS analyses 3–5 heart attributes\n'
        'active in you right now.\n\n'
        'You also see your current growth path through the four stations\n'
        'of the Nafs.\n\n'
        'The more you check in, the more accurate the picture becomes —\n'
        'and the clearer your path forward.',
    icon: Icons.insights_rounded,
    accentIcon: Icons.psychology_outlined,
    gradientColors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF26A69A)],
  ),

  // Card 5 — Nafs Meter
  OnboardingCardData(
    headline: 'Track Your Soul\'s Progress',
    body:
        'The four stations of the soul in Islam:\n\n'
        'Ammarah  →  Lawwamah  →  Mulhamah‡  →  Mutmainnah\n\n'
        'Your daily check-in moves the meter. Watch the trend —\n'
        'a quiet nudge toward peace, or a warning when you drift.\n\n'
        'Think of it as a fitness tracker, but for your heart.\n\n'
        '‡ Ammarah, Lawwamah and Mutmainnah are explicitly Qur\'anic.\n'
        'Mulhamah (the inspired soul) is adopted from classical\n'
        'scholarship (al-Tirmidhī, al-Ghazālī).',
    icon: Icons.speed_rounded,
    accentIcon: Icons.show_chart_rounded,
    gradientColors: [Color(0xFFE53935), Color(0xFFFB8C00), Color(0xFF43A047)],
  ),

  // Card 6 — Personal Prescription
  OnboardingCardData(
    headline: 'A Prescription Just for You',
    body:
        'Based on your detected attributes, receive a daily prescription —\n'
        'each card is one of six types:\n\n'
        '📖  Quran     ✋  Hadith     🤲  Dua\n'
        '💎  Allah Names     🔁  Dhikr     ✅  Action\n\n'
        'Mark each as Done or Skip to refine tomorrow\'s prescription.',
    icon: Icons.medical_services_outlined,
    accentIcon: Icons.medication_outlined,
    gradientColors: [Color(0xFFFF8F00), Color(0xFFFFB300), Color(0xFFFFCA28)],
  ),

  // Card 7 — 15-Day Journey
  OnboardingCardData(
    headline: 'Watch Your Transformation Unfold',
    body:
        'Every check-in is saved to your private journey.\n\n'
        '• See a trend of your last 15 days\n'
        '• Discover which Allah Names are guiding you most\n'
        '• Review day-by-day what surfaced\n\n'
        'Tap any day to dive into the full picture. Watch yourself grow.',
    icon: Icons.timeline_rounded,
    accentIcon: Icons.calendar_today_outlined,
    gradientColors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
  ),

  // Card 8 — 8 Master Pathways
  OnboardingCardData(
    headline: 'Every Struggle Has a Map',
    body:
        'All spiritual struggles follow one of 8 mapped pathways —\n'
        'from a challenging emotion to the soul at peace.\n\n'
        'Example: Anger → Patience → Gentleness → Mercy → Compassion\n\n'
        'HeartOS shows your current path and where it leads.\n\n'
        'You\'re never lost — the map exists.',
    icon: Icons.account_tree_outlined,
    accentIcon: Icons.explore_outlined,
    gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
  ),
];
