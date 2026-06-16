# Appendix A — 50 Core Emotions

> The complete list of the 50 emotions a user can log in Heart OS v1.
> Source: `50-cores.xlsx` (extracted 2026-06-12).
> Distribution: 40 Negative · 10 Positive.

---

> ⚠️ **DATA QUALITY NOTE (2026-06-12 reaudit):** The detail sections for emotions 21–30 are duplicated. The duplicate copy (originally at lines 758–984) has been removed in this revision. Detail sections for emotions 31–40 are not present in this appendix; refer to the source file `../50-cores.xlsx` for the complete data. See `../AUDIT_REPORT.md` for the full reaudit findings.

## A.1 · Quick reference table

| ID | Emotion | Arabic | Cat. | Severity | Nafs | Growth Path |
|---:|---|---|---|---:|---|---|
| 1 | **Anger** | الغضب | Negative | 8 | Ammarah | `Ghadab→Sabr→Hilm→Rifq` |
| 2 | **Jealousy** | الحسد | Negative | 9 | Ammarah | `Hasad→Shukr→Qanaah→Ridha` |
| 3 | **Anxiety** | القلق | Negative | 7 | Lawwamah | `Anxiety→Tawakkul→Yaqeen→Sakinah` |
| 4 | **Fear** | الخوف | Negative | 7 | Lawwamah | `Fear→Tawakkul→Yaqeen→Sakinah` |
| 5 | **Sadness** | الحزن | Negative | 6 | Lawwamah | `Huzn→Sabr→Raja→Husn az-Zann` |
| 6 | **Hopelessness** | اليأس | Negative | 9 | Lawwamah | `Ya's→Raja→Husn az-Zann→Mahabbah` |
| 7 | **Guilt** | الندم | Negative | 5 | Lawwamah | `Guilt→Tawbah→Inabah→Ikhlas` |
| 8 | **Laziness** | الكسل | Negative | 8 | Ammarah | `Kasal→Himmah→Mujahadah→Istiqamah` |
| 9 | **Loneliness** | الوحدة | Negative | 6 | Lawwamah | `Loneliness→Dhikr→Uns billah→Sakinah` |
| 10 | **Emptiness** | الفراغ الروحي | Negative | 8 | Lawwamah | `Emptiness→Yaqzah→Dhikr→Uns bil-Quran` |
| 11 | **Arrogance** | الكبر | Negative | 9 | Ammarah | `Kibr→Tawadu→Ikhlas` |
| 12 | **Pride** | العجب | Negative | 8 | Ammarah | `Ujb→Tawadu→Shukr` |
| 13 | **Showing Off** | الرياء | Negative | 9 | Ammarah | `Riya→Ikhlas→Ihsan` |
| 14 | **Greed** | الطمع | Negative | 8 | Ammarah | `Tama→Qanaah→Ridha` |
| 15 | **Love of Dunya** | حب الدنيا | Negative | 9 | Ammarah | `Hubb ad-Dunya→Zuhd→Ridha` |
| 16 | **Hatred** | الحقد | Negative | 8 | Ammarah | `Hiqd→Afw→Rahmah→Hilm` |
| 17 | **Desire for Revenge** | الانتقام | Negative | 8 | Ammarah | `Intiqam→Afw→Sabr→Hilm` |
| 18 | **Suspicion** | سوء الظن | Negative | 7 | Lawwamah | `Su az-Zann→Husn az-Zann→Ukhuwwah` |
| 19 | **Doubt** | الشك | Negative | 8 | Lawwamah | `Shakk→Yaqeen→Tawakkul` |
| 20 | **Confusion** | الحيرة | Negative | 6 | Lawwamah | `Hirah→Basirah→Istikharah→Tawakkul` |
| 21 | **Distractedness** | الغفلة | Negative | 8 | Lawwamah | `Ghaflah→Yaqzah→Dhikr→Muraqabah` |
| 22 | **Weak Faith** | ضعف الإيمان | Negative | 9 | Lawwamah | `Weak Faith→Yaqeen→Tawakkul→Sakinah` |
| 23 | **Impatience** | قلة الصبر | Negative | 7 | Lawwamah | `Jaza→Sabr→Ridha→Sakinah` |
| 24 | **Hard-heartedness** | قسوة القلب | Negative | 9 | Ammarah | `Qaswah→Dhikr→Khushu→Riqqah` |
| 25 | **Stinginess** | البخل | Negative | 8 | Ammarah | `Bukhl→Sakha→Shukr→Ridha` |
| 26 | **Excessive Attachment** | التعلق الزائد | Negative | 8 | Lawwamah | `Attachment→Tawakkul→Zuhd→Ridha` |
| 27 | **Envy of Status** | حب الجاه | Negative | 8 | Ammarah | `Hubb al-Jah→Ikhlas→Tawadu` |
| 28 | **Shame after Sin** | الخجل بعد الذنب | Negative | 6 | Lawwamah | `Taqsir→Tawbah→Raja→Mahabbah` |
| 29 | **Overthinking** | كثرة التفكير | Negative | 7 | Lawwamah | `Hamm→Basirah→Tawakkul→Sakinah` |
| 30 | **Restlessness** | الاضطراب | Negative | 7 | Lawwamah | `Restlessness→Dhikr→Yaqeen→Sakinah` |
| 21 | **Distractedness** | الغفلة | Negative | 8 | Lawwamah | `Ghaflah→Yaqzah→Dhikr→Muraqabah` |
| 22 | **Weak Faith** | ضعف الإيمان | Negative | 9 | Lawwamah | `Weak Faith→Yaqeen→Tawakkul→Sakinah` |
| 23 | **Impatience** | قلة الصبر | Negative | 7 | Lawwamah | `Jaza→Sabr→Ridha→Sakinah` |
| 24 | **Hard-heartedness** | قسوة القلب | Negative | 9 | Ammarah | `Qaswah→Dhikr→Khushu→Riqqah` |
| 25 | **Stinginess** | البخل | Negative | 8 | Ammarah | `Bukhl→Sakha→Shukr→Ridha` |
| 26 | **Excessive Attachment** | التعلق الزائد | Negative | 8 | Lawwamah | `Attachment→Tawakkul→Zuhd→Ridha` |
| 27 | **Envy of Status** | حب الجاه | Negative | 8 | Ammarah | `Hubb al-Jah→Ikhlas→Tawadu` |
| 28 | **Shame after Sin** | الخجل بعد الذنب | Negative | 6 | Lawwamah | `Taqsir→Tawbah→Raja→Mahabbah` |
| 29 | **Overthinking** | كثرة التفكير | Negative | 7 | Lawwamah | `Hamm→Basirah→Tawakkul→Sakinah` |
| 30 | **Restlessness** | الاضطراب | Negative | 7 | Lawwamah | `Restlessness→Dhikr→Yaqeen→Sakinah` |
| 41 | **Humility** | التواضع | Positive | 2 | Mulhamah | `Tawadu→Ikhlas→Shukr→Mahabbah` |
| 42 | **Sincerity** | الإخلاص | Positive | 1 | Mutmainnah | `Ikhlas→Ihsan→Mahabbah→Wilayah` |
| 43 | **Trust** | الثقة بالله | Positive | 2 | Mutmainnah | `Tawakkul→Ridha→Sakinah→Yaqeen` |
| 44 | **Certainty** | اليقين | Positive | 1 | Mutmainnah | `Yaqeen→Tawakkul→Sakinah→Ridha` |
| 45 | **Reverence** | الخشية | Positive | 1 | Mutmainnah | `Khashyah→Khushu→Mahabbah→Ihsan` |
| 46 | **Tranquility** | السكينة | Positive | 1 | Mutmainnah | `Sakinah→Ridha→Mahabbah→Liqa Allah` |
| 47 | **Repentance** | التوبة | Positive | 2 | Mulhamah | `Tawbah→Inabah→Raja→Mahabbah` |
| 48 | **Spiritual Longing** | الشوق إلى الله | Positive | 1 | Mutmainnah | `Shawq→Mahabbah→Liqa Allah→Ridhwan Allah` |
| 49 | **Happiness in Worship** | حلاوة العبادة | Positive | 1 | Mutmainnah | `Halawat al-Iman→Mahabbah→Uns billah→Ihsan` |
| 50 | **Nearness to Allah** | القرب من الله | Positive | 1 | Mutmainnah | `Wilayah→Ihsan→Ridhwan Allah→Fawz al-Azim` |

---

## A.2 · Full details (one section per emotion)

### 1. Anger (الغضب)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Feeling upset irritated or provoked by people or circumstances
- **Common Triggers:** Insult injustice disagreement frustration
- **Primary Negative Attributes:** Ghadab
- **Secondary Negative Attributes:** Hiqd;Intiqam
- **Primary Positive Attributes:** Sabr;Hilm;Rifq
- **Growth Path:** `Ghadab→Sabr→Hilm→Rifq`
- **Recommended Attribute Priority:** Ghadab
- **Recommended Intervention Type:** Patience
- **Recommended Dua:** Allahumma ihdini li ahsani al-akhlaq
- **Recommended Allah Names:** Al-Halim;Ar-Rahim;Ar-Rafiq
- **Recommended Dhikr:** SubhanAllahi wa bihamdihi
- **Daily Action:** Remain silent and perform wudu
- **Related Emotions:** Fear;Hatred;Desire for Revenge
- **Related Attribute IDs:** 41;151;152
- **Keywords:** anger rage irritation temper resentment

---

### 2. Jealousy (الحسد)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Disliking blessings given to others and wishing to possess them
- **Common Triggers:** Comparison status wealth success
- **Primary Negative Attributes:** Hasad
- **Secondary Negative Attributes:** Tama;Su az-Zann
- **Primary Positive Attributes:** Shukr;Qanaah;Ridha
- **Growth Path:** `Hasad→Shukr→Qanaah→Ridha`
- **Recommended Attribute Priority:** Hasad
- **Recommended Intervention Type:** Gratitude
- **Recommended Dua:** Rabbana atina fid-dunya hasanah
- **Recommended Allah Names:** Ash-Shakur;Al-Ghani;Al-Karim
- **Recommended Dhikr:** Alhamdulillah
- **Daily Action:** Count five blessings Allah has given you
- **Related Emotions:** Greed;Sadness;Love of Dunya
- **Related Attribute IDs:** 154;33;177
- **Keywords:** jealous envy comparison resentment competition

---

### 3. Anxiety (القلق)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Excessive worry about future events provision or outcomes
- **Common Triggers:** Finances health family uncertainty
- **Primary Negative Attributes:** Weak Tawakkul
- **Secondary Negative Attributes:** Weak Yaqeen;Fear
- **Primary Positive Attributes:** Tawakkul;Yaqeen;Sakinah
- **Growth Path:** `Anxiety→Tawakkul→Yaqeen→Sakinah`
- **Recommended Attribute Priority:** Tawakkul
- **Recommended Intervention Type:** Dua
- **Recommended Dua:** Hasbiyallahu la ilaha illa huwa
- **Recommended Allah Names:** Al-Wakil;Ar-Razzaq;Al-Hafiz
- **Recommended Dhikr:** La hawla wa la quwwata illa billah
- **Daily Action:** Entrust one major concern to Allah and continue taking means
- **Related Emotions:** Fear;Overthinking;Restlessness
- **Related Attribute IDs:** 176;183;185
- **Keywords:** worry anxiety stress nervous uncertainty

---

### 4. Fear (الخوف)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Feeling threatened insecure or afraid of harm
- **Common Triggers:** Uncertainty danger loss
- **Primary Negative Attributes:** Khawf imbalance
- **Secondary Negative Attributes:** Wahn;Weak Yaqeen
- **Primary Positive Attributes:** Tawakkul;Raja;Yaqeen
- **Growth Path:** `Fear→Tawakkul→Yaqeen→Sakinah`
- **Recommended Attribute Priority:** Khawf
- **Recommended Intervention Type:** Dua
- **Recommended Dua:** Allahumma inni as'aluka khashyataka
- **Recommended Allah Names:** Al-Hafiz;Al-Mumin;Al-Wakil
- **Recommended Dhikr:** Hasbunallahu wa ni'mal wakeel
- **Daily Action:** Read Ayat al-Kursi and make dua
- **Related Emotions:** Anxiety;Restlessness;Weak Faith
- **Related Attribute IDs:** 3;30;178
- **Keywords:** fear panic insecurity danger

---

### 5. Sadness (الحزن)

- **Category:** Negative
- **Severity:** 6 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Experiencing emotional pain disappointment or grief
- **Common Triggers:** Loss failure separation
- **Primary Negative Attributes:** Huzn excessive
- **Secondary Negative Attributes:** Ya's
- **Primary Positive Attributes:** Sabr;Raja;Husn az-Zann
- **Growth Path:** `Huzn→Sabr→Raja→Husn az-Zann`
- **Recommended Attribute Priority:** Sabr
- **Recommended Intervention Type:** Patience
- **Recommended Dua:** Rabbana afrigh alayna sabran
- **Recommended Allah Names:** As-Sabur;Ar-Rahim;Al-Latif
- **Recommended Dhikr:** La ilaha illa Anta subhanaka inni kuntu minaz-zalimin
- **Daily Action:** Perform two rak'ahs and speak to Allah in dua
- **Related Emotions:** Hopelessness;Loneliness;Guilt
- **Related Attribute IDs:** 6;9;7
- **Keywords:** sad grief sorrow disappointment

---

### 6. Hopelessness (اليأس)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Losing hope in Allah's mercy and expecting only negative outcomes
- **Common Triggers:** Repeated sins hardships failures
- **Primary Negative Attributes:** Ya's
- **Secondary Negative Attributes:** Qunut
- **Primary Positive Attributes:** Raja;Tawbah;Husn az-Zann
- **Growth Path:** `Ya's→Raja→Husn az-Zann→Mahabbah`
- **Recommended Attribute Priority:** Raja
- **Recommended Intervention Type:** Repentance
- **Recommended Dua:** Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah wa qina adhab an-nar
- **Recommended Allah Names:** At-Tawwab;Al-Ghafur;Ar-Rahman
- **Recommended Dhikr:** Astaghfirullah wa atubu ilayh
- **Daily Action:** Read verses about Allah's mercy
- **Related Emotions:** Sadness;Guilt;Weak Faith
- **Related Attribute IDs:** 5;7;22
- **Keywords:** hopeless despair discouraged depressed

---

### 7. Guilt (الندم)

- **Category:** Negative
- **Severity:** 5 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Feeling regret and remorse because of sins or mistakes
- **Common Triggers:** Sins negligence failures
- **Primary Negative Attributes:** Taqsir
- **Secondary Negative Attributes:** Qaswah
- **Primary Positive Attributes:** Tawbah;Inabah;Ikhlas
- **Growth Path:** `Guilt→Tawbah→Inabah→Ikhlas`
- **Recommended Attribute Priority:** Tawbah
- **Recommended Intervention Type:** Repentance
- **Recommended Dua:** Sayyid al-Istighfar
- **Recommended Allah Names:** At-Tawwab;Al-Ghafur;Al-Afuww
- **Recommended Dhikr:** Astaghfirullah
- **Daily Action:** Repent immediately and perform a good deed
- **Related Emotions:** Hopelessness;Sadness;Shame after Sin
- **Related Attribute IDs:** 6;5;28
- **Keywords:** guilt regret remorse repentance

---

### 8. Laziness (الكسل)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Lack of energy motivation and willingness to perform beneficial actions
- **Common Triggers:** Fatigue distractions procrastination
- **Primary Negative Attributes:** Kasal
- **Secondary Negative Attributes:** Taswif
- **Primary Positive Attributes:** Himmah;Mujahadah;Istiqamah
- **Growth Path:** `Kasal→Himmah→Mujahadah→Istiqamah`
- **Recommended Attribute Priority:** Himmah
- **Recommended Intervention Type:** Physical Action
- **Recommended Dua:** Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik
- **Recommended Allah Names:** Al-Qawiyy;Al-Matin;Al-Hayy
- **Recommended Dhikr:** La hawla wa la quwwata illa billah
- **Daily Action:** Begin with a task that takes less than five minutes
- **Related Emotions:** Emptiness;Weak Faith;Distractedness
- **Related Attribute IDs:** 10;22;21
- **Keywords:** lazy procrastination inactivity sluggish

---

### 9. Loneliness (الوحدة)

- **Category:** Negative
- **Severity:** 6 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Feeling isolated disconnected and lacking meaningful companionship
- **Common Triggers:** Loss distance from people spiritual neglect
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Weak Dhikr;Weak Mahabbah
- **Primary Positive Attributes:** Uns billah;Dhikr;Mahabbah
- **Growth Path:** `Loneliness→Dhikr→Uns billah→Sakinah`
- **Recommended Attribute Priority:** Dhikr
- **Recommended Intervention Type:** Social Connection
- **Recommended Dua:** Allahumma inni as'aluka hubbaka
- **Recommended Allah Names:** Al-Wadud;Ar-Rahman;As-Salam
- **Recommended Dhikr:** SubhanAllahi wa bihamdihi
- **Daily Action:** Spend ten minutes with Quran or dhikr
- **Related Emotions:** Sadness;Emptiness;Peace
- **Related Attribute IDs:** 5;10;34
- **Keywords:** lonely isolated abandoned disconnected

---

### 10. Emptiness (الفراغ الروحي)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Feeling spiritually empty despite worldly possessions or success
- **Common Triggers:** Dunya attachment heedlessness
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Hijr al-Quran;Weak Dhikr
- **Primary Positive Attributes:** Yaqzah;Dhikr;Uns bil-Quran
- **Growth Path:** `Emptiness→Yaqzah→Dhikr→Uns bil-Quran`
- **Recommended Attribute Priority:** Yaqzah
- **Recommended Intervention Type:** Quran
- **Recommended Dua:** Rabbi zidni ilma
- **Recommended Allah Names:** An-Nur;Al-Hadi;Al-Wadud
- **Recommended Dhikr:** SubhanAllah walhamdulillah wa la ilaha illa Allah wallahu akbar
- **Daily Action:** Read one page of Quran with reflection
- **Related Emotions:** Loneliness;Distractedness;Weak Faith
- **Related Attribute IDs:** 9;21;22
- **Keywords:** empty numb meaningless disconnected

---

### 11. Arrogance (الكبر)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Feeling superior to others and rejecting truth
- **Common Triggers:** Praise status knowledge wealth
- **Primary Negative Attributes:** Kibr
- **Secondary Negative Attributes:** Ujb;Tahqir
- **Primary Positive Attributes:** Tawadu;Ikhlas
- **Growth Path:** `Kibr→Tawadu→Ikhlas`
- **Recommended Attribute Priority:** Tawadu
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Allahumma inni a'udhu bika min sharri nafsi
- **Recommended Allah Names:** Al-Kabir;Al-Haqq;Al-Hakim
- **Recommended Dhikr:** SubhanAllahi wa bihamdihi
- **Daily Action:** Remember your dependence upon Allah and serve others
- **Related Emotions:** Envy;Pride;Showing Off
- **Related Attribute IDs:** 72;67;112
- **Keywords:** arrogance pride superiority ego

---

### 12. Pride (العجب)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Being excessively impressed with oneself
- **Common Triggers:** Success beauty achievements
- **Primary Negative Attributes:** Ujb
- **Secondary Negative Attributes:** Kibr;Riya
- **Primary Positive Attributes:** Tawadu;Shukr
- **Growth Path:** `Ujb→Tawadu→Shukr`
- **Recommended Attribute Priority:** Tawadu
- **Recommended Intervention Type:** Gratitude
- **Recommended Dua:** Rabbana ma khalaqta hadha batila
- **Recommended Allah Names:** Al-Khaliq;Ash-Shakur;Al-Hakim
- **Recommended Dhikr:** Alhamdulillah
- **Daily Action:** Thank Allah for every blessing and attribute it to Him
- **Related Emotions:** Arrogance;Showing Off;Love of Dunya
- **Related Attribute IDs:** 67;72;154
- **Keywords:** self admiration vanity pride ego

---

### 13. Showing Off (الرياء)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Seeking people's praise instead of Allah's pleasure
- **Common Triggers:** Recognition fame social media
- **Primary Negative Attributes:** Riya
- **Secondary Negative Attributes:** Ujb;Sum'ah
- **Primary Positive Attributes:** Ikhlas;Ihsan
- **Growth Path:** `Riya→Ikhlas→Ihsan`
- **Recommended Attribute Priority:** Ikhlas
- **Recommended Intervention Type:** Repentance
- **Recommended Dua:** Allahumma inni a'udhu bika an ushrika bika wa ana a'lam
- **Recommended Allah Names:** Al-Basir;Ash-Shahid;Al-Wahid
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Hide one good deed from everyone
- **Related Emotions:** Arrogance;Pride;Love of Status
- **Related Attribute IDs:** 91;194;196
- **Keywords:** show off hypocrisy reputation fame

---

### 14. Greed (الطمع)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Excessive desire for wealth possessions or favors
- **Common Triggers:** Poverty comparison ambition
- **Primary Negative Attributes:** Tama
- **Secondary Negative Attributes:** Hirs;Hasad
- **Primary Positive Attributes:** Qanaah;Shukr
- **Growth Path:** `Tama→Qanaah→Ridha`
- **Recommended Attribute Priority:** Qanaah
- **Recommended Intervention Type:** Gratitude
- **Recommended Dua:** Rabbana atina fid-dunya hasanah
- **Recommended Allah Names:** Ar-Razzaq;Al-Ghani;Al-Karim
- **Recommended Dhikr:** Alhamdulillah
- **Daily Action:** Write three blessings you already possess
- **Related Emotions:** Jealousy;Love of Dunya;Envy of Status
- **Related Attribute IDs:** 33;154;174
- **Keywords:** greed desire craving materialism

---

### 15. Love of Dunya (حب الدنيا)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Excessive attachment to worldly life and pleasures
- **Common Triggers:** Wealth status entertainment
- **Primary Negative Attributes:** Hubb ad-Dunya
- **Secondary Negative Attributes:** Hirs;Ghaflah
- **Primary Positive Attributes:** Zuhd;Akhirah Orientation
- **Growth Path:** `Hubb ad-Dunya→Zuhd→Ridha`
- **Recommended Attribute Priority:** Zuhd
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Allahumma la taj'alid-dunya akbara hammina
- **Recommended Allah Names:** Al-Awwal;Al-Akhir;Al-Warith
- **Recommended Dhikr:** La hawla wa la quwwata illa billah
- **Daily Action:** Reflect on death and the Hereafter
- **Related Emotions:** Greed;Emptiness;Love of Status
- **Related Attribute IDs:** 177;35;200
- **Keywords:** worldliness attachment materialism distraction

---

### 16. Hatred (الحقد)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Holding resentment and wishing evil for others
- **Common Triggers:** Conflict betrayal injustice
- **Primary Negative Attributes:** Hiqd
- **Secondary Negative Attributes:** Ghadab;Hasad
- **Primary Positive Attributes:** Afw;Rahmah;Hilm
- **Growth Path:** `Hiqd→Afw→Rahmah→Hilm`
- **Recommended Attribute Priority:** Afw
- **Recommended Intervention Type:** Forgiveness
- **Recommended Dua:** Rabbighfir li wa li ikhwanina
- **Recommended Allah Names:** Ar-Rahman;Al-Afuww;Al-Barr
- **Recommended Dhikr:** Astaghfirullah
- **Daily Action:** Pray for the person you resent
- **Related Emotions:** Anger;Revenge;Jealousy
- **Related Attribute IDs:** 151;38;41
- **Keywords:** hatred resentment bitterness hostility

---

### 17. Desire for Revenge (الانتقام)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Strong urge to retaliate against others
- **Common Triggers:** Hurt injustice humiliation
- **Primary Negative Attributes:** Intiqam
- **Secondary Negative Attributes:** Ghadab;Hiqd
- **Primary Positive Attributes:** Afw;Sabr;Hilm
- **Growth Path:** `Intiqam→Afw→Sabr→Hilm`
- **Recommended Attribute Priority:** Afw
- **Recommended Intervention Type:** Patience
- **Recommended Dua:** Rabbana afrigh alayna sabran
- **Recommended Allah Names:** Al-Adl;Al-Halim;Ar-Rahim
- **Recommended Dhikr:** Hasbunallahu wa ni'mal wakeel
- **Daily Action:** Leave justice to Allah and avoid retaliation
- **Related Emotions:** Anger;Hatred;Fear
- **Related Attribute IDs:** 38;41;151
- **Keywords:** revenge retaliation vengeance anger

---

### 18. Suspicion (سوء الظن)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Thinking badly about others without evidence
- **Common Triggers:** Misunderstanding jealousy insecurity
- **Primary Negative Attributes:** Su az-Zann
- **Secondary Negative Attributes:** Hasad;Takabbur
- **Primary Positive Attributes:** Husn az-Zann;Ukhuwwah
- **Growth Path:** `Su az-Zann→Husn az-Zann→Ukhuwwah`
- **Recommended Attribute Priority:** Husn az-Zann
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Rabbana la tuzigh qulubana
- **Recommended Allah Names:** Al-Alim;Al-Hakim;Al-Latif
- **Recommended Dhikr:** Astaghfirullah
- **Daily Action:** Assume the best unless clear evidence appears
- **Related Emotions:** Jealousy;Confusion;Fear
- **Related Attribute IDs:** 58;126;136
- **Keywords:** suspicion mistrust assumptions negativity

---

### 19. Doubt (الشك)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Uncertainty regarding truth faith or decisions
- **Common Triggers:** Trials misinformation confusion
- **Primary Negative Attributes:** Shakk
- **Secondary Negative Attributes:** Weak Yaqeen
- **Primary Positive Attributes:** Yaqeen;Tawakkul
- **Growth Path:** `Shakk→Yaqeen→Tawakkul`
- **Recommended Attribute Priority:** Yaqeen
- **Recommended Intervention Type:** Knowledge
- **Recommended Dua:** Rabbi zidni ilma
- **Recommended Allah Names:** Al-Haqq;Al-Alim;An-Nur
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Seek authentic knowledge and avoid speculation
- **Related Emotions:** Weak Faith;Confusion;Overthinking
- **Related Attribute IDs:** 178;176;186
- **Keywords:** doubt uncertainty skepticism hesitation

---

### 20. Confusion (الحيرة)

- **Category:** Negative
- **Severity:** 6 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Lack of clarity and inability to decide
- **Common Triggers:** Complex situations stress
- **Primary Negative Attributes:** Hirah
- **Secondary Negative Attributes:** Weak Basirah;Shakk
- **Primary Positive Attributes:** Basirah;Istikharah
- **Growth Path:** `Hirah→Basirah→Istikharah→Tawakkul`
- **Recommended Attribute Priority:** Basirah
- **Recommended Intervention Type:** Knowledge
- **Recommended Dua:** Rabbi zidni ilma
- **Recommended Allah Names:** Al-Hadi;Al-Hakim;An-Nur
- **Recommended Dhikr:** SubhanAllah
- **Daily Action:** Pray Istikharah and seek wise counsel
- **Related Emotions:** Doubt;Overthinking;Anxiety
- **Related Attribute IDs:** 186;125;176
- **Keywords:** confusion uncertainty indecision perplexity

---

### 21. Distractedness (الغفلة)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Being heedless and unable to focus on Allah and priorities
- **Common Triggers:** Social media entertainment busyness
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Hijr al-Quran;Kasal
- **Primary Positive Attributes:** Dhikr;Yaqzah;Muraqabah
- **Growth Path:** `Ghaflah→Yaqzah→Dhikr→Muraqabah`
- **Recommended Attribute Priority:** Dhikr
- **Recommended Intervention Type:** Dhikr
- **Recommended Dua:** Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik
- **Recommended Allah Names:** Al-Hadi;An-Nur;Al-Wadud
- **Recommended Dhikr:** SubhanAllahi wa bihamdihi
- **Daily Action:** Spend ten minutes without devices and recite Quran
- **Related Emotions:** Emptiness;Laziness;Weak Faith
- **Related Attribute IDs:** 171;161;51
- **Keywords:** heedlessness distraction absent minded

---

### 22. Weak Faith (ضعف الإيمان)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Feeling spiritually weak and distant from acts of worship
- **Common Triggers:** Sins neglect trials
- **Primary Negative Attributes:** Weak Yaqeen
- **Secondary Negative Attributes:** Ghaflah;Kasal
- **Primary Positive Attributes:** Yaqeen;Tawakkul;Dhikr
- **Growth Path:** `Weak Faith→Yaqeen→Tawakkul→Sakinah`
- **Recommended Attribute Priority:** Yaqeen
- **Recommended Intervention Type:** Quran
- **Recommended Dua:** Rabbi zidni ilma
- **Recommended Allah Names:** Al-Mumin;Al-Haqq;An-Nur
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Increase Quran recitation and salah
- **Related Emotions:** Anxiety;Doubt;Emptiness
- **Related Attribute IDs:** 178;176;171
- **Keywords:** weak faith low iman spiritual weakness

---

### 23. Impatience (قلة الصبر)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Wanting immediate outcomes and struggling to endure delays
- **Common Triggers:** Hardship waiting disappointment
- **Primary Negative Attributes:** Jaza
- **Secondary Negative Attributes:** Sakhat
- **Primary Positive Attributes:** Sabr;Ridha
- **Growth Path:** `Jaza→Sabr→Ridha→Sakinah`
- **Recommended Attribute Priority:** Sabr
- **Recommended Intervention Type:** Patience
- **Recommended Dua:** Rabbana afrigh alayna sabran
- **Recommended Allah Names:** As-Sabur;Al-Hakim;Ar-Rahim
- **Recommended Dhikr:** Inna lillahi wa inna ilayhi rajiun
- **Daily Action:** Delay reaction and trust Allah's timing
- **Related Emotions:** Anger;Sadness;Fear
- **Related Attribute IDs:** 38;33;185
- **Keywords:** impatience frustration intolerance

---

### 24. Hard-heartedness (قسوة القلب)

- **Category:** Negative
- **Severity:** 9 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Lack of humility mercy and remembrance
- **Common Triggers:** Sins worldly distractions
- **Primary Negative Attributes:** Qaswah
- **Secondary Negative Attributes:** Ghaflah
- **Primary Positive Attributes:** Riqqah;Dhikr;Khushu
- **Growth Path:** `Qaswah→Dhikr→Khushu→Riqqah`
- **Recommended Attribute Priority:** Khushu
- **Recommended Intervention Type:** Quran
- **Recommended Dua:** Rabbana la tuzigh qulubana
- **Recommended Allah Names:** Al-Latif;Ar-Rahman;Al-Barr
- **Recommended Dhikr:** Astaghfirullah
- **Daily Action:** Read Quran with reflection and visit the needy
- **Related Emotions:** Emptiness;Love of Dunya;Weak Faith
- **Related Attribute IDs:** 148;171;177
- **Keywords:** hardness insensitive numb heart

---

### 25. Stinginess (البخل)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Reluctance to spend or share blessings
- **Common Triggers:** Fear of poverty attachment
- **Primary Negative Attributes:** Bukhl
- **Secondary Negative Attributes:** Tama;Hirs
- **Primary Positive Attributes:** Sakha;Shukr;Tawakkul
- **Growth Path:** `Bukhl→Sakha→Shukr→Ridha`
- **Recommended Attribute Priority:** Sakha
- **Recommended Intervention Type:** Charity
- **Recommended Dua:** Rabbana atina fid-dunya hasanah
- **Recommended Allah Names:** Ar-Razzaq;Al-Karim;Al-Ghani
- **Recommended Dhikr:** Alhamdulillah
- **Daily Action:** Give something small in charity today
- **Related Emotions:** Greed;Fear;Love of Dunya
- **Related Attribute IDs:** 96;154;176
- **Keywords:** miserliness stinginess selfishness

---

### 26. Excessive Attachment (التعلق الزائد)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Depending emotionally on worldly things or people
- **Common Triggers:** Relationships wealth ambitions
- **Primary Negative Attributes:** Taalluq
- **Secondary Negative Attributes:** Hubb ad-Dunya
- **Primary Positive Attributes:** Tawakkul;Zuhd;Ridha
- **Growth Path:** `Attachment→Tawakkul→Zuhd→Ridha`
- **Recommended Attribute Priority:** Tawakkul
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Hasbiyallahu la ilaha illa huwa
- **Recommended Allah Names:** Al-Wakil;Al-Wadud;Al-Qayyum
- **Recommended Dhikr:** La hawla wa la quwwata illa billah
- **Daily Action:** Detach from one unnecessary dependence
- **Related Emotions:** Love of Dunya;Fear;Anxiety
- **Related Attribute IDs:** 176;177;33
- **Keywords:** attachment dependency obsession

---

### 27. Envy of Status (حب الجاه)

- **Category:** Negative
- **Severity:** 8 / 10
- **Dominant Nafs State:** Ammarah
- **Description:** Craving recognition position and prestige
- **Common Triggers:** Comparison fame competition
- **Primary Negative Attributes:** Hubb al-Jah
- **Secondary Negative Attributes:** Riya;Kibr
- **Primary Positive Attributes:** Ikhlas;Tawadu
- **Growth Path:** `Hubb al-Jah→Ikhlas→Tawadu`
- **Recommended Attribute Priority:** Ikhlas
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Allahumma inni a'udhu bika an ushrika bika wa ana a'lam
- **Recommended Allah Names:** Al-Wahid;Ash-Shahid;Al-Basir
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Perform a good deed secretly
- **Related Emotions:** Showing Off;Arrogance;Pride
- **Related Attribute IDs:** 91;72;67
- **Keywords:** status prestige fame recognition

---

### 28. Shame after Sin (الخجل بعد الذنب)

- **Category:** Negative
- **Severity:** 6 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Pain and embarrassment after wrongdoing
- **Common Triggers:** Major sins repeated mistakes
- **Primary Negative Attributes:** Taqsir
- **Secondary Negative Attributes:** Ya's
- **Primary Positive Attributes:** Tawbah;Raja
- **Growth Path:** `Taqsir→Tawbah→Raja→Mahabbah`
- **Recommended Attribute Priority:** Tawbah
- **Recommended Intervention Type:** Repentance
- **Recommended Dua:** Sayyid al-Istighfar
- **Recommended Allah Names:** At-Tawwab;Al-Ghafur;Al-Afuww
- **Recommended Dhikr:** Astaghfirullah wa atubu ilayh
- **Daily Action:** Repent immediately and do a righteous deed
- **Related Emotions:** Guilt;Hopelessness;Sadness
- **Related Attribute IDs:** 164;56;60
- **Keywords:** shame remorse repentance regret

---

### 29. Overthinking (كثرة التفكير)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Excessive analysis leading to anxiety and indecision
- **Common Triggers:** Uncertainty fear pressure
- **Primary Negative Attributes:** Hamm
- **Secondary Negative Attributes:** Hirah;Shakk
- **Primary Positive Attributes:** Tawakkul;Basirah
- **Growth Path:** `Hamm→Basirah→Tawakkul→Sakinah`
- **Recommended Attribute Priority:** Tawakkul
- **Recommended Intervention Type:** Dua
- **Recommended Dua:** Allahumma aslih li sha'ni kullahu
- **Recommended Allah Names:** Al-Hakim;Al-Wakil;Al-Hadi
- **Recommended Dhikr:** Hasbunallahu wa ni'mal wakeel
- **Daily Action:** Write down concerns and leave them to Allah
- **Related Emotions:** Anxiety;Confusion;Fear
- **Related Attribute IDs:** 183;186;176
- **Keywords:** overthinking rumination excessive thoughts

---

### 30. Restlessness (الاضطراب)

- **Category:** Negative
- **Severity:** 7 / 10
- **Dominant Nafs State:** Lawwamah
- **Description:** Lack of inner peace and emotional stability
- **Common Triggers:** Stress uncertainty excessive activity
- **Primary Negative Attributes:** Idtirab
- **Secondary Negative Attributes:** Hamm;Weak Tawakkul
- **Primary Positive Attributes:** Sakinah;Dhikr;Yaqeen
- **Growth Path:** `Restlessness→Dhikr→Yaqeen→Sakinah`
- **Recommended Attribute Priority:** Sakinah
- **Recommended Intervention Type:** Dhikr
- **Recommended Dua:** Allahumma ati nafsi taqwaha
- **Recommended Allah Names:** As-Salam;Al-Mumin;An-Nur
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Spend fifteen minutes in quiet dhikr and reflection
- **Related Emotions:** Anxiety;Fear;Overthinking
- **Related Attribute IDs:** 185;178;171
- **Keywords:** restlessness unease agitation instability

---

### 41. Humility (التواضع)

- **Category:** Positive
- **Severity:** 2 / 10
- **Dominant Nafs State:** Mulhamah
- **Description:** Recognizing one's dependence upon Allah and avoiding superiority
- **Common Triggers:** Knowledge worship blessings
- **Primary Negative Attributes:** Kibr
- **Secondary Negative Attributes:** Ujb
- **Primary Positive Attributes:** Tawadu;Ikhlas;Shukr
- **Growth Path:** `Tawadu→Ikhlas→Shukr→Mahabbah`
- **Recommended Attribute Priority:** Tawadu
- **Recommended Intervention Type:** Service
- **Recommended Dua:** Allahumma inni a'udhu bika min sharri nafsi
- **Recommended Allah Names:** Al-Kabir;Al-Hakim;Al-Barr
- **Recommended Dhikr:** SubhanAllahi wa bihamdihi
- **Daily Action:** Serve others quietly without seeking praise
- **Related Emotions:** Mercy;Love for People;Sincerity
- **Related Attribute IDs:** 67;91;154
- **Keywords:** humility modesty meekness simplicity

---

### 42. Sincerity (الإخلاص)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Purifying intentions solely for Allah
- **Common Triggers:** Worship charity knowledge
- **Primary Negative Attributes:** Riya
- **Secondary Negative Attributes:** Ujb
- **Primary Positive Attributes:** Ikhlas;Ihsan
- **Growth Path:** `Ikhlas→Ihsan→Mahabbah→Wilayah`
- **Recommended Attribute Priority:** Ikhlas
- **Recommended Intervention Type:** Reflection
- **Recommended Dua:** Allahumma inni a'udhu bika an ushrika bika wa ana a'lam
- **Recommended Allah Names:** Al-Wahid;Ash-Shahid;Al-Basir
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Hide one righteous deed from people
- **Related Emotions:** Humility;Trust;Nearness to Allah
- **Related Attribute IDs:** 91;194;198
- **Keywords:** sincerity purity intention devotion

---

### 43. Trust (الثقة بالله)

- **Category:** Positive
- **Severity:** 2 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Relying upon Allah while taking lawful means
- **Common Triggers:** Trials uncertainty
- **Primary Negative Attributes:** Fear
- **Secondary Negative Attributes:** Weak Yaqeen
- **Primary Positive Attributes:** Tawakkul;Ridha
- **Growth Path:** `Tawakkul→Ridha→Sakinah→Yaqeen`
- **Recommended Attribute Priority:** Tawakkul
- **Recommended Intervention Type:** Dua
- **Recommended Dua:** Hasbiyallahu la ilaha illa huwa
- **Recommended Allah Names:** Al-Wakil;Al-Hafiz;Ar-Razzaq
- **Recommended Dhikr:** Hasbunallahu wa ni'mal wakeel
- **Daily Action:** Entrust one unresolved affair to Allah
- **Related Emotions:** Certainty;Peace;Hope
- **Related Attribute IDs:** 176;34;185
- **Keywords:** trust reliance confidence dependence

---

### 44. Certainty (اليقين)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Firm conviction in Allah and His promises
- **Common Triggers:** Dhikr knowledge worship
- **Primary Negative Attributes:** Shakk
- **Secondary Negative Attributes:** Weak Faith
- **Primary Positive Attributes:** Yaqeen;Tawakkul;Sakinah
- **Growth Path:** `Yaqeen→Tawakkul→Sakinah→Ridha`
- **Recommended Attribute Priority:** Yaqeen
- **Recommended Intervention Type:** Knowledge
- **Recommended Dua:** Rabbi zidni ilma
- **Recommended Allah Names:** Al-Haqq;An-Nur;Al-Alim
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Reflect on Allah's signs and blessings
- **Related Emotions:** Trust;Tranquility;Hope
- **Related Attribute IDs:** 178;176;185
- **Keywords:** certainty conviction faith assurance

---

### 45. Reverence (الخشية)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Awe and deep respect for Allah
- **Common Triggers:** Knowledge Quran reflection
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Qaswah
- **Primary Positive Attributes:** Khashyah;Khushu
- **Growth Path:** `Khashyah→Khushu→Mahabbah→Ihsan`
- **Recommended Attribute Priority:** Khashyah
- **Recommended Intervention Type:** Quran
- **Recommended Dua:** Allahumma inni as'aluka khashyataka
- **Recommended Allah Names:** Al-Jalil;Al-Azim;Al-Quddus
- **Recommended Dhikr:** SubhanAllah
- **Daily Action:** Read Quran slowly with reflection
- **Related Emotions:** Tranquility;Love for Allah;Repentance
- **Related Attribute IDs:** 168;148;170
- **Keywords:** reverence awe fear of Allah

---

### 46. Tranquility (السكينة)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Inner serenity and calm bestowed by Allah
- **Common Triggers:** Dhikr tawakkul contentment
- **Primary Negative Attributes:** Idtirab
- **Secondary Negative Attributes:** Hamm
- **Primary Positive Attributes:** Sakinah;Yaqeen;Ridha
- **Growth Path:** `Sakinah→Ridha→Mahabbah→Liqa Allah`
- **Recommended Attribute Priority:** Sakinah
- **Recommended Intervention Type:** Dhikr
- **Recommended Dua:** Allahumma ati nafsi taqwaha
- **Recommended Allah Names:** As-Salam;Al-Mumin;An-Nur
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Spend quiet time in remembrance of Allah
- **Related Emotions:** Peace;Trust;Contentment
- **Related Attribute IDs:** 185;178;34
- **Keywords:** tranquility serenity calm inner peace

---

### 47. Repentance (التوبة)

- **Category:** Positive
- **Severity:** 2 / 10
- **Dominant Nafs State:** Mulhamah
- **Description:** Returning to Allah after mistakes or sins
- **Common Triggers:** Sins remorse awareness
- **Primary Negative Attributes:** Ya's
- **Secondary Negative Attributes:** Qunut
- **Primary Positive Attributes:** Tawbah;Inabah;Raja
- **Growth Path:** `Tawbah→Inabah→Raja→Mahabbah`
- **Recommended Attribute Priority:** Tawbah
- **Recommended Intervention Type:** Repentance
- **Recommended Dua:** Sayyid al-Istighfar
- **Recommended Allah Names:** At-Tawwab;Al-Ghafur;Al-Afuww
- **Recommended Dhikr:** Astaghfirullah wa atubu ilayh
- **Daily Action:** Repent immediately and increase good deeds
- **Related Emotions:** Hope;Humility;Love for Allah
- **Related Attribute IDs:** 164;165;56
- **Keywords:** repentance return forgiveness remorse

---

### 48. Spiritual Longing (الشوق إلى الله)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Yearning for Allah and the Hereafter
- **Common Triggers:** Dhikr Quran worship
- **Primary Negative Attributes:** Hubb ad-Dunya
- **Secondary Negative Attributes:** Ghaflah
- **Primary Positive Attributes:** Shawq ila Allah;Mahabbah
- **Growth Path:** `Shawq→Mahabbah→Liqa Allah→Ridhwan Allah`
- **Recommended Attribute Priority:** Shawq ila Allah
- **Recommended Intervention Type:** Dhikr
- **Recommended Dua:** Allahumma inni as'aluka ladhdhata an-nazari ila wajhik
- **Recommended Allah Names:** Al-Wadud;Ar-Rahman;Al-Karim
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Increase voluntary worship and Quran recitation
- **Related Emotions:** Love for Allah;Tranquility;Nearness to Allah
- **Related Attribute IDs:** 182;170;193
- **Keywords:** yearning longing desire for Allah

---

### 49. Happiness in Worship (حلاوة العبادة)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Experiencing joy and sweetness in worship
- **Common Triggers:** Consistent obedience sincerity
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Kasal
- **Primary Positive Attributes:** Halawat al-Iman;Mahabbah
- **Growth Path:** `Halawat al-Iman→Mahabbah→Uns billah→Ihsan`
- **Recommended Attribute Priority:** Halawat al-Iman
- **Recommended Intervention Type:** Salah
- **Recommended Dua:** Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik
- **Recommended Allah Names:** Al-Wadud;Ash-Shakur;Ar-Rahman
- **Recommended Dhikr:** SubhanAllah walhamdulillah wa la ilaha illa Allah wallahu akbar
- **Daily Action:** Perform one voluntary act of worship with reflection
- **Related Emotions:** Love for Allah;Gratitude;Tranquility
- **Related Attribute IDs:** 172;170;185
- **Keywords:** sweetness worship joy devotion

---

### 50. Nearness to Allah (القرب من الله)

- **Category:** Positive
- **Severity:** 1 / 10
- **Dominant Nafs State:** Mutmainnah
- **Description:** Feeling closeness and companionship with Allah
- **Common Triggers:** Consistent worship sincerity and remembrance
- **Primary Negative Attributes:** Ghaflah
- **Secondary Negative Attributes:** Hubb ad-Dunya
- **Primary Positive Attributes:** Wilayah;Ihsan;Mahabbah
- **Growth Path:** `Wilayah→Ihsan→Ridhwan Allah→Fawz al-Azim`
- **Recommended Attribute Priority:** Wilayah
- **Recommended Intervention Type:** Dhikr
- **Recommended Dua:** Allahumma inni as'aluka ridaka wal-jannah
- **Recommended Allah Names:** Al-Wali;Al-Wadud;Ar-Rahim
- **Recommended Dhikr:** La ilaha illa Allah
- **Daily Action:** Increase hidden worship and remembrance daily
- **Related Emotions:** Love for Allah;Spiritual Longing;Tranquility
- **Related Attribute IDs:** 198;194;193
- **Keywords:** closeness intimacy friendship with Allah

---

