# AI Layer (v2) — Future

> The optional AI companion that will be added in v2. **It is not in v1** and the system is designed to work fully without it. This file documents what the AI layer *will* do and, just as importantly, what it will *not* do.

---

## 1 · Why an AI layer at all?

The graph-based recommendation engine (see `../00_root/heart_graph.md` and `../08_algorithms/recommendation_algorithm.md`) is **deterministic and explainable** but also **rigid**. It always recommends the same 6 cards for the same check-in. Over months of use, a user may feel they have "seen it all".

An AI layer can add:

- **Personalised reflections** — a weekly note from the AI summarising the user's journey.
- **Varied phrasing** — the same Quran verse explained differently each time.
- **Cross-tradition insights** — references to scholarly works the seed does not include.
- **Conversational Q&A** — the user asks "why do I keep getting angry?" and the AI responds.

These are **additive** — the graph still produces the canonical recommendations.

## 2 · What the AI layer will NOT do

To preserve the integrity of Heart OS:

- ❌ **Will not generate the recommendations themselves.** The graph is canonical. The AI can *comment* on a recommendation, not *replace* it.
- ❌ **Will not invent Quran verses or Hadith.** All scripture is fetched from the local seed. The AI can only reference, not generate.
- ❌ **Will not store user data on the cloud** without explicit opt-in.
- ❌ **Will not be used for advertising, profiling, or any non-spiritual purpose.**
- ❌ **Will not produce a "score" or "rank" of the user.** The Nafs meter is computed by the local algorithm, not the AI.
- ❌ **Will not replace the ulema.** The AI is a *companion*, not a *scholar*.

## 3 · The three AI features

### 3.1 Weekly reflection

A once-a-week (Sunday morning) note generated from the user's last 7 days:

```
   "This week you logged 5 check-ins. The most-detected attribute was
    'Weak Tawakkul', which surfaces when anxiety arises. You completed
    4 of 6 interventions. The Quran verse that was most surfaced was
    At-Talaq 65:3 — 'And whoever relies upon Allah — then He is
    sufficient for him.' Consider reciting it daily for the coming week."
```

This is **purely a reflection** — no new recommendations, no new actions. It is generated locally by the AI service.

### 3.2 Phrase variation

When a Quran verse is shown for the 5th time, the AI can offer a *different translation* or a *brief commentary excerpt* from a curated offline tafsir pack. The verse itself is unchanged — only the surrounding prose varies.

### 3.3 Conversational Q&A (v2.1)

The user can ask the AI:

- *"Why is Kibr so dangerous?"*
- *"What is the difference between Hasad and Ghibtah?"*
- *"How do I cultivate Sabr when I have none?"*

The AI responds using the local seed as its knowledge base. It **never** draws on external training data — it is a fine-tuned model on the Islamic content, with retrieval over the local seed.

## 4 · Privacy & data

The AI layer has **two modes**:

| Mode | Where the AI runs | Where data lives |
|---|---|---|
| **Local mode** | On-device (e.g. llama.cpp with a 3B model) | All on device. No network. |
| **Cloud mode** | On a server (v2.1+) | Data sent only with explicit opt-in. End-to-end encrypted. |

In v1.0, **only local mode** is shipped — and only if the device can run the model. Otherwise, the AI layer is simply not available.

## 5 · The architecture of the AI layer

```
   ┌─────────────────────────────────────────────┐
   │  Heart OS v2 (graph engine + UI)            │
   │                                             │
   │  ┌─────────────────────────────────────┐    │
   │  │  AI Companion (optional, v2)        │    │
   │  │  ┌────────────┐  ┌────────────┐     │    │
   │  │  │ Reflection │  │   Phrase   │     │    │
   │  │  │ Generator  │  │  Variator  │     │    │
   │  │  └────────────┘  └────────────┘     │    │
   │  │  ┌────────────────────────────┐     │    │
   │  │  │  Q&A Engine (v2.1)         │     │    │
   │  │  │  - Retrieval over seed     │     │    │
   │  │  │  - Fine-tuned on Islamic    │     │    │
   │  │  │    content                 │     │    │
   │  │  └────────────────────────────┘     │    │
   │  └─────────────────────────────────────┘    │
   │                  │                          │
   │                  ▼                          │
   │  ┌─────────────────────────────────────┐    │
   │  │  Local LLM (llama.cpp / ML Kit)    │    │
   │  │  OR Cloud endpoint (opt-in)        │    │
   │  └─────────────────────────────────────┘    │
   └─────────────────────────────────────────────┘
```

The graph engine is **downstream** of the AI layer, not the other way around. The AI layer feeds into the UI, but the graph engine's recommendations are unaffected.

## 6 · The model card

When the v2 AI layer ships, it must come with a **model card** that documents:

- Training data (the local seed only).
- Capabilities (reflection, phrase variation, Q&A).
- Limitations (cannot answer fiqh questions, cannot give fatwas).
- Safety filters (rejects questions about suicide, self-harm, haram content).
- Evaluation (tested against the 8 master pathways).

## 7 · Why local-first

The v2 AI layer is **local-first** for three reasons:

1. **Privacy** — the user's emotional data never leaves the device.
2. **Latency** — local inference is faster than cloud round-trips.
3. **Reliability** — the AI works even without a network.

Cloud mode is an **opt-in** feature for users who want a more capable model.

## 8 · Open questions (TBD)

- Which base model? (Candidate: a 3B parameter model fine-tuned on the seed.)
- How to evaluate the AI's reflections? (Human review by a scholar advisory board.)
- Should the AI have a *persona*? (Probably not — the AI should not pretend to be a scholar.)
- Should the AI's outputs be *reproducible*? (Yes — same input → same output, ideally.)

## 9 · What the AI layer means for the existing schema

**Nothing changes.** The 14 core tables are sufficient. The AI layer is a **consumer** of the schema, not a producer. It reads from `checkins`, `detected_attributes`, `nafs_history` and writes nothing.

In v2.1, a new table may be added:

- `ai_reflections` — stores the generated reflections so they can be re-read.

This is **additive** and does not affect the 14 core tables.

## 10 · See also

- `../00_root/roadmap.md` §4 — the v2.0 roadmap.
- `analytics.md` — the analytics dashboard (v2).
- `synchronization.md` — the cloud sync layer (v2.1).
- `multilingual_support.md` — the i18n layer (v1.1).
- `../00_root/architecture.md` — the four-layer model that the AI layer slots into.
