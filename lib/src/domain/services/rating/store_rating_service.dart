/// Resolves the canonical store-rating URL for the running platform and opens it.
///
/// Concrete implementations are responsible for platform detection and URL
/// launching; consumers depend only on this interface so the Settings UI can
/// be unit-tested with a fake.
abstract class StoreRatingService {
  /// Returns a non-null, well-formed URL where the user can rate the app.
  /// Falls back to the marketing website when the platform is unsupported.
  String resolveStoreUrl();

  /// Opens the resolved store URL in an external application.
  ///
  /// Returns `true` when the URL was launched, `false` when launch failed
  /// (e.g. no handler available). Never throws.
  Future<bool> open();
}
