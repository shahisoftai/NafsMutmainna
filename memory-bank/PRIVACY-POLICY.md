# HeartOS Privacy Policy

**Effective Date:** June 17, 2026

**HeartOS** ("we," "us," or "our") is committed to protecting your privacy. This Privacy Policy explains how HeartOS collects, uses, stores, and protects your personal information. HeartOS is designed as a completely private, offline-first application with no data sharing with any external source.

---

## 1. Information We Collect

### 1.1 Information You Provide

- **Check-in Data**: When you record emotional and spiritual check-ins, you provide information about your emotional state, intensity levels, and optional notes. This data is stored locally on your device.
- **Habit Tracking Data**: Information about habits you create, track, and complete within the app.
- **User Preferences**: Settings and preferences you configure within the app, such as your display name (if provided) and app configuration choices.

### 1.2 Automatically Collected Information

- **Device Information**: Limited to device type and operating system version, used solely to optimize app performance and compatibility.
- **Usage Analytics (Local Only)**: App usage patterns and feature engagement data are collected and stored **exclusively on your device** to improve your experience. This data is never transmitted to any external server.

### 1.3 Biometric Data

- **Biometric Authentication**: If you enable the Privacy Lock feature, HeartOS may use your device's biometric capabilities (fingerprint, Face ID, or similar) for authentication. Biometric data is processed by your device's native biometric system and **never leaves your device** or is stored by HeartOS.
- **PIN Data**: If you set a PIN for Privacy Lock, your PIN is hashed using SHA-256 and stored securely in your device's encrypted storage. The actual PIN is never stored.

---

## 2. How We Use Your Information

Your information is used solely to provide and improve the HeartOS experience:

- **Personalized Spiritual Guidance**: To offer tailored recommendations, interventions, and reflections based on your check-ins and emotional patterns.
- **Progress Tracking**: To display your spiritual journey, trends, and growth over time.
- **App Functionality**: To enable features such as daily dhikr reminders, habit tracking, and NAFS state monitoring.
- **Security**: To protect your private data through the Privacy Lock feature.
- **Bug Fixes and Improvements**: To identify and resolve issues, and to understand how features are used (all analysis remains on-device).

---

## 3. Data Storage and Security

### 3.1 Local Storage Only

HeartOS stores all data **exclusively on your device**. Your check-ins, habits, preferences, and all other personal information are stored in a local database on your device. **No data is ever transmitted to external servers, cloud services, or third parties.**

### 3.2 Data Encryption

- **PIN Security**: Your Privacy Lock PIN is hashed using SHA-256 before storage. The actual PIN is never saved.
- **Secure Storage**: Sensitive preferences are stored using platform-native secure storage mechanisms:
  - **Android**: EncryptedSharedPreferences
  - **iOS**: iOS Keychain with `first_unlock_this_device` accessibility

### 3.3 Biometric Authentication

Biometric authentication is handled entirely by your device's operating system. HeartOS does not collect, store, or access any biometric data. The biometric prompt is displayed by your OS, and authentication results are returned to HeartOS.

---

## 4. Data Sharing

### 4.1 No External Sharing

HeartOS **does not share, sell, rent, or transmit** any personal information to:
- External servers or cloud services
- Third-party analytics services
- Advertising networks
- Any other third parties

### 4.2 No Social Features

HeartOS does not include any social features, community forums, or sharing capabilities. Your data remains private to your device.

### 4.3 No Account Required

HeartOS does not require you to create an account or provide any personal information to use the app.

---

## 5. Your Rights

As a completely offline, private application, you have full control over your data:

### 5.1 Data Deletion

You can delete all your data at any time:
- **Within the App**: Go to Settings → Delete my data
- **Uninstalling the App**: Uninstalling HeartOS will remove all app data from your device

Deleting your data is permanent and cannot be undone.

### 5.2 Data Portability

Because all data is stored locally on your device, you can access your data directly through your device's file system (on supported platforms) or by exporting data through any device backup mechanisms you choose to use.

### 5.3 Privacy Lock

You can enable or disable the Privacy Lock feature at any time through Settings. When enabled, the app requires biometric or PIN authentication to access your data.

---

## 6. Children's Privacy

HeartOS is intended for users who are capable of independent spiritual reflection. The app is not specifically directed to children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with personal information, please contact us at **support@shahisoftware.com** to have the data removed.

---

## 7. Changes to This Policy

We may update this Privacy Policy from time to time to reflect changes in the app or legal requirements. Any changes will be communicated through:
- A notice within the app on next launch
- An update to this policy document in the app's memory-bank

Your continued use of HeartOS after any changes constitutes acceptance of the updated policy.

---

## 8. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy or HeartOS's privacy practices, please contact us:

**Email:** support@shahisoftware.com
**Website:** https://shahisoftware.com/products/heartos
**Privacy Policy URL:** https://shahisoftware.com/products/heartos/privacy

---

## 9. Third-Party Services

HeartOS does not integrate with any third-party services that would involve data sharing. The app's functionality is entirely self-contained and offline.

### 9.1 Native Platform Features

HeartOS uses the following platform-native features for security purposes:
- **Android Biometric API**: For biometric authentication on Android devices
- **iOS LocalAuthentication**: For Face ID and Touch ID on iOS devices
- **Platform Keychain/Secure Storage**: For secure local PIN storage

These features are used only for local authentication and storage, not for data transmission.

---

## 10. Data Retention

Your data is retained on your device for as long as you use HeartOS. There is no cloud backup of your data maintained by us. If you wish to retain your data, you must use your device's native backup mechanisms.

When you delete your data or uninstall the app, all associated data is permanently removed from your device.

---

## 11. Security Measures

HeartOS employs the following security measures to protect your private data:

- **Local-Only Storage**: No network transmission of personal data
- **Encrypted PIN Storage**: SHA-256 hashed PINs in platform secure storage
- **Privacy Lock**: Biometric and PIN protection to prevent unauthorized device access
- **No Third-Party SDKs with Network Access**: All integrated libraries are offline-only

While we are committed to protecting your privacy, no method of electronic storage or security is 100% secure. We encourage users to also employ device-level security measures such as device encryption and strong device unlock credentials.

---

## 12. International Users

HeartOS is designed for universal use. If you are accessing the app from outside your country, please note that your information may be transferred to and stored on your device in your current location, which may have different data protection laws than your country of residence.

---

*This Privacy Policy was last updated on June 17, 2026.*
