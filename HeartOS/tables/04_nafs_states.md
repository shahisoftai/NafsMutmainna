# `nafs_states` — The Four Stations of the Soul

> The four canonical Islamic stations of the soul, used as the scoring spine of the Nafs Meter.
> **Source:** `HeartOS/01_core_tables/nafs_states.md`, `assets/seeds/nafs_states_seed.sample.json`
> **Quran anchors:** 12:53 (Ammarah) · 75:2 (Lawwamah) · 91:7-8 (Mulhamah) · 89:27-30 (Mutmainnah)

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Nafs_ID` | INTEGER PK | 1–4 |
| `Name` | TEXT | `Ammarah` · `Lawwamah` · `Mulhamah` · `Mutmainnah` |
| `Arabic_Name` | TEXT | with diacritics |
| `Description` | TEXT | one paragraph |

---

## Seed Data (4 rows)

### 1. Ammarah (النفس الأمّارة) — Nafs_ID 1

**The soul that commands evil.**

> "Indeed, the soul is a persistent enjoiner of evil — except those upon which my Lord has bestowed mercy." (Qur'an 12:53)

| Aspect | Description |
|---|---|
| Description | The base-desire-driven state. The self follows every whim; the whisper of Shaytan is louder than the whisper of faith. |
| Dominant emotions | Anger, jealousy, greed, hatred, lust, arrogance. |
| Dominant attributes (negative) | Kibr, Riya, Hasad, Ghadab, Hubb ad-Dunya, Tama. |
| Dominant attributes (positive, dormant) | Sabr (very low), Tawakkul (very low), Shukr (very low). |
| Signs | Impulsive acts, broken promises, no regret, no intention to change. |
| Remedy | Struggle (mujahadah), remembrance of death, accountability to a teacher. |

---

### 2. Lawwamah (النفس اللوّامة) — Nafs_ID 2

**The self-reproaching soul.**

> "And I swear by the self-reproaching soul." (Qur'an 75:2)

| Aspect | Description |
|---|---|
| Description | The believer's *normal* state. The self commits sin, then immediately feels guilt. The conscience is active and loud. |
| Dominant emotions | Anxiety, regret, fear (of punishment), shame, hope. |
| Dominant attributes (negative, active) | Dhann (suspicion), Waswasa, Khawf, Huzn. |
| Dominant attributes (positive, growing) | Tawbah, Inabah, Raja, Sabr. |
| Signs | Frequent istighfar, sincere regret, oscillations between hope and fear. |
| Remedy | Sustained dhikr, consistent salah, study of the Quran, a practicing community. |
| System role | **Default starting state for a new user.** |

---

### 3. Mulhamah (النفس الملهمة) — Nafs_ID 3

**The inspired soul.**

> "And [by] the soul at rest and proportioned — then He inspired it [to know] its wickedness and its righteousness." (Qur'an 91:7-8, paraphrased)

| Aspect | Description |
|---|---|
| Description | The soul that has been *inspired* to distinguish good from evil. It receives ilham from Allah. It is rare and precious. |
| Dominant emotions | Hope, gratitude, contentment, longing, insight. |
| Dominant attributes (positive, dominant) | Tawakkul, Shukr, Ikhlas, Tawadu, Muraqabah, Yaqeen. |
| Dominant attributes (negative, residual) | Waswasa (low), Dhann (low). |
| Signs | Stable salah, consistent dhikr, absence of major sins, ease in giving advice. |
| Remedy | Continued dhikr, service to creation, sincere du'a. |

---

### 4. Mutmainnah (النفس المطمئنة) — Nafs_ID 4

**The tranquil soul.**

> "O soul at peace, return to your Lord, well-pleased and well-pleasing to Him. Enter among My servants. Enter My Paradise." (Qur'an 89:27-30)

| Aspect | Description |
|---|---|
| Description | The highest station attainable in this life. The soul is at peace with Allah, with His decree, and with His creation. It is the state of the Siddiqin. |
| Dominant emotions | Tranquility, deep gratitude, love, serenity, certainty. |
| Dominant attributes (positive, total) | Sabr, Shukr, Tawakkul, Ikhlas, Mahabbah, Muraqabah, Yaqeen, Ridha, Tawadu, Hilm. |
| Dominant attributes (negative) | None of significance. |
| Signs | No complaint against Allah's decree, no attachment to the dunya, constant dhikr, radiant face. |
| Remedy | None — it is the goal itself. Sustained by the constant remembrance of death. |

---

## See also

- `HeartOS/01_core_tables/nafs_states.md` — full prose
- `HeartOS/03_nafs_engine/attribute_nafs_weights.md` — attribute 4-vectors
- `HeartOS/03_nafs_engine/emotion_nafs_weights.md` — emotion 4-vectors
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — the 50/20/20/10 blend
- `HeartOS/assets/seeds/nafs_states_seed.sample.json` — JSON seed (full data)
