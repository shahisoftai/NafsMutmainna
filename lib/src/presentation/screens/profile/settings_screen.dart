import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_router.dart';
import '../../theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionLabel('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('System default (light/dark)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack(context, 'Theme selector coming in v1.1'),
          ),
          const _SectionLabel('Content'),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack(context, 'Urdu language support coming in v1.1'),
          ),
          const _SectionLabel('Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export data (JSON)'),
            onTap: () => _snack(context, 'Coming in v1.1'),
          ),
          const _SectionLabel('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('HeartOS v1.0'),
            subtitle: Text('Offline-first spiritual self-improvement'),
          ),
          const ListTile(
            leading: Icon(Icons.menu_book_outlined),
            title: Text('Sources'),
            subtitle: Text('Quran, Hadith, Names of Allah from canonical references'),
          ),
          const SizedBox(height: 24),
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

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
