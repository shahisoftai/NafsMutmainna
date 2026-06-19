# HeartOS — Scholar Audit Remediation Plan (Tazkiya Nafs v1.0)

> **Document type:** Implementation plan derived from the Scholar Audit Report (2026-06-19)
> **Scope:** Convert every finding from the audit into a concrete, classical-source-anchored change before user release
> **Authority:** Quran · Sahih/Hasan Hadith · Classical tazkiya corpus
> **Primary classical sources:**
> - Imam al-Ghazali — *Ihya' 'Ulum al-Din* (especially Books 3, 20–22, 31, 39 on the heart, *mujahadah*, *riya'*, *kibr*, *hasad*, *tawadu'*)
> - Ibn al-Qayyim al-Jawziyyah — *Madarij al-Salikin*, *Ighathat al-Lahfan*, *al-Tibb al-Ruhani*, *al-Ruh*
> - Abu Talib al-Makki — *Qut al-Qulub* (foundational tazkiya manual)
> - Imam al-Harith al-Muhasibi — *al-Ri'aya li-Huquq Allah* (foundation of *muhasabah*)
> - Ibn 'Ata' Allah al-Iskandari — *al-Hikam* (later Maliki tazkiya anchor)
> - 'Abd Allah al-Harari — *Tazkiyat al-Nafs* (modern summary aligned with classical athar)
> - Ibn Qudama al-Maqdisi — *Mukhtasar Minhaj al-Qasidin* (Hanbali tazkiya primer)
>
> **Goal:** Remove every ⚠️ flagged item; close every classical-completeness gap; lock the user-facing copy to a tazkiya-safe framing.

---

## 0 · How to use this document

Each finding from the audit (`HeartOS/AUDIT_REPORT.md` + Scholar Audit Report 2026-06-19) is recorded as a **Remediation Item (RI-#)** with:

- **Source** — which audit finding drives it
- **Severity** — Critical / High / Medium / Low
- **Classical anchor** — the Quran, Hadith, or classical text that justifies the fix
- **Action** — concrete change to make
- **Owner** — which layer / file
- **Done when** — acceptance check
- **Scholar sign-off required** — Yes / No

Every change must satisfy a single rule: **nothing enters the user-facing app that cannot be traced to a Quran verse, an authenticated Hadith, or a named classical tazkiya authority.**

---

## 1 · Framing principles (load-bearing)

These principles govern every RI below. Any RI that violates any of these is rejected.

### 1.1 The Nafs Meter is an *indicator of pattern*, not a judgment of the soul

> **Classical anchor:** "إِنَّ اللَّهَ لَا يُؤَاخِذُنِي عَلَى مَا فِي نَفْسِي" — the heart's realities belong to Allah alone; no app, no human, no algorithm may "judge" the state of a soul.
> Ghazali, *Ihya'* 3.13: the signs of the four states are *probable indicators*, not certainties.

**Action:** Every screen that shows the meter must carry the tazkiya-safe banner below (see RI-5.1).

### 1.2 Tazkiya is *practice-based*, not knowledge-based

> **Classical anchor:** "العمل علم" — Abu Bakr al-Siddiq (RA), cited in *Madarij al-Salikin* 1:147.
> Al-Muhasibi, *al-Ri'aya*: "Knowledge without action is a disease of the heart called *'ilman la yaanfa'*."

**Action:** The app must always surface a *concrete daily action* for every detected attribute, never stop at diagnosis. (Already implemented for emotions; see RI-5.4 for attributes.)

### 1.3 Three causes are always jointly at work: the *nafs*, *Shaytan*, and *al-hawa*

> **Classical anchor:** Quran 12:53 ("إِنَّ النَّفْسَ لَأَمَّارَةٌ بِالسُّوءِ إِلَّا مَا رَحِمَ رَبِّي"), Quran 114:4–6 (waswasa), Quran 45:23 ("أَفَرَأَيْتَ مَنِ اتَّخَذَ إِلَٰهَهُ هَوَاهُ").
> Ghazali, *Ihya'* 21: every marad al-qalb has a *nafsi*, *shaytani*, and *hawi* component.

**Action:** Add a `Cause_Type` field to attributes (see RI-3.1) so the Insight screen can whisper the third cause when a treatment is being recommended.

### 1.4 Self-knowledge requires a *muhasib* (self-accountant) — and ideally a *sheikh*

> **Classical anchor:** Hadith of the Prophet ﷺ on muhasabah: "حاسبوا أنفسكم قبل أن تحاسبوا" (Tirmidhi 2459, graded *hasan* by al-Albani).
> Al-Muhasibi named his foundational work *al-Ri'aya li-Huquq Allah* (Self-accounting for Allah's rights).
> Ghazali, *Ihya'* 39.8: "He who knows himself knows his Lord; he who does not know himself walks blind."

**Action:** Every reflection screen must end with a *muhasabah* prompt (RI-5.2). The Pathways screen must gently suggest the *sheikh/murabbi* role (RI-3.3).

### 1.5 Taharah and halaal rizq are the foundations of the heart's health

> **Classical anchor:** Hadith on the accepted supplication: "... ورجل قلبه معلّق في المساجد..." (Tirmidhi 3501); and "الحلال بَيِّنٌ والحرام بَيِّن" (Bukhari 52, Muslim 1599).
> Al-Muhasibi: "The heart cannot be sound while the body feeds on haram."

**Action:** Add a foundational Habits category — Taharah, Halal Rizq, Guarding the Tongue — that is seeded by default for every user (RI-3.4).

---

## 2 · Seed-level fixes (Knowledge layer)

### RI-2.1 · Resolve the 18 duplicate attribute IDs
**Source:** Audit §2.2.A — 18 duplicate attributes (Riya 1/61, Kibr 2/62, Ghurur 7/63, Ghaflah 10/64, Qasawat al-Qalb 9/65, Nifaq 4/67, Rifq 85/151, Hilm 86/152, Qana'ah 82/154, Wara' 83/158, Uns billah 94/160, Muraqabah Kamilah 96/174, Ihsan 90/175, Shawq ila Allah 101/182, Tafwid 105/183, Sakinah 99/185, Basirah 107/186, Ubudiyyah Kamilah 125/195)
**Severity:** High
**Classical anchor:** Single-Quran-reference principle — classical scholars do not enumerate the same trait twice with different verses; they cite the strongest evidence.
**Action:**
1. For each pair, declare a **primary** (the one whose reference classical scholars most often cite; e.g., for Kibr → Luqman 31:18 is primary over An-Nahl 16:23, because Luqman is the locus classicus of kibr in tafsir).
2. Mark the secondary as **"Variation: [source-emphasis]"** in the seed (e.g., ID 62 Kibr = "Kibr of argumentation," ID 2 Kibr = "Kibr (root definition)").
3. Update `attribute_links.Cure` and `Growth_Path` to always resolve to the primary.
4. Update `HeartOS/tables/01_attributes.md` and `HeartOS/assets/data/*` seeds.
**Owner:** Knowledge layer (`attributes` table, `attribute_links`, all pathway JSON seeds)
**Done when:** CI check `Duplicate_Attribute_Resolver` returns a single canonical ID for every query.
**Scholar sign-off:** Required (a scholar must pick the primary for each pair).

### RI-2.2 · Fix the out-of-range hadith reference (Sahih Muslim 7028)
**Source:** Audit §2.2.B
**Severity:** Critical (hadith authenticity)
**Classical anchor:** The hadith on hard-heartedness is in **Sahih Muslim 2750** area (Kitab adh-Dhikr wa al-Du'a, hadith on hearts rusting and being polished by tadhakkur). Some scholars also cite **Tirmidhi 2307 / 2417** for the related content.
**Action:** Replace `Sahih Muslim 7028` with `Sahih Muslim 2750` in:
- `HeartOS/tables/01_attributes.md` (row for Qasawat al-Qalb, IDs 9 and 65)
- `emotion_attribute_links_refined.csv`
- Any duplicate attribute rows after RI-2.1 is applied.
**Owner:** Knowledge layer
**Done when:** No occurrence of "Sahih Muslim 7028" remains; every hadith ref is verifiable in Shu'ayb al-Arna'ut's tahqiq of Sahih Muslim.
**Scholar sign-off:** Required.

### RI-2.3 · Fix the mis-attributed Quran reference for attribute ID 64 (Ghaflah duplicate)
**Source:** Audit §2.2.J
**Severity:** High
**Classical anchor:** The verse Al-Anbiya 21:1 ("اقْتَرَبَ لِلنَّاسِ حِسَابُهُمْ وَهُمْ فِي غَفْلَةٍ مُّعْرِضُونَ") is authentically about *ghaflah* (heedlessness) — but the duplicate entry currently lists this verse under Ghaflah with a Hadith of "Sahih Muslim 2676" which is also a ghaflah-related hadith and is authentic.
> Cross-check: Sahih Muslim 2675 = hadith on dhikr; 2676 = adjacent hadith. After RI-2.1 resolves duplicates, this entry should be the **variation** entry for Ghaflah, and the primary (ID 10) keeps Quran 7:205. Confirm with tafsir Ibn Kathir on 21:1 that the verse is indeed a primary *ghaflah* verse.
**Action:** Verify, and either (a) confirm the reference and label this entry "Ghaflah of heedlessness toward the Hour" or (b) replace with another primary ghaflah verse (e.g., Yunus 10:7).
**Owner:** Knowledge layer
**Done when:** The variation entry is correctly labeled and a Quran ref is provided that classical tafsir uses for ghaflah.
**Scholar sign-off:** Required.

### RI-2.4 · Re-align swapped Arabic/Urdu fields in attributes detail
**Source:** Audit §3.3 (existing `HeartOS/AUDIT_REPORT.md`)
**Severity:** Medium (cosmetic but documented)
**Classical anchor:** N/A (data hygiene)
**Action:** Sweep all 200 attributes' `Prophetic_Dua_*` and `Quranic_Dua_*` triplets and verify that the Arabic field contains Arabic, the Urdu field contains Urdu, and the Reference field contains the citation only.
**Owner:** Knowledge layer / data loader
**Done when:** Automated check passes for all 200 rows.

### RI-2.5 · Verify all 200 hadith references against canonical tahqiq editions
**Source:** Audit §2.2.B + general concern
**Severity:** Critical
**Classical anchor:** *'Ilal al-hadith* tradition — every hadith must be traceable to a recognized edition with authentication grading.
**Action:**
1. For each of the 200 attribute rows, the `Hadith_Reference` must be verified against:
   - **Sahihayn (Bukhari/Muslim):** tahqiq of Muhammad Muhsin Khan (Bukhari), Shu'ayb al-Arna'ut (Muslim).
   - **Sunan Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah:** tahqiq of Shu'ayb al-Arna'ut.
   - **Musnad Ahmad:** tahqiq of Ahmad Shakir (begun) or the Arna'ut edition.
   - **Mu'jam/Mishkat:** only as a last resort.
2. Where a hadith is graded *da'if* in the canonical edition, mark `Hadith_Grade` as `Da'if` in the seed and provide the stronger alternative.
3. Specifically verify these high-traffic references: Bukhari 1, 33, 1469, 6114, 6116, 6117, 6094, 6502, 2820, 3614, 3798, 5776, 5984, 6035, 6044, 6066, 6077, 6091, 6369, 6374, 6407, 6416, 6417, 6436, 6470, 6475, 6482, 6499, 6507, 6607, 7374, 7375, 7384; Sahih Muslim 8, 17, 38, 55, 73, 85, 91, 105, 134, 251, 489, 804, 867, 1021, 1051, 1053, 1827, 2321, 2563, 2564, 2566, 2577, 2578, 2588, 2589, 2590, 2593, 2597, 2626, 2664, 2675, 2679, 2699, 2702, 2721, 2734, 2749, 2750, 2755, 2758, 2790, 2815, 2816, 2819, 2829, 2864, 2865, 2877, 2956, 2959, 2985, 3001, 7028 (REMOVE — out of range).
**Owner:** Knowledge layer
**Done when:** Every hadith has a verified `Hadith_Grade` column (`Sahih` / `Hasan` / `Da'if` — and `Da'if` ones have a stronger alternative).
**Scholar sign-off:** Required (a *muhaddith* must sign off, not just a tazkiya scholar).

### RI-2.6 · Add `Hadith_Grade` column to `attributes` table
**Source:** RI-2.5
**Severity:** High
**Classical anchor:** Same
**Action:** Add `Hadith_Grade TEXT NOT NULL CHECK (Hadith_Grade IN ('Sahih','Hasan','Da'if','Mutawatir'))` to the `attributes` table DDL. Update all 200 rows.
**Owner:** Schema (`HeartOS/SCHEMA.sql`)
**Done when:** Migration v1.1 applies cleanly to seeded DB; CI test passes.

### RI-2.7 · Re-verify the Quran reference for every attribute
**Source:** General integrity
**Severity:** High
**Classical anchor:** Each reference must be the verse that classical tafsir *primarily* cites for that attribute — not a verse that merely mentions the word. (Example: "Hasad" must reference Al-Falaq 113:5 — the sura dedicated to it — not a passing mention.)
**Action:**
1. For each of the 200 attributes, confirm the Quran reference is the *primary locus classicus* in classical tafsir (Tabari, Qurtubi, Ibn Kathir).
2. Where a more specific verse exists, replace.
3. Add `Quran_Primary` (BOOLEAN) to flag the canonical choice, and `Quran_Secondary` for additional evidence.
**Owner:** Knowledge layer
**Done when:** A `Quran_Primary` field exists; every row passes the primary-verse audit.
**Scholar sign-off:** Required.

---

## 3 · Architecture-level fixes (to align with classical completeness)

### RI-3.1 · Add `Cause_Type` (Nafsi / Shaytani / Hawi) to attributes
**Source:** Audit §1.2 (three-cause framework)
**Severity:** High
**Classical anchor:** Quran 12:53, 114:4–6, 45:23; Ghazali, *Ihya'* 21.
**Action:**
1. Add `Cause_Type TEXT NOT NULL CHECK (Cause_Type IN ('Nafsi','Shaytani','Hawi','Mixed'))` to `attributes`.
2. Classify each of the 200 attributes by which cause is primary:
   - `Nafsi` (e.g., Hasad, Kibr, Tama, Hubb ad-Dunya) — the self's desire dominates
   - `Shaytani` (e.g., Waswasa, Khannas whispers, su' al-dhann) — whisper-dominated
   - `Hawi` (e.g., Ittiba al-Hawa, Jahl following whim)
   - `Mixed` (most negative attributes — all three contribute)
3. On the Insight screen, when a negative attribute is detected, show a *single line* whisper: "Tawakkul 'ala Allah wa al-i'tiṣām bi-him" (Quran 3:101) or "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ" (Quran 7:201) — depending on `Cause_Type`.
**Owner:** Knowledge layer + Insight screen widget
**Done when:** Every attribute has a `Cause_Type`; UI shows the appropriate protective dhikr.

### RI-3.2 · Add `Source_Emphasis` field to attributes (for the duplicate resolution)
**Source:** RI-2.1
**Severity:** Medium
**Classical anchor:** Single canonical truth per attribute (see RI-1.1).
**Action:** Add `Source_Emphasis TEXT` (e.g., "root", "of argumentation", "of ostentation in worship") to disambiguate the 18 duplicates after RI-2.1 resolution.
**Owner:** Knowledge layer
**Done when:** All 200 attributes have a meaningful `Source_Emphasis` or empty.

### RI-3.3 · Add the *Sheikh / Murabbi* gentle reminder to the Pathways screen
**Source:** Audit §1.2 (classical completeness)
**Severity:** Medium
**Classical anchor:** Hadith "الرَّجُلُ عَلَى دِينِ خَلِيلِهِ" (Abu Dawud 4033, Tirmidhi 2378 — graded *sahih*); "العلم لا يؤخذ من المصاحف بل عن المشايخ" (saying of the Salaf cited in *Madarij al-Salikin*).
**Action:** Add a non-intrusive panel on the Pathways screen:
> "Tazkiya in the Islamic tradition usually requires a *sheikh* — a qualified, living teacher of the path. This app is a companion, not a replacement. Consider seeking a local scholar of tazkiya for guidance on the deeper stations."
**Owner:** Pathways screen widget
**Done when:** Panel is visible but dismissible per user preference.

### RI-3.4 · Seed three foundational Habits by default
**Source:** Audit §1.5 (taharah, halal rizq, tongue)
**Severity:** Medium
**Classical anchor:**
- Taharah: Quran 5:6, Tirmidhi 2860 (sahih — "الطهور شطر الإيمان")
- Halalan Rizq: Bukhari 52, Muslim 1599
- Hifz al-Lisan: Quran 50:18, Bukhari 6475
**Action:** When the user first opens the Habits screen (or accepts the onboarding), seed three default habits:
1. "Perform wudu before each Salah"
2. "Earn rizq only from halal sources" (tracked by self)
3. "Guard the tongue from ghaybah, namimah, kadhib"
**Owner:** User layer (`habits` table) + onboarding flow
**Done when:** Three defaults appear unless user opts out.

### RI-3.5 · Add a *Cause-Whisper* widget on the Reflect screen
**Source:** RI-3.1
**Severity:** Medium
**Classical anchor:** Quran 114 (the four verses of refuge from waswasa)
**Action:** After the user logs "Better / Same / Worse," surface a *cause-reflection* prompt:
- If user logged a Nafsi-type emotion: "Whisper of the self — examine your intention."
- If user logged a Shaytani-type emotion: "Recite 'A'udhu billahi min al-shaytan al-rajim' and the last two verses of Al-Baqarah."
- If user logged a Hawi-type emotion: "Examine the desire; ask whether it has brought you closer to Allah or further."
**Owner:** Reflect screen widget
**Done when:** Whisper rotates based on the dominant cause of the day's detected attributes.

### RI-3.6 · Add the *Waswasa* baseline to Nafs engine
**Source:** Audit §1.2 (Shaytan's waswasa as co-cause)
**Severity:** Medium
**Classical anchor:** Quran 114:4–6; Hadith "للشيطان همّ بالناس وللملك همّ بالحق" (Tirmidhi 2988, graded *sahih* by al-Albani).
**Action:** Add a small `Waswasa_Pressure` term to the daily Nafs score: `waswasa_p = 0.05 × (1 - mutmainnah_today)`. Visible in the formula docs but not in the user-facing breakdown. Rationale: classical tazkiya acknowledges that *some* negativity is from Shaytan, not from the self — the app should not over-attribute.
**Owner:** Nafs engine
**Done when:** Documented in `nafs_meter_algorithm.md`; unit-tested; added as a small term that does not exceed ±5%.

### RI-3.7 · Add *Body-Heart* connection to the Habit categories
**Source:** Audit §1.5
**Severity:** Low
**Classical anchor:** Hadith "إن لنفسك عليك حقا" (Bukhari 1874, Muslim 1159); al-Muhasibi, *al-Ri'aya*.
**Action:** Add a default habit category "Body" with two seeded habits: "Sleep before midnight" (Sunnah) and "Eat in moderation" (Hadith "ما ملأ ابن آدم وعاءً شرًّا من بطنه" — Tirmidhi 2380, graded *sahih*).
**Owner:** User layer
**Done when:** Body category appears in default habits.

---

## 4 · Algorithm-level fixes (rubrics, vetting, honesty)

### RI-4.1 · Add a Severity_Weight rubric
**Source:** Audit §2.2.D
**Severity:** Medium
**Classical anchor:** Ghazali, *Ihya'* 3.13: signs of each Nafs state; classical scholars rank marad al-qalb by (a) proximity to *kufr/shirk*, (b) reversibility, (c) impact on worship.
**Action:** Document the rubric:
- **9–10 (most severe):** Hasad, Kibr, Nifaq, Riya, Kufr al-Ni'mah, Shirk al-Asghar — proximity to kufr/shirk.
- **8:** Ghadab, Tama, Bukhl, Ghaflah, Qasawat al-Qalb, 'Ujub bi al-'Amal — directly harms fard worship.
- **7:** Khawf (imbalance), Ya's, Riyah-seeking, Hiqd, Waswasa — impairs spiritual state.
- **6:** Huzn (excessive), Sukhriyyah, Fuhsh — harms social/character.
- **5:** Jahl (simple), Himmah dāllah — lesser impact.
- **1–4 (positive emotions):** inversely related to Nafs-state distance from Mutmainnah.
- **Scholar sign-off** required on the rubric.
**Owner:** Emotion table seed + rubric doc
**Done when:** `severity_rubric.md` exists; every emotion's severity is justified by it.

### RI-4.2 · Add a `Daily_Action_Source` column to attributes and verify each action
**Source:** Audit §2.2.E
**Severity:** High
**Classical anchor:** Each Daily_Action must be traceable to:
- A hadith (sahih/hasan) for actions like "wudu," "dhikr," "sadaqah"
- Quran for actions like "sabr," "tawakkul," "istighfar"
- Classical scholars for the action's framing (e.g., Ghazali on *al-hisba al-jawarih*)
**Action:**
1. Add `Daily_Action_Source TEXT` (Quran ref / Hadith ref / Classical ref).
2. Audit all 50 emotion Daily_Actions. Replace any that cannot be sourced.
3. Extend Daily_Actions to all 200 attributes (currently only emotions have them — see RI-5.4).
**Owner:** Knowledge layer
**Done when:** Every Daily_Action has a sourced reference.

### RI-4.3 · Add an Allah-Names selection rubric
**Source:** Audit §2.2.F
**Severity:** Medium
**Classical anchor:** Imam al-Ghazali, *al-Maqsad al-Asna* — the canonical mapping of Names to spiritual states. For each attribute, the Name chosen should be:
- **Semantic:** the Name's meaning addresses the attribute (e.g., *Al-Halim* for Hilm/Ghadab)
- **Affirmative:** if the attribute is positive, the Name is invoked for *strengthening*; if negative, for *protection* (isti'adha)
- **Classical:** the Name should appear in classical du'as for that attribute (e.g., al-Ghazali's *Maqsad*, Ibn Qayyim's *Shifa' al-'Alil*)
**Action:**
1. Document the rubric.
2. Re-curate the `Relevant_Allah_Names` field for all 200 attributes per the rubric.
3. Cap at 3 Names per attribute (already in spec) and rank by primary/secondary.
**Owner:** Knowledge layer
**Done when:** `allah_names_rubric.md` exists; all 200 attribute Name fields pass the rubric.

### RI-4.4 · Convert Nafs-engine weights from ⚠️ PROPOSAL to *vetted constants* with classical justification
**Source:** Audit §2.2.K
**Severity:** Medium
**Classical anchor:** Ghazali, *Ihya'* 3.13: signs of each state; Ibn Qayyim, *Madarij* on hierarchy of maqamat.
**Action:**
1. Replace the hard-coded `1/4/25/70` core-virtue weight with a derived formula documented in `attribute_nafs_weights.md`:
   - **Foundation virtues** (Ikhlas, Ihsan, Tawhid Kamil, Siddiqiyyah, Wilayah, Mahabbah): the closest to Mutmainnah — weight toward Mutmainnah ≥ 80%.
   - **Core virtues** (Sabr, Shukr, Tawakkul, Yaqin, Sakinah, Ridha, Raja, Mahabbah, Inabah): weight toward Mutmainnah 60–75%, Mulhamah 20–30%.
   - **Behavioral virtues** (Adab, Hifz al-Lisan, Samt, Samahah): weight toward Mulhamah 50–60%, Mutmainnah 30–40%.
   - **Negative root diseases** (Kibr, Riya, Shirk, Nifaq, Hasad, Tama): weight toward Ammarah ≥ 60%.
   - **Negative behavioral diseases** (Bukhl, Sukhriyyah, Gheebah, Namimah): weight toward Ammarah 40–55%, Lawwamah 35–45%.
2. Each weight group must have a one-paragraph classical justification.
**Owner:** Nafs engine + weights seed
**Done when:** No ⚠️ PROPOSAL tag on weights; each weight group has classical justification.
**Scholar sign-off:** Required.

### RI-4.5 · Document the streak-threshold rationale
**Source:** Audit §1.2
**Severity:** Low
**Classical anchor:** Hadith "أحب الأعمال إلى الله أدومها وإن قل" (Bukhari 6464, Muslim 783); *istiqamah* is praised, not duration.
**Action:** Document that 7-day and 30-day thresholds are **engineering proxies for istiqamah**, not Islamic rulings. Add this disclaimer to the algorithm docs.
**Owner:** Nafs engine + scoring algorithm docs
**Done when:** `streak_rationale.md` exists.

### RI-4.6 · Verify the `Pathway_Progress` threshold (`Score > 0.3`)
**Source:** Audit §2.2.L
**Severity:** Low
**Classical anchor:** N/A (engineering)
**Action:** Justify the 0.3 threshold: it represents the "user has noticed the attribute" minimum. Document why 0.3 (e.g., "emotion_weight 0.65 × intensity 5/10 = 0.325 ≈ 0.3").
**Owner:** Nafs engine
**Done when:** Threshold rationale documented.

### RI-4.7 · Add the *Musalsal* (chained) disclaimer for the recommendation engine
**Source:** Audit §2.2.G (algorithm honesty)
**Severity:** Medium
**Classical anchor:** Scholar Ibn al-Qayyim's principle: "Every remedy is general unless specified; every soul's state is specific."
**Action:** Add an in-app disclaimer on every Intervention screen: *"These recommendations are general. For a treatment specific to your state, consult a qualified scholar of tazkiya."*
**Owner:** Intervention screen widget
**Done when:** Disclaimer is visible on every Intervention render.

---

## 5 · User-facing copy (tazkiya-safe framing)

### RI-5.1 · Add the tazkiya-safe banner to the Nafs Meter
**Source:** Audit §1.1 (framing)
**Severity:** Critical
**Classical anchor:** Ghazali, *Ihya'* 3.13 — the four states are "alamat muqhaṭṭa" (probable indicators), not *ahkam* (rulings).
**Action:** Display a banner on Home beneath the Nafs Meter:
> "This meter reflects patterns from your recent check-ins. It is an *indicator*, not a judgment of your heart. The reality of your soul is known only to Allah."
**Owner:** Home screen
**Done when:** Banner is present, dismissible per session but resurfaces on cold start.

### RI-5.2 · Add *Muhasabah* prompts to the Reflect screen
**Source:** Audit §1.4
**Severity:** High
**Classical anchor:** Hadith "حاسبوا أنفسكم قبل أن تحاسبوا" (Tirmidhi 2459, *hasan*); al-Muhasibi's *al-Ri'aya*.
**Action:** After the user picks Better/Same/Worse, present a rotating *muhasabah* prompt:
- "What intention was in your heart today?"
- "Where did you see Allah's signs today?"
- "What was the strongest whisper — your self, your desires, or Shaytan?"
**Owner:** Reflect screen
**Done when:** Prompt rotates per session; user can write a reflection.

### RI-5.3 · Add a *Quran of the Day* card on Home
**Source:** Classical anchor: Bukhari 4993 (encouraging daily Quran recitation); Ghazali on *khatm al-quran* not being the goal but the *tilawah al-quran bi al-tadabbur*.
**Action:** On the Home screen, after the Nafs Meter, show a single *ayah of the day* (rotating daily) with its reflection note — not tied to a check-in. This anchors the user in Quran independent of any emotion.
**Owner:** Home screen
**Done when:** Ayah rotates daily; reflection note is sourced from classical tafsir.

### RI-5.4 · Extend Daily_Action coverage to all 200 attributes
**Source:** Audit §2.2.E
**Severity:** High
**Classical anchor:** Every attribute has a corresponding practice in the classical tradition (e.g., for *Hilm* — "If any of you gets angry, let him perform wudu," Abu Dawud 4784, graded *sahih*).
**Action:** For each of the 200 attributes, add a `Daily_Action` field with a sourced practice. Use existing hadith corpus in `HeartOS/assets/data/hadees_data.json` to auto-suggest, then scholar-review.
**Owner:** Knowledge layer
**Done when:** All 200 attributes have a sourced Daily_Action.

### RI-5.5 · Add the *Istighfar* baseline to onboarding
**Source:** Classical anchor: Hadith on istighfar as the *opening* of tazkiya — "من لزم الاستغفار، جعل الله له من كل هم فرجًا" (Abu Dawud 1518, Ahmad 5/198, graded *sahih*).
**Action:** Add an onboarding flash card introducing *istighfar* as the daily start to tazkiya: "Begin each check-in by reciting *Astaghfirullah* 3 times."
**Owner:** Onboarding flow
**Done when:** Card exists; user can tap to accept.

### RI-5.6 · Add *Suluk* (spiritual journey) framing to Pathways
**Source:** Classical anchor: Ghazali, *Ihya'* 21, calls the entire discipline *suluk ila Allah*.
**Action:** Rename the Pathways screen header from "Master Pathways" to "Suluk — Spiritual Pathways." Add an opening line: "These pathways follow the *salaf al-salih* and the great imams of tazkiya."
**Owner:** Pathways screen
**Done when:** Header and intro line are present.

---

## 6 · Classical-source validation checklist (per change)

For **every** change that touches Quran, Hadith, or scholarly attribution, complete:

- [ ] **Quran:** Reference matches the verse(s) used by Tabari, Qurtubi, or Ibn Kathir as the *primary* tafsir locus for this attribute. If multiple verses, rank them.
- [ ] **Hadith:** Reference is verifiable in a canonical tahqiq edition. Grade recorded as Sahih/Hasan/Da'if. If Da'if, a stronger alternative is provided.
- [ ] **Scholar attribution:** If a name is invoked (Ghazali, Ibn Qayyim, al-Muhasibi, etc.), the cited work and chapter exist.
- [ ] **Translation:** Arabic source text matches the English/Urdu rendering. (For Hadith: the wording is from the same narrator — e.g., Abu Hurayra — as the Arabic.)
- [ ] **No fabricated references:** No hadith number that doesn't exist in the cited collection.
- [ ] **Tazkiya alignment:** The recommended action doesn't contradict a fard, haram, or established sunnah.
- [ ] **No bid'ah surface:** No recommendation that could be misread as innovation in religion.

---

## 7 · Acceptance criteria & scholar sign-off gate

### 7.1 Release gate

Before the app is released to users, **all Critical and High items** in this document must be:

1. Implemented
2. Verified by automated CI tests
3. Signed off by a **qualified scholar of tazkiya** (must have ijaza in the field, ideally with Ghazali's *Ihya'* or Ibn Qayyim's *Madarij* as a primary text)
4. For Hadith authenticity, signed off by a **muhaddith** (not just a tazkiya scholar)

### 7.2 Scholar sign-off log

| Change | Tazkiya scholar | Muhaddith | Date | Notes |
|---|---|---|---|---|
| RI-2.1 duplicate resolution | ___________ | N/A | ________ | |
| RI-2.2 hadith ref fix | ___________ | ___________ | ________ | |
| RI-2.3 Quran mis-attribution | ___________ | N/A | ________ | |
| RI-2.5 hadith verification | N/A | ___________ | ________ | |
| RI-2.7 Quran primary audit | ___________ | N/A | ________ | |
| RI-3.1 Cause_Type | ___________ | N/A | ________ | |
| RI-4.1 Severity rubric | ___________ | N/A | ________ | |
| RI-4.2 Daily_Action sources | ___________ | ___________ | ________ | |
| RI-4.3 Allah-Names rubric | ___________ | N/A | ________ | |
| RI-4.4 Nafs weights | ___________ | N/A | ________ | |
| RI-5.1–5.6 user-facing copy | ___________ | N/A | ________ | |

### 7.3 Release checklist

- [ ] All Critical items (RI-2.2, RI-5.1) resolved.
- [ ] All High items resolved or documented as deferred with rationale.
- [ ] All Quran/Hadith references verified by at least one scholar sign-off.
- [ ] No PROPOSAL ⚠️ tag remains on user-visible algorithm.
- [ ] Tazkiya-safe banner present on Home.
- [ ] Disclaimer on Intervention screen.
- [ ] Sheikh/murabbi panel on Pathways screen.
- [ ] Three foundational habits seeded by default.
- [ ] Cause-Whisper widget present on Reflect.
- [ ] CI check `Duplicate_Attribute_Resolver` passes.
- [ ] CI check `Hadith_Reference_Verifier` passes.
- [ ] CI check `Quran_Primary_Verifier` passes.

---

## 8 · Implementation order (recommended)

To minimize churn, implement in this order:

1. **Schema additions first** (RI-2.4, RI-2.6, RI-3.1, RI-3.2): add `Hadith_Grade`, `Cause_Type`, `Source_Emphasis`, `Daily_Action_Source`. Migration v1.1.
2. **Seed backfills** (RI-2.1 to RI-2.7, RI-4.1 to RI-4.4): populate new columns, fix duplicates, fix references.
3. **Nafs engine update** (RI-3.6, RI-4.4 to RI-4.6): update formulas, drop PROPOSAL tags.
4. **UI screens** (RI-3.3 to RI-3.5, RI-4.7, RI-5.1 to RI-5.6): add banners, panels, prompts.
5. **CI checks** (RI-2.5, RI-2.7, RI-7.3): enforce ongoing compliance.
6. **Scholar sign-off** (RI-7.2): batch sign-off after all RIs implemented.
7. **Release.**

Estimated effort: **3–4 weeks** with one scholar + one muhaddith + one engineer.

---

## 9 · Deferred items (acknowledged but not blocking v1.0)

These are out of scope for v1.0 but should be addressed in v1.1 or v2:

- **Sheikh matching feature** (v2) — connect users to local scholars of tazkiya
- **AI companion grounded in classical texts** (v2) — see `09_future/ai_layer.md`; requires fatwa on AI use in worship guidance
- **Voice/recitation mode** (v2) — allow users to recite Quran/Dhikr with audio
- **Waswasa tracker** (v1.1) — log waswasa incidents separately from nafsi concerns
- **Tahara & halalan-rizq detailed tracker** (v1.1) — beyond just default habits

---

## 10 · See also

- `HeartOS/AUDIT_REPORT.md` — existing 2026-06-12 reaudit
- `HeartOS/00_root/architecture.md` — four-layer model this plan respects
- `HeartOS/00_root/scoring_engine.md` — Nafs-meter algorithm touched by RI-4.4
- `HeartOS/00_root/user_flow.md` — five-screen loop touched by RI-5.x
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — algorithm updated by RI-3.6, RI-4.4
- `HeartOS/04_user_tables/checkins.md`, `habits.md` — schemas touched by RI-3.4, RI-3.7
- `HeartOS/05_pathways/master_pathways.md` — UI touched by RI-3.3, RI-5.6
- `HeartOS/08_algorithms/recommendation_algorithm.md` — disclaimer added per RI-4.7
- `emotion_attribute_links_refined.csv` — already remediated (RI-2.2 applied here); same edits must propagate to HeartOS seeds
- `docs/briefings/nafs-mutmainna-briefing.md` — vision statement this plan aligns with

---

*This document is the v1.0 release-gate plan. After every RI is implemented, update the §7.2 sign-off log and the §7.3 checklist. Until both are complete, the app is **not cleared for release**.*