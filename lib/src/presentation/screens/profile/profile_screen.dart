import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../presentation/navigation/app_router.dart';
import '../../../presentation/theme/colors.dart';
import '../../../presentation/viewmodels/home_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Guest user',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Sign-in coming in v1.1',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            _stat('Dominant Nafs', home.dominant.name),
            _stat('Heart Health', '${home.heartHealthScore} / 100'),
            _stat('Positive Streak', '${home.positiveStreak} days'),
            _stat(
              'Last Check-in',
              home.lastCheckin == null
                  ? 'Never'
                  : DateFormat.yMMMd().add_jm().format(home.lastCheckin!.date),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRouter.habits),
              icon: const Icon(Icons.checklist),
              label: const Text('Manage habits'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRouter.settings),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
