/// Centralized canonical URLs for store listings and marketing surfaces.
///
/// Keeping these in one place avoids drift between the Settings screen and any
/// DI-injected services that open the store.
library;

/// Public Play Store listing for the Android app.
const String kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.shahisoftware.heartos';

/// App Store listing for the iOS app.
///
/// TODO: replace `id000000000` with the real Apple ID once App Store Connect
/// publish is complete. The test suite asserts a non-placeholder form before
/// release.
const String kAppStoreUrl = 'https://apps.apple.com/app/id000000000';

/// Marketing website. Used as the universal fallback when the running platform
/// is neither Android nor iOS (desktop, web, etc.).
const String kAppWebsite = 'https://shahisoftware.com/products/heartos';
