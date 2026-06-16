# `emotions` — 50 Core Emotions

> The 50 emotions a user can log in Heart OS v1.
> **Source of truth:** `50-cores.xlsx` (parent directory)
> **Full data:** `HeartOS/07_appendices/50_core_emotions.md`
> **JSON seed:** `assets/seeds/emotions_seed.sample.json` (2-row sample) → full in `assets/data/emotions_seed.json`
> **Generated:** 2026-06-12

---

## Schema (21 columns)

| Col | Type | Notes |
|---|---|---|
| `Emotion_ID` | INTEGER PK | 1–50 |
| `Core_Emotion` | TEXT | English name |
| `Arabic_Name` | TEXT | e.g. الغضب |
| `Category` | TEXT | `Negative` or `Positive` |
| `Description` | TEXT | one-sentence |
| `Common_Triggers` | TEXT | what usually triggers it |
| `Primary_Negative_Attributes` | TEXT | `;`-separated |
| `Secondary_Negative_Attributes` | TEXT | `;`-separated |
| `Primary_Positive_Attributes` | TEXT | `;`-separated |
| `Growth_Path` | TEXT | e.g. `Ghadab→Sabr→Hilm→Rifq` |
| `Dominant_Nafs_State` | TEXT | one of the 4 Nafs states |
| `Severity_Weight` | INTEGER | 1–10, default severity |
| `Recommended_Attribute_Priority` | TEXT | which attribute to address first |
| `Recommended_Intervention_Type` | TEXT | e.g. `Patience`, `Dua`, `Gratitude` |
| `Recommended_Dua` | TEXT | the dua text |
| `Recommended_Allah_Names` | TEXT | `;`-separated |
| `Recommended_Dhikr` | TEXT | e.g. `SubhanAllahi wa bihamdihi` |
| `Daily_Action` | TEXT | one micro-action |
| `Related_Emotions` | TEXT | `;`-separated IDs or names |
| `Related_Attribute_IDs` | TEXT | `;`-separated attribute IDs |
| `Keywords` | TEXT | search tokens |

---

## Distribution

- **30 Negative** (IDs 1–30) — 10 highly severe (severity 8–9: Anger, Jealousy, Arrogance, Showing Off, Love of Dunya, Hard-heartedness, Weak Faith, Hopelessness, Stinginess, Envy of Status, Laziness)
- **20 Positive** (IDs 31–50) — all Mulhamah/Mutmainnah

> **Note:** The xlsx distribution is 30 Negative / 20 Positive. The narrative appendix stated "40 Negative · 10 Positive" — corrected in the 2026-06-12 reaudit.

---

## Quick Reference Table (50 rows)

| ID | Emotion | Arabic | Cat. | Severity | Nafs | Growth Path |
|---:|---|---|---|---:|---|---|
| 1 | **Anger** | الغضب | Negative | 8 | Ammarah | `Ghadab->Sabr->Hilm->Rifq` |
| 2 | **Jealousy** | الحسد | Negative | 9 | Ammarah | `Hasad->Shukr->Qanaah->Ridha` |
| 3 | **Anxiety** | القلق | Negative | 7 | Lawwamah | `Anxiety->Tawakkul->Yaqeen->Sakinah` |
| 4 | **Fear** | الخوف | Negative | 7 | Lawwamah | `Fear->Tawakkul->Yaqeen->Sakinah` |
| 5 | **Sadness** | الحزن | Negative | 6 | Lawwamah | `Huzn->Sabr->Raja->Husn az-Zann` |
| 6 | **Hopelessness** | اليأس | Negative | 9 | Lawwamah | `Ya's->Raja->Husn az-Zann->Mahabbah` |
| 7 | **Guilt** | الندم | Negative | 5 | Lawwamah | `Guilt->Tawbah->Inabah->Ikhlas` |
| 8 | **Laziness** | الكسل | Negative | 8 | Ammarah | `Kasal->Himmah->Mujahadah->Istiqamah` |
| 9 | **Loneliness** | الوحدة | Negative | 6 | Lawwamah | `Loneliness->Dhikr->Uns billah->Sakinah` |
| 10 | **Emptiness** | الفراغ الروحي | Negative | 8 | Lawwamah | `Emptiness->Yaqzah->Dhikr->Uns bil-Quran` |
| 11 | **Arrogance** | الكبر | Negative | 9 | Ammarah | `Kibr->Tawadu->Ikhlas` |
| 12 | **Pride** | العجب | Negative | 8 | Ammarah | `Ujb->Tawadu->Shukr` |
| 13 | **Showing Off** | الرياء | Negative | 9 | Ammarah | `Riya->Ikhlas->Ihsan` |
| 14 | **Greed** | الطمع | Negative | 8 | Ammarah | `Tama->Qanaah->Ridha` |
| 15 | **Love of Dunya** | حب الدنيا | Negative | 9 | Ammarah | `Hubb ad-Dunya->Zuhd->Ridha` |
| 16 | **Hatred** | الحقد | Negative | 8 | Ammarah | `Hiqd->Afw->Rahmah->Hilm` |
| 17 | **Desire for Revenge** | الانتقام | Negative | 8 | Ammarah | `Intiqam->Afw->Sabr->Hilm` |
| 18 | **Suspicion** | سوء الظن | Negative | 7 | Lawwamah | `Su az-Zann->Husn az-Zann->Ukhuwwah` |
| 19 | **Doubt** | الشك | Negative | 8 | Lawwamah | `Shakk->Yaqeen->Tawakkul` |
| 20 | **Confusion** | الحيرة | Negative | 6 | Lawwamah | `Hirah->Basirah->Istikharah->Tawakkul` |
| 21 | **Distractedness** | الغفلة | Negative | 8 | Lawwamah | `Ghaflah->Yaqzah->Dhikr->Muraqabah` |
| 22 | **Weak Faith** | ضعف الإيمان | Negative | 9 | Lawwamah | `Weak Faith->Yaqeen->Tawakkul->Sakinah` |
| 23 | **Impatience** | قلة الصبر | Negative | 7 | Lawwamah | `Jaza->Sabr->Ridha->Sakinah` |
| 24 | **Hard-heartedness** | قسوة القلب | Negative | 9 | Ammarah | `Qaswah->Dhikr->Khushu->Riqqah` |
| 25 | **Stinginess** | البخل | Negative | 8 | Ammarah | `Bukhl->Sakha->Shukr->Ridha` |
| 26 | **Excessive Attachment** | التعلق الزائد | Negative | 8 | Lawwamah | `Attachment->Tawakkul->Zuhd->Ridha` |
| 27 | **Envy of Status** | حب الجاه | Negative | 8 | Ammarah | `Hubb al-Jah->Ikhlas->Tawadu` |
| 28 | **Shame after Sin** | الخجل بعد الذنب | Negative | 6 | Lawwamah | `Taqsir->Tawbah->Raja->Mahabbah` |
| 29 | **Overthinking** | كثرة التفكير | Negative | 7 | Lawwamah | `Hamm->Basirah->Tawakkul->Sakinah` |
| 30 | **Restlessness** | الاضطراب | Negative | 7 | Lawwamah | `Restlessness->Dhikr->Yaqeen->Sakinah` |
| 31 | **Hope** | الأمل | Positive | 3 | Mulhamah | `Raja->Tawakkul->Sakinah->Yaqeen` |
| 32 | **Gratitude** | الشكر | Positive | 2 | Mutmainnah | `Shukr->Qanaah->Ridha->Tawakkul` |
| 33 | **Patience** | الصبر | Positive | 1 | Mulhamah | `Sabr->Tawakkul->Ridha->Sakinah` |
| 34 | **Love for the Prophet** | محبة النبي ﷺ | Positive | 1 | Mutmainnah | `Mahabbah->Ithar->Ittiba->Sunan` |
| 35 | **Love for Knowledge** | حب العلم | Positive | 2 | Mulhamah | `Ilm->Tafakkur->Basirah->Yaqeen` |
| 36 | **Generosity** | السخاء | Positive | 2 | Mulhamah | `Sakhawah->Jud->Ithar->Mahabbah` |
| 37 | **Courage** | الشجاعة | Positive | 3 | Mulhamah | `Shaja'ah->Thabat->Istiqamah->Siddiqiyyah` |
| 38 | **Justice** | العدل | Positive | 1 | Mulhamah | `Adl->Hikmah->Ihsan->Mahabbah` |
| 39 | **Contentment** | القناعة | Positive | 2 | Mutmainnah | `Qanaah->Ridha->Shukr->Tawakkul` |
| 40 | **Devotion** | الإخلاص في العبادة | Positive | 1 | Mutmainnah | `Ubudiyyah->Ikhlas->Ihsan->Wilayah` |
| 41 | **Humility** | التواضع | Positive | 2 | Mulhamah | `Tawadu->Ikhlas->Shukr->Mahabbah` |
| 42 | **Sincerity** | الإخلاص | Positive | 1 | Mutmainnah | `Ikhlas->Ihsan->Mahabbah->Wilayah` |
| 43 | **Trust** | الثقة بالله | Positive | 2 | Mutmainnah | `Tawakkul->Ridha->Sakinah->Yaqeen` |
| 44 | **Certainty** | اليقين | Positive | 1 | Mutmainnah | `Yaqeen->Tawakkul->Sakinah->Ridha` |
| 45 | **Reverence** | الخشية | Positive | 1 | Mutmainnah | `Khashyah->Khushu->Mahabbah->Ihsan` |
| 46 | **Tranquility** | السكينة | Positive | 1 | Mutmainnah | `Sakinah->Ridha->Mahabbah->Liqa Allah` |
| 47 | **Repentance** | التوبة | Positive | 2 | Mulhamah | `Tawbah->Inabah->Raja->Mahabbah` |
| 48 | **Spiritual Longing** | الشوق إلى الله | Positive | 1 | Mutmainnah | `Shawq->Mahabbah->Liqa Allah->Ridhwan Allah` |
| 49 | **Happiness in Worship** | حلاوة العبادة | Positive | 1 | Mutmainnah | `Halawat al-Iman->Mahabbah->Uns billah->Ihsan` |
| 50 | **Nearness to Allah** | القرب من الله | Positive | 1 | Mutmainnah | `Wilayah->Ihsan->Ridhwan Allah->Fawz al-Azim` |

---

## Full Data (all 21 columns)

| ID | Emotion | Arabic | Cat. | Sev | Nafs | Growth Path | Priority | Intervention | Primary_Neg | Primary_Pos |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | Anger | الغضب | Negative | 8 | Ammarah | Ghadab->Sabr->Hilm->Rifq | Ghadab | Patience | Ghadab | Sabr;Hilm;Rifq |
| 2 | Jealousy | الحسد | Negative | 9 | Ammarah | Hasad->Shukr->Qanaah->Ridha | Hasad | Gratitude | Hasad | Shukr;Qanaah;Ridha |
| 3 | Anxiety | القلق | Negative | 7 | Lawwamah | Anxiety->Tawakkul->Yaqeen->Sakinah | Tawakkul | Dua | Weak Tawakkul | Tawakkul;Yaqeen;Sakinah |
| 4 | Fear | الخوف | Negative | 7 | Lawwamah | Fear->Tawakkul->Yaqeen->Sakinah | Khawf | Dua | Khawf imbalance | Tawakkul;Raja;Yaqeen |
| 5 | Sadness | الحزن | Negative | 6 | Lawwamah | Huzn->Sabr->Raja->Husn az-Zann | Sabr | Patience | Huzn excessive | Sabr;Raja;Husn az-Zann |
| 6 | Hopelessness | اليأس | Negative | 9 | Lawwamah | Ya's->Raja->Husn az-Zann->Mahabbah | Raja | Repentance | Ya's | Raja;Tawbah;Husn az-Zann |
| 7 | Guilt | الندم | Negative | 5 | Lawwamah | Guilt->Tawbah->Inabah->Ikhlas | Tawbah | Repentance | Taqsir | Tawbah;Inabah;Ikhlas |
| 8 | Laziness | الكسل | Negative | 8 | Ammarah | Kasal->Himmah->Mujahadah->Istiqamah | Himmah | Physical Action | Kasal | Himmah;Mujahadah;Istiqamah |
| 9 | Loneliness | الوحدة | Negative | 6 | Lawwamah | Loneliness->Dhikr->Uns billah->Sakinah | Dhikr | Social Connection | Ghaflah | Uns billah;Dhikr;Mahabbah |
| 10 | Emptiness | الفراغ الروحي | Negative | 8 | Lawwamah | Emptiness->Yaqzah->Dhikr->Uns bil-Quran | Yaqzah | Quran | Ghaflah | Yaqzah;Dhikr;Uns bil-Quran |
| 11 | Arrogance | الكبر | Negative | 9 | Ammarah | Kibr->Tawadu->Ikhlas | Tawadu | Reflection | Kibr | Tawadu;Ikhlas |
| 12 | Pride | العجب | Negative | 8 | Ammarah | Ujb->Tawadu->Shukr | Tawadu | Gratitude | Ujb | Tawadu;Shukr |
| 13 | Showing Off | الرياء | Negative | 9 | Ammarah | Riya->Ikhlas->Ihsan | Ikhlas | Repentance | Riya | Ikhlas;Ihsan |
| 14 | Greed | الطمع | Negative | 8 | Ammarah | Tama->Qanaah->Ridha | Qanaah | Gratitude | Tama | Qanaah;Shukr |
| 15 | Love of Dunya | حب الدنيا | Negative | 9 | Ammarah | Hubb ad-Dunya->Zuhd->Ridha | Zuhd | Reflection | Hubb ad-Dunya | Zuhd;Akhirah Orientation |
| 16 | Hatred | الحقد | Negative | 8 | Ammarah | Hiqd->Afw->Rahmah->Hilm | Afw | Forgiveness | Hiqd | Afw;Rahmah;Hilm |
| 17 | Desire for Revenge | الانتقام | Negative | 8 | Ammarah | Intiqam->Afw->Sabr->Hilm | Afw | Patience | Intiqam | Afw;Sabr;Hilm |
| 18 | Suspicion | سوء الظن | Negative | 7 | Lawwamah | Su az-Zann->Husn az-Zann->Ukhuwwah | Husn az-Zann | Reflection | Su az-Zann | Husn az-Zann;Ukhuwwah |
| 19 | Doubt | الشك | Negative | 8 | Lawwamah | Shakk->Yaqeen->Tawakkul | Yaqeen | Knowledge | Shakk | Yaqeen;Tawakkul |
| 20 | Confusion | الحيرة | Negative | 6 | Lawwamah | Hirah->Basirah->Istikharah->Tawakkul | Basirah | Knowledge | Hirah | Basirah;Istikharah |
| 21 | Distractedness | الغفلة | Negative | 8 | Lawwamah | Ghaflah->Yaqzah->Dhikr->Muraqabah | Dhikr | Dhikr | Ghaflah | Dhikr;Yaqzah;Muraqabah |
| 22 | Weak Faith | ضعف الإيمان | Negative | 9 | Lawwamah | Weak Faith->Yaqeen->Tawakkul->Sakinah | Yaqeen | Quran | Weak Yaqeen | Yaqeen;Tawakkul;Dhikr |
| 23 | Impatience | قلة الصبر | Negative | 7 | Lawwamah | Jaza->Sabr->Ridha->Sakinah | Sabr | Patience | Jaza | Sabr;Ridha |
| 24 | Hard-heartedness | قسوة القلب | Negative | 9 | Ammarah | Qaswah->Dhikr->Khushu->Riqqah | Khushu | Quran | Qaswah | Riqqah;Dhikr;Khushu |
| 25 | Stinginess | البخل | Negative | 8 | Ammarah | Bukhl->Sakha->Shukr->Ridha | Sakha | Charity | Bukhl | Sakha;Shukr;Tawakkul |
| 26 | Excessive Attachment | التعلق الزائد | Negative | 8 | Lawwamah | Attachment->Tawakkul->Zuhd->Ridha | Tawakkul | Reflection | Taalluq | Tawakkul;Zuhd;Ridha |
| 27 | Envy of Status | حب الجاه | Negative | 8 | Ammarah | Hubb al-Jah->Ikhlas->Tawadu | Ikhlas | Reflection | Hubb al-Jah | Ikhlas;Tawadu |
| 28 | Shame after Sin | الخجل بعد الذنب | Negative | 6 | Lawwamah | Taqsir->Tawbah->Raja->Mahabbah | Tawbah | Repentance | Taqsir | Tawbah;Raja |
| 29 | Overthinking | كثرة التفكير | Negative | 7 | Lawwamah | Hamm->Basirah->Tawakkul->Sakinah | Tawakkul | Dua | Hamm | Tawakkul;Basirah |
| 30 | Restlessness | الاضطراب | Negative | 7 | Lawwamah | Restlessness->Dhikr->Yaqeen->Sakinah | Sakinah | Dhikr | Idtirab | Sakinah;Dhikr;Yaqeen |
| 31 | Hope | الأمل | Positive | 3 | Mulhamah | Raja->Tawakkul->Sakinah->Yaqeen | Raja | Dua | Ya's | Raja;Tawakkul |
| 32 | Gratitude | الشكر | Positive | 2 | Mutmainnah | Shukr->Qanaah->Ridha->Tawakkul | Shukr | Reflection | Kufr al-Ni'mah | Shukr;Qanaah;Ridha |
| 33 | Patience | الصبر | Positive | 1 | Mulhamah | Sabr->Tawakkul->Ridha->Sakinah | Sabr | Patience | Jaza | Sabr;Tawakkul;Ridha |
| 34 | Love for the Prophet | محبة النبي ﷺ | Positive | 1 | Mutmainnah | Mahabbah->Ithar->Ittiba->Sunan | Mahabbat ar-Rasul | Quran | Jafa | Mahabbat ar-Rasul;Ithar |
| 35 | Love for Knowledge | حب العلم | Positive | 2 | Mulhamah | Ilm->Tafakkur->Basirah->Yaqeen | Ilm | Quran | Jahl | Ilm;Tafakkur;Basirah |
| 36 | Generosity | السخاء | Positive | 2 | Mulhamah | Sakhawah->Jud->Ithar->Mahabbah | Sakhawah | Charity | Bukhl | Sakhawah;Jud;Ithar |
| 37 | Courage | الشجاعة | Positive | 3 | Mulhamah | Shaja'ah->Thabat->Istiqamah->Siddiqiyyah | Shaja'ah | Reflection | Jubn | Shaja'ah;Thabat;Istiqamah |
| 38 | Justice | العدل | Positive | 1 | Mulhamah | Adl->Hikmah->Ihsan->Mahabbah | Adl | Reflection | Zulm | Adl;Hikmah;Ihsan |
| 39 | Contentment | القناعة | Positive | 2 | Mutmainnah | Qanaah->Ridha->Shukr->Tawakkul | Qanaah | Reflection | Tama;Hirs | Qanaah;Ridha;Shukr |
| 40 | Devotion | الإخلاص في العبادة | Positive | 1 | Mutmainnah | Ubudiyyah->Ikhlas->Ihsan->Wilayah | Ubudiyyah | Worship | Shirk al-Asghar | Ubudiyyah;Ikhlas;Ihsan |
| 41 | Humility | التواضع | Positive | 2 | Mulhamah | Tawadu->Ikhlas->Shukr->Mahabbah | Tawadu | Service | Kibr | Tawadu;Ikhlas;Shukr |
| 42 | Sincerity | الإخلاص | Positive | 1 | Mutmainnah | Ikhlas->Ihsan->Mahabbah->Wilayah | Ikhlas | Reflection | Riya | Ikhlas;Ihsan |
| 43 | Trust | الثقة بالله | Positive | 2 | Mutmainnah | Tawakkul->Ridha->Sakinah->Yaqeen | Tawakkul | Dua | Fear | Tawakkul;Ridha |
| 44 | Certainty | اليقين | Positive | 1 | Mutmainnah | Yaqeen->Tawakkul->Sakinah->Ridha | Yaqeen | Knowledge | Shakk | Yaqeen;Tawakkul;Sakinah |
| 45 | Reverence | الخشية | Positive | 1 | Mutmainnah | Khashyah->Khushu->Mahabbah->Ihsan | Khashyah | Quran | Ghaflah | Khashyah;Khushu |
| 46 | Tranquility | السكينة | Positive | 1 | Mutmainnah | Sakinah->Ridha->Mahabbah->Liqa Allah | Sakinah | Dhikr | Idtirab | Sakinah;Yaqeen;Ridha |
| 47 | Repentance | التوبة | Positive | 2 | Mulhamah | Tawbah->Inabah->Raja->Mahabbah | Tawbah | Repentance | Ya's | Tawbah;Inabah;Raja |
| 48 | Spiritual Longing | الشوق إلى الله | Positive | 1 | Mutmainnah | Shawq->Mahabbah->Liqa Allah->Ridhwan Allah | Shawq ila Allah | Dhikr | Hubb ad-Dunya | Shawq ila Allah;Mahabbah |
| 49 | Happiness in Worship | حلاوة العبادة | Positive | 1 | Mutmainnah | Halawat al-Iman->Mahabbah->Uns billah->Ihsan | Halawat al-Iman | Salah | Ghaflah | Halawat al-Iman;Mahabbah |
| 50 | Nearness to Allah | القرب من الله | Positive | 1 | Mutmainnah | Wilayah->Ihsan->Ridhwan Allah->Fawz al-Azim | Wilayah | Dhikr | Ghaflah | Wilayah;Ihsan;Mahabbah |

---

## Recommended Interventions (Dua, Names, Dhikr, Action)

| ID | Emotion | Dua | Allah Names | Dhikr | Daily Action |
|---:|---|---|---|---|---|
| 1 | Anger | Allahumma ihdini li ahsani al-akhlaq | Al-Halim;Ar-Rahim;Ar-Rafiq | SubhanAllahi wa bihamdihi | Remain silent and perform wudu |
| 2 | Jealousy | Rabbana atina fid-dunya hasanah | Ash-Shakur;Al-Ghani;Al-Karim | Alhamdulillah | Count five blessings Allah has given you |
| 3 | Anxiety | Hasbiyallahu la ilaha illa huwa | Al-Wakil;Ar-Razzaq;Al-Hafiz | La hawla wa la quwwata illa billah | Entrust one major concern to Allah and continue taking means |
| 4 | Fear | Allahumma inni as'aluka khashyataka | Al-Hafiz;Al-Mumin;Al-Wakil | Hasbunallahu wa ni'mal wakeel | Read Ayat al-Kursi and make dua |
| 5 | Sadness | Rabbana afrigh alayna sabran | As-Sabur;Ar-Rahim;Al-Latif | La ilaha illa Anta subhanaka inni kuntu minaz-zalimin | Perform two rak'ahs and speak to Allah in dua |
| 6 | Hopelessness | Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah wa qina adhab an-nar | At-Tawwab;Al-Ghafur;Ar-Rahman | Astaghfirullah wa atubu ilayh | Read verses about Allah's mercy |
| 7 | Guilt | Sayyid al-Istighfar | At-Tawwab;Al-Ghafur;Al-Afuww | Astaghfirullah | Repent immediately and perform a good deed |
| 8 | Laziness | Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik | Al-Qawiyy;Al-Matin;Al-Hayy | La hawla wa la quwwata illa billah | Begin with a task that takes less than five minutes |
| 9 | Loneliness | Allahumma inni as'aluka hubbaka | Al-Wadud;Ar-Rahman;As-Salam | SubhanAllahi wa bihamdihi | Spend ten minutes with Quran or dhikr |
| 10 | Emptiness | Rabbi zidni ilma | An-Nur;Al-Hadi;Al-Wadud | SubhanAllah walhamdulillah wa la ilaha illa Allah wallahu akbar | Read one page of Quran with reflection |
| 11 | Arrogance | Allahumma inni a'udhu bika min sharri nafsi | Al-Kabir;Al-Haqq;Al-Hakim | SubhanAllahi wa bihamdihi | Remember your dependence upon Allah and serve others |
| 12 | Pride | Rabbana ma khalaqta hadha batila | Al-Khaliq;Ash-Shakur;Al-Hakim | Alhamdulillah | Thank Allah for every blessing and attribute it to Him |
| 13 | Showing Off | Allahumma inni a'udhu bika an ushrika bika wa ana a'lam | Al-Basir;Ash-Shahid;Al-Wahid | La ilaha illa Allah | Hide one good deed from everyone |
| 14 | Greed | Rabbana atina fid-dunya hasanah | Ar-Razzaq;Al-Ghani;Al-Karim | Alhamdulillah | Write three blessings you already possess |
| 15 | Love of Dunya | Allahumma la taj'alid-dunya akbara hammina | Al-Awwal;Al-Akhir;Al-Warith | La hawla wa la quwwata illa billah | Reflect on death and the Hereafter |
| 16 | Hatred | Rabbighfir li wa li ikhwanina | Ar-Rahman;Al-Afuww;Al-Barr | Astaghfirullah | Pray for the person you resent |
| 17 | Desire for Revenge | Rabbana afrigh alayna sabran | Al-Adl;Al-Halim;Ar-Rahim | Hasbunallahu wa ni'mal wakeel | Leave justice to Allah and avoid retaliation |
| 18 | Suspicion | Rabbana la tuzigh qulubana | Al-Alim;Al-Hakim;Al-Latif | Astaghfirullah | Assume the best unless clear evidence appears |
| 19 | Doubt | Rabbi zidni ilma | Al-Haqq;Al-Alim;An-Nur | La ilaha illa Allah | Seek authentic knowledge and avoid speculation |
| 20 | Confusion | Rabbi zidni ilma | Al-Hadi;Al-Hakim;An-Nur | SubhanAllah | Pray Istikharah and seek wise counsel |
| 21 | Distractedness | Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik | Al-Hadi;An-Nur;Al-Wadud | SubhanAllahi wa bihamdihi | Spend ten minutes without devices and recite Quran |
| 22 | Weak Faith | Rabbi zidni ilma | Al-Mumin;Al-Haqq;An-Nur | La ilaha illa Allah | Increase Quran recitation and salah |
| 23 | Impatience | Rabbana afrigh alayna sabran | As-Sabur;Al-Hakim;Ar-Rahim | Inna lillahi wa inna ilayhi rajiun | Delay reaction and trust Allah's timing |
| 24 | Hard-heartedness | Rabbana la tuzigh qulubana | Al-Latif;Ar-Rahman;Al-Barr | Astaghfirullah | Read Quran with reflection and visit the needy |
| 25 | Stinginess | Rabbana atina fid-dunya hasanah | Ar-Razzaq;Al-Karim;Al-Ghani | Alhamdulillah | Give something small in charity today |
| 26 | Excessive Attachment | Hasbiyallahu la ilaha illa huwa | Al-Wakil;Al-Wadud;Al-Qayyum | La hawla wa la quwwata illa billah | Detach from one unnecessary dependence |
| 27 | Envy of Status | Allahumma inni a'udhu bika an ushrika bika wa ana a'lam | Al-Wahid;Ash-Shahid;Al-Basir | La ilaha illa Allah | Perform a good deed secretly |
| 28 | Shame after Sin | Sayyid al-Istighfar | At-Tawwab;Al-Ghafur;Al-Afuww | Astaghfirullah wa atubu ilayh | Repent immediately and do a righteous deed |
| 29 | Overthinking | Allahumma aslih li sha'ni kullahu | Al-Hakim;Al-Wakil;Al-Hadi | Hasbunallahu wa ni'mal wakeel | Write down concerns and leave them to Allah |
| 30 | Restlessness | Allahumma ati nafsi taqwaha | As-Salam;Al-Mumin;An-Nur | La ilaha illa Allah | Spend fifteen minutes in quiet dhikr and reflection |
| 31 | Hope | Allahumma la taqumit qalbi ba'da idh hadaytani | Ar-Rahman;Ar-Raheem;Al-Kareem | La ilaha illa Allah | Make du'a for something you hope for |
| 32 | Gratitude | Alhamdulillah | Ash-Shakur;Al-Ghani;Al-Karim | Alhamdulillah | Recite Alhamdulillah 100 times |
| 33 | Patience | Rabbana afrigh alayna sabran | As-Sabur;Al-Hakim;Ar-Rahim | La ilaha illa Allah | Practice restraint in one situation today |
| 34 | Love for the Prophet | Allahumma salli ala Muhammad wa ala ali Muhammad | Al-Wadud;Ar-Rahim;Al-Kareem | Salawat | Send salawat upon the Prophet ﷺ 100 times |
| 35 | Love for Knowledge | Rabbi zidni ilma | Al-Alim;Al-Hakim;An-Nur | La ilaha illa Allah | Study one hadith or verse today |
| 36 | Generosity | Allahumma inni as'aluka al-afiyah | Al-Kareem;Al-Wahhab;Ar-Razzaq | Alhamdulillah | Give charity today no matter how small |
| 37 | Courage | Allahumma inni a'udhu bika min al-jubn | Al-Qawiyy;Al-Matin;An-Nasir | La ilaha illa Allah | Speak one truth today despite difficulty |
| 38 | Justice | Rabbana iftah baynana wa bayna qawmina bil-haqq | Al-Adl;Al-Hakam;Al-Haqq | La ilaha illa Allah | Be fair in one decision today |
| 39 | Contentment | Allahumma qanni'ni bima razaqtani | Al-Ghani;Ar-Razzaq;Al-Kareem | Alhamdulillah | Reflect on three blessings you have |
| 40 | Devotion | Allahumma inni a'udhu bika an ushrika bika shay'an wa ana a'lam | Al-Ahad;As-Samad;Al-Haqq | La ilaha illa Allah | Pray two rak'ahs with full presence |
| 41 | Humility | Allahumma inni a'udhu bika min sharri nafsi | Al-Kabir;Al-Hakim;Al-Barr | SubhanAllahi wa bihamdihi | Serve others quietly without seeking praise |
| 42 | Sincerity | Allahumma inni a'udhu bika an ushrika bika wa ana a'lam | Al-Wahid;Ash-Shahid;Al-Basir | La ilaha illa Allah | Hide one righteous deed from people |
| 43 | Trust | Hasbiyallahu la ilaha illa huwa | Al-Wakil;Al-Hafiz;Ar-Razzaq | Hasbunallahu wa ni'mal wakeel | Entrust one unresolved affair to Allah |
| 44 | Certainty | Rabbi zidni ilma | Al-Haqq;An-Nur;Al-Alim | La ilaha illa Allah | Reflect on Allah's signs and blessings |
| 45 | Reverence | Allahumma inni as'aluka khashyataka | Al-Jalil;Al-Azim;Al-Quddus | SubhanAllah | Read Quran slowly with reflection |
| 46 | Tranquility | Allahumma ati nafsi taqwaha | As-Salam;Al-Mumin;An-Nur | La ilaha illa Allah | Spend quiet time in remembrance of Allah |
| 47 | Repentance | Sayyid al-Istighfar | At-Tawwab;Al-Ghafur;Al-Afuww | Astaghfirullah wa atubu ilayh | Repent immediately and increase good deeds |
| 48 | Spiritual Longing | Allahumma inni as'aluka ladhdhata an-nazari ila wajhik | Al-Wadud;Ar-Rahman;Al-Karim | La ilaha illa Allah | Increase voluntary worship and Quran recitation |
| 49 | Happiness in Worship | Allahumma ainni ala dhikrika wa shukrika wa husni ibadatik | Al-Wadud;Ash-Shakur;Ar-Rahman | SubhanAllah walhamdulillah wa la ilaha illa Allah wallahu akbar | Perform one voluntary act of worship with reflection |
| 50 | Nearness to Allah | Allahumma inni as'aluka ridaka wal-jannah | Al-Wali;Al-Wadud;Ar-Rahim | La ilaha illa Allah | Increase hidden worship and remembrance daily |

---

## See also

- `HeartOS/07_appendices/50_core_emotions.md` — full detail section
- `HeartOS/01_core_tables/emotions.md` — schema discussion and distribution
- `HeartOS/assets/seeds/emotions_seed.sample.json` — JSON sample (2 rows)
- `50-cores.xlsx` (parent directory) — source of truth
- `HeartOS/AUDIT_REPORT.md` §2.3, §3.2 — distribution correction and duplicate removal
