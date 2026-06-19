# Scholar Sign-Off Log — HeartOS v1.0

> **Implements §7.2 of `docs/scholar-audit-remediation-plan.md`.**
> Tracks which Remediation Items (RIs) have been signed off by a qualified
> tazkiya scholar and a muhaddith.

## Required credentials

A **tazkiya scholar** must have ijaza in classical tazkiya works, ideally
with primary text experience in:

- Imam al-Ghazali, *Ihya' 'Ulum al-Din*
- Ibn al-Qayyim al-Jawziyyah, *Madarij al-Salikin*
- al-Harith al-Muhasibi, *al-Ri'aya li-Huquq Allah*
- Abu Talib al-Makki, *Qut al-Qulub*

A **muhaddith** must be qualified in hadith authentication, ideally with
experience in:

- Shu'ayb al-Arna'ut's tahqiq of Sahih Muslim
- Muhammad Muhsin Khan's translation/edition of Sahih al-Bukhari
- The Six Books (Kutub al-Sitta)

## Sign-off table

| RI | Change | Tazkiya scholar | Muhaddith | Date | Notes |
|---|---|---|---|---|---|
| RI-2.1 | Resolve 18 duplicate attributes | ___________ | N/A | ________ | Awaiting scholar input |
| RI-2.2 | Sahih Muslim 7028 → 2750 | ___________ | ___________ | ________ | Fixed in seed JSON |
| RI-2.3 | Mis-attributed Quran ref for ID 64 | ___________ | N/A | ________ | Pending review |
| RI-2.4 | Arabic/Urdu alignment | ___________ | N/A | ________ | Pending review |
| RI-2.5 | All 200 hadith refs verified | N/A | ___________ | ________ | CI verifier added |
| RI-2.6 | `Hadith_Grade` column | ___________ | ___________ | ________ | Added (schema v11) |
| RI-2.7 | Quran primary audit | ___________ | N/A | ________ | CI verifier added |
| RI-3.1 | Cause_Type (Nafsi/Shaytani/Hawi) | ___________ | N/A | ________ | Added (schema v11) |
| RI-3.2 | Source_Emphasis for duplicates | ___________ | N/A | ________ | Added (schema v11) |
| RI-3.3 | Sheikh/Murabbi panel | ___________ | N/A | ________ | Implemented (widget) |
| RI-3.4 | Three foundational habits | ___________ | N/A | ________ | Implemented (service) |
| RI-3.5 | Cause-Whisper widget | ___________ | N/A | ________ | Implemented (widget) |
| RI-3.6 | Waswasa baseline in Nafs engine | ___________ | N/A | ________ | Implemented (constants + engine) |
| RI-3.7 | Body-Heart habit category | ___________ | N/A | ________ | Implemented (service) |
| RI-4.1 | Severity_Weight rubric | ___________ | N/A | ________ | Documented (`docs/rubrics/severity_rubric.md`) |
| RI-4.2 | Daily_Action_Source rubric | ___________ | ___________ | ________ | Documented (`docs/rubrics/daily_action_source_rubric.md`) |
| RI-4.3 | Allah-Names selection rubric | ___________ | N/A | ________ | Documented (`docs/rubrics/allah_names_rubric.md`) |
| RI-4.4 | Nafs-engine weights (drop PROPOSAL) | ___________ | N/A | ________ | Implemented (NafsConstants) |
| RI-4.5 | Streak-threshold rationale | ___________ | N/A | ________ | Documented (NafsConstants) |
| RI-4.6 | Pathway progress threshold | ___________ | N/A | ________ | Documented (NafsConstants) |
| RI-4.7 | Intervention disclaimer | ___________ | N/A | ________ | Implemented (widget) |
| RI-5.1 | Nafs Meter tazkiya-safe banner | ___________ | N/A | ________ | Implemented (widget) |
| RI-5.2 | Muhasabah prompts | ___________ | N/A | ________ | Implemented (widget) |
| RI-5.3 | Quran of the Day | ___________ | N/A | ________ | Implemented (widget + seed) |
| RI-5.4 | Daily_Action for all 200 attributes | ___________ | ___________ | ________ | Seed populated |
| RI-5.5 | Istighfar baseline in onboarding | ___________ | N/A | ________ | Copy provided |
| RI-5.6 | Suluk framing | ___________ | N/A | ________ | Implemented (widget) |

## Verification status (from CI)

Last CI run: see `tools/ci/run_all.sh` output.

```bash
$ bash tools/ci/run_all.sh
=== HeartOS Scholar-Audit CI ===
[1/3] Hadith reference verifier (RI-2.5) — PASS
[2/3] Quran reference verifier (RI-2.7) — PASS
[3/3] Attribute duplicate resolver (RI-2.1) — PASS
=== ALL CHECKS PASSED ===
```

## Release gate

The app is **not cleared for release** until:

1. All Critical items (RI-2.2, RI-5.1) are implemented AND signed off.
2. All High items (severity-tagged "High" in the remediation plan) are
   implemented AND signed off.
3. All Quran/Hadith references are verified by at least one scholar.
4. No ⚠️ PROPOSAL tag remains on a user-visible algorithm.
5. CI checks pass (RI-2.5, RI-2.7, RI-2.1).
6. Tazkiya-safe banner present on Home.
7. Disclaimer on Intervention screen.
8. Sheikh/murabbi panel on Pathways screen.
9. Three foundational habits seeded by default.
10. Cause-Whisper widget present on Reflect.

When all criteria are met, fill in the date and reviewers below:

| Criterion | Verified by | Date |
|---|---|---|
| All Critical items | ___________ | ________ |
| All High items | ___________ | ________ |
| Quran/Hadith refs verified | ___________ | ________ |
| No ⚠️ PROPOSAL on user-visible | ___________ | ________ |
| CI checks pass | (automated) | ________ |
| Tazkiya banner present | ___________ | ________ |
| Intervention disclaimer | ___________ | ________ |
| Sheikh panel present | ___________ | ________ |
| Foundational habits seeded | ___________ | ________ |
| Cause-Whisper widget | ___________ | ________ |

**Release cleared:** ___________ (tazkiya scholar) &nbsp;&nbsp; ___________ (muhaddith) &nbsp;&nbsp; Date: ________