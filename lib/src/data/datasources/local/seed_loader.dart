import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../../../../core/logger/logger.dart';

/// Reads the 10 bundled JSON seed files and inserts into the SQLite database.
/// All inserts are idempotent (INSERT OR IGNORE) so this is safe to run on
/// every cold start.
class SeedLoader {
  static const _base = 'assets/data';

  static Future<void> seedAll(Database db) async {
    // Order matches HeartOS seed order from 00_index.md.
    await _seedNafsStates(db);
    await _seedEmotions(db);
    await _seedAttributes(db);
    await _seedDomains(db);
    await _seedEmotionNafsWeights(db);
    await _seedAttributeNafsWeights(db);
    await _seedEmotionAttributeLinks(db);
    await _seedAttributeLinks(db);
    await _seedDomainAttributeLinks(db);
    await _seedDomainEmotionLinks(db);
    await _seedHadees(db);
    await _seedQuranAyat(db);
    await _seedEmotionHadeesLinks(db);
    await _seedEmotionQuranLinks(db);
  }

  static Future<List<Map<String, Object?>>> _load(String name) async {
    final raw = await rootBundle.loadString('$_base/$name.json');
    final j = jsonDecode(raw) as Map<String, Object?>;
    return (j['rows'] as List).cast<Map<String, Object?>>();
  }

  /// Inserts each row individually so a single foreign-key violation (e.g. a
  /// link table referencing an Attribute_ID that doesn't exist) skips just
  /// that row instead of aborting the entire batch. Without this, one stale
  /// row poisons the whole table AND every subsequent table in [seedAll],
  /// leaving the database in a broken state (e.g. no emotion→attribute
  /// links → "no attributes detected" on Heart Analysis).
  static Future<void> _insertBatch(DatabaseExecutor db, String table, List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return;
    var inserted = 0;
    var skipped = 0;
    for (final row in rows) {
      final cleaned = <String, Object?>{};
      for (final e in row.entries) {
        if (e.value == null) continue;
        if (e.value is double && (e.value as double).isNaN) continue;
        cleaned[e.key] = e.value;
      }
      try {
        await db.insert(table, cleaned, conflictAlgorithm: ConflictAlgorithm.replace);
        inserted++;
      } catch (e) {
        skipped++;
        Logger.warning('Seed: skipped $table row — $e');
      }
    }
    if (skipped > 0) {
      Logger.info('Seed $table: $inserted inserted, $skipped skipped (likely FK violations)');
    } else {
      Logger.info('Seeded $table: $inserted');
    }
  }

  static Future<void> _seedNafsStates(Database db) async {
    final rows = await _load('nafs_states_seed');
    await _insertBatch(db, 'nafs_states', rows);
    Logger.info('Seeded nafs_states: ${rows.length}');
  }

  static Future<void> _seedEmotions(Database db) async {
    final rows = await _load('emotions_seed');
    await _insertBatch(db, 'emotions', rows);
    Logger.info('Seeded emotions: ${rows.length}');
  }

  static Future<void> _seedAttributes(Database db) async {
    final rows = await _load('attributes_seed');
    await _insertBatch(db, 'attributes', rows);
    Logger.info('Seeded attributes: ${rows.length}');
  }

  static Future<void> _seedDomains(Database db) async {
    final rows = await _load('domains_seed');
    await _insertBatch(db, 'domains', rows);
    Logger.info('Seeded domains: ${rows.length}');
  }

  static Future<void> _seedEmotionNafsWeights(Database db) async {
    final rows = await _load('emotion_nafs_weights_seed');
    await _insertBatch(db, 'emotion_nafs_weights', rows);
    Logger.info('Seeded emotion_nafs_weights: ${rows.length}');
  }

  static Future<void> _seedAttributeNafsWeights(Database db) async {
    final rows = await _load('attribute_nafs_weights_seed');
    await _insertBatch(db, 'attribute_nafs_weights', rows);
    Logger.info('Seeded attribute_nafs_weights: ${rows.length}');
  }

  static Future<void> _seedEmotionAttributeLinks(Database db) async {
    final rows = await _load('emotion_attribute_links_seed');
    await _insertBatch(db, 'emotion_attribute_links', rows);
    Logger.info('Seeded emotion_attribute_links: ${rows.length}');
  }

  static Future<void> _seedAttributeLinks(Database db) async {
    final rows = await _load('attribute_links_seed');
    await _insertBatch(db, 'attribute_links', rows);
    Logger.info('Seeded attribute_links: ${rows.length}');
  }

  static Future<void> _seedDomainAttributeLinks(Database db) async {
    final rows = await _load('domain_attribute_links_seed');
    await _insertBatch(db, 'domain_attribute_links', rows);
    Logger.info('Seeded domain_attribute_links: ${rows.length}');
  }

  static Future<void> _seedDomainEmotionLinks(Database db) async {
    final rows = await _load('domain_emotion_links_seed');
    await _insertBatch(db, 'domain_emotion_links', rows);
    Logger.info('Seeded domain_emotion_links: ${rows.length}');
  }

  static Future<void> _seedHadees(Database db) async {
    final rows = await _load('hadees_seed');
    await _insertBatch(db, 'hadees', rows);
    Logger.info('Seeded hadees: ${rows.length}');
  }

  static Future<void> _seedQuranAyat(Database db) async {
    final rows = await _load('quran_ayat_seed');
    await _insertBatch(db, 'quran_ayat', rows);
    Logger.info('Seeded quran_ayat: ${rows.length}');
  }

  static Future<void> _seedEmotionHadeesLinks(Database db) async {
    final rows = await _load('emotion_hadees_links_seed');
    await _insertBatch(db, 'emotion_hadees_links', rows);
    Logger.info('Seeded emotion_hadees_links: ${rows.length}');
  }

  static Future<void> _seedEmotionQuranLinks(Database db) async {
    final rows = await _load('emotion_quran_links_seed');
    await _insertBatch(db, 'emotion_quran_links', rows);
    Logger.info('Seeded emotion_quran_links: ${rows.length}');
  }
}
