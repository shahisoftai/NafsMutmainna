import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../viewmodels/privacy_lock_view_model.dart';
import 'authentic_sources_data.dart';
import 'delete_data_service.dart';

// ============================================================================
// App metadata constants
// ============================================================================
const String kAppVersion = '1.1.14';
const String kAppWebsite = 'https://shahisoftware.com/products/heartos';
const String kSupportEmail = 'support@shahisoftware.com';
const String kPrivacyUrl = 'https://shahisoftware.com/products/heartos/privacy';
const String kTermsUrl = 'https://shahisoftware.com/products/heartos/terms';

// Store listing URLs (placeholders until the apps are published).
const String kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.shahisoftware.heartos';
const String kAppStoreUrl =
    'https://apps.apple.com/app/id000000000'; // TODO: replace with real Apple ID

const String kDisclaimerText =
    'All precautions have been taken to use only authentic sources, but user '
    'discretion is strongly recommended.';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---- Data ----
          const _SectionLabel('Data'),
          const _DeleteDataTile(),
          const _SectionDivider(),

          // ---- Privacy & Security ----
          const _SectionLabel('Privacy & Security'),
          const _PrivacyLockTile(),
          const _SectionDivider(),

          // ---- Legal ----
          const _SectionLabel('Legal'),
          const _LinkTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            url: kPrivacyUrl,
          ),
          const _LinkTile(
            icon: Icons.gavel_outlined,
            title: 'Terms of Service',
            url: kTermsUrl,
          ),
          const _DisclaimerTile(),
          const _SectionDivider(),

          // ---- About ----
          const _SectionLabel('About'),
          const _AboutHeader(),
          const _ReplayOnboardingTile(),
          const _LinkTile(
            icon: Icons.language_outlined,
            title: 'Website',
            subtitle: kAppWebsite,
            url: kAppWebsite,
          ),
          const _ContactUsTile(),
          const _SourcesTile(),
          const _RateAppTile(),
          const _SectionDivider(),

          // ---- Disclaimer banner ----
          const _DisclaimerBanner(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Section helpers
// ============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 24, thickness: 1, indent: 16, endIndent: 16);
  }
}

// ============================================================================
// Data
// ============================================================================

class _DeleteDataTile extends ConsumerWidget {
  const _DeleteDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: AppColors.error),
      title: const Text('Delete my data'),
      subtitle: const Text(
        'Removes all check-ins, history, habits and preferences',
      ),
      onTap: () => _confirm(context, ref),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This will permanently delete all your check-ins, heart history, '
          'interventions, habits, and preferences. This action cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final service = DeleteDataService(ref.read(appDatabaseProvider));
    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.deleteAllUserData();
      messenger.showSnackBar(
        const SnackBar(content: Text('All data deleted.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete data: $e')),
      );
    }
  }
}

// ============================================================================
// Legal
// ============================================================================

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String url;
  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _open(context, url),
    );
  }
}

class _DisclaimerTile extends StatelessWidget {
  const _DisclaimerTile();
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Content disclaimer'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          kDisclaimerText,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// About
// ============================================================================

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/heartos_logo.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'HeartOS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'v$kAppVersion  ·  Offline-first spiritual self-improvement',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactUsTile extends StatelessWidget {
  const _ContactUsTile();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mail_outline),
      title: const Text('Contact us'),
      subtitle: Text(kSupportEmail),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _open(context, 'mailto:$kSupportEmail'),
    );
  }
}

class _SourcesTile extends StatelessWidget {
  const _SourcesTile();
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: const Text('Authentic sources'),
      subtitle: const Text(
        'Quran, Hadith, Names of Allah from canonical references',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        for (final cat in kAuthenticSources) ...[
          if (cat.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                cat.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                cat.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          for (final w in cat.works)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                '• $w',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
        ],
        const SizedBox(height: 12),
        Text(
          'Sources intentionally avoided:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        for (final a in kSourcesAvoided)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $a',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

class _RateAppTile extends StatelessWidget {
  const _RateAppTile();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star_rate_outlined),
      title: const Text('Rate this app'),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        final url = _storeUrl();
        _open(context, url);
      },
    );
  }

  String _storeUrl() {
    try {
      if (Platform.isIOS) return kAppStoreUrl;
    } catch (_) {
      // Platform not available (web/tests) — fall through.
    }
    return kPlayStoreUrl;
  }
}

class _ReplayOnboardingTile extends ConsumerWidget {
  const _ReplayOnboardingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.replay_outlined),
      title: const Text('Replay App Introduction'),
      subtitle: const Text('View the onboarding cards again'),
      onTap: () => _replayOnboarding(context, ref),
    );
  }

  Future<void> _replayOnboarding(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replay App Introduction?'),
        content: const Text(
          'You will see the onboarding cards again to learn about '
          'the app\'s purpose and features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replay'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final box = ref.read(prefsBoxProvider).maybeWhen(
            data: (b) => b,
            orElse: () => null,
          );
      if (box != null) {
        await box.delete(kOnboardingSeenKey);
      }
    } catch (_) {
      // Best-effort — if the flag can't be cleared, onboarding may show again anyway.
    }

    if (!context.mounted) return;
    context.go(AppRouter.onboarding);
  }
}

// ============================================================================
// Footer
// ============================================================================

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textHint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kDisclaimerText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Privacy & Security
// ============================================================================

class _PrivacyLockTile extends ConsumerWidget {
  const _PrivacyLockTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(privacyLockProvider);

    return ListTile(
      leading: const Icon(Icons.lock_outline),
      title: const Text('Privacy Lock'),
      subtitle: Text(
        lockState.isEnabled
            ? 'App is protected with PIN and biometrics'
            : 'Protect app with PIN and biometrics',
      ),
      trailing: Switch.adaptive(
        value: lockState.isEnabled,
        onChanged: (value) => _togglePrivacyLock(context, ref, value),
        activeTrackColor: AppColors.primary,
      ),
      onTap: () => _showPrivacyLockOptions(context, ref),
    );
  }

  void _showPrivacyLockOptions(BuildContext context, WidgetRef ref) {
    final lockState = ref.read(privacyLockProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Set up Privacy Lock'),
              subtitle: const Text('Require PIN or biometrics to open app'),
              onTap: () {
                Navigator.pop(ctx);
                context.go(AppRouter.lockSetup);
              },
            ),
            if (lockState.isEnabled)
              ListTile(
                leading: const Icon(Icons.lock_open, color: AppColors.error),
                title: const Text('Disable Privacy Lock'),
                subtitle: const Text('Remove PIN and biometric protection'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _confirmDisable(context, ref);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePrivacyLock(BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      context.go(AppRouter.lockSetup);
    } else {
      await _confirmDisable(context, ref);
    }
  }

  Future<void> _confirmDisable(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Privacy Lock?'),
        content: const Text(
          'This will remove PIN and biometric protection. '
          'Anyone will be able to access your app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(privacyLockProvider.notifier).disable();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy Lock disabled')),
        );
      }
    }
  }
}

// ============================================================================
// URL launcher
// ============================================================================

Future<void> _open(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open the link: $e')),
      );
    }
  }
}
