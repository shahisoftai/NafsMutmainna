# Heart OS — Roadmap

> What ships in v1, what is deferred, and what is on the longer horizon.

This roadmap is **deliberately small**. The system is intentionally a 14-table SQLite database plus a Flutter UI. Every item below is a meaningful commitment; adding a v1 feature costs at least one PR and one round of review.

---

## 1 · v1.0 (this release) — the offline core

| Area | Status |
|---|---|
| Knowledge layer (50 emotions · 200 attributes) | ✅ Designed & seeded |
| Graph layer (Heart Graph + domains) | ✅ Designed |
| Nafs engine (weights + meter) | ✅ Designed (formulas in **proposal** state, tuneable) |
| User layer (checkins, history, interventions, habits) | ✅ Designed |
| Flutter app — Home, Check-in, Insight, Intervention, Reflect | 🚧 In development (Phase 5 of the Flutter plan) |
| SQLite schema (Drift / sqflite) | 🚧 In development |
| English content | ✅ Seeded from `50-cores.xlsx` + `200-Attributes.xlsx` |
| 8 master pathways | ✅ Defined (see `05_pathways/`) |
| 1-day chart on Home | 🚧 In development |

### 1.1 Quality gates for v1.0

- [ ] All 14 tables migrated cleanly from a fresh install.
- [ ] A user can complete the 5-screen loop in <60 seconds.
- [ ] The Nafs meter advances after a 7-day positive streak.
- [ ] No network calls in the critical path.
- [ ] APK < 50 MB; cold start < 1.5 s on a Pixel 5.

---

## 2 · v1.1 (post-launch, ~2 months) — polish & languages

| Item | Notes |
|---|---|
| Arabic translation of UI | Use ARB files; reference Quran/Hadith already in Arabic in `attributes`. |
| Urdu translation of UI | Reference Quran/Hadith already in Urdu. |
| Push notifications | Fajr reminder + daily check-in nudge (opt-in, local notifications only). |
| Habit streaks & achievements | Lightweight gamification. |
| 7-day / 30-day charts | Built on `nafs_history` + `checkins`. |
| Export data as JSON | One-tap, no network. |

### 2.1 Quality gates for v1.1

- [ ] All three languages (en, ar, ur) cover 100% of UI strings.
- [ ] No analytics events leave the device.
- [ ] A user with no SIM card can complete the entire 5-screen loop.

---

## 3 · v1.2 (post-launch, ~4 months) — content expansion

| Item | Notes |
|---|---|
| Extend `attributes` to 300 (or 500) | New negative/positive pairs. |
| Add 10 more `domains` (20 total) | New macro-categories: Family, Health, Knowledge, Time, … |
| Add 8 more `master_pathways` | Cover Loneliness, Debt, Grief, Distraction, … |
| Per-attribute audio recitations | Optional, ~50 MB extra. |
| Tafsir excerpts for each Quran reference | 1–2 lines, pulled from a curated offline pack. |

---

## 4 · v2.0 (aspirational) — AI companion & sync

> None of this is in v1. All of it is **additive** — the four-layer model in `architecture.md` does not change.

| Item | Notes |
|---|---|
| **AI companion** | An optional, opt-in LLM layer that generates a personal weekly reflection. **Strictly not in the recommendation path** — the graph still produces the canonical suggestions. See `09_future/ai_layer.md`. |
| **Cloud sync** | Opt-in E2E-encrypted sync of `checkins`, `detected_attributes`, `nafs_history`. The knowledge and graph layers are bundled in the app — no need to sync. See `09_future/synchronization.md`. |
| **Multi-device** | After cloud sync, the same user can switch between phone and tablet. |
| **Family sharing** | A parent can opt to receive a weekly summary of a child's meter (with the child's consent). |
| **Community pathways** | A curated, moderated marketplace of community-authored pathways. |

### 4.1 What is **not** on the roadmap

- A social feed.
- Public profiles or leaderboards.
- An always-on microphone or biometric sensor.
- Crypto, NFTs, or any tokenised incentive.
- Ads of any kind.

The product is a **quiet companion**, not a social network. Anything that turns the journey into a performance is rejected.

---

## 5 · Decision log

| Date | Decision | Why |
|---|---|---|
| 2026-06 | 14 tables, not 25+ | Smaller surface, offline-first, easier to audit. |
| 2026-06 | Graph-based recs, not LLM | Determinism, explainability, no network. |
| 2026-06 | Nafs-meter weights = 50/20/20/10 (proposed) | Pending empirical tuning; constants live in DB, easy to adjust. |
| 2026-06 | Habits, pathways, goals are **deferred** | The 14 core tables cover v1; deferring keeps the schema stable. |
| 2026-06 | English-only at launch | Adding i18n later is a UI change, not a schema change. |

---

## 6 · How to propose a change

1. Open an issue with the tag `roadmap`.
2. Reference the file in `HeartOS/` that the change touches.
3. State: (a) what changes, (b) what stays the same, (c) what risk it adds.
4. If it is a schema change, it must be a **forward-compatible migration** (no dropping of columns or tables in v1+).
