import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../theme/colors.dart';

/// "Quran of the Day" card shown on the Home screen.
///
/// Per RI-5.3 (Scholar Audit Remediation Plan §5.3):
/// Surah + reflection rotates daily. Anchored to classical tafsir, not to
/// the user's emotion — so the user is brought to Quran independent of any
/// check-in. Reminds the user that *tilawah al-quran bi al-tadabbur* is a
/// foundation of tazkiya (Ghazali, Ihya' 3.13).
///
/// Source: `assets/data/quran_of_the_day.json` — a curated list of ~30 short
/// verses with classical reflection notes. The card picks the verse whose
/// index equals `dayOfYear mod verses.length`, giving a deterministic daily
/// rotation.
class QuranOfTheDayCard extends StatefulWidget {
  const QuranOfTheDayCard({super.key});

  @override
  State<QuranOfTheDayCard> createState() => _QuranOfTheDayCardState();
}

class _QuranOfTheDayCardState extends State<QuranOfTheDayCard> {
  late Future<_QuranOfTheDayEntry?> _entry;

  @override
  void initState() {
    super.initState();
    _entry = _loadTodayEntry();
  }

  Future<_QuranOfTheDayEntry?> _loadTodayEntry() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/quran_of_the_day.json');
      final json = jsonDecode(raw) as Map<String, Object?>;
      final verses =
          (json['verses'] as List).cast<Map<String, Object?>>();
      if (verses.isEmpty) return null;
      final now = DateTime.now();
      final dayOfYear =
          now.difference(DateTime(now.year, 1, 1)).inDays;
      final idx = dayOfYear % verses.length;
      return _QuranOfTheDayEntry.fromJson(verses[idx]);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_QuranOfTheDayEntry?>(
      future: _entry,
      builder: (context, snap) {
        final entry = snap.data;
        if (entry == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Quran of the Day',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.8,
                  fontFamily: 'Amiri',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.english,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.surfaceVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.reference,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.reflection,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One entry from the quran_of_the_day.json file.
class _QuranOfTheDayEntry {
  final String arabic;
  final String english;
  final String reference;
  final String reflection;

  const _QuranOfTheDayEntry({
    required this.arabic,
    required this.english,
    required this.reference,
    required this.reflection,
  });

  factory _QuranOfTheDayEntry.fromJson(Map<String, Object?> j) {
    return _QuranOfTheDayEntry(
      arabic: (j['arabic'] as String?) ?? '',
      english: (j['english'] as String?) ?? '',
      reference: (j['reference'] as String?) ?? '',
      reflection: (j['reflection'] as String?) ?? '',
    );
  }
}