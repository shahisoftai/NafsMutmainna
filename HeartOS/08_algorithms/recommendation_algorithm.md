# Recommendation Algorithm v2

> The offline, deterministic algorithm that takes a check-in and produces the 6 (or fewer) intervention cards shown on the Intervention screen.

> **v2 supersedes the v1 algorithm documented in earlier revisions.** v1 used the `emotion_attribute_links.Treatment` table to pick attributes and `ORDER BY RANDOM()` for Quran/Hadith — both were misaligned with the curated seed data. v2 walks the Emotion's `Growth_Path` deterministically and uses the Emotion row's hand-curated `Recommended_*` fields.

---

## 1 · Goals

The algorithm must:

1. **Be on-point** — every card must be directly relevant to the selected core emotion.
2. **Be deterministic** — the same check-in must produce the same cards.
3. **Be explainable** — every card has a "why" string that traces back to the emotion, attribute, or verse.
4. **Be oriented toward Mutmainnah** — the recommended path is the `Growth_Path`, which always ends at a high-Mutmainnah attribute.
5. **Be failproof** — missing or unresolvable data produces a fallback card, never an exception.
6. **Be fast** — under 50 ms end-to-end.

## 2 · Input

- `checkin` — the current `checkins` row.
- The **immutable** Knowledge, Graph, and Nafs tables.
- `interventions_history` — the last 3 days (for soft-skip).

## 3 · Output

A list of up to **6 cards**, each typed as one of:

```
Quran | Hadith | Dua | Allah_Names | Dhikr | Action
```

The order is **deterministic**:

1. Quran  (top from `emotion_quran_links` by `Weight DESC`)
2. Hadith (top from `emotion_hadees_links` by `Weight DESC`)
3. Dua    (from `emotions.Recommended_Dua_*`)
4. Names  (from `emotions.Recommended_Allah_Names`)
5. Dhikr  (from `emotions.Recommended_Dhikr`)
6. Action (from `emotions.Daily_Action`)

If a slot has no content (e.g. no linked verse for the emotion), the algorithm falls back to the focus attribute's embedded content; if still empty, the slot is dropped.

If every slot is empty, a single "reflection" card is returned as a last resort.

## 4 · Algorithm

### 4.1 Step 1 — Resolve the emotion

```python
emotion = sql.get("emotions", id=checkin.Emotion_ID)
```

### 4.2 Step 2 — Resolve the growth path

```python
path = emotion.Growth_Path.split("→")          # e.g. "Ghadab→Sabr→Hilm→Rifq"
attrs = [resolve(step_name) for step_name in path if step_name]
attrs = [a for a in attrs if a is not None]     # drop unresolvable
if not attrs:
    attrs = [resolve(n) for n in emotion.Primary_Positive_Attributes.split(";")]
    attrs = [a for a in attrs if a is not None]
```

**`resolve(name)`** uses a 4-step matcher:
1. Exact (case-insensitive) match against `Attribute.Attribute`.
2. Aliased match against a hand-curated `aliases` table (e.g. `Yaqeen → Yaqin`, `Qanaah → Qana'ah`).
3. Normalized match — strip punctuation, diacritics, hyphens, the "al-" prefix.
4. Substring match (either direction), preferring the shorter attribute name.

Unresolvable names are logged and skipped. The first two steps of a negative emotion's path are often the emotion name itself ("Anxiety", "Fear") or a non-attribute concept ("Dhikr", "Huzn") — they are silently skipped, and the algorithm walks the path from the first resolvable step.

### 4.3 Step 3 — Pick the focus attribute by intensity

```python
n = len(attrs)
if intensity <= 3:    idx = n - 1       # mild → aspirational (last step)
elif intensity >= 7:  idx = 0           # acute → immediate (first step)
else:                 idx = n // 2      # moderate → middle step
focus = attrs[idx]
```

The terminal step is **always** the last step on the path — and since every `Growth_Path` ends at a high-Mutmainnah attribute (Sakinah×9, Ridha×8, Mahabbah×7, etc., verified at `_verifyIntegrity` time in `seed_loader.dart`), the focus is always oriented toward Mutmainnah.

### 4.4 Step 4 — Pick the Quran and Hadith

```python
# Soft-skip: try top 1 excluding IDs shown in last 3 days;
# if all excluded, fall back to the unfiltered top.
recent_quran_ids = {r.Ayat_ID for r in interventions_history
                    if r.Intervention_Type == "Quran" and r.Date >= today - 3 days}
quran = findTopForEmotionExcluding(emotion_id, limit=1, exclude=recent_quran_ids)[0]
# (Same for hadith.)
```

`findTopForEmotionExcluding` does `ORDER BY Weight DESC LIMIT 1` with a `WHERE Ayat_ID NOT IN (...)` clause when possible. If the exclusion filter wipes out every candidate, the function falls back to the unfiltered top — the user is never blocked.

### 4.5 Step 5 — Emit the 6 cards

```python
cards = [
  build_quran_card(quran, emotion),
  build_hadees_card(hadees, emotion),
  build_dua_card(emotion),     # from Recommended_Dua_*
  build_names_card(emotion),   # from Recommended_Allah_Names
  build_dhikr_card(emotion),   # from Recommended_Dhikr
  build_action_card(emotion),  # from Daily_Action
]
```

Each card carries a `why` string tying it back to the emotion (and the focus attribute, when relevant).

If a slot is empty (e.g. no linked verse, or empty `Recommended_Dua_Arabic`), the algorithm:
1. Tries the focus attribute's embedded content (e.g. `attribute.Quran_Reference`).
2. Drops the slot if still empty.

If **all** slots are empty (the only way this happens is an emotion with no Growth_Path, no Primary_Positive_Attributes, and empty `Recommended_*` fields), a single reflection card is returned.

## 5 · Edge cases

| Situation | Handled how |
|---|---|
| Unknown `emotionId` | Returns `[]` (the screen shows the "no interventions" message). |
| `Growth_Path` is empty | Falls back to `Primary_Positive_Attributes`. |
| `Growth_Path` step is the emotion name (e.g. "Anxiety") | Logged and skipped. |
| `Growth_Path` step is a transliteration variant (e.g. "Yaqeen") | Aliased to "Yaqin". |
| `emotion_quran_links` has no rows for the emotion | Falls back to the focus attribute's `Quran_Reference`. |
| Top Quran shown in last 3 days | Try the next; fall back to top 1 if all candidates shown. |
| `Recommended_Dua_Arabic` is empty | Falls back to the short `Recommended_Dua` transliteration. |
| Every emotion-row field is empty | A single reflection card is returned. |

## 6 · What changed from v1

| v1 | v2 | Why |
|---|---|---|
| `emotion_attribute_links.Treatment` query | `emotion.Growth_Path` walker | The Treatment role held "what grows when you work on the core" — often irrelevant to the emotion (e.g. "Zuhd" for Anger). The Growth_Path is the curated trajectory toward Mutmainnah. |
| `findRandomForEmotionExcluding` (RANDOM()) | `findTopForEmotionExcluding` (Weight DESC) | The hand-curated verses/hadith are weighted 0.7-1.0; random selection ignored that signal. |
| 0.6 / 0.3 / 0.1 weighted-sum ranking | Deterministic slot order | The scoring formula was opaque and produced non-deterministic results when combined with the random picker. |
| `attribute_nafs_weights` biasing | n/a | The Growth_Path already encodes the trajectory; the bias was redundant. |
| Hard 7-day exclusion | Soft 3-day exclusion | The hard 7-day filter could empty the entire card list, leaving the user with no recommendation. |
| Dedup-by-type (one Quran max) | n/a | The user can now see multiple Quran/Hadith cards (one from the emotion link, plus attribute-embedded fallbacks). |
| Emotion row's `Recommended_Dua*` and `Recommended_Allah_Names` ignored | Used directly | These are hand-curated for each emotion. |

## 7 · Performance

| Step | Time |
|---|---|
| Step 1: resolve emotion | < 1 ms (in-memory cache) |
| Step 2: resolve growth path | < 5 ms (200-attribute cache, hit once) |
| Step 3: pick focus | < 1 ms (in-memory) |
| Step 4: top Quran / Hadith | < 5 ms (indexed join) |
| Step 5: build 6 cards | < 1 ms (in-memory) |
| **Total** | **< 20 ms** |

## 8 · Tunable constants

| Constant | Value | Location |
|---|---|---|
| Soft-skip window | 3 days | `Recommend.softSkipDays` |
| Maximum cards | 6 | `Recommend.maxCards` |
| Acute intensity threshold | ≥ 7 | `Recommend._pickFocus` |
| Mild intensity threshold | ≤ 3 | `Recommend._pickFocus` |

## 9 · Integrity check

After every seed, `SeedLoader._verifyIntegrity` logs a warning for each `Growth_Path` step that does not resolve to an existing attribute, and for each terminal step whose `Mutmainnah` score is below 50. As of v2, both checks pass for all 50 emotions. New emotions or path edits should preserve this invariant.

## 10 · See also

- `../03_nafs_engine/nafs_meter_algorithm.md` — the scoring side.
- `../02_relationships/emotion_attribute_links.md` — the legacy link table (still used by `DetectAttributes` for the Insight screen, but NOT used by the recommendation engine).
- `../01_core_tables/attributes.md` — the embedded content on each attribute row.
- `../01_core_tables/emotions.md` — the Emotion row's `Recommended_*` fields and `Growth_Path`.
