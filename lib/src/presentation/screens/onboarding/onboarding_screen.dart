import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import 'widgets/onboarding_card.dart';
import 'widgets/onboarding_data.dart';
import 'widgets/page_indicator.dart';

/// Swipable onboarding flow shown on first launch only.
///
/// Hosts a horizontal [PageView] of [kOnboardingCards]. When the user
/// reaches the last card and taps "Get Started" (or the "Skip" button
/// at any time), a "has seen onboarding" flag is written to the
/// dedicated Hive `prefs` box and the user is routed to the home
/// screen. On every subsequent launch the splash screen will see
/// the flag and skip straight to home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _completeOnboarding() async {
    try {
      final box = ref.read(prefsBoxProvider).maybeWhen(
            data: (b) => b,
            orElse: () => null,
          );
      if (box != null) {
        await box.put(kOnboardingSeenKey, '1');
      }
    } catch (_) {
      // Best-effort — if the flag can't be written the user just sees
      // onboarding again on the next launch. No data is lost.
    }
    // RI-3.4 + RI-3.7: Seed the foundational habits (Taharah, Halal Rizq,
    // Hifz al-Lisan) and Body-Heart habits (sleep, eating) on first launch.
    // Idempotent — does nothing if they already exist.
    try {
      await ref.read(foundationalHabitsSeederProvider).seedIfMissing();
    } catch (_) {
      // Non-fatal — habits can be added manually from the Habits screen.
    }
    if (!mounted) return;
    context.go(AppRouter.home);
  }

  void _next() {
    if (_currentPage < kOnboardingCards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == kOnboardingCards.length - 1;
    return Scaffold(
      // The first card's gradient must fill the status bar area, so we
      // don't apply a system AppBar — each card paints its own header.
      body: Stack(
        children: [
          // Cards
          PageView.builder(
            controller: _pageController,
            itemCount: kOnboardingCards.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingCard(
                data: kOnboardingCards[index],
                index: index,
                total: kOnboardingCards.length,
              );
            },
          ),
          // Top-right Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls — dot indicator + next/get-started button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PageIndicator(
                      total: kOnboardingCards.length,
                      currentIndex: _currentPage,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textOnPrimary,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
