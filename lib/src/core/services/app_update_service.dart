import 'dart:io' show Platform;

import 'package:in_app_update/in_app_update.dart';
import 'package:nafsmutmainna/core/logger/logger.dart';

/// Handles Google Play in-app update checks using the Flexible update flow.
///
/// Android-only. All public methods are guarded with [Platform.isAndroid] so
/// they are safe to call on iOS / web — they simply return `false`.
///
/// Failures are silently swallowed so an update issue never prevents the
/// user from starting the app. Each method returns a boolean indicating
/// whether the update action was attempted and succeeded.
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  /// Checks for a Play Store update and starts a flexible download if one is
  /// available. Returns true if an update was started, false otherwise.
  ///
  /// Call once per app launch (e.g. on the splash screen). This method is
  /// non-blocking — the user continues using the app while the update
  /// downloads in the background.
  Future<bool> checkAndStartFlexibleUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      final info = await InAppUpdate.checkForUpdate();
      Logger.info(
        'In-app update: availability=${info.updateAvailability.name}, '
        'version=${info.availableVersionCode}',
      );

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        Logger.info('In-app update: flexible update started successfully');
        return true;
      }
      return false;
    } catch (e, st) {
      Logger.error(
        'In-app update: checkAndStartFlexibleUpdate failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Completes a flexible update that was downloaded in a prior session.
  ///
  /// **Must be awaited** — this may trigger a Play Store install dialog and
  /// potentially restart the app. Call once on app startup before routing.
  ///
  /// Returns true if the update was completed, false otherwise.
  Future<bool> completeFlexibleUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      await InAppUpdate.completeFlexibleUpdate();
      Logger.info('In-app update: completeFlexibleUpdate succeeded');
      return true;
    } catch (e, st) {
      Logger.error(
        'In-app update: completeFlexibleUpdate failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
