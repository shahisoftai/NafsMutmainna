import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/rating/store_rating_service.dart';
import '../../../infrastructure/di/providers.dart';
import '../../theme/colors.dart';

/// Top-of-Settings tile that opens the store-listing URL for the running
/// platform. Depends only on [StoreRatingService] — never on `Platform` —
/// so the widget is fully unit-testable.
class RateThisAppTile extends ConsumerWidget {
  const RateThisAppTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(
        Icons.star_rate_outlined,
        color: AppColors.primary,
      ),
      title: const Text('Rate this app'),
      subtitle: const Text(
        'Help us grow — takes a moment',
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _onTap(context, ref),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    final StoreRatingService service = ref.read(storeRatingServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await service.open();
    if (ok || !context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the store.')),
    );
  }
}
