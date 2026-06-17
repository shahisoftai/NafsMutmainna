import 'package:go_router/go_router.dart';

import '../../domain/entities/intervention_card.dart';
import '../../domain/usecases/nafs/compute_daily_nafs.dart' show SubmitCheckinResult;
import '../screens/checkin/checkin_screen.dart';
import '../screens/heart_graph/heart_graph_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/insight/insight_screen.dart';
import '../screens/intervention/intervention_detail_screen.dart';
import '../screens/intervention/intervention_screen.dart';
import '../screens/journey/journey_screen.dart';
import '../screens/nafs_detail/nafs_detail_screen.dart';
import '../screens/reflect/reflect_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String checkin = '/checkin';
  static const String insight = '/insight';
  static const String intervention = '/intervention';
  static const String interventionDetail = '/intervention/detail';
  static const String reflect = '/reflect';
  static const String heartGraph = '/heart-graph';
  static const String history = '/history';
  static const String habits = '/habits';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String journey = '/journey';
  static const String nafsDetail = '/nafs-detail';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: splash, name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: onboarding, name: 'onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: home, name: 'home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: checkin, name: 'checkin', builder: (_, __) => const CheckinScreen()),
      GoRoute(
        path: insight,
        name: 'insight',
        builder: (context, state) {
          final result = state.extra as SubmitCheckinResult?;
          if (result == null) return const HomeScreen();
          return InsightScreen(result: result);
        },
      ),
      GoRoute(
        path: intervention,
        name: 'intervention',
        builder: (context, state) {
          final result = state.extra as SubmitCheckinResult?;
          if (result == null) return const HomeScreen();
          return InterventionScreen(result: result);
        },
      ),
      GoRoute(
        path: interventionDetail,
        name: 'interventionDetail',
        builder: (context, state) {
          final card = state.extra as InterventionCard;
          return InterventionDetailScreen(card: card);
        },
      ),
      GoRoute(
        path: reflect,
        name: 'reflect',
        builder: (context, state) {
          final result = state.extra as SubmitCheckinResult?;
          if (result == null) return const HomeScreen();
          return ReflectScreen(result: result);
        },
      ),
      GoRoute(path: heartGraph, name: 'heartGraph', builder: (_, __) => const HeartGraphScreen()),
      GoRoute(path: history, name: 'history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: habits, name: 'habits', builder: (_, __) => const HabitsScreen()),
      GoRoute(path: profile, name: 'profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: settings, name: 'settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: journey, name: 'journey', builder: (_, __) => const JourneyScreen()),
      GoRoute(
        path: nafsDetail,
        name: 'nafsDetail',
        builder: (_, _) => const NafsDetailScreen(),
      ),
    ],
  );
}
