# HeartOS — Operational Flow

> The day-to-day operating flow of the NafsMutmainna app, end-to-end.
> This is the **user-facing** counterpart to the architecture docs. It is the single source of truth for "what does the app actually do, in what order, and why".
> **Generated:** 2026-06-13

---

## 1 · The Core Loop (one cycle)

```
Open App
    ↓
How do you feel?
    ↓
Select Emotion(s)
    ↓
Heart Analysis
    ↓
Personal Prescription
    ↓
Take Action
    ↓
How do you feel now?
    ↓
Save Progress
    ↓
Update Nafs Meter
```

In reality, the whole app is just:

```
Emotion
    ↓
Attribute
    ↓
Prescription
    ↓
Action
    ↓
Feedback
    ↓
Nafs
```

Everything else is secondary. This simplicity will make the app **useful rather than overwhelming**.

---

## 2 · Screen-by-Screen Walkthrough

### 2.1 Home Screen

**Very simple.**

Shows:

- **Today's Nafs Meter** — the 4-segment arc (Ammarah · Lawwamah · Mulhamah · Mutmainnah) shaded by the last 15 days.
- **Heart Health Score** — a single 0–100 number derived from the 15-day meter.
- **Last check-in time** — when did the user last log an emotion?

Buttons:

- **Check In** (primary CTA)
- **History**
- **Heart Graph**
- **Settings**

Typical session starts here. The user lands, sees the meter, taps **Check In**.

---

### 2.2 Check-In

User selects:

- **Primary emotion** (required) — e.g. *Anxiety*
- **Secondary emotion** (optional) — e.g. *Fear*
- **Intensity** (1–10, optional, default 5)
- **Notes** (optional free text, max 500 chars)

Example:

```
Primary:   Anxiety
Secondary: Fear
Intensity: 7
```

**Stored in:** `checkins` table.

After tapping **Continue**, the system performs the following in one synchronous transaction (target < 500 ms):

1. INSERT into `checkins` (one row per emotion selected).
2. The `trg_checkin_insert` SQLite trigger fires and INSERTs into `detected_attributes` (one row per `emotion_attribute_links` match, weighted by `intensity / 10`).
3. The recommendation engine is called to build 6 cards.
4. The daily Nafs algorithm is run, and the result is UPSERTed into `nafs_history`.
5. The screen transitions to the **Heart Analysis** screen.

---

### 2.3 Heart Analysis (Insight)

Using `emotion_attribute_links`, the system finds:

- **Negative attributes** (what the user is struggling with)
- **Positive attributes** (what the user should cultivate)
- **Priority attribute** (the single most important one)

Example:

```
Emotion:              Anxiety
Underlying disease:   Weak Tawakkul
Strength to develop:  Tawakkul
Growth path:          Weak Tawakkul → Tawakkul → Yaqeen → Sakinah
Domain badge:          Sabr & Tawakkul
```

The screen shows:

- The **top 3–5 detected attributes** (the top-weighted from `emotion_attribute_links`).
- For each: a short label + Arabic name + a one-line definition.
- A **growth path strip** — the next 2–3 attributes in the Heart Graph that lead toward the remedy.
- A **domain badge** showing which macro-area is most affected.

**Stored in:** `detected_attributes` table (via the trigger).

The user can:
- Tap any attribute to learn more.
- Tap **Show me what to do** → transitions to the **Personal Prescription** screen.

---

### 2.4 Personal Prescription (Intervention)

Using the `attributes` table, the system shows up to 6 cards:

1. **Quran** — verse with reference, Arabic, English/Urdu translation
2. **Hadith** — with source collection (Bukhari, Muslim, …)
3. **Dua** — short prophetic or Quranic supplication
4. **Allah Names** — 1–3 names most relevant to the attribute
5. **Dhikr** — a small set to recite
6. **Daily Action** — one concrete micro-task ("Remain silent and perform wudu")

**No searching required. Everything is offline.**

The user can:
- Read / recite.
- Mark a card as **Done** (saved to `interventions_history`).
- Tap **How did this make you feel?** → transitions to the **User Feedback** screen.

---

### 2.5 User Feedback (Reflect)

Question:

> **How do you feel now?**

Options:

- **Much better**
- **Better**
- **Same**
- **Worse**

**Saved into:** `interventions_history` (the `Completed` flag and an implicit feedback delta).

After the user taps **Save**, the system returns to the Home screen, where the Nafs meter has been updated by the algorithm.

---

### 2.6 Update Nafs Meter

Using:

- Current emotions (from today's `checkins`)
- Detected attributes (from today's `detected_attributes`)
- Previous 15 days (`nafs_history` rows from D-14 to D-0)

Calculate:

- **Ammarah**
- **Lawwamah**
- **Mulhamah**
- **Mutmainnah**

The full algorithm is `0.50 × AttributeScore + 0.20 × EmotionScore + 0.20 × HabitScore + 0.10 × TrendScore`.

**Stored in:** `nafs_history`.

---

### 2.7 Home Screen Updates

After the check-in, the user returns to Home. The screen now shows:

- **Dominant Nafs** — e.g. *Lawwamah*
- **Heart Health Score** — e.g. *76/100*
- **Main area for growth** — e.g. *Tawakkul* (the priority attribute)
- **Main strength** — e.g. *Sabr* (the strongest positive attribute detected)
- **Streak counter** — consecutive days with a check-in
- **Last check-in time** — just now

---

## 3 · Secondary Screens (off the home menu)

### 3.1 History Screen

Shows the last 7 days:

```
Emotions  →  Attributes  →  Nafs trend
```

A simple chart (line chart of the 4-vector over time, or stacked area).

**Nothing complicated.** The user wants to see their progress, not analyse it.

### 3.2 Heart Graph Screen

Shows only:

```
Current Emotion
    ↓
Current Attribute
    ↓
Growth Path
```

Example:

```
Anxiety
    ↓
Weak Tawakkul
    ↓
Tawakkul
    ↓
Yaqeen
    ↓
Sakinah
```

Or:

```
Anger
    ↓
Sabr
    ↓
Hilm
    ↓
Rifq
    ↓
Rahmah
```

The graph is **directed, finite, and finite-lookable** — never more than 4 hops.

---

## 4 · Daily Usage Pattern

A typical 30-second session:

```
Open App
    ↓
30-second check-in (pick emotion, intensity, optional note)
    ↓
Read Quran (1 verse)
    ↓
Read Hadith (1 hadith)
    ↓
Make Dua (1 short supplication)
    ↓
Perform Dhikr (1 set, e.g. SubhanAllah 33×)
    ↓
Take one action (e.g. perform wudu, step away for 5 minutes)
    ↓
Mark feedback (Much better / Better / Same / Worse)
    ↓
Done
```

The user has done something meaningful in **under 3 minutes** and their Nafs meter has been updated.

---

## 5 · First-Run Experience

```
Splash
    ↓
Onboarding (3 cards: Why? What? How?)
    ↓
Permission (notifications — opt-in)
    ↓
Optional seed check-in (or skip straight to Home)
    ↓
Home (with the Nafs meter initialised at Lawwamah baseline)
```

If the user skips the seed check-in, the meter defaults to:

```
Ammarah:     0.10
Lawwamah:    0.60
Mulhamah:    0.20
Mutmainnah:  0.10
```

This is the *believer's default* — conscience is active (Lawwamah dominant), with some Mulhamah (inspiration) and a small Mutmainnah (tranquility) seed.

---

## 6 · Edge Cases

| Situation | Handled how |
|---|---|
| User misses a day | Streak resets; Nafs meter rolls the missing day out of the 15-day window. |
| User logs the same emotion 7 days in a row | The system shows a Pathway suggestion on Home. |
| User logs no emotion (notes only) | Treated as a "neutral" check-in: `Emotion_ID = NULL`, `Intensity = 0`. |
| Offline | Everything works — the graph, the data, the scoring are all local. |
| User clears app data | On next launch, all 16 tables are re-seeded from the bundled JSON. |
| User installs on a new device | v1 is single-device only. Multi-device is deferred to v2 (opt-in cloud sync). |

---

## 7 · Where the User Flow Maps to Data

| Screen | Tables read | Tables written |
|---|---|---|
| **Home** | `nafs_history` (last 15), `attributes` (top 1 each for growth/strength), `checkins` (last time) | — |
| **Check-in** | `emotions` | `checkins` (via trigger → `detected_attributes`) |
| **Heart Analysis** | `emotions`, `attributes`, `emotion_attribute_links`, `attribute_links`, `domain_attribute_links` | `detected_attributes` (via trigger) |
| **Personal Prescription** | `attributes` (Quran/Hadith/Dua/Names), `emotions` (Dhikr/Action) | `interventions_history` |
| **User Feedback** | — | `interventions_history.Completed` |
| **Nafs update** | `checkins`, `detected_attributes`, `habit_logs`, `nafs_history` (14-day) | `nafs_history` |
| **History** | `checkins`, `detected_attributes`, `nafs_history` | — |
| **Heart Graph** | `attribute_links`, `emotion_attribute_links` | — |

This is the physical realisation of the four-layer model (Knowledge → Graph → Nafs → User) described in `00_root/architecture.md`.

---

## 8 · Performance Budget

The full loop (Check-in → Heart Analysis → Personal Prescription → Feedback → Home) must complete in:

| Step | Target | Notes |
|---|---|---|
| Check-in submit + trigger | < 100 ms | SQLite trigger fires synchronously |
| Heart Analysis render | < 50 ms | in-memory cache of `emotion_attribute_links` |
| Personal Prescription render | < 50 ms | 6 cards from in-memory cache |
| Feedback save + Nafs update | < 100 ms | one UPSERT into `nafs_history` |
| **Total round trip** | **< 300 ms** | comfortably under the 500 ms target |

The 15-day Home meter reads are also fast — under 30 ms per `nafs_meter_algorithm.md`.

---

## 9 · Why This Flow Works

1. **Linear, not branching** — the user goes Open → Log → Read → Act → Feedback → Done. No "what should I do?" paralysis.
2. **One emotion at a time** — the user picks *Anxiety* (and optionally *Fear*). The system does the rest.
3. **The app does the heavy lifting** — the user does not navigate the graph. The graph navigates the user.
4. **Feedback closes the loop** — the user sees their meter move. This is the dopamine that makes the habit stick.
5. **Nothing is hidden behind a menu** — the 5 core screens are visible from the Home. Settings, History, and Heart Graph are secondary.

---

## 10 · Cross-References

- `HeartOS/00_root/user_flow.md` — the prose version (less detailed).
- `HeartOS/00_root/architecture.md` — the four-layer model.
- `HeartOS/00_root/scoring_engine.md` — the Nafs meter conceptual walkthrough.
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — the formal daily Nafs algorithm.
- `HeartOS/08_algorithms/recommendation_algorithm.md` — the prescription engine.
- `HeartOS/08_algorithms/scoring_algorithm.md` — the full scoring pseudo-code.
- `HeartOS/05_pathways/master_pathways.md` — the 8 long-term pathways.
- `HeartOS/IMPLEMENTATION_PLAN.md` — the implementation roadmap.
