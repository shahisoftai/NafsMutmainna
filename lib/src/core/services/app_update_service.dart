import 'package:in_app_update/in_app_update.dart';

/// Handles Google Play in-app update checks using the Flexible update flow.
///
/// This service is Android-only. All methods are non-blocking and
/// fail silently — an update failure never prevents the app from starting.
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  AppUpdateInfo? _lastInfo;

  /// Checks for a Play Store update and starts a flexible download if one is
  /// available. Returns true if an update was started, false otherwise.
  ///
  /// This method should be called once per app launch (e.g. on the splash
  /// screen). It is non-blocking — the user continues using the app normally
  /// while the update downloads in the background.
  Future<bool> checkAndStartFlexibleUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      _lastInfo = info;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Completes a flexible update that was downloaded in a prior session.
  /// Call this once on app startup — it will succeed only if a flexible
  /// update was downloaded and is pending installation.
  ///
  /// Returns true if the update was completed, false otherwise.
  Future<bool> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (_) {
      return false;
    }
  }
}
