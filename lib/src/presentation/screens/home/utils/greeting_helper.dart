import 'package:intl/intl.dart';

/// Pure helpers for the time-aware greeting on the home page.
///
/// Kept stateless and side-effect free so it is trivially unit-testable.
class GreetingHelper {
  GreetingHelper._();

  /// English greeting phrase based on the hour of the day.
  ///
  /// Buckets:
  /// - 00:00–04:59  → "Good night"
  /// - 05:00–11:59  → "Good morning"
  /// - 12:00–16:59  → "Good afternoon"
  /// - 17:00–20:59  → "Good evening"
  /// - 21:00–23:59  → "Good night"
  static String timeOfDayGreeting(DateTime now) {
    final h = now.hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  /// Hijri date string formatted in English.
  ///
  /// Uses the "Kuwaiti algorithm" (Badr, 2007) — a pure-Dart Hijri conversion
  /// that doesn't require an extra dependency. Accurate to ±1 day.
  /// Example output: "14 Rajab 1447 AH"
  static String hijriDate(DateTime d) {
    final h = gregorianToHijri(d);
    const monthNames = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];
    final monthName = (h.month >= 1 && h.month <= 12)
        ? monthNames[h.month - 1]
        : 'Month ${h.month}';
    return '${h.day} $monthName ${h.year} AH';
  }

  /// Gregorian date for display next to the Hijri date.
  /// Example output: "14 Jun 2026"
  static String gregorianDate(DateTime d) {
    return DateFormat('d MMM yyyy', 'en').format(d);
  }

  /// Arabic greeting prefix used on the home page.
  /// Kept as a constant so the screen never inlines a magic string.
  static const String arabicGreeting = 'السلام عليكم';
}

/// Julian Day Number of 1 Muharram 1 AH (Islamic civil epoch).
/// Corresponds to JD 1948439.5 (Friday, 16 July 622 CE Julian).
const int _islamicEpoch = 1948440;

/// Gregorian → Hijri conversion using the standard Tabular Islamic calendar
/// (type IIa, the same scheme used by the Microsoft "Kuwaiti algorithm").
/// Returns (year, month, day).
/// Note: Hijri day begins at sunset, so this is approximate.
({int year, int month, int day}) gregorianToHijri(DateTime g) {
  // Julian Day Number of the Gregorian date.
  final jd = _gregorianToJulianDay(g.year, g.month, g.day);

  // Islamic year: a 30-year cycle has 10631 days (11 leap years of 355 days,
  // 19 common years of 354 days).
  final year = (((jd - _islamicEpoch) * 30) + 10646) ~/ 10631;

  // Islamic month: odd months have 30 days, even months 29 days, except in a
  // leap year when the 12th month (Dhu al-Hijjah) has 30 days.
  final firstOfYear = _hijriToJulianDay(year, 1, 1);
  var month = ((jd - (29 + firstOfYear)) / 29.5).ceil() + 1;
  if (month < 1) month = 1;
  if (month > 12) month = 12;

  // Islamic day: the offset from the first day of the month.
  final firstOfMonth = _hijriToJulianDay(year, month, 1);
  final day = jd - firstOfMonth + 1;

  return (year: year, month: month, day: day);
}

/// Convert an Islamic (Hijri) date to a Julian Day Number.
/// Uses the standard Tabular Islamic calendar with leap years in positions
/// 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29 of each 30-year cycle.
int _hijriToJulianDay(int year, int month, int day) {
  return day +
      (29.5 * (month - 1)).ceil() +
      (year - 1) * 354 +
      ((3 + (11 * year)) ~/ 30) +
      _islamicEpoch -
      1;
}

int _gregorianToJulianDay(int year, int month, int day) {
  final a = ((14 - month) / 12).floor();
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
}
