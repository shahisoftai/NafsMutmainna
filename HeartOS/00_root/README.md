# Heart OS v1

> An offline-first Islamic spiritual self-improvement platform built on a knowledge graph of **50 core emotions** and **200 heart attributes**.

Heart OS is a Flutter + SQLite application that helps Muslims diagnose the state of their heart (qalb) through a daily check-in, maps feelings onto a directed graph of spiritual attributes, traverses a growth path, and recommends **Quran · Hadith · Dua · Dhikr · Action** interventions — all without requiring an internet connection or an AI service.

---

## What is in this folder?

This `HeartOS/` directory is the **authoritative source-code documentation** of the Heart OS v1 architecture. It is organised in nine numbered sections:

```
HeartOS/
├── 00_root/             ← You are here. Top-level overview.
│   ├── README.md
│   ├── architecture.md
│   ├── user_flow.md
│   ├── erd.md
│   ├── heart_graph.md
│   ├── scoring_engine.md
│   └── roadmap.md
│
├── 01_core_tables/      ← 4 foundational tables (attributes, emotions, domains, nafs_states)
├── 02_relationships/    ← 4 link tables that wire the graph together
├── 03_nafs_engine/      ← Nafs weight matrices + meter algorithm
├── 04_user_tables/      ← 6 user-activity tables (checkins, history, habits, …)
├── 05_pathways/         ← 8 master pathways (e.g. Anger → Mercy)
├── 06_diagrams/         ← Markdown renderings of all system diagrams
├── 07_appendices/       ← Full lists (50 emotions, 200 attributes, 10 domains, …)
├── 08_algorithms/       ← Recommendation, scoring, trend, severity formulas
└── 09_future/           ← AI layer, analytics, i18n, sync (deferred)
```

---

## The 30-second summary

| | |
|---|---|
| **Platform** | Flutter 3.24+ (Android, iOS, Web) |
| **Storage** | SQLite (offline-first) |
| **Content** | 50 emotions · 200 attributes · 10 domains · 4 Nafs states |
| **Schema** | 14 core tables (+ 3 optional) |
| **Engine** | Graph-based recommendation (no AI required) |
| **Languages** | English (seed) · Urdu (planned) · Arabic (planned) |
| **License** | TBD |

The system is intentionally **small, dense, and offline-first**. It does not require any cloud service, large-language model, or network call to function. An AI companion can be added later as a non-essential layer.

---

## Start here

1. **[architecture.md](./00_root/architecture.md)** — the four-layer model (Knowledge → Graph → Nafs → User) and how data flows through it.
2. **[user_flow.md](./00_root/user_flow.md)** — what a user actually experiences, step by step.
3. **[erd.md](./00_root/erd.md)** — the entity-relationship diagram of the 14 core tables.
4. **[heart_graph.md](./00_root/heart_graph.md)** — the directed graph that powers the growth paths.
5. **[scoring_engine.md](./00_root/scoring_engine.md)** — how the Nafs meter is computed from check-ins.
6. **[roadmap.md](./00_root/roadmap.md)** — what is in v1, what is deferred, what is aspirational.

For an interactive HTML rendering of the same architecture, see [`../docs/HEART_OS_ARCHITECTURE.html`](../docs/HEART_OS_ARCHITECTURE.html).

---

## Core design principles

1. **Offline-first.** Every feature works without a network. The 50 emotions, 200 attributes, Quranic verses, and Hadith references are shipped in the binary.
2. **Graph over AI.** Recommendations come from traversing `attribute_links` and `emotion_attribute_links` — deterministic, explainable, fast.
3. **Small surface area.** 14 tables. ~50 markdown files. No microservices, no event bus, no ML pipeline.
4. **Deterministic Nafs meter.** The score is a function of the last 15 days of check-ins — reproducible and testable.
5. **Privacy by design.** All user data is local. The optional cloud sync (see `09_future/synchronization.md`) is opt-in.

---

## Data sources

The seed content in this documentation was extracted from the following project files:

| File | Contents | Rows |
|---|---|---|
| `../50-cores.xlsx` | 50 core emotions | 50 |
| `../200-Attributes.xlsx` | 200 heart attributes with Quran/Hadith/Allah Names | 200 |
| `../Attributes-database.ods` | Mirror copy of `200-Attributes.xlsx` | 200 |
| `../NafsMutmainna-200-Attributes.docx` | Narrative guide to the 200 attributes, grouped by 5 macro-domains | 1 414 lines |

The appendices in `07_appendices/` reproduce the structured data from these files.

---

## Status

| Phase | Status |
|---|---|
| Architecture design | **Complete** (this folder) |
| Schema (DDL) | Designed, not yet migrated |
| Seed data | Available in xlsx/ods; needs to be loaded into SQLite |
| Flutter implementation | Phase 5 of `../memory-bank/flutter-implementation-plan-comprehensive.md` |
| AI companion | Deferred to v2 |

---

*Heart OS v1 — "A heart at rest is better than a heart that knows."*
