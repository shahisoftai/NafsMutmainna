# Allah-Names Selection Rubric — HeartOS Attributes

> **Implements RI-4.3** of `docs/scholar-audit-remediation-plan.md`.

Each of the 200 attributes carries a `Relevant_Allah_Names` field (3 names
max, ranked primary/secondary). This rubric documents the selection
criteria.

## Sources

1. **Imam al-Ghazali, *al-Maqsad al-Asna fi Sharh Asma' Allah al-Husna***
   — the canonical mapping of Names to spiritual states.
2. **Ibn al-Qayyim, *Shifa' al-'Alil fi Masa'il al-Qada' wa al-Qadar***
   — Names applied to specific heart diseases.
3. **Classical du'a corpus** — Names that appear in the prophetic du'as
   addressing a particular attribute (e.g., *Allahumma inni as'aluka
   al-hilm* uses *al-Halim* for *hilm*).

## Selection criteria (must satisfy all 3)

A Name is included in `Relevant_Allah_Names` for an attribute **only if**:

1. **Semantic relevance** — the Name's meaning (per its entry in
   *al-Maqsad al-Asna*) addresses the attribute. For example:
   - *Al-Halim* (The Forbearing) → relevant to *Hilm* (forbearance) and
     *Ghadab* (anger — its opposite).
   - *Al-Wadud* (The Loving) → relevant to *Mahabbah* (love).
   - *Al-'Alim* (The All-Knowing) → relevant to *'Ilm* (knowledge).

2. **Affirmative use** — the Name is invoked for:
   - **Positive attributes:** strengthening (e.g., *Ya Sabur* for *sabr*).
   - **Negative attributes:** protection through isti'adha (e.g.,
     *Ya Hafiz* for protection against *dhann su'*).

3. **Classical attestation** — the Name appears in classical du'as for
   this attribute (see corpus below).

## Classical du'a corpus (for verification)

| Attribute | Classical du'a | Names |
|---|---|---|
| Sabr | "Rabbana afrigh 'alayna sabran..." (Quran 2:250) | As-Sabur, Al-Halim |
| Tawakkul | "HasbunAllah wa ni'mal-wakeel" (Quran 3:173; 8:49; 9:129; 39:38) | Al-Wakil, Al-Kafi, Al-Hasib |
| Shukr | "Alhamdulillah" — opening of every state | Al-Wahhab, Al-Karim, Ash-Shakur |
| Tawbah | "Allahumma inni as'aluka at-tawbata wa al-'afiyah" | Al-Tawwab, Al-Ghafur, Al-'Afuww |
| Mahabbah | "Allahumma inni as'aluka hubbaka..." | Al-Wadud, Al-Habib, Al-Jamil |
| Khawf | "Allahi akbar wa ni'mal-wakil" (Ibn Majah) | Al-Jabbar, Al-Mutakabbir, Al-Qahhar |
| Raja | "Man yaqbil al-tawwaba taqabbal minni" | Ar-Rahman, Ar-Rahim, Al-Wadud |
| Kibr (its cure) | "La ilaha illa Allah" — humility through tawhid | Al-Kabir, Al-Mutakabbir, Al-'Alim |
| Hasad (its cure) | "Allahumma barik li..." (Bukhari 5020) | Al-Muqtadir, Al-Wahhab, Al-Karim |

## Cap and ranking

- **Cap at 3 Names** per attribute (UI limitation; already in spec).
- **Primary:** the Name that classical sources cite most often.
- **Secondary:** Names used in specific du'as for that attribute.
- **Tertiary:** Names with semantic affinity but less classical support.

## Forbidden patterns

- **No Names outside the 99** (no invented Names — *al-Asma' al-Husna* is closed).
- **No Names paired with their opposites** (e.g., don't list *Al-Khaliq*
  and *Al-Mumit* together in a way that confuses the user).
- **No Names without classical attestation** for that attribute (always
  consult *al-Maqsad al-Asna*).

## Scholar sign-off

| Reviewer | Date | Notes |
|---|---|---|
| ___________ | ________ | |