# Analytics (v2) — Future

> The in-app analytics dashboard. Not in v1 — the v1 user sees only the Home meter, the streak card, and the 7-day history. v2 will add a full analytics screen.

---

## 1 · What v1 already shows

The v1 app surfaces **three** analytics artefacts:

1. **The Nafs Meter** — 4-vector on Home, weighted 15-day average.
2. **The streak card** — current positive streak on Home.
3. **The 7-day emotion history** — a simple bar chart on the History screen.

These are **summary statistics**, not analytics. v2 adds the *real* analytics.

## 2 · What v2 will add

### 2.1 The Analytics screen (`/analytics`)

A new screen with **5 sections**:

1. **Nafs over time** — 30 / 90 / 365-day chart with the 4 Nafs values stacked.
2. **Emotion frequency** — top 10 emotions logged, with their average intensity.
3. **Domain distribution** — pie chart of detected domains.
4. **Attribute heatmap** — calendar heatmap of the top 20 attributes.
5. **Habit completion** — bar chart of 7 / 30 / 90-day habit completion rates.

### 2.2 The "insights" card

A small card at the top of the Analytics screen that surfaces 1–3 auto-generated insights:

- *"You log Anxiety most often on Mondays."*
- *"Your Mulhamah score has improved 12% over the last 30 days."*
- *"You have not completed the Fajr habit 3 days this week."*

These are **rule-based insights** in v2.0. The AI layer (see `ai_layer.md`) will add **AI-generated insights** in v2.1.

## 3 · The 10 v2 metrics

| # | Metric | Source | Window |
|---|---|---|---|
| 1 | Nafs over time (4 lines) | `nafs_history` | 30/90/365 d |
| 2 | Top emotions | `checkins` + `emotions` | 30/90 d |
| 3 | Average intensity | `checkins` | 30/90 d |
| 4 | Domain distribution | `detected_attributes` + `domain_attribute_links` | 30/90 d |
| 5 | Top attributes | `detected_attributes` | 30/90 d |
| 6 | Streak history | `nafs_history` | 365 d |
| 7 | Habit completion | `habit_logs` | 7/30/90 d |
| 8 | Intervention completion | `interventions_history` | 30/90 d |
| 9 | Average severity | `checkins` + `emotions.Severity_Weight` | 30/90 d |
| 10 | Master pathway progress | `master_pathways` (deferred) | all-time |

## 4 · Privacy

All v2 analytics are computed **locally**. No data leaves the device. The user can:

- View their analytics.
- Export them as JSON (for personal backup).
- Delete them (which wipes the underlying tables).

The cloud sync layer (see `synchronization.md`) is **opt-in**. The user can use the analytics screen without ever enabling sync.

## 5 · The "share" feature (v2.1)

A user can choose to **share** a single analytics card (e.g. "My 30-day Nafs journey") as an image. The shared image is generated locally and contains **no identifying information** — no name, no email, no exact dates. It is a generic-looking infographic.

Sharing is **opt-in per card** — the user must tap "Share" explicitly.

## 6 · The "compare" feature (deferred)

In v3.0 (aspirational), the user can choose to compare their analytics with **anonymised, aggregated** data from other users:

- "Users your age who started 30 days ago have an average Mulhamah score of 0.32. Yours is 0.41."

This is **strictly opt-in**, **anonymised**, and **only aggregate** — no individual data ever leaves the device.

## 7 · Why analytics in v2, not v1

Three reasons:

1. **Focus.** v1 is about the *core loop* — check-in, insight, intervention, reflect. Analytics is a v2 feature.
2. **Performance.** The v1 Home screen must render in < 50 ms. Analytics queries are heavier and would slow the Home screen if combined.
3. **Stability.** The Nafs algorithm is proposed and subject to tuning. Showing analytics on top of an unstable algorithm would be confusing.

## 8 · Open questions (TBD)

- Should the Analytics screen be **opt-in** (the user must explicitly navigate to it) or always visible in the bottom nav?
- Should the user be able to **bookmark** a specific metric for the Home screen?
- Should there be a **monthly PDF report** the user can download?

## 9 · The schema impact

**None.** The Analytics screen reads from the existing 14 tables. No new tables are needed for v2.0 analytics.

For the AI-generated insights in v2.1, a new `insights` table may be added — but it is purely an output cache, not a source of truth.

## 10 · See also

- `../00_root/roadmap.md` §4 — the v2.0 roadmap.
- `ai_layer.md` — the AI insights that will complement the rule-based ones.
- `synchronization.md` — the cloud sync layer (v2.1).
- `../04_user_tables/nafs_history.md` — the source of the Nafs over time chart.
- `../04_user_tables/checkins.md` — the source of the emotion frequency.
- `../04_user_tables/detected_attributes.md` — the source of the domain distribution.
