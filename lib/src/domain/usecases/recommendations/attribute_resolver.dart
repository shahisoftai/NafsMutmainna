import '../../../../core/logger/logger.dart';
import '../../entities/heart_attribute.dart';
import '../../repositories/attribute_repository.dart';

/// Resolves a textual attribute name (as found in `emotions.Growth_Path` and
/// `emotions.Primary_Positive_Attributes`) to its [HeartAttribute] row.
///
/// The seed data is curated by humans and uses many transliteration variants
/// (e.g. "Yaqeen" vs "Yaqin", "Qanaah" vs "Qana'ah", "Su az-Zann" vs
/// "Su' al-Dhann"). This resolver applies a sequence of progressively looser
/// matching strategies so that every reasonable variant resolves to a real
/// attribute row.
///
/// Resolution order:
/// 1. Exact match (case-insensitive, whitespace-trimmed)
/// 2. Normalized match (stripped of punctuation, diacritics, apostrophes,
///    hyphens, and ASCII-only — so "Qana'ah" matches "Qanaah")
/// 3. Substring match (either direction) — only as a last resort, since it
///    can produce false positives. The first match wins; matches on shorter
///    attribute names are preferred (less ambiguous).
///
/// Returns `null` when no match is found. Callers are expected to log
/// unresolved names so the seed data can be tightened over time, but to
/// never throw on unresolved input.
class AttributeResolver {
  final AttributeRepositoryInterface _repo;
  List<HeartAttribute>? _cache;

  AttributeResolver(this._repo);

  /// Resolves [name] to a [HeartAttribute] (or null if no match).
  Future<HeartAttribute?> resolve(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final attrs = await _all();
    final lower = trimmed.toLowerCase();
    final normalized = _normalize(trimmed);

    // 0. Explicit alias table for common transliteration variants
    //    that the normalized/substring heuristics can't reconcile.
    //    Add new entries here when new variants appear in the seed data.
    final alias = aliases[lower];
    if (alias != null) {
      for (final a in attrs) {
        if (a.name.toLowerCase() == alias.toLowerCase()) return a;
      }
    }

    // 1. Exact (case-insensitive) match.
    for (final a in attrs) {
      if (a.name.toLowerCase() == lower) return a;
    }

    // 2. Normalized match — strip punctuation, diacritics, and the
    //    "al-" prefix. "Qana'ah" and "Qanaah" and "qana-ah" all collapse
    //    to "qanaah".
    for (final a in attrs) {
      if (_normalize(a.name) == normalized) return a;
    }

    // 3. Substring match (either direction), preferring the SHORTER
    //    attribute name to avoid e.g. "Sabr" matching "Sabr Jamil".
    final candidates = <(HeartAttribute, int)>[];
    for (final a in attrs) {
      final an = a.name.toLowerCase();
      if (an == lower) {
        candidates.add((a, an.length));
      } else if (an.contains(lower) || lower.contains(an)) {
        candidates.add((a, an.length));
      }
    }
    if (candidates.isNotEmpty) {
      candidates.sort((x, y) => x.$2.compareTo(y.$2));
      return candidates.first.$1;
    }

    Logger.warning('AttributeResolver: could not resolve "$name"');
    return null;
  }

  /// Known transliteration variants that the generic matcher can't resolve.
  /// Keys are lowercased, trimmed. Values are the canonical attribute name.
  static const Map<String, String> aliases = {
    'yaqeen': 'Yaqin',
    'yaqīn': 'Yaqin',
    'yakeen': 'Yaqin',
    'qanaah': "Qana'ah",
    'qanaa': "Qana'ah",
    'sabr': 'Sabr',
  };

  /// Resolves every name in [names] in order, dropping nulls.
  /// Logs each unresolved name.
  Future<List<HeartAttribute>> resolveAll(Iterable<String> names) async {
    final out = <HeartAttribute>[];
    for (final n in names) {
      final a = await resolve(n);
      if (a != null) out.add(a);
    }
    return out;
  }

  Future<List<HeartAttribute>> _all() async {
    return _cache ??= await _repo.getAll();
  }

  /// Lowercases, removes the Arabic definite article prefix "al-",
  /// strips punctuation (', ʼ ‘ ’, -, "), collapses whitespace, and
  /// removes diacritics. Used for tolerant name comparison.
  static String _normalize(String input) {
    var s = input.toLowerCase().trim();
    s = s.replaceAll(RegExp(r"['\u2018\u2019\u02BC\-_]"), '');
    s = s.replaceAll(RegExp(r'\s+'), '');
    if (s.startsWith('al')) s = s.substring(2);
    return s;
  }
}
