# Recommendation Algorithm

> The offline, graph-based algorithm that takes a check-in and produces the 6 (or fewer) intervention cards shown on the Intervention screen.

> ⚠️ **PROPOSAL — subject to tuning.** The constants below are the v1 proposal. They are hard-coded in `lib/src/domain/usecases/recommendations/recommend.dart` and can be adjusted without a database migration.

---

## 1 · Goals

The algorithm must:

1. **Be explainable** — every card must have a "why" (which emotion, which attribute, which link).
2. **Be deterministic** — the same check-in must produce the same cards.
3. **Be diverse** — no card should repeat within 7 days.
4. **Be ranked** — the most relevant card first.
5. **Be fast** — under 50 ms end-to-end.

## 2 · Input

- `checkin` — the current `checkins` row.
- `recent_interventions` — the last 7 days of `interventions_history`.
- The **immutable** Knowledge, Graph, and Nafs tables.

## 3 · Output

A list of up to **6 cards**, each with:

```python
@dataclass
class Card:
    type: str          # "Quran" | "Hadith" | "Dua" | "Allah_Names" | "Dhikr" | "Action"
    content: str       # the Arabic text
    reference: str     # e.g. "Surah Al-Ma'un 107:4-6" or "Sahih Muslim 91"
    translations: dict # {"en": ..., "ur": ...}
    why: str           # human-readable explanation
    source_attr_id: int
    source_emotion_id: int
```

## 4 · Algorithm

### 4.1 Step 1 — Resolve the emotion

```python
emotion = sql.get("emotions", id=checkin.Emotion_ID)
```

### 4.2 Step 2 — Find the top 3 detected attributes

```python
links = sql.query("""
    SELECT Attribute_ID, Weight, Role
    FROM emotion_attribute_links
    WHERE Emotion_ID = ? AND Role IN ('Treatment', 'Core')
    ORDER BY Weight DESC
    LIMIT 3
""", checkin.Emotion_ID)
```

The query restricts to `Treatment` and `Core` roles — we want to *recommend remedies*, not surface diseases (those are shown on the Insight screen, not the Intervention screen).

### 4.3 Step 3 — For each attribute, build candidate cards

```python
candidates = []
for link in links:
    attr = sql.get("attributes", id=link.Attribute_ID)
    intensity_mult = checkin.Intensity / 10.0
    score = link.Weight * intensity_mult
    candidates.extend(build_cards(attr, emotion, score))
```

The `build_cards` function produces 4 cards per attribute (Quran, Hadith, Dua, Names):

```python
def build_cards(attr, emotion, score):
    cards = []
    if attr.Quran_Reference:
        cards.append(Card(
            type="Quran",
            content=attr.Quran_Arabic,
            reference=attr.Quran_Reference,
            translations={"en": attr.Quran_English, "ur": attr.Quran_Urdu},
            why=f"Surfaces {attr.Attribute} (recommended for {emotion.Core_Emotion})",
            source_attr_id=attr.ID,
            source_emotion_id=emotion.ID,
        ))
    if attr.Hadith_Reference:
        cards.append(Card(
            type="Hadith",
            content=attr.Hadith_Arabic,
            reference=attr.Hadith_Reference,
            translations={"en": "", "ur": attr.Hadith_Urdu},
            why=f"Practical guidance for {attr.Attribute}",
            source_attr_id=attr.ID,
            source_emotion_id=emotion.ID,
        ))
    if attr.Prophetic_Dua_Reference:
        cards.append(Card(
            type="Dua",
            content=attr.Prophetic_Dua_Arabic,
            reference=attr.Prophetic_Dua_Reference,
            translations={"en": "", "ur": attr.Prophetic_Dua_Urdu},
            why=f"A dua for {attr.Attribute}",
            source_attr_id=attr.ID,
            source_emotion_id=emotion.ID,
        ))
    if attr.Relevant_Allah_Names:
        cards.append(Card(
            type="Allah_Names",
            content=attr.Relevant_Allah_Names,
            reference="",
            translations={},
            why=f"Reflect on these names to cultivate {attr.Attribute}",
            source_attr_id=attr.ID,
            source_emotion_id=emotion.ID,
        ))
    return cards
```

### 4.4 Step 4 — Add the emotion-level cards (Dhikr, Action)

```python
candidates.append(Card(
    type="Dhikr",
    content=emotion.Recommended_Dhikr,
    reference="",
    translations={},
    why=f"Recommended dhikr for {emotion.Core_Emotion}",
    source_attr_id=0,
    source_emotion_id=emotion.ID,
))
candidates.append(Card(
    type="Action",
    content=emotion.Daily_Action,
    reference="",
    translations={},
    why=f"A Prophetic action for {emotion.Core_Emotion}",
    source_attr_id=0,
    source_emotion_id=emotion.ID,
))
```

### 4.5 Step 5 — Apply the 7-day no-repeat filter

```python
shown_recently = sql.query("""
    SELECT Intervention_Type, Attribute_ID, Emotion_ID
    FROM interventions_history
    WHERE Date >= date('now', '-7 day')
""")
shown_set = {(r.Intervention_Type, r.Attribute_ID, r.Emotion_ID) for r in shown_recently}

candidates = [
    c for c in candidates
    if (c.type, c.source_attr_id, c.source_emotion_id) not in shown_set
]
```

### 4.6 Step 6 — Rank

```python
def rank(card):
    anw = sql.get("attribute_nafs_weights", id=card.source_attr_id) or DEFAULT
    return (
        0.6 * (card.score or 0.5)              # attribute score
        + 0.3 * (checkin.Intensity / 10.0)      # intensity
        + 0.1 * (anw.Mutmainnah / 100.0)        # virtue bias
    )

candidates.sort(key=rank, reverse=True)
```

### 4.7 Step 7 — Take top 6

```python
return candidates[:6]
```

## 5 · Edge cases

| Situation | Handled how |
|---|---|
| No check-in (impossible — recommendation is triggered by a check-in) | Return empty list. |
| Emotion has no `Treatment` or `Core` links | Return empty list (seed quality bar prevents this). |
| All candidates are filtered by 7-day rule | Show a "Come back tomorrow for new suggestions" card. |
| Some attributes have no Quran/Hadith/Dua fields | Skip those card types silently. |
| The user has logged the same emotion 5 days in a row | Different cards each time (the seed has multiple options per attribute). |
| attributeId = 0 (Dhikr / Action emotion-level cards) | Ranked by `0.6 × score + 0.3 × intensity`; no Nafs bias lookup. |

## 6 · Performance

| Step | Time |
|---|---|
| Step 1: resolve emotion | < 1 ms (in-memory cache) |
| Step 2: top 3 attributes | < 5 ms (indexed) |
| Step 3: build candidates | < 5 ms |
| Step 4: add emotion cards | < 1 ms |
| Step 5: filter | < 5 ms (indexed) |
| Step 6: rank | < 1 ms (in-memory) |
| Step 7: take top 6 | < 1 ms |
| **Total** | **< 20 ms** |

## 7 · Unit tests

The algorithm is **fully unit-testable** — no IO, no clock, no network. The test cases:

1. **Anger at intensity 7** → 6 cards: Quran, Hadith, Dua, Names, Dhikr, Action.
2. **Anxiety at intensity 5** → 6 cards for Tawakkul / Yaqeen / Sakinah.
3. **Gratitude at intensity 8** → 1–3 cards (positive emotions have fewer links).
4. **All candidates filtered** → "come back tomorrow" card.
5. **Same emotion on consecutive days** → different cards each day.

## 8 · Why this algorithm

| Alternative | Why rejected |
|---|---|
| LLM-generated cards | Latency, cost, network, non-deterministic, not authoritative. |
| Random selection | No explainability. |
| Time-of-day based | Doesn't reflect the user's actual state. |
| User-history only (no graph) | Doesn't introduce new content; user gets stuck in a loop. |

The chosen algorithm is **graph-first, deterministic, explainable, fast, and offline**.

## 9 · Tunable constants

| Constant | Value | Location |
|---|---|---|
| Max attributes per recommendation | 3 | `recommend.dart` |
| Max cards per check-in | 6 | `recommend.dart` |
| No-repeat window | 7 days | `recommend.dart` |
| Score weight | 0.6 | `recommend.dart` |
| Intensity weight | 0.3 | `recommend.dart` |
| Nafs bias weight | 0.1 | `recommend.dart` |

## 10 · See also

- `../03_nafs_engine/nafs_meter_algorithm.md` — the scoring side.
- `../02_relationships/emotion_attribute_links.md` — the source of attributes.
- `../01_core_tables/attributes.md` — the intervention content.
- `../01_core_tables/emotions.md` — the Dhikr + Action.
- `../06_diagrams/recommendation_engine_diagram.md` — the visual.
- `../00_root/heart_graph.md` — the graph that powers the recommendations.
