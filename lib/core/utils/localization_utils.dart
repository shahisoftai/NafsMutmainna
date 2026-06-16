import 'package:flutter/material.dart';

/// Localization utilities for RTL support and internationalization
class LocalizationUtils {
  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Check if a specific locale is RTL
  static bool isRTLLocale(Locale locale) {
    return locale.languageCode == 'ar' ||
        locale.languageCode == 'ur' ||
        locale.languageCode == 'he' ||
        locale.languageCode == 'fa';
  }

  /// Get text alignment based on locale direction
  static TextAlign getTextAlignment(BuildContext context) {
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get icon alignment based on locale direction
  static MainAxisAlignment getIconAlignment(BuildContext context) {
    return isRTL(context) ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// Create RTL-aware padding
  static EdgeInsetsDirectional getPadding({
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start,
      end: end,
      top: top,
      bottom: bottom,
    );
  }

  /// Create margin that respects RTL
  static EdgeInsetsDirectional getMargin({
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start,
      end: end,
      top: top,
      bottom: bottom,
    );
  }
}

/// Date/time formatting utilities respecting locale
class DateTimeUtils {
  /// Format date for display based on locale
  static String formatDate(DateTime date, {Locale? locale}) {
    // Simple implementation - in production use intl package
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format time for display based on locale
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Format relative time (e.g., "2 hours ago")
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

/// Number formatting utilities
class NumberUtils {
  /// Format number based on locale
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    if (decimalPlaces == 0) {
      return number.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return number.toStringAsFixed(decimalPlaces).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 0}) {
    return '${formatNumber(value * 100, decimalPlaces: decimalPlaces)}%';
  }
}

/// Locale provider helper
class LocaleHelper {
  static const supportedLocales = [
    Locale('en', ''), // English (default)
    Locale('ur', ''), // Urdu
    Locale('ar', ''), // Arabic
  ];

  static Locale getDefaultLocale() {
    return const Locale('en', '');
  }

  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          (supported.countryCode == locale.countryCode ||
              supported.countryCode!.isEmpty),
    );
  }

  static Locale getFallbackLocale(Locale locale) {
    // Try to find a locale with the same language
    final fallback = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => getDefaultLocale(),
    );
    return fallback;
  }
}