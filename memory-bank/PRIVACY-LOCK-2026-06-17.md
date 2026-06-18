# HeartOS Privacy Lock — 2026-06-17

## Summary

Added **Biometric + PIN Fallback Privacy Lock** feature. App is now protected by a 6-digit PIN and/or device biometrics (Face ID / Touch ID / Fingerprint). Fully configurable via Settings. All data stored securely on-device only.

---

## Architecture

### Flow

```
App Launch
    │
    ▼
SplashScreen._init()
    │
    ├─► Check: hasSeenOnboarding?
    │       │
    │       ├─► NO  ──► Go to /onboarding
    │       │
    │       └─► YES ──► Check: privacyLockEnabled?
    │                       │
    │                       ├─► NO  ──► Go to /home
    │                       │
    │                       └─► YES ──► Go to /lock
    │                                           │
    │                                           ▼
    │                               PrivacyLockScreen
    │                               (biometric attempt first,
    │                                fallback to PIN keypad)
    │                                           │
    │                   ┌─────────────────────┼─────────────────────┐
    │                   ▼                     ▼                     ▼
    │             Success?              PIN entry?            Setup mode?
    │               │                     │                     │
    │               ▼                     ▼                     ▼
    │         Go to /home          Verify PIN           Create + confirm
    │                                                  PIN → enable → /home
    │
    ▼
Home / Onboarding / Lock
```

### Key Files

| File | Purpose |
|---|---|
| `lib/src/core/services/privacy_lock_service.dart` | `local_auth` wrapper + PIN hashing/storage via `flutter_secure_storage` |
| `lib/src/presentation/viewmodels/privacy_lock_view_model.dart` | Riverpod state notifier + providers |
| `lib/src/presentation/screens/lock/privacy_lock_screen.dart` | Lock UI (PIN keypad + biometric button) |
| `lib/src/presentation/navigation/app_router.dart` | Added `/lock` + `/lock/setup` routes |
| `lib/src/presentation/screens/profile/settings_screen.dart` | Added Privacy Lock toggle section |
| `lib/src/presentation/screens/splash/splash_screen.dart` | Added lock check on init |

---

## Privacy Lock Service

- **PIN storage**: SHA-256 hashed, stored in `flutter_secure_storage` (Android EncryptedSharedPreferences / iOS Keychain)
- **Biometrics**: Uses `local_auth` package — checks `canCheckBiometrics` + `isDeviceSupported` before offering
- **Auth flow**: Biometrics attempted first; if fails/unavailable, falls back to PIN
- **State keys** (all in secure storage):
  - `privacy_lock_pin` — hashed PIN
  - `privacy_lock_has_pin` — "1" when PIN is set
  - `privacy_lock_enabled` — "1" when lock is active

---

## Settings Integration

**Location**: Settings → Privacy & Security → Privacy Lock

- Toggle switch to enable/disable
- Bottom sheet with options:
  - "Set up Privacy Lock" → navigates to `/lock/setup`
  - "Disable Privacy Lock" (only visible when enabled) → confirms → disables

---

## Native Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```
Required for `LocalAuthentication.canCheckBiometrics` to return accurate results on Android 10+.

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSFaceIDUsageDescription</key>
<string>HeartOS uses Face ID to protect your private spiritual data.</string>
```
Required for Face ID to function — iOS will reject the app without this key.

---

## Dependencies Added

| Package | Version | Purpose |
|---|---|---|
| `local_auth` | ^2.3.0 | Biometric authentication (Android/iOS) |
| `crypto` | ^3.0.3 | SHA-256 PIN hashing |

---

## All Modified Files

| File | Changes |
|---|---|
| `pubspec.yaml` | Added `local_auth: ^2.3.0` + `crypto: ^3.0.3` |
| `lib/src/core/services/privacy_lock_service.dart` | **NEW** — biometric + PIN auth service |
| `lib/src/presentation/viewmodels/privacy_lock_view_model.dart` | **NEW** — Riverpod providers/state |
| `lib/src/presentation/screens/lock/privacy_lock_screen.dart` | **NEW** — lock UI |
| `lib/src/presentation/navigation/app_router.dart` | Added `lock` + `lockSetup` routes + import |
| `lib/src/presentation/screens/profile/settings_screen.dart` | Added Privacy & Security section |
| `lib/src/presentation/screens/splash/splash_screen.dart` | Added privacy lock check on init |
| `android/app/src/main/AndroidManifest.xml` | Added `USE_BIOMETRIC` permission |
| `ios/Runner/Info.plist` | Added `NSFaceIDUsageDescription` |

---

## How to Test

1. `flutter clean && flutter pub get`
2. `flutter run -d <device>`
3. **First launch (no lock)**:
   - Complete onboarding
   - Go to Settings → Privacy & Security → Privacy Lock
   - Toggle ON → redirected to PIN setup
   - Enter 6-digit PIN → confirm → returned to home
4. **Lock working**:
   - Force-close and reopen app
   - Should see lock screen with biometric prompt (if available) or PIN keypad
   - Authenticate → returns to home
5. **Disable lock**:
   - Settings → Privacy & Security → Privacy Lock → Disable
   - Confirm → reopen app → should go directly to home

---

## What Was NOT Changed

- No existing screen or feature behavior modified
- Existing auth repository (`LocalAuthDataSource`, `NoopAuthDataSource`) left untouched
- `providers.dart` auth providers unchanged (existing `remoteAuthDataSourceProvider` still points to `NoopAuthDataSource`)
- Splash screen navigation logic preserved — lock check is an extra branch after onboarding check
