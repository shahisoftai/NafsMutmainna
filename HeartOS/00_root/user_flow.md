# Heart OS — User Flow

> The user's journey, from opening the app to seeing their Nafs meter move.

This document is the **user-facing** counterpart to `architecture.md`. It describes what the user actually sees, taps, and feels — independent of the internal data model.

---

## 1 · Five-screen core loop

```
   ┌────────────────────────────────────────────┐
   │                                            │
   │           ┌──────────────────┐             │
   │           │   1 · HOME       │             │
   │           │   (Nafs meter)   │             │
   │           └────────┬─────────┘             │
   │                    │                       │
   │                    ▼                       │
   │           ┌──────────────────┐             │
   │           │ 2 · CHECK-IN     │             │
   │           │ (emotion picker) │             │
   │           └────────┬─────────┘             │
   │                    │                       │
   │                    ▼                       │
   │           ┌──────────────────┐             │
   │           │ 3 · INSIGHT      │             │
   │           │ (attributes +    │             │
   │           │  growth path)    │             │
   │           └────────┬─────────┘             │
   │                    │                       │
   │                    ▼                       │
   │           ┌──────────────────┐             │
   │           │ 4 · INTERVENTION │             │
   │           │ (Quran, Hadith,  │             │
   │           │  Dua, Action)    │             │
   │           └────────┬─────────┘             │
   │                    │                       │
   │                    ▼                       │
   │           ┌──────────────────┐             │
   │           │ 5 · REFLECT      │             │
   │           │ (Better / Same / │──┐          │
   │           │  Worse)          │  │          │
   │           └──────────────────┘  │          │
   │                                 │          │
   │                                 ▼          │
   │                    back to HOME (meter)    │
   │                                            │
   └────────────────────────────────────────────┘
```

This loop is the **spine** of the app. Everything else (habits, pathways, analytics) is secondary navigation off the HOME screen.

---

## 2 · Detailed walkthrough

### 2.1 Home (`/`)
- **What the user sees**
  - The **Nafs Meter** — a 4-segment arc (Ammarah · Lawwamah · Mulhamah · Mutmainnah) shaded by the last 15 days.
  - A **streak counter** (consecutive days with a check-in).
  - A large **"How is your heart today?"** CTA.
  - Mini-cards for: today's habit progress, last intervention, domain spotlight.

- **What the user does**
  - Taps the CTA → goes to Check-in.
  - Or opens a habit / pathway / journal from the side menu.

### 2.2 Check-in (`/checkin`)
- **What the user sees**
  - A **flat list of 50 emotions**, each with an Arabic name and a small icon. Grouped by category (Negative / Positive).
  - A horizontal **intensity slider** (1–10) that appears after an emotion is tapped.
  - An optional **notes field** ("What happened?").

- **What the user does**
  - Picks one or more emotions (multiple allowed).
  - Adjusts intensity.
  - Optionally writes a note.
  - Taps **Continue** → goes to Insight.

### 2.3 Insight (`/insight`)
- **What the user sees**
  - **3–5 attributes** detected (the top-weighted from `emotion_attribute_links`).
  - For each, a short label + Arabic name + a one-line definition.
  - A **growth path** strip — the next 2–3 attributes in the Heart Graph that lead toward the remedy (e.g. Ghadab → Sabr → Hilm → Rifq).
  - A **domain badge** showing which macro-area is most affected (e.g. Character).

- **What the user does**
  - Taps any attribute to learn more.
  - Taps **Show me what to do** → goes to Intervention.

### 2.4 Intervention (`/intervention`)
- **What the user sees** (cards, vertically scrollable)
  - **Quran** — verse with reference, Arabic, English/Urdu translation.
  - **Hadith** — with source (Bukhari, Muslim, …).
  - **Dua** — short prophetic or Quranic supplication.
  - **Allah Names** — 1–3 names most relevant to the attribute.
  - **Dhikr** — a small set to recite (e.g. SubhanAllah 33×).
  - **Daily Action** — one concrete micro-task ("Remain silent and perform wudu").

- **What the user does**
  - Reads / recites.
  - Marks as **Done** (saved to `interventions_history`).
  - Taps **How did this make you feel?** → goes to Reflect.

### 2.5 Reflect (`/reflect`)
- **What the user sees**
  - Three large buttons: **Better · Same · Worse**.
  - A small text field: "What shifted?"

- **What the user does**
  - Picks one of the three.
  - Taps **Save** → returns to Home, where the Nafs meter has been updated by the algorithm in `08_algorithms/scoring_algorithm.md`.

---

## 3 · Secondary screens (off the home menu)

| Screen | Path | Purpose |
|---|---|---|
| Habits | `/habits` | Define & log daily habits (Fajr, Quran page, …). |
| Pathways | `/pathways` | Browse 8 master spiritual pathways and see your progress on each. |
| History | `/history` | 7-day / 15-day / 30-day charts of emotions, Nafs, habits. |
| Domains | `/domains` | Drill into a domain (Iman, Character, …) and see the strongest attributes. |
| Settings | `/settings` | Language, theme, reset, export, data deletion. |

---

## 4 · First-run experience

```
  Splash  →  Onboarding (7 swipable flash cards)
          →  Home
```

The onboarding is shown **once** on a fresh install. A Skip button on every card and a Get-Started button on the last card both close the flow and write the `hasSeenOnboarding` flag to the `prefs` Hive box. On every subsequent launch the splash routes straight to Home.

### 4.1 The 7 onboarding cards

| # | Headline | Core message |
|---|----------|-------------|
| 1 | Welcome to HeartOS | Privacy-first · offline · no account · no ads |
| 2 | Check In With Your Heart | 3-step daily check-in (emotion → intensity → note) under 60 seconds |
| 3 | See What Your Heart Reveals | 3–5 heart attributes detected per check-in · growth path through the Nafs |
| 4 | A Prescription Just for You | 6 intervention types (Quran · Hadith · Dua · Allah Names · Dhikr · Action) |
| 5 | Your Nafs Meter | 4 stations of the soul · daily check-in moves the needle |
| 6 | Your 15-Day Journey | Trend chart · Allah Names patterns · day-by-day breakdown |
| 7 | The 8 Master Pathways | Every struggle has a mapped path · example: Ghadab → Sabr → Hilm → Rifq → Rahmah |

Full implementation reference (visual design, persistence, state machine, file map) is in [`onboarding_flash_cards.md`](onboarding_flash_cards.md).

The seed check-in is **no longer required** as part of first run — the user lands on Home where the Nafs meter initialises at the Lawwamah baseline (50/30/15/5) if no history exists. The user can complete their first check-in at any time from the Home CTA.

---

## 5 · Edge cases

| Situation | Handled how |
|---|---|
| User misses a day | Streak resets; Nafs meter rolls the missing day out of the 15-day window. |
| User logs the same emotion 7 days in a row | Algorithm detects the pattern; a Pathway suggestion is offered on Home. |
| User logs no emotion (notes only) | Treated as a "neutral" check-in; intensity = 0; no attribute weights applied. |
| Offline | Everything works — see `architecture.md` §1. |
| User clears app data | On next launch, all 14 tables are re-seeded; user tables are empty. |

---

## 6 · Where the user flow maps to data

| Screen | Tables read | Tables written |
|---|---|---|
| Home | `nafs_history` (last 15) | — |
| Check-in | `emotions` | `checkins` |
| Insight | `emotions`, `attributes`, `emotion_attribute_links`, `attribute_links` | `detected_attributes` |
| Intervention | `attributes` (Quran/Hadith/Dua/Names) | `interventions_history` |
| Reflect | — | `nafs_history`, `interventions_history.Completed` |

This is the physical realisation of the four-layer model described in `architecture.md`.
