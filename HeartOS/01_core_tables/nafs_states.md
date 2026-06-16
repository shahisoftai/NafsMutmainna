# `nafs_states` — The Four Stations of the Soul

> The Islamic classification of the soul's state, used as the **scoring spine** of the entire system. Every check-in moves the user along the spectrum from Ammarah to Mutmainnah.

---

## 1 · Purpose

`nafs_states` defines the **four canonical stations** of the soul in Islamic spirituality. The Nafs Meter (see `../00_root/scoring_engine.md`) is a probability distribution over these four states, computed from the user's recent check-ins, habits, and trend.

This table is **the smallest table in the system** (4 rows) and **the most important** — it is the only column that all the weight matrices and the meter agree on.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Nafs_ID` | INTEGER PK | 1–4 |
| `Name` | TEXT | English transliteration |
| `Arabic_Name` | TEXT | with diacritics |
| `Description` | TEXT | one paragraph |

## 3 · The four states

### 3.1 Ammarah (النفس الأمّارة بالسوء)

**The soul that commands evil.**

> "Indeed, the soul is a persistent enjoiner of evil — except those upon which my Lord has bestowed mercy." (Qur'an 12:53)

| Aspect | Description |
|---|---|
| **Description** | The base-desire-driven state. The self follows every whim; the whisper of Shaytan is louder than the whisper of faith. |
| **Dominant emotions** | Anger, jealousy, greed, hatred, lust, arrogance. |
| **Dominant attributes (negative)** | Kibr, Riya, Hasad, Ghadab, Hubb ad-Dunya, Tama. |
| **Dominant attributes (positive, dormant)** | Sabr (very low), Tawakkul (very low), Shukr (very low). |
| **Signs** | Impulsive acts, broken promises, no regret, no intention to change. |
| **Remedy** | Struggle (mujahadah), remembrance of death, accountability to a teacher. |
| **Nafs-weight role** | `attribute_nafs_weights` for disease attributes is heavily skewed toward Ammarah. |

### 3.2 Lawwamah (النفس اللوّامة)

**The self-reproaching soul.**

> "And I swear by the self-reproaching soul." (Qur'an 75:2)

| Aspect | Description |
|---|---|
| **Description** | The believer's *normal* state. The self commits sin, then immediately feels guilt. The conscience is active and loud. |
| **Dominant emotions** | Anxiety, regret, fear (of punishment), shame, hope. |
| **Dominant attributes (negative, active)** | Dhann (suspicion), Waswasa, Khawf, Huzn. |
| **Dominant attributes (positive, growing)** | Tawbah, Inabah, Raja, Sabr. |
| **Signs** | Frequent istighfar, sincere regret, oscillations between hope and fear. |
| **Remedy** | Sustained dhikr, consistent salah, study of the Quran, a practicing community. |
| **Nafs-weight role** | Most attributes' "middle ground" — disease attributes still pull here, but so do awakening virtues. |
| **System role** | **Default starting state for a new user.** |

### 3.3 Mulhamah (النفس الملهمة)

**The inspired soul.**

> "And [by] the soul at rest and proportioned — then He inspired it [to know] its wickedness and its righteousness." (Qur'an 91:7–8, paraphrased)

| Aspect | Description |
|---|---|
| **Description** | The soul that has been *inspired* to distinguish good from evil. It receives ilham from Allah. It is rare and precious. |
| **Dominant emotions** | Hope, gratitude, contentment, longing, insight. |
| **Dominant attributes (positive, dominant)** | Tawakkul, Shukr, Ikhlas, Tawadu, Muraqabah, Yaqeen. |
| **Dominant attributes (negative, residual)** | Waswasa (low), Dhann (low). |
| **Signs** | Stable salah, consistent dhikr, absence of major sins, ease in giving advice. |
| **Remedy** | Continued dhikr, service to creation, sincere du'a. |
| **Nafs-weight role** | Positive attributes skew here; only a few negative attributes reach this state. |

### 3.4 Mutmainnah (النفس المطمئنة)

**The tranquil soul.**

> "O soul at peace, return to your Lord, well-pleased and well-pleasing to Him. Enter among My servants. Enter My Paradise." (Qur'an 89:27–30)

| Aspect | Description |
|---|---|
| **Description** | The highest station attainable in this life. The soul is at peace with Allah, with His decree, and with His creation. It is the state of the Siddiqin. |
| **Dominant emotions** | Tranquility, deep gratitude, love, serenity, certainty. |
| **Dominant attributes (positive, total)** | Sabr, Shukr, Tawakkul, Ikhlas, Mahabbah, Muraqabah, Yaqeen, Ridha, Tawadu, Hilm. |
| **Dominant attributes (negative)** | None of significance. |
| **Signs** | No complaint against Allah's decree, no attachment to the dunya, constant dhikr, radiant face. |
| **Remedy** | None — it is the goal itself. Sustained by the constant remembrance of death. |
| **Nafs-weight role** | The "perfect" target. Most positive attributes are heavily weighted here; no negative attribute reaches Mutmainnah. |

## 4 · Visualisation on the Nafs Meter

```
   Ammarah   Lawwamah   Mulhamah   Mutmainnah
       │         │          │            │
       ▼         ▼          ▼            ▼
   ░░░░░░░   ████████   ████░░░░    ██░░░░░░
   (red)     (amber)     (blue)      (green)
       │         │          │            │
       │         │          │            │
   base        default     inspired     tranquil
   desires     conscience  ilham        at peace
```

A user is always a **mix** of all four; the dominant one is shown in saturated colour.

## 5 · Relationships

`nafs_states` is referenced by **every** weight matrix in the system:

| Table | Column | Role |
|---|---|---|
| `attribute_nafs_weights` | `Ammarah`, `Lawwamah`, `Mulhamah`, `Mutmainnah` | the 4-vector of biases for an attribute |
| `emotion_nafs_weights` | same | the 4-vector of biases for an emotion |
| `nafs_history` | same | the 4-vector recorded for the day |

`nafs_states` does **not** itself have any link tables — it is a *lookup* table whose only purpose is to be a foreign-key target for the four columns.

## 6 · Why exactly 4?

| Count | Verdict |
|---|---|
| 2 | Too coarse — Iman/Kufr doesn't capture the journey. |
| 3 | Drops the "Lawwamah" middle — the most important state for a new user. |
| **4** | ✅ Canonical — these are the four stations named in the Quran and the Sirat al-Mustaqim. |
| 5+ | Splits hairs (e.g. separating "inspired" from "tranquil" breaks the Islamic taxonomy). |

The four states also map cleanly onto:
- **Spiritual growth** — beginner to advanced.
- **Self-awareness** — denying, blaming, accepting, surrendering.
- **Practical goals** — compliance, struggle, insight, peace.

## 7 · Transitions

Transitions between states are **not discrete**. The Nafs Meter shows percentages, and a user might be:
- *30% Ammarah, 55% Lawwamah, 12% Mulhamah, 3% Mutmainnah* — typical new user
- *5% Ammarah, 25% Lawwamah, 50% Mulhamah, 20% Mutmainnah* — practicing user
- *2% Ammarah, 8% Lawwamah, 35% Mulhamah, 55% Mutmainnah* — rare, advanced

A user "transitions" when the dominant state changes for **7 consecutive days** (to avoid a single bad day knocking them back).

## 8 · Implementation notes

- `Nafs_ID` 1 = Ammarah, 2 = Lawwamah, 3 = Mulhamah, 4 = Mutmainnah. This ordering is also the **canonical ordering on the meter** (left to right).
- The Arabic name uses full diacritics; the Arabic locale shows the Arabic name; other locales show the English name with the Arabic name as a secondary line.
- The Description field is rendered as a 1-paragraph "About this station" section on the Home screen when the user taps the meter.
- A new user starts with the **Lawwamah baseline**: (0.10, 0.60, 0.20, 0.10). The system treats this as "default conscience-active" rather than zero, because Lawwamah is the *believer's* normal state.

## 9 · File outputs

- The full descriptions of the four states are in this file.
- The weight matrices are described in `../03_nafs_engine/attribute_nafs_weights.md` and `../03_nafs_engine/emotion_nafs_weights.md`.
- The algorithm that produces the meter is in `../03_nafs_engine/nafs_meter_algorithm.md` and `../08_algorithms/scoring_algorithm.md`.
