# Daily-Action Source Rubric — HeartOS Attributes

> **Implements RI-4.2** of `docs/scholar-audit-remediation-plan.md`.

Every Daily_Action (whether on an emotion or attribute) must be sourced from
one of three categories, ranked by priority.

## Sourcing priority

### Priority 1 — Direct Quran verse

The action is **explicitly commanded** or **recommended** by a specific
Quran verse. The verse citation is required.

> Examples:
> - *Sabr* — "Recite 'HasbunAllah wa ni'mal-wakeel' in difficulty."
>   Source: Quran 2:153 (the patience verse) and 3:173 (HasbunAllah).
> - *Taharah* — "Perform wudu before each Salah."
>   Source: Quran 5:6.

### Priority 2 — Sahih/Hasan Hadith

The action is **explicitly narrated** from the Prophet ﷺ.

> Examples:
> - *Anger* — "Perform wudu when anger rises; change posture; remain silent."
>   Source: Sahih al-Bukhari 6116.
> - *Gheebah* — "Before mentioning anyone, recite dhikr."
>   Source: Quran 49:12 + Sahih Muslim 2589.

### Priority 3 — Classical scholar (Tazkiya Nafs)

The action is **derived from classical tazkiya methodology** when no direct
Quran/Hadith covers the specific attribute. The author and work must be
cited.

> Examples:
> - *Ujub* — "Before each good deed, recite 'Allahumma la tukhayyibani bi 'ajli'."
>   Source: Ibn al-Qayyim, *Madarij al-Salikin* 2:300 (paraphrase).
> - *Irfan/Shukr* — "Recite 'Ya Rabbu, la taqzi' al-jannah...' (hope)."
>   Source: classical istighfar corpus.

## Forbidden patterns

- **No bid'ah**: actions must not introduce innovations in religion.
  Anything that resembles a "spiritual technique" without Quran/Hadith
  backing is rejected.
- **No fard violation**: actions must not contradict an obligation.
  (E.g., a "spiritual fast" that requires skipping the fard fast is
  rejected.)
- **No fabricated hadith**: every Hadith source must be verifiable.
- **No advice that could be misread as a fatwa**: actions are presented
  as *practices*, not as legal rulings.

## Verification workflow

For every Daily_Action in the seed:

1. Identify the priority (Quran / Hadith / Classical).
2. Verify the source via canonical tahqiq editions.
3. Cross-check against at least one classical tazkiya work.
4. Mark the row with the verified source.

## Schema

In `attributes` and `emotions`, the columns are:

- `Daily_Action` (TEXT) — the action text.
- `Daily_Action_Source` (TEXT) — the source citation.

## Scholar sign-off

| Reviewer | Date | Notes |
|---|---|---|
| ___________ | ________ | |