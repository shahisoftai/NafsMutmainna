# Multilingual Support (v1.1) — Future

> Adding Arabic, Urdu, and additional language support to Heart OS. v1.0 ships with **English UI** but the seed content already includes Arabic and Urdu for the Quran, Hadith, and Duas.

---

## 1 · What v1.0 already supports

The **seed content** (the immutable Knowledge and Graph layers) is already in three languages for the scriptural text:

| Field | English | Arabic | Urdu |
|---|---|---|---|
| `attributes.Attribute` | ✅ | — | — |
| `attributes.Arabic_Name` | — | ✅ | — |
| `attributes.Definition` | ✅ | — | — |
| `attributes.Quran_*` | ✅ | ✅ | ✅ |
| `attributes.Hadith_*` | — | ✅ | ✅ |
| `attributes.Dua_*` | — | ✅ | ✅ |
| `emotions.Core_Emotion` | ✅ | — | — |
| `emotions.Arabic_Name` | — | ✅ | — |

What v1.0 does **not** ship with:

- ❌ Translated UI strings.
- ❌ Translated emotion descriptions.
- ❌ Translated domain descriptions.
- ❌ Tafsir excerpts.

## 2 · The v1.1 plan

### 2.1 Arabic UI (v1.1)

- All UI strings translated to Arabic via Flutter ARB files.
- RTL layout support (already in Flutter, needs configuration).
- Arabic emotion names as the **primary** label in Arabic locale; English as secondary.
- Arabic domain names as the primary label.

### 2.2 Urdu UI (v1.1)

- All UI strings translated to Urdu via ARB files.
- RTL support not needed (Urdu is RTL — wait, Urdu is RTL! — needs configuration).
- Urdu Quran/Hadith translations already in the seed.

### 2.3 Other languages (v2.0+)

The following are candidate languages for v2.0:

| Language | Status | Notes |
|---|---|---|
| Turkish | Candidate | Large Muslim population; no seed content yet. |
| Bahasa Indonesia | Candidate | Largest Muslim country by population. |
| French | Candidate | Large Muslim population in Europe and Africa. |
| Spanish | Candidate | Growing Muslim population in Latin America. |
| Swahili | Candidate | East Africa. |
| Bengali | Candidate | Large Muslim population in South Asia. |

For each, the work is:

1. Translate the **UI strings** (ARB files).
2. Translate the **emotion descriptions** (50 short paragraphs).
3. Translate the **domain descriptions** (10 short paragraphs).
4. Translate the **attribute definitions** (200 short paragraphs).
5. Provide **Quran translations** (use a vetted, well-known translation).
6. Provide **Hadith translations** (use a vetted, well-known collection).

## 3 · RTL support

Flutter has first-class RTL support. The configuration:

```yaml
# pubspec.yaml
flutter:
  generate: true

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

The Material widgets (TextField, Button, etc.) automatically mirror in RTL locales.

### 3.1 Things to check in RTL

- Nafs meter: the arc direction is **unchanged** (Ammarah → Mutmainnah is left to right in all locales — it represents a *journey*, not a direction).
- Heart Graph: the directed edges are **unchanged** (Source → Target is always source-then-target).
- Streak counter: numbers are always LTR within the RTL layout.
- Arabic content (Quran, Hadith, Duas) is **always** RTL, even in an LTR locale.

## 4 · Translation quality bar

A translation is **accepted** into the v1.1 seed if:

1. It has been reviewed by a native speaker of the target language.
2. It has been reviewed by a scholar of Islamic studies (for any religious content).
3. It has been proofread by a second translator.
4. It is consistent with the source English text in *meaning* (not necessarily in wording — translations can be looser).

The project will maintain a `TRANSLATIONS.md` file in `assets/translations/` documenting who reviewed each language.

## 5 · The schema impact

**None.** The seed content already has the three languages side-by-side. The UI strings are in `lib/l10n/*.arb` files, which are **outside the database**.

For new languages, the seed will gain additional columns (e.g. `Quran_Turkish`). The migration is **additive** — no existing columns are changed.

## 6 · The "add a language" workflow

To add a new language (e.g. Turkish):

1. Create `lib/l10n/app_tr.arb` with the translated UI strings.
2. Add `Quran_Turkish`, `Hadith_Turkish`, `Dua_Turkish` columns to `attributes` (nullable, additive migration).
3. Add a `Definition_Turkish` column to `attributes`.
4. Add `Description_Turkish` to `emotions`.
5. Populate the new columns with the translations.
6. Add the locale to `l10n.yaml`.
7. Test the app in `tr` locale.
8. Update the seed CI to validate the new translations.

## 7 · The "right to left" vs "right to left content" distinction

| Element | Direction |
|---|---|
| UI layout (buttons, lists, …) | Mirrors in RTL locales |
| Numerals (1, 2, 3, …) | Always LTR |
| Arabic Quran / Hadith / Duas | Always RTL (in any locale) |
| Urdu Quran / Hadith / Duas | Always RTL (in any locale) |
| English / Turkish / Indonesian content | LTR (in any locale) |
| The Nafs meter | Unchanged (left = Ammarah, right = Mutmainnah) |
| The Heart Graph | Unchanged (source → target) |

## 8 · The "language preference" setting

In Settings (`/settings`), the user picks:

- **App language** — affects UI strings only.
- **Scripture language** — affects which translation of Quran/Hadith/Dua is shown.

These can be **different**. A Pakistani user may want the UI in English but the Quran in Urdu.

## 9 · Why not all 3 languages at v1.0 launch

Three reasons:

1. **Translation quality** — getting *one* language right is hard; getting three is much harder.
2. **Testing surface** — every language adds a combinatorial explosion of test cases.
3. **Maintenance burden** — every new feature in v1.1+ must be translated into all shipped languages.

The v1.0 launch is **English-only** for the UI, with Arabic and Urdu **content** in the seed. v1.1 adds Arabic and Urdu UI.

## 10 · See also

- `../00_root/roadmap.md` §2 — the v1.1 plan.
- `../01_core_tables/attributes.md` §11 — the existing language support.
- `synchronization.md` — how language preferences sync across devices.
- `ai_layer.md` — the AI layer that may also become multilingual.
