import 'package:flutter_test/flutter_test.dart';
import 'package:nafsmutmainna/core/constants/store_urls.dart';
import 'package:nafsmutmainna/src/data/services/rating/platform_store_rating_service.dart';

/// Test-double that lets the test force the platform detection result without
/// touching the real `Platform` global.
class _FakePlatformService extends PlatformStoreRatingService {
  _FakePlatformService({required this.android, required this.ios});

  final bool android;
  final bool ios;

  @override
  bool isAndroid() => android;

  @override
  bool isIOS() => ios;
}

void main() {
  group('PlatformStoreRatingService.resolveStoreUrl', () {
    test('returns the Play Store URL on Android', () {
      final service = _FakePlatformService(android: true, ios: false);
      expect(service.resolveStoreUrl(), kPlayStoreUrl);
    });

    test('returns the App Store URL on iOS', () {
      final service = _FakePlatformService(android: false, ios: true);
      expect(service.resolveStoreUrl(), kAppStoreUrl);
    });

    test('falls back to the marketing website on other platforms', () {
      final service = _FakePlatformService(android: false, ios: false);
      expect(service.resolveStoreUrl(), kAppWebsite);
    });
  });
}
