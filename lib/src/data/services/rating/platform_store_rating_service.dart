import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/store_urls.dart';
import '../../../domain/services/rating/store_rating_service.dart';

/// Production [StoreRatingService] that picks the right store URL based on
/// [Platform] and hands the launch off to `url_launcher` in external mode.
class PlatformStoreRatingService implements StoreRatingService {
  const PlatformStoreRatingService();

  @override
  String resolveStoreUrl() {
    if (isAndroid()) return kPlayStoreUrl;
    if (isIOS()) return kAppStoreUrl;
    return kAppWebsite;
  }

  @override
  Future<bool> open() async {
    final uri = Uri.tryParse(resolveStoreUrl());
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// `true` when running on Android. Falls back to `false` if [Platform] is
  /// not available (web/tests).
  @visibleForTesting
  bool isAndroid() {
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// `true` when running on iOS. Falls back to `false` if [Platform] is
  /// not available (web/tests).
  @visibleForTesting
  bool isIOS() {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
}
