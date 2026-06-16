# `attributes` — 200 Heart Attributes

> The 200 heart attributes that form the vocabulary of Heart OS v1.
> **Source of truth:** `200-Attributes.xlsx` (parent directory) + `NafsMutmainna-200-Attributes.docx`
> **Full data:** `HeartOS/07_appendices/200_attributes.md`
> **JSON seed:** `assets/seeds/attributes_seed.sample.json` (2-row sample) → full in `assets/data/attributes_seed.json`
> **Generated:** 2026-06-12

---

## Schema (23 columns)

| Col | Type | Notes |
|---|---|---|
| `Attribute_ID` | INTEGER PK | 1–200 |
| `Attribute` | TEXT | English name |
| `Arabic_Name` | TEXT | e.g. الرياء |
| `Nature` | TEXT | `Positive` or `Negative` |
| `Definition` | TEXT | One-sentence definition |
| `Opposite_Trait` | TEXT | e.g. Ikhlas |
| `Opposite_Arabic_Name` | TEXT | e.g. الإخلاص |
| `Keywords` | TEXT | comma-separated search tokens |
| `Quran_Reference` | TEXT | e.g. `Al-Ma'un 107:4-6` |
| `Quran_Arabic` | TEXT | verse text (Arabic) |
| `Quran_English` | TEXT | translation |
| `Quran_Urdu` | TEXT | translation |
| `Hadith_Reference` | TEXT | e.g. `Sahih Muslim 91` |
| `Hadith_Arabic` | TEXT | hadith text (Arabic) |
| `Hadith_Urdu` | TEXT | translation |
| `Quranic_Dua_Reference` | TEXT | optional |
| `Quranic_Dua_Arabic` | TEXT | |
| `Quranic_Dua_Urdu` | TEXT | |
| `Prophetic_Dua_Reference` | TEXT | optional |
| `Prophetic_Dua_Arabic` | TEXT | |
| `Prophetic_Dua_Urdu` | TEXT | |
| `Relevant_Allah_Names` | TEXT | comma-separated, e.g. `Al-Halim,Ar-Rahim` |
| `Practical_Understanding` | TEXT | 1–3 line practitioner note |

> **Note:** The quick-reference table below shows the 10 most essential columns. The full 23-column data (including Arabic/Urdu Quranic text, Hadith text, Duas, Allah Names, and Practical Understanding) is in the appendix and the xlsx source.

---

## Distribution

- **70 Negative** (IDs 1–70)
- **130 Positive** (IDs 71–200)

---

## Quick Reference Table (200 rows)

| ID | Attribute | Arabic | Nature | Opposite | Quran Ref | Hadith Ref |
|---:|---|---|---|---|---|---|
| 1 | **Riya** | الرياء | Negative | Seeking people's praise and recognition through acts intended for Allah. | Al-Ma'un 107:4-6 | Musnad Ahmad 23630 |
| 2 | **Kibr** | الكبر | Negative | Rejecting truth and considering oneself superior to others. | Luqman 31:18 | Sahih Muslim 91 |
| 3 | **Ujb** | العجب | Negative | Being impressed with oneself and one's achievements. | An-Najm 53:32 | Sahih Muslim 2749 |
| 4 | **Nifaq** | النفاق | Negative | Difference between outward appearance and inward reality. | Al-Baqarah 2:8-9 | Sahih al-Bukhari 33; Sahih Muslim 59 |
| 5 | **Sum'ah** | السُّمعة | Negative | Seeking fame and recognition through good deeds. | Al-Qasas 28:83 | Sahih al-Bukhari 6499; Sahih Muslim 2987 |
| 6 | **Kufr al-Ni'mah** | كفر النعمة | Negative | Failing to recognize and appreciate Allah's blessings. | Ibrahim 14:7 | Sahih Muslim 2734 |
| 7 | **Ghurur** | الغرور | Negative | Being deceived by worldly life or false hopes. | Luqman 31:33 | Sahih Muslim 2959 |
| 8 | **Irtiyab** | الارتياب | Negative | Persistent doubt and uncertainty regarding faith. | Al-Hujurat 49:15 | Sahih Muslim 134 |
| 9 | **Qasawat al-Qalb** | قسوة القلب | Negative | Hardness and lack of spiritual sensitivity in the heart. | Al-Hadid 57:16 | Sahih Muslim 7028 |
| 10 | **Ghaflah** | الغفلة | Negative | Heedlessness and neglect of Allah and the Hereafter. | Al-A'raf 7:205 | Sahih al-Bukhari 6407 |
| 11 | **Amn min Makrillah** | الأمن من مكر الله | Negative | False security from Allah's punishment. | Al-A'raf 7:99 | Sahih al-Bukhari 6607 |
| 12 | **Tul al-Amal** | طول الأمل | Negative | Having excessive worldly hopes and forgetting death. | Al-Hijr 15:3 | Sahih al-Bukhari 6417 |
| 13 | **Ittiba al-Hawa** | اتباع الهوى | Negative | Following desires over divine guidance. | Al-Jathiyah 45:23 | Sahih Muslim 2657 |
| 14 | **Yas** | اليأس | Negative | Despairing of Allah's mercy. | Az-Zumar 39:53 | Sahih Muslim 2755 |
| 15 | **Shirk al-Asghar** | الشرك الأصغر | Negative | Subtle forms of associating partners with Allah. | Luqman 31:13 | Musnad Ahmad 23630 |
| 16 | **Karahiyyat al-Mawt** | كراهية الموت | Negative | Excessive dislike of death due to attachment to worldly life. | Al-Jumu'ah 62:8 | Sahih al-Bukhari 6412 |
| 17 | **Sukhriyyah** | السخرية | Negative | Mocking and ridiculing others. | Al-Hujurat 49:11 | Sahih Muslim 2564 |
| 18 | **Tazkiyat an-Nafs al-Madhmumah** | تزكية النفس المذمومة | Negative | Self-justification and falsely claiming purity. | An-Najm 53:32 | Sahih Muslim 2865 |
| 19 | **Taassub** | التعصب | Negative | Blind partisanship and fanaticism. | Al-Ma'idah 5:8 | Sahih Muslim 1848 |
| 20 | **Wahn** | الوهن | Negative | Weakness caused by excessive love of worldly life and dislike of death. | Al-Anfal 8:46 | Sunan Abu Dawud 4297 |
| 21 | **Hasad** | الحسد | Negative | Wishing the removal of blessings from others. | Al-Falaq 113:5 | Sahih Muslim 2564 |
| 22 | **Hiqd** | الحقد | Negative | Harboring grudges and resentment. | Al-Hashr 59:10 | Sahih Muslim 2563 |
| 23 | **Ghadab** | الغضب | Negative | Uncontrolled anger. | Ali Imran 3:134 | Sahih al-Bukhari 6116 |
| 24 | **Bukhl** | البخل | Negative | Miserliness and withholding good. | Ali Imran 3:180 | Sahih Muslim 1021 |
| 25 | **Shuhh** | الشح | Negative | Greedy selfishness. | Al-Hashr 59:9 | Sahih Muslim 2578 |
| 26 | **Tama** | الطمع | Negative | Excessive covetousness. | At-Takathur 102:1 | Sahih Muslim 1051 |
| 27 | **Hubb ad-Dunya** | حب الدنيا | Negative | Excessive attachment to worldly life. | Al-Hadid 57:20 | Sahih Muslim 2956 |
| 28 | **Takathur** | التكاثر | Negative | Competing for worldly abundance. | At-Takathur 102:1 | Sahih al-Bukhari 6436 |
| 29 | **Kadhib** | الكذب | Negative | Speaking falsehood. | At-Tawbah 9:119 | Sahih al-Bukhari 6094 |
| 30 | **Khiyanah** | الخيانة | Negative | Betrayal of trusts. | Al-Anfal 8:27 | Sahih al-Bukhari 33 |
| 31 | **Gheebah** | الغيبة | Negative | Mentioning about a person what he dislikes in his absence. | Al-Hujurat 49:12 | Sahih Muslim 2589 |
| 32 | **Namimah** | النميمة | Negative | Carrying tales between people to create discord. | Al-Qalam 68:11 | Sahih Muslim 105 |
| 33 | **Su' al-Dhann** | سوء الظن | Negative | Having evil suspicion about others. | Al-Hujurat 49:12 | Sahih al-Bukhari 6066; Sahih Muslim 2563 |
| 34 | **Tajassus** | التجسس | Negative | Spying and searching for people's faults. | Al-Hujurat 49:12 | Sahih Muslim 2564 |
| 35 | **Fuhsh** | الفحش | Negative | Obscene and indecent speech or behavior. | Al-A'raf 7:33 | Sahih al-Bukhari 6117 |
| 36 | **Sabb** | السب | Negative | Insulting and abusing others. | Al-Hujurat 49:11 | Sahih al-Bukhari 6044 |
| 37 | **La'n** | اللعن | Negative | Habitually cursing others. | Al-Ahzab 58 | Sahih Muslim 2597 |
| 38 | **Jidal** | الجدال | Negative | Argumentation leading to hostility. | An-Nahl 16:125 | Jami' at-Tirmidhi 1993 |
| 39 | **Mira'** | المراء | Negative | Disputation and unnecessary controversy. | Al-Kahf 18:54 | Jami' at-Tirmidhi 1993 |
| 40 | **Istihza'** | الاستهزاء | Negative | Mocking and ridiculing people or religious matters. | Al-Hujurat 49:11 | Sahih Muslim 2564 |
| 41 | **Shahadat az-Zur** | شهادة الزور | Negative | Giving false testimony. | Al-Hajj 22:30 | Sahih al-Bukhari 2654 |
| 42 | **Ikhlaf al-Wa'd** | إخلاف الوعد | Negative | Breaking promises. | Al-Isra 17:34 | Sahih al-Bukhari 33 |
| 43 | **Qaswah fi al-Mu'amalah** | القسوة | Negative | Harshness and severity toward others. | Ali Imran 3:159 | Sahih Muslim 2593 |
| 44 | **Su' al-Khuluq** | سوء الخلق | Negative | Bad manners and character. | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 45 | **Hijran al-Muslim** | هجر المسلم | Negative | Boycotting a Muslim without a valid reason. | Al-Hujurat 49:10 | Sahih al-Bukhari 6077 |
| 46 | **Hubb al-Madh** | حب المدح | Negative | Love of praise and admiration. | An-Najm 53:32 | Sahih Muslim 3001 |
| 47 | **Tafakhur** | التفاخر | Negative | Boasting about wealth, lineage or status. | At-Takathur 102:1 | Sahih Muslim 2865 |
| 48 | **Ta'ali** | التعالي | Negative | Looking down upon others. | Al-Hujurat 49:13 | Sahih Muslim 2564 |
| 49 | **Raghbah fi ad-Dunya** | الرغبة في الدنيا | Negative | Overeagerness for worldly gain. | Al-Hadid 57:20 | Sahih al-Bukhari 6416 |
| 50 | **Ujub bi al-'Amal** | العجب بالعمل | Negative | Being impressed with one's deeds. | An-Najm 53:32 | Sahih Muslim 2818 |
| 51 | **Kasal** | الكسل | Negative | Laziness and reluctance in beneficial actions. | An-Najm 53:39 | Sahih al-Bukhari 6369 |
| 52 | **Ajz** | العجز | Negative | Helplessness caused by abandoning means. | Al-Anfal 8:60 | Sahih Muslim 2664 |
| 53 | **Jubn** | الجبن | Negative | Cowardice and fear preventing obedience. | Al-Imran 3:175 | Sahih al-Bukhari 6374 |
| 54 | **Hirs** | الحرص | Negative | Excessive greed and eagerness for worldly gain. | At-Takathur 102:1 | Sahih Muslim 1051 |
| 55 | **Israaf** | الإسراف | Negative | Exceeding limits and extravagance. | Al-A'raf 7:31 | Sahih al-Bukhari 6091 |
| 56 | **Tabdhir** | التبذير | Negative | Squandering wealth uselessly. | Al-Isra 17:26-27 | Sahih Muslim 593 |
| 57 | **Ghaflah an al-Mawt** | الغفلة عن الموت | Negative | Neglecting remembrance of death. | Al-Jumu'ah 62:8 | Jami' at-Tirmidhi 2307 |
| 58 | **Qat' ar-Rahim** | قطع الرحم | Negative | Severing family ties. | Muhammad 47:22-23 | Sahih al-Bukhari 5984 |
| 59 | **Zulm** | الظلم | Negative | Oppression and injustice. | Ash-Shura 42:42 | Sahih Muslim 2577 |
| 60 | **Qanut min Rahmatillah** | القنوط من رحمة الله | Negative | Losing hope in Allah's mercy. | Az-Zumar 39:53 | Sahih Muslim 2755 |
| 61 | **Riya** | الرياء | Negative | Performing deeds to be seen by people. | Al-Bayyinah 98:5 | Sahih Muslim 2985 |
| 62 | **Kibr** | الكبر | Negative | Rejecting truth and looking down upon others. | An-Nahl 16:23 | Sahih Muslim 91 |
| 63 | **Ghurur** | الغرور | Negative | Being deceived by worldly life or oneself. | Luqman 31:33 | Sahih al-Bukhari 6416 |
| 64 | **Ghaflah** | الغفلة | Negative | Heedlessness regarding Allah and the Hereafter. | Al-Anbiya 21:1 | Sahih Muslim 2676 |
| 65 | **Qaswat al-Qalb** | قسوة القلب | Negative | Hardness of the heart. | Al-Hadid 57:16 | Sahih Muslim 2750 |
| 66 | **Shakk** | الشك | Negative | Persistent doubt in matters clearly established. | Al-Baqarah 2:2 | Sahih Muslim 134 |
| 67 | **Nifaq** | النفاق | Negative | Hypocrisy between inner belief and outward conduct. | An-Nisa 4:145 | Sahih al-Bukhari 33 |
| 68 | **Taswif** | التسويف | Negative | Procrastination in repentance and obedience. | Al-Munafiqun 63:10 | Sahih al-Bukhari 6416 |
| 69 | **Qillat ash-Shukr** | قلة الشكر | Negative | Failure to appreciate Allah's blessings. | Ibrahim 14:7 | Sahih Muslim 2819 |
| 70 | **Qillat as-Sabr** | قلة الصبر | Negative | Weakness in perseverance and endurance. | Al-Baqarah 2:153 | Sahih Muslim 1053 |
| 71 | **Tawbah** | التوبة | Positive | Returning to Allah after sin with regret and resolve. | At-Tahrim 66:8 | Sahih Muslim 2749 |
| 72 | **Ikhlas** | الإخلاص | Positive | Purifying intentions solely for Allah. | Al-Bayyinah 98:5 | Sahih al-Bukhari 1 |
| 73 | **Sidq** | الصدق | Positive | Truthfulness in speech and conduct. | At-Tawbah 9:119 | Sahih al-Bukhari 6094 |
| 74 | **Taqwa** | التقوى | Positive | Consciousness and fear of Allah leading to obedience. | Al-Baqarah 2:197 | Sahih Muslim 2564 |
| 75 | **Sabr** | الصبر | Positive | Perseverance and endurance upon truth. | Al-Baqarah 2:153 | Sahih Muslim 1053 |
| 76 | **Shukr** | الشكر | Positive | Recognizing and appreciating Allah's blessings. | Ibrahim 14:7 | Sahih Muslim 2819 |
| 77 | **Tawakkul** | التوكل | Positive | Relying upon Allah while taking lawful means. | Ali Imran 3:159 | Sahih al-Bukhari 6470 |
| 78 | **Khawf** | الخوف | Positive | Fear of Allah that prevents sin. | Ali Imran 3:175 | Sahih Muslim 2758 |
| 79 | **Raja** | الرجاء | Positive | Hope in Allah's mercy and reward. | Az-Zumar 39:53 | Sahih Muslim 2877 |
| 80 | **Yaqin** | اليقين | Positive | Firm certainty in Allah and His promises. | Al-Baqarah 2:2 | Sahih Muslim 8 |
| 81 | **Zuhd** | الزهد | Positive | Detachment from worldly excess while utilizing lawful means. | Al-Hadid 57:20 | Sahih Ibn Majah 4102 |
| 82 | **Qana'ah** | القناعة | Positive | Contentment with Allah's provision. | Ta-Ha 20:131 | Sahih Muslim 1051 |
| 83 | **Wara'** | الورع | Positive | Avoiding doubtful matters out of fear of Allah. | Al-Baqarah 2:168 | Sahih al-Bukhari 52; Sahih Muslim 1599 |
| 84 | **Haya'** | الحياء | Positive | Modesty and shame before Allah and people. | Al-A'raf 7:26 | Sahih al-Bukhari 6117 |
| 85 | **Rifq** | الرفق | Positive | Gentleness and kindness in dealing with others. | Ali Imran 3:159 | Sahih Muslim 2593 |
| 86 | **Hilm** | الحلم | Positive | Forbearance and control over anger. | Ali Imran 3:134 | Sahih al-Bukhari 6114 |
| 87 | **Rahmah** | الرحمة | Positive | Showing compassion and mercy toward creation. | Al-Anbiya 21:107 | Sahih al-Bukhari 6013; Sahih Muslim 2319 |
| 88 | **Afw** | العفو | Positive | Pardoning others despite having the ability to retaliate. | Ash-Shura 42:40 | Sahih Muslim 2588 |
| 89 | **Safh** | الصفح | Positive | Overlooking faults and letting go of grievances. | An-Nur 24:22 | Sahih Muslim 2588 |
| 90 | **Ihsan** | الإحسان | Positive | Worshipping Allah as though you see Him and excelling in goodness. | An-Nahl 16:90 | Sahih Muslim 8 |
| 91 | **Mahabbah** | المحبة | Positive | Love of Allah above all else. | Al-Baqarah 2:165 | Sahih al-Bukhari 6502 |
| 92 | **Khushu'** | الخشوع | Positive | Humility and attentiveness of the heart in worship. | Al-Mu'minun 23:1-2 | Sahih Muslim 489 |
| 93 | **Inabah** | الإنابة | Positive | Constantly turning back to Allah. | Az-Zumar 39:54 | Sahih Muslim 2702 |
| 94 | **Uns billah** | الأنس بالله | Positive | Finding comfort and tranquility in Allah. | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 95 | **Muhasabah** | المحاسبة | Positive | Self-accountability before being judged. | Al-Hashr 59:18 | Sahih Muslim 2816 |
| 96 | **Muraqabah** | المراقبة | Positive | Living with awareness that Allah sees everything. | Qaf 50:16 | Sahih Muslim 8 |
| 97 | **Ikhbat** | الإخبات | Positive | Deep humility and submissiveness before Allah. | Al-Hajj 22:34 | Sahih Muslim 2865 |
| 98 | **Tawadu'** | التواضع | Positive | Humility toward Allah and people. | Al-Furqan 25:63 | Sahih Muslim 2588 |
| 99 | **Sakinah** | السكينة | Positive | Inner tranquility bestowed by Allah. | Al-Fath 48:4 | Sahih al-Bukhari 3614 |
| 100 | **Ridha** | الرضا | Positive | Content acceptance of Allah's decree. | Al-Bayyinah 98:8 | Sahih Muslim 2815 |
| 101 | **Shawq ila Allah** | الشوق إلى الله | Positive | Longing to meet and draw near to Allah. | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 102 | **Mahabbat ar-Rasul** | محبة الرسول ﷺ | Positive | Loving the Messenger ﷺ above all creation. | At-Tawbah 9:24 | Sahih al-Bukhari 15 |
| 103 | **Tafakkur** | التفكر | Positive | Deep reflection upon Allah's signs. | Ali Imran 3:191 | Sahih Muslim 2699 |
| 104 | **Tadhakkur** | التذكر | Positive | Remembering Allah and His favors. | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 105 | **Tafwid** | التفويض | Positive | Entrusting affairs completely to Allah. | Ghafir 40:44 | Sahih al-Bukhari 6369 |
| 106 | **Haybah** | الهيبة | Positive | Reverential awe of Allah. | Al-Hashr 59:21 | Sahih Muslim 2356 |
| 107 | **Basirah** | البصيرة | Positive | Inner insight and spiritual understanding. | Yusuf 12:108 | Sahih Muslim 2699 |
| 108 | **Firasah** | الفراسة | Positive | Perceptiveness granted to believers. | Al-Hijr 15:75 | Jami' at-Tirmidhi 3127 (Hasan) |
| 109 | **Samt** | الصمت | Positive | Guarding the tongue and speaking only good. | Qaf 50:18 | Sahih al-Bukhari 6475; Sahih Muslim 47 |
| 110 | **Husn az-Zann billah** | حسن الظن بالله | Positive | Having good expectations of Allah. | Az-Zumar 39:53 | Sahih Muslim 2877 |
| 111 | **Hikmah** | الحكمة | Positive | Putting things in their proper place and acting with sound judgment. | Al-Baqarah 2:269 | Sahih al-Bukhari 73 |
| 112 | **Adl** | العدل | Positive | Establishing justice and giving everyone their rights. | An-Nahl 16:90 | Sahih Muslim 1827 |
| 113 | **Amanah** | الأمانة | Positive | Trustworthiness in all responsibilities. | An-Nisa 4:58 | Sahih al-Bukhari 33 |
| 114 | **Wafa bil-Ahd** | الوفاء بالعهد | Positive | Honoring promises and commitments. | Al-Isra 17:34 | Sahih al-Bukhari 33 |
| 115 | **Shaja'ah** | الشجاعة | Positive | Courage in defending truth and fulfilling duties. | Al-Imran 3:175 | Sahih al-Bukhari 2820 |
| 116 | **Iffah** | العفة | Positive | Chastity and self-restraint. | An-Nur 24:33 | Sahih al-Bukhari 1469 |
| 117 | **Sakhawah** | السخاوة | Positive | Generosity and willingness to give. | Al-Baqarah 2:261 | Sahih al-Bukhari 6035 |
| 118 | **Ithar** | الإيثار | Positive | Preferring others over oneself. | Al-Hashr 59:9 | Sahih al-Bukhari 3798 |
| 119 | **Husn al-Khuluq** | حسن الخلق | Positive | Excellent manners and conduct. | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 120 | **Haya' min Allah** | الحياء من الله | Positive | Feeling modesty and shame before Allah. | Al-A'raf 7:26 | Jami' at-Tirmidhi 2458 (Hasan) |
| 121 | **Istiqamah** | الاستقامة | Positive | Steadfastness upon the straight path. | Fussilat 41:30 | Sahih Muslim 38 |
| 122 | **Mujahadah** | المجاهدة | Positive | Striving against the desires of the soul for Allah's sake. | Al-Ankabut 29:69 | Sahih Muslim 2664 |
| 123 | **Murabitah** | المرابطة | Positive | Constant vigilance and guarding faith. | Ali Imran 3:200 | Sahih Muslim 251 |
| 124 | **Faqr ila Allah** | الفقر إلى الله | Positive | Recognizing complete dependence upon Allah. | Fatir 35:15 | Sahih Muslim 2577 |
| 125 | **Ubudiyyah** | العبودية | Positive | Complete servitude and submission to Allah. | Adh-Dhariyat 51:56 | Sahih Muslim 8 |
| 126 | **Tafarrugh lil-Ibadah** | التفرغ للعبادة | Positive | Giving priority to worship and remembrance. | Al-Jumuah 62:10 | Jami at-Tirmidhi 2466 (Hasan) |
| 127 | **Sidq al-Mahabbah** | صدق المحبة | Positive | Truthfulness and sincerity in love for Allah. | Ali Imran 3:31 | Sahih al-Bukhari 15 |
| 128 | **Taqarrub ila Allah** | التقرب إلى الله | Positive | Seeking nearness to Allah through righteous deeds. | Al-Maidah 5:35 | Sahih al-Bukhari 6502 |
| 129 | **Thabat** | الثبات | Positive | Firmness upon faith until death. | Ibrahim 14:27 | Jami at-Tirmidhi 2140 (Sahih) |
| 130 | **Tajrid** | التجريد | Positive | Purifying intentions and dependence solely for Allah. | Az-Zumar 39:11 | Sahih al-Bukhari 1 |
| 131 | **Ikhlas al-Qasd** | إخلاص القصد | Positive | Purifying one's objectives solely for Allah. | Al-Bayyinah 98:5 | Sahih al-Bukhari 1 |
| 132 | **Futuwwah** | الفتوة | Positive | Nobility, generosity and preferring others while maintaining righteousness. | Al-Hashr 59:9 | Sahih Muslim 2588 |
| 133 | **Tawakkul al-Kamil** | التوكل الكامل | Positive | Perfect reliance upon Allah while utilizing lawful means. | At-Talaq 65:3 | Sahih al-Bukhari 6470 |
| 134 | **Jam'iyyat al-Qalb** | جمعية القلب | Positive | The heart being focused upon Allah without distraction. | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 135 | **Hudur al-Qalb** | حضور القلب | Positive | Presence and attentiveness of the heart during worship. | Al-Mu'minun 23:1-2 | Sahih Muslim 489 |
| 136 | **Musharakah fi al-Khayr** | المشاركة في الخير | Positive | Cooperating with others in righteousness and beneficial work. | Al-Maidah 5:2 | Sahih Muslim 2699 |
| 137 | **Nasihah** | النصيحة | Positive | Sincere concern and goodwill toward Allah, His Book and His creation. | Al-Asr 103:3 | Sahih Muslim 55 |
| 138 | **Islah** | الإصلاح | Positive | Bringing reconciliation and improvement. | Al-Hujurat 49:10 | Sahih al-Bukhari 2692 |
| 139 | **Himmah Aliyah** | الهمة العالية | Positive | High aspiration toward pleasing Allah and attaining excellence. | Ash-Sharh 94:7-8 | Sahih Muslim 2664 |
| 140 | **Mushahadah** | المشاهدة | Positive | Worshipping Allah with profound awareness and certainty, as though seeing Him. | Qaf 50:16 | Sahih Muslim 8 |
| 141 | **Yusr** | اليسر | Positive | Moderation and ease in religion without negligence. | Al-Baqarah 2:185 | Sahih al-Bukhari 39 |
| 142 | **Bashashah** | البشاشة | Positive | Cheerfulness and pleasantness in dealing with people. | Abasa 80:1-2 | Sahih Muslim 2626 |
| 143 | **Tafa'ul** | التفاؤل | Positive | Optimism and expecting goodness from Allah. | Az-Zumar 39:53 | Sahih al-Bukhari 5776 |
| 144 | **Husn az-Zann bin-Nas** | حسن الظن بالناس | Positive | Thinking well of fellow believers unless proven otherwise. | Al-Hujurat 49:12 | Sahih Muslim 2563 |
| 145 | **Adab** | الأدب | Positive | Refined manners and proper conduct. | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 146 | **Hifz al-Lisan** | حفظ اللسان | Positive | Protecting the tongue from harmful speech. | Qaf 50:18 | Sahih al-Bukhari 6475 |
| 147 | **Samahah** | السماحة | Positive | Tolerance, leniency and ease in dealings. | Al-Araf 7:199 | Sahih al-Bukhari 2076 |
| 148 | **Waqar** | الوقار | Positive | Dignity, calmness and composed behavior. | Al-Furqan 25:63 | Sahih al-Bukhari 6118 |
| 149 | **Jud** | الجود | Positive | Magnanimity and abundant generosity. | Al-Baqarah 2:261 | Sahih al-Bukhari 6035 |
| 150 | **Tawazun** | التوازن | Positive | Maintaining balance between worldly and spiritual responsibilities. | Al-Qasas 28:77 | Sahih al-Bukhari 6139 |
| 151 | **Rifq** | الرفق | Positive | Gentleness and kindness in conduct. | Ali Imran 3:159 | Sahih Muslim 2593 |
| 152 | **Hilm** | الحلم | Positive | Forbearance and self-control when provoked. | Al-Araf 7:199 | Sahih Muslim 17 |
| 153 | **Anah** | الأناة | Positive | Deliberation and avoiding haste. | Al-Isra 17:11 | Sahih Muslim 17 |
| 154 | **Qana'ah** | القناعة | Positive | Contentment with Allah's provision. | Ta-Ha 20:131 | Sahih Muslim 1054 |
| 155 | **Satr** | الستر | Positive | Concealing the faults of others. | An-Nur 24:19 | Sahih Muslim 2590 |
| 156 | **Rahmah lil-Khalq** | الرحمة للخلق | Positive | Mercy and compassion toward creation. | Al-Anbiya 21:107 | Sahih al-Bukhari 6013 |
| 157 | **Tawadu fi al-Ilm** | التواضع في العلم | Positive | Humility despite possessing knowledge. | Al-Kahf 18:66 | Sahih Muslim 2865 |
| 158 | **Wara** | الورع | Positive | Avoiding doubtful matters to protect religion. | Al-Baqarah 2:168 | Sahih al-Bukhari 52; Sahih Muslim 1599 |
| 159 | **Zuhd fi ad-Dunya** | الزهد في الدنيا | Positive | Detachment from excessive attachment to worldly life. | Al-Hadid 57:20 | Sunan Ibn Majah 4102 (Hasan) |
| 160 | **Uns billah** | الأنس بالله | Positive | Finding comfort and companionship in Allah. | Ar-Rad 13:28 | Sahih Muslim 2675 |
| 161 | **Yaqzah** | اليقظة | Positive | Spiritual awakening and awareness of one's purpose. | Al-Hadid 57:16 | Sahih Muslim 2750 |
| 162 | **Firasah Imaniyyah** | الفراسة الإيمانية | Positive | Discernment granted through faith and taqwa. | Al-Hijr 15:75 | Jami at-Tirmidhi 3127 (Hasan) |
| 163 | **I'tisam billah** | الاعتصام بالله | Positive | Holding firmly to Allah and His guidance. | Ali Imran 3:103 | Sahih Muslim 867 |
| 164 | **Inabah Kamilah** | الإنابة الكاملة | Positive | Complete return and surrender to Allah. | Az-Zumar 39:54 | Sahih Muslim 2702 |
| 165 | **Sabr Jamil** | الصبر الجميل | Positive | Patience without complaint against Allah. | Yusuf 12:18 | Sahih al-Bukhari 1469 |
| 166 | **Hijrah ila Allah** | الهجرة إلى الله | Positive | Migrating with the heart toward Allah through obedience. | Adh-Dhariyat 51:50 | Sahih al-Bukhari 1 |
| 167 | **Tadhallul** | التذلل | Positive | Utter humility and brokenness before Allah. | Al-Furqan 25:63 | Sahih Muslim 2865 |
| 168 | **Khashyah** | الخشية | Positive | Fear based upon knowledge of Allah. | Fatir 35:28 | Sahih al-Bukhari 6482 |
| 169 | **Wajal** | الوجل | Positive | A heart trembling out of awe and concern for acceptance. | Al-Anfal 8:2 | Sahih al-Bukhari 50 |
| 170 | **Raghabah wa Rahabah** | الرغبة والرهبة | Positive | Combining hope and fear in worship. | Al-Anbiya 21:90 | Sahih Muslim 2679 |
| 171 | **Uns bil-Quran** | الأنس بالقرآن | Positive | Finding comfort, companionship and guidance in the Quran. | Az-Zukhruf 43:36 | Sahih Muslim 804 |
| 172 | **Ta'zim Allah** | تعظيم الله | Positive | Magnifying Allah in the heart and honoring His greatness. | Al-Hajj 22:74 | Sahih al-Bukhari 7384 |
| 173 | **Ta'zim Sha'air Allah** | تعظيم شعائر الله | Positive | Honoring the symbols and sacred rites established by Allah. | Al-Hajj 22:32 | Sahih al-Bukhari 1610 |
| 174 | **Muraqabah Kamilah** | المراقبة الكاملة | Positive | Living with continuous awareness that Allah sees and knows everything. | Al-Hadid 57:4 | Sahih Muslim 8 |
| 175 | **Ihsan** | الإحسان | Positive | Worshipping Allah as though one sees Him and excelling in all deeds. | An-Nahl 16:90 | Sahih Muslim 8 |
| 176 | **Sidq at-Tawakkul** | صدق التوكل | Positive | True and sincere reliance upon Allah. | At-Talaq 65:3 | Sahih al-Bukhari 6470 |
| 177 | **Ridha bil-Qada** | الرضا بالقضاء | Positive | Being pleased with Allah's decree and wisdom. | Al-Baqarah 2:216 | Jami at-Tirmidhi 2396 (Hasan) |
| 178 | **Mahabbah fillah** | المحبة في الله | Positive | Loving others for the sake of Allah. | Al-Hashr 59:10 | Sahih Muslim 2566 |
| 179 | **Bughd fillah** | البغض في الله | Positive | Disliking disbelief and sin for Allah's sake without injustice. | Al-Mumtahanah 60:4 | Sunan Abi Dawud 4681 (Hasan) |
| 180 | **Ikhlas al-Mahabbah** | إخلاص المحبة | Positive | Purifying love so that Allah becomes the highest beloved. | Al-Baqarah 2:165 | Sahih Muslim 2721 |
| 181 | **Sidq al-Mahabbah** | صدق المحبة | Positive | Truthfulness in one's love for Allah. | Ali Imran 3:31 | Sahih al-Bukhari 15 |
| 182 | **Shawq ila Allah** | الشوق إلى الله | Positive | Longing and yearning for meeting Allah. | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 183 | **Tafwid** | التفويض | Positive | Entrusting all affairs to Allah. | Ghafir 40:44 | Sahih Muslim 2717 |
| 184 | **Istiqamah Kamilah** | الاستقامة الكاملة | Positive | Remaining steadfast until death. | Fussilat 41:30 | Sahih Muslim 38 |
| 185 | **Sakinah** | السكينة | Positive | Inner tranquility sent by Allah. | Al-Fath 48:4 | Sahih Muslim 2700 |
| 186 | **Basirah** | البصيرة | Positive | Deep spiritual insight and understanding. | Yusuf 12:108 | Sahih Muslim 2699 |
| 187 | **Shukr al-Khalq** | شكر الخلق | Positive | Showing gratitude to people for their kindness. | Luqman 31:14 | Jami at-Tirmidhi 1954 (Sahih) |
| 188 | **Falah** | الفلاح | Positive | True success in this world and the Hereafter. | Al-Muminun 23:1 | Sahih Muslim 85 |
| 189 | **Husn al-Khatimah** | حسن الخاتمة | Positive | A good and blessed ending. | Ali Imran 3:102 | Sahih al-Bukhari 6607 |
| 190 | **Rifq billah** | الرفق بالله | Positive | Experiencing Allah's gentleness in His decrees and dealings. | At-Talaq 65:7 | Sahih Muslim 2593 |
| 191 | **Fawz al-Azim** | الفوز العظيم | Positive | Attaining the supreme success of Paradise and Allah's pleasure. | At-Tawbah 9:72 | Sahih Muslim 2829 |
| 192 | **Liqa Allah** | لقاء الله | Positive | Longing and preparation for meeting Allah. | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 193 | **Ridhwan Allah** | رضوان الله | Positive | Seeking and attaining Allah's pleasure above everything. | At-Tawbah 9:72 | Sahih Muslim 2829 |
| 194 | **Darajat al-Ihsan** | درجات الإحسان | Positive | Ascending in excellence and nearness to Allah. | Al-Mutaffifin 83:28 | Sahih Muslim 8 |
| 195 | **Ubudiyyah Kamilah** | العبودية الكاملة | Positive | Complete servitude and submission to Allah. | Adh-Dhariyat 51:56 | Sahih Muslim 8 |
| 196 | **Tawhid Kamil** | التوحيد الكامل | Positive | Perfect realization of Allah's Oneness. | Al-Ikhlas 112:1 | Sahih al-Bukhari 7375 |
| 197 | **Siddiqiyyah** | الصديقية | Positive | Highest rank of truthfulness after Prophethood. | An-Nisa 4:69 | Sahih al-Bukhari 6094 |
| 198 | **Wilayah** | الولاية | Positive | Nearness and friendship with Allah through obedience. | Yunus 10:62 | Sahih al-Bukhari 6502 |
| 199 | **Talab al-Firdaws al-Ala** | طلب الفردوس الأعلى | Positive | Aspiring for the highest level of Paradise. | Al-Mutaffifin 83:26 | Sahih al-Bukhari 2790 |
| 200 | **Jannat an-Naim Orientation** | التطلع إلى جنة النعيم | Positive | Living with the Hereafter as the ultimate objective. | Ash-Shura 42:20 | Sahih Muslim 2864 |

---

## Full Data (all 23 columns)

| ID | Name | Arabic | Nature | Definition | Opposite | Opposite_Arabic | Keywords | Quran_Ref | Hadith_Ref |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | Riya | الرياء | Negative | Seeking people's praise and recognition through acts intended for Allah. | Ikhlas | الإخلاص | showing off,sincerity,intention,worship | Al-Ma'un 107:4-6 | Musnad Ahmad 23630 |
| 2 | Kibr | الكبر | Negative | Rejecting truth and considering oneself superior to others. | Tawadu | التواضع | arrogance,pride,humility | Luqman 31:18 | Sahih Muslim 91 |
| 3 | Ujb | العجب | Negative | Being impressed with oneself and one's achievements. | Humility | التواضع | self admiration,ego,pride | An-Najm 53:32 | Sahih Muslim 2749 |
| 4 | Nifaq | النفاق | Negative | Difference between outward appearance and inward reality. | Sidq | الصدق | hypocrisy,truthfulness,sincerity | Al-Baqarah 2:8-9 | Sahih al-Bukhari 33; Sahih Muslim 59 |
| 5 | Sum'ah | السُّمعة | Negative | Seeking fame and recognition through good deeds. | Ikhlas | الإخلاص | fame,reputation,showing off | Al-Qasas 28:83 | Sahih al-Bukhari 6499; Sahih Muslim 2987 |
| 6 | Kufr al-Ni'mah | كفر النعمة | Negative | Failing to recognize and appreciate Allah's blessings. | Shukr | الشكر | gratitude,blessings,thankfulness | Ibrahim 14:7 | Sahih Muslim 2734 |
| 7 | Ghurur | الغرور | Negative | Being deceived by worldly life or false hopes. | Basirah | البصيرة | delusion,deception,worldliness | Luqman 31:33 | Sahih Muslim 2959 |
| 8 | Irtiyab | الارتياب | Negative | Persistent doubt and uncertainty regarding faith. | Yaqin | اليقين | certainty,doubt,faith | Al-Hujurat 49:15 | Sahih Muslim 134 |
| 9 | Qasawat al-Qalb | قسوة القلب | Negative | Hardness and lack of spiritual sensitivity in the heart. | Riqah | الرقة | hardness,heart,mercy | Al-Hadid 57:16 | Sahih Muslim 7028 |
| 10 | Ghaflah | الغفلة | Negative | Heedlessness and neglect of Allah and the Hereafter. | Yaqzah | اليقظة | heedlessness,awareness,remembrance | Al-A'raf 7:205 | Sahih al-Bukhari 6407 |
| 11 | Amn min Makrillah | الأمن من مكر الله | Negative | False security from Allah's punishment. | Khawf wa Raja | الخوف والرجاء | complacency,false security | Al-A'raf 7:99 | Sahih al-Bukhari 6607 |
| 12 | Tul al-Amal | طول الأمل | Negative | Having excessive worldly hopes and forgetting death. | Zuhd | الزهد | long hopes,worldliness | Al-Hijr 15:3 | Sahih al-Bukhari 6417 |
| 13 | Ittiba al-Hawa | اتباع الهوى | Negative | Following desires over divine guidance. | Taqwa | التقوى | desires,temptations | Al-Jathiyah 45:23 | Sahih Muslim 2657 |
| 14 | Yas | اليأس | Negative | Despairing of Allah's mercy. | Raja | الرجاء | despair,hope | Az-Zumar 39:53 | Sahih Muslim 2755 |
| 15 | Shirk al-Asghar | الشرك الأصغر | Negative | Subtle forms of associating partners with Allah. | Tawhid | التوحيد | minor shirk,purity | Luqman 31:13 | Musnad Ahmad 23630 |
| 16 | Karahiyyat al-Mawt | كراهية الموت | Negative | Excessive dislike of death due to attachment to worldly life. | Shawq ila Allah | الشوق إلى الله | fear of death | Al-Jumu'ah 62:8 | Sahih al-Bukhari 6412 |
| 17 | Sukhriyyah | السخرية | Negative | Mocking and ridiculing others. | Ihtiram | الاحترام | mockery,respect | Al-Hujurat 49:11 | Sahih Muslim 2564 |
| 18 | Tazkiyat an-Nafs al-Madhmumah | تزكية النفس المذمومة | Negative | Self-justification and falsely claiming purity. | Muhasabah | المحاسبة | self praise,self righteousness | An-Najm 53:32 | Sahih Muslim 2865 |
| 19 | Taassub | التعصب | Negative | Blind partisanship and fanaticism. | Insaf | الإنصاف | fanaticism,bias | Al-Ma'idah 5:8 | Sahih Muslim 1848 |
| 20 | Wahn | الوهن | Negative | Weakness caused by excessive love of worldly life and dislike of death. | Quwwah | القوة | weakness,worldliness | Al-Anfal 8:46 | Sunan Abu Dawud 4297 |
| 21 | Hasad | الحسد | Negative | Wishing the removal of blessings from others. | Ghibtah | الغبطة | envy,jealousy | Al-Falaq 113:5 | Sahih Muslim 2564 |
| 22 | Hiqd | الحقد | Negative | Harboring grudges and resentment. | Safh | الصفح | resentment,grudge | Al-Hashr 59:10 | Sahih Muslim 2563 |
| 23 | Ghadab | الغضب | Negative | Uncontrolled anger. | Hilm | الحلم | anger,patience | Ali Imran 3:134 | Sahih al-Bukhari 6116 |
| 24 | Bukhl | البخل | Negative | Miserliness and withholding good. | Sakha | السخاء | stinginess,generosity | Ali Imran 3:180 | Sahih Muslim 1021 |
| 25 | Shuhh | الشح | Negative | Greedy selfishness. | Ithar | الإيثار | greed,selfishness | Al-Hashr 59:9 | Sahih Muslim 2578 |
| 26 | Tama | الطمع | Negative | Excessive covetousness. | Qanaah | القناعة | greed,contentment | At-Takathur 102:1 | Sahih Muslim 1051 |
| 27 | Hubb ad-Dunya | حب الدنيا | Negative | Excessive attachment to worldly life. | Zuhd | الزهد | worldliness | Al-Hadid 57:20 | Sahih Muslim 2956 |
| 28 | Takathur | التكاثر | Negative | Competing for worldly abundance. | Iqtisad | الاقتصاد | materialism,competition | At-Takathur 102:1 | Sahih al-Bukhari 6436 |
| 29 | Kadhib | الكذب | Negative | Speaking falsehood. | Sidq | الصدق | lying,truthfulness | At-Tawbah 9:119 | Sahih al-Bukhari 6094 |
| 30 | Khiyanah | الخيانة | Negative | Betrayal of trusts. | Amanah | الأمانة | betrayal,trust | Al-Anfal 8:27 | Sahih al-Bukhari 33 |
| 31 | Gheebah | الغيبة | Negative | Mentioning about a person what he dislikes in his absence. | Hifz al-Lisan | حفظ اللسان | backbiting,tongue,sins | Al-Hujurat 49:12 | Sahih Muslim 2589 |
| 32 | Namimah | النميمة | Negative | Carrying tales between people to create discord. | Islah | الإصلاح | slander,gossip | Al-Qalam 68:11 | Sahih Muslim 105 |
| 33 | Su' al-Dhann | سوء الظن | Negative | Having evil suspicion about others. | Husn al-Dhann | حسن الظن | suspicion,judgment | Al-Hujurat 49:12 | Sahih al-Bukhari 6066; Sahih Muslim 2563 |
| 34 | Tajassus | التجسس | Negative | Spying and searching for people's faults. | Satr | الستر | spying,privacy | Al-Hujurat 49:12 | Sahih Muslim 2564 |
| 35 | Fuhsh | الفحش | Negative | Obscene and indecent speech or behavior. | Haya | الحياء | obscenity,indecency | Al-A'raf 7:33 | Sahih al-Bukhari 6117 |
| 36 | Sabb | السب | Negative | Insulting and abusing others. | Rifq | الرفق | abuse,insult | Al-Hujurat 49:11 | Sahih al-Bukhari 6044 |
| 37 | La'n | اللعن | Negative | Habitually cursing others. | Du'a bil-Khayr | الدعاء بالخير | curse,speech | Al-Ahzab 58 | Sahih Muslim 2597 |
| 38 | Jidal | الجدال | Negative | Argumentation leading to hostility. | Husn al-Khuluq | حسن الخلق | argument,dispute | An-Nahl 16:125 | Jami' at-Tirmidhi 1993 |
| 39 | Mira' | المراء | Negative | Disputation and unnecessary controversy. | Tawadu | التواضع | debate,ego | Al-Kahf 18:54 | Jami' at-Tirmidhi 1993 |
| 40 | Istihza' | الاستهزاء | Negative | Mocking and ridiculing people or religious matters. | Ihtiram | الاحترام | ridicule,mockery | Al-Hujurat 49:11 | Sahih Muslim 2564 |
| 41 | Shahadat az-Zur | شهادة الزور | Negative | Giving false testimony. | Sidq | الصدق | false witness,testimony | Al-Hajj 22:30 | Sahih al-Bukhari 2654 |
| 42 | Ikhlaf al-Wa'd | إخلاف الوعد | Negative | Breaking promises. | Wafa | الوفاء | promise,covenant | Al-Isra 17:34 | Sahih al-Bukhari 33 |
| 43 | Qaswah fi al-Mu'amalah | القسوة | Negative | Harshness and severity toward others. | Rifq | الرفق | harshness,kindness | Ali Imran 3:159 | Sahih Muslim 2593 |
| 44 | Su' al-Khuluq | سوء الخلق | Negative | Bad manners and character. | Husn al-Khuluq | حسن الخلق | character,manners | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 45 | Hijran al-Muslim | هجر المسلم | Negative | Boycotting a Muslim without a valid reason. | Silah | الصلة | boycott,brotherhood | Al-Hujurat 49:10 | Sahih al-Bukhari 6077 |
| 46 | Hubb al-Madh | حب المدح | Negative | Love of praise and admiration. | Ikhlas | الإخلاص | praise,ego | An-Najm 53:32 | Sahih Muslim 3001 |
| 47 | Tafakhur | التفاخر | Negative | Boasting about wealth, lineage or status. | Tawadu | التواضع | boasting,pride | At-Takathur 102:1 | Sahih Muslim 2865 |
| 48 | Ta'ali | التعالي | Negative | Looking down upon others. | Tawadu | التواضع | superiority,arrogance | Al-Hujurat 49:13 | Sahih Muslim 2564 |
| 49 | Raghbah fi ad-Dunya | الرغبة في الدنيا | Negative | Overeagerness for worldly gain. | Zuhd | الزهد | materialism,worldliness | Al-Hadid 57:20 | Sahih al-Bukhari 6416 |
| 50 | Ujub bi al-'Amal | العجب بالعمل | Negative | Being impressed with one's deeds. | Ikhlas | الإخلاص | self admiration,deeds | An-Najm 53:32 | Sahih Muslim 2818 |
| 51 | Kasal | الكسل | Negative | Laziness and reluctance in beneficial actions. | Jidd | الجد | laziness,effort | An-Najm 53:39 | Sahih al-Bukhari 6369 |
| 52 | Ajz | العجز | Negative | Helplessness caused by abandoning means. | Quwwah | القوة | weakness,inability | Al-Anfal 8:60 | Sahih Muslim 2664 |
| 53 | Jubn | الجبن | Negative | Cowardice and fear preventing obedience. | Shaja'ah | الشجاعة | fear,courage | Al-Imran 3:175 | Sahih al-Bukhari 6374 |
| 54 | Hirs | الحرص | Negative | Excessive greed and eagerness for worldly gain. | Qana'ah | القناعة | greed,desire | At-Takathur 102:1 | Sahih Muslim 1051 |
| 55 | Israaf | الإسراف | Negative | Exceeding limits and extravagance. | Iqtisad | الاقتصاد | waste,extravagance | Al-A'raf 7:31 | Sahih al-Bukhari 6091 |
| 56 | Tabdhir | التبذير | Negative | Squandering wealth uselessly. | Husn at-Tadbir | حسن التدبير | waste,wealth | Al-Isra 17:26-27 | Sahih Muslim 593 |
| 57 | Ghaflah an al-Mawt | الغفلة عن الموت | Negative | Neglecting remembrance of death. | Tadhakkur | التذكر | death,heedlessness | Al-Jumu'ah 62:8 | Jami' at-Tirmidhi 2307 |
| 58 | Qat' ar-Rahim | قطع الرحم | Negative | Severing family ties. | Silat ar-Rahim | صلة الرحم | family,relations | Muhammad 47:22-23 | Sahih al-Bukhari 5984 |
| 59 | Zulm | الظلم | Negative | Oppression and injustice. | Adl | العدل | injustice,oppression | Ash-Shura 42:42 | Sahih Muslim 2577 |
| 60 | Qanut min Rahmatillah | القنوط من رحمة الله | Negative | Losing hope in Allah's mercy. | Raja | الرجاء | despair,hope | Az-Zumar 39:53 | Sahih Muslim 2755 |
| 61 | Riya | الرياء | Negative | Performing deeds to be seen by people. | Ikhlas | الإخلاص | showing off,sincerity | Al-Bayyinah 98:5 | Sahih Muslim 2985 |
| 62 | Kibr | الكبر | Negative | Rejecting truth and looking down upon others. | Tawadu | التواضع | pride,arrogance | An-Nahl 16:23 | Sahih Muslim 91 |
| 63 | Ghurur | الغرور | Negative | Being deceived by worldly life or oneself. | Basirah | البصيرة | deception,delusion | Luqman 31:33 | Sahih al-Bukhari 6416 |
| 64 | Ghaflah | الغفلة | Negative | Heedlessness regarding Allah and the Hereafter. | Yaqzah | اليقظة | heedlessness,awareness | Al-Anbiya 21:1 | Sahih Muslim 2676 |
| 65 | Qaswat al-Qalb | قسوة القلب | Negative | Hardness of the heart. | Riqqat al-Qalb | رقة القلب | hardness,softness | Al-Hadid 57:16 | Sahih Muslim 2750 |
| 66 | Shakk | الشك | Negative | Persistent doubt in matters clearly established. | Yaqin | اليقين | doubt,certainty | Al-Baqarah 2:2 | Sahih Muslim 134 |
| 67 | Nifaq | النفاق | Negative | Hypocrisy between inner belief and outward conduct. | Sidq | الصدق | hypocrisy,sincerity | An-Nisa 4:145 | Sahih al-Bukhari 33 |
| 68 | Taswif | التسويف | Negative | Procrastination in repentance and obedience. | Mubadarah | المبادرة | delay,repentance | Al-Munafiqun 63:10 | Sahih al-Bukhari 6416 |
| 69 | Qillat ash-Shukr | قلة الشكر | Negative | Failure to appreciate Allah's blessings. | Shukr | الشكر | gratitude,blessings | Ibrahim 14:7 | Sahih Muslim 2819 |
| 70 | Qillat as-Sabr | قلة الصبر | Negative | Weakness in perseverance and endurance. | Sabr | الصبر | impatience,endurance | Al-Baqarah 2:153 | Sahih Muslim 1053 |
| 71 | Tawbah | التوبة | Positive | Returning to Allah after sin with regret and resolve. | Taswif | التسويف | repentance,return | At-Tahrim 66:8 | Sahih Muslim 2749 |
| 72 | Ikhlas | الإخلاص | Positive | Purifying intentions solely for Allah. | Riya | الرياء | sincerity,intention | Al-Bayyinah 98:5 | Sahih al-Bukhari 1 |
| 73 | Sidq | الصدق | Positive | Truthfulness in speech and conduct. | Kadhib | الكذب | truthfulness,honesty | At-Tawbah 9:119 | Sahih al-Bukhari 6094 |
| 74 | Taqwa | التقوى | Positive | Consciousness and fear of Allah leading to obedience. | Ittiba al-Hawa | اتباع الهوى | piety,God-consciousness | Al-Baqarah 2:197 | Sahih Muslim 2564 |
| 75 | Sabr | الصبر | Positive | Perseverance and endurance upon truth. | Qillat as-Sabr | قلة الصبر | patience,endurance | Al-Baqarah 2:153 | Sahih Muslim 1053 |
| 76 | Shukr | الشكر | Positive | Recognizing and appreciating Allah's blessings. | Qillat ash-Shukr | قلة الشكر | gratitude,blessings | Ibrahim 14:7 | Sahih Muslim 2819 |
| 77 | Tawakkul | التوكل | Positive | Relying upon Allah while taking lawful means. | Ajz | العجز | trust,reliance | Ali Imran 3:159 | Sahih al-Bukhari 6470 |
| 78 | Khawf | الخوف | Positive | Fear of Allah that prevents sin. | Amn min Makrillah | الأمن من مكر الله | fear,awe | Ali Imran 3:175 | Sahih Muslim 2758 |
| 79 | Raja | الرجاء | Positive | Hope in Allah's mercy and reward. | Yas | اليأس | hope,mercy | Az-Zumar 39:53 | Sahih Muslim 2877 |
| 80 | Yaqin | اليقين | Positive | Firm certainty in Allah and His promises. | Shakk | الشك | certainty,conviction | Al-Baqarah 2:2 | Sahih Muslim 8 |
| 81 | Zuhd | الزهد | Positive | Detachment from worldly excess while utilizing lawful means. | Hubb ad-Dunya | حب الدنيا | asceticism,hereafter | Al-Hadid 57:20 | Sahih Ibn Majah 4102 |
| 82 | Qana'ah | القناعة | Positive | Contentment with Allah's provision. | Tama | الطمع | contentment,satisfaction | Ta-Ha 20:131 | Sahih Muslim 1051 |
| 83 | Wara' | الورع | Positive | Avoiding doubtful matters out of fear of Allah. | Tasahul | التساهل | caution,piety | Al-Baqarah 2:168 | Sahih al-Bukhari 52; Sahih Muslim 1599 |
| 84 | Haya' | الحياء | Positive | Modesty and shame before Allah and people. | Fuhsh | الفحش | modesty,purity | Al-A'raf 7:26 | Sahih al-Bukhari 6117 |
| 85 | Rifq | الرفق | Positive | Gentleness and kindness in dealing with others. | Qaswah | القسوة | gentleness,kindness | Ali Imran 3:159 | Sahih Muslim 2593 |
| 86 | Hilm | الحلم | Positive | Forbearance and control over anger. | Ghadab | الغضب | forbearance,patience | Ali Imran 3:134 | Sahih al-Bukhari 6114 |
| 87 | Rahmah | الرحمة | Positive | Showing compassion and mercy toward creation. | Qaswah | القسوة | mercy,compassion | Al-Anbiya 21:107 | Sahih al-Bukhari 6013; Sahih Muslim 2319 |
| 88 | Afw | العفو | Positive | Pardoning others despite having the ability to retaliate. | Intiqam | الانتقام | forgiveness,pardon | Ash-Shura 42:40 | Sahih Muslim 2588 |
| 89 | Safh | الصفح | Positive | Overlooking faults and letting go of grievances. | Hiqd | الحقد | overlooking,pardon | An-Nur 24:22 | Sahih Muslim 2588 |
| 90 | Ihsan | الإحسان | Positive | Worshipping Allah as though you see Him and excelling in goodness. | Isa'ah | الإساءة | excellence,worship | An-Nahl 16:90 | Sahih Muslim 8 |
| 91 | Mahabbah | المحبة | Positive | Love of Allah above all else. | Hubb ad-Dunya | حب الدنيا | love,devotion | Al-Baqarah 2:165 | Sahih al-Bukhari 6502 |
| 92 | Khushu' | الخشوع | Positive | Humility and attentiveness of the heart in worship. | Qaswat al-Qalb | قسوة القلب | humility,worship | Al-Mu'minun 23:1-2 | Sahih Muslim 489 |
| 93 | Inabah | الإنابة | Positive | Constantly turning back to Allah. | Ghaflah | الغفلة | return,repentance | Az-Zumar 39:54 | Sahih Muslim 2702 |
| 94 | Uns billah | الأنس بالله | Positive | Finding comfort and tranquility in Allah. | Wahshah | الوحشة | intimacy,tranquility | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 95 | Muhasabah | المحاسبة | Positive | Self-accountability before being judged. | Ghaflah | الغفلة | self evaluation,awareness | Al-Hashr 59:18 | Sahih Muslim 2816 |
| 96 | Muraqabah | المراقبة | Positive | Living with awareness that Allah sees everything. | Ghaflah | الغفلة | awareness,vigilance | Qaf 50:16 | Sahih Muslim 8 |
| 97 | Ikhbat | الإخبات | Positive | Deep humility and submissiveness before Allah. | Kibr | الكبر | humility,submission | Al-Hajj 22:34 | Sahih Muslim 2865 |
| 98 | Tawadu' | التواضع | Positive | Humility toward Allah and people. | Kibr | الكبر | humility,modesty | Al-Furqan 25:63 | Sahih Muslim 2588 |
| 99 | Sakinah | السكينة | Positive | Inner tranquility bestowed by Allah. | Qalaq | القلق | peace,tranquility | Al-Fath 48:4 | Sahih al-Bukhari 3614 |
| 100 | Ridha | الرضا | Positive | Content acceptance of Allah's decree. | Sakhat | السخط | contentment,decree | Al-Bayyinah 98:8 | Sahih Muslim 2815 |
| 101 | Shawq ila Allah | الشوق إلى الله | Positive | Longing to meet and draw near to Allah. | Ghaflah | الغفلة | longing,yearning | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 102 | Mahabbat ar-Rasul | محبة الرسول ﷺ | Positive | Loving the Messenger ﷺ above all creation. | Jafa | الجفاء | love,sunnah | At-Tawbah 9:24 | Sahih al-Bukhari 15 |
| 103 | Tafakkur | التفكر | Positive | Deep reflection upon Allah's signs. | Ghaflah | الغفلة | reflection,pondering | Ali Imran 3:191 | Sahih Muslim 2699 |
| 104 | Tadhakkur | التذكر | Positive | Remembering Allah and His favors. | Nisyan | النسيان | remembrance,awareness | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 105 | Tafwid | التفويض | Positive | Entrusting affairs completely to Allah. | Qalaq | القلق | entrust,reliance | Ghafir 40:44 | Sahih al-Bukhari 6369 |
| 106 | Haybah | الهيبة | Positive | Reverential awe of Allah. | Amn min Makrillah | الأمن من مكر الله | awe,reverence | Al-Hashr 59:21 | Sahih Muslim 2356 |
| 107 | Basirah | البصيرة | Positive | Inner insight and spiritual understanding. | Ghurur | الغرور | insight,wisdom | Yusuf 12:108 | Sahih Muslim 2699 |
| 108 | Firasah | الفراسة | Positive | Perceptiveness granted to believers. | Ghaflah | الغفلة | discernment,perception | Al-Hijr 15:75 | Jami' at-Tirmidhi 3127 (Hasan) |
| 109 | Samt | الصمت | Positive | Guarding the tongue and speaking only good. | Kathrat al-Kalam | كثرة الكلام | silence,speech | Qaf 50:18 | Sahih al-Bukhari 6475; Sahih Muslim 47 |
| 110 | Husn az-Zann billah | حسن الظن بالله | Positive | Having good expectations of Allah. | Qunut | القنوط | hope,trust | Az-Zumar 39:53 | Sahih Muslim 2877 |
| 111 | Hikmah | الحكمة | Positive | Putting things in their proper place and acting with sound judgment. | Safah | السفه | wisdom,judgment | Al-Baqarah 2:269 | Sahih al-Bukhari 73 |
| 112 | Adl | العدل | Positive | Establishing justice and giving everyone their rights. | Zulm | الظلم | justice,fairness | An-Nahl 16:90 | Sahih Muslim 1827 |
| 113 | Amanah | الأمانة | Positive | Trustworthiness in all responsibilities. | Khiyanah | الخيانة | trust,integrity | An-Nisa 4:58 | Sahih al-Bukhari 33 |
| 114 | Wafa bil-Ahd | الوفاء بالعهد | Positive | Honoring promises and commitments. | Ikhlaf al-Wa'd | إخلاف الوعد | promise,covenant | Al-Isra 17:34 | Sahih al-Bukhari 33 |
| 115 | Shaja'ah | الشجاعة | Positive | Courage in defending truth and fulfilling duties. | Jubn | الجبن | courage,strength | Al-Imran 3:175 | Sahih al-Bukhari 2820 |
| 116 | Iffah | العفة | Positive | Chastity and self-restraint. | Fujur | الفجور | chastity,self-control | An-Nur 24:33 | Sahih al-Bukhari 1469 |
| 117 | Sakhawah | السخاوة | Positive | Generosity and willingness to give. | Bukhl | البخل | generosity,giving | Al-Baqarah 2:261 | Sahih al-Bukhari 6035 |
| 118 | Ithar | الإيثار | Positive | Preferring others over oneself. | Atharah | الأثرة | selflessness,altruism | Al-Hashr 59:9 | Sahih al-Bukhari 3798 |
| 119 | Husn al-Khuluq | حسن الخلق | Positive | Excellent manners and conduct. | Su' al-Khuluq | سوء الخلق | character,manners | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 120 | Haya' min Allah | الحياء من الله | Positive | Feeling modesty and shame before Allah. | Fuhsh | الفحش | modesty,purity | Al-A'raf 7:26 | Jami' at-Tirmidhi 2458 (Hasan) |
| 121 | Istiqamah | الاستقامة | Positive | Steadfastness upon the straight path. | Inhiraf | الانحراف | steadfastness,consistency | Fussilat 41:30 | Sahih Muslim 38 |
| 122 | Mujahadah | المجاهدة | Positive | Striving against the desires of the soul for Allah's sake. | Ittiba al-Hawa | اتباع الهوى | struggle,self-discipline | Al-Ankabut 29:69 | Sahih Muslim 2664 |
| 123 | Murabitah | المرابطة | Positive | Constant vigilance and guarding faith. | Ghaflah | الغفلة | vigilance,watchfulness | Ali Imran 3:200 | Sahih Muslim 251 |
| 124 | Faqr ila Allah | الفقر إلى الله | Positive | Recognizing complete dependence upon Allah. | Istighna anillah | الاستغناء عن الله | neediness,dependence | Fatir 35:15 | Sahih Muslim 2577 |
| 125 | Ubudiyyah | العبودية | Positive | Complete servitude and submission to Allah. | Kibr | الكبر | servitude,worship | Adh-Dhariyat 51:56 | Sahih Muslim 8 |
| 126 | Tafarrugh lil-Ibadah | التفرغ للعبادة | Positive | Giving priority to worship and remembrance. | Lahw | اللهو | devotion,worship | Al-Jumuah 62:10 | Jami at-Tirmidhi 2466 (Hasan) |
| 127 | Sidq al-Mahabbah | صدق المحبة | Positive | Truthfulness and sincerity in love for Allah. | Da'wa al-Mahabbah | دعوى المحبة | love,sincerity | Ali Imran 3:31 | Sahih al-Bukhari 15 |
| 128 | Taqarrub ila Allah | التقرب إلى الله | Positive | Seeking nearness to Allah through righteous deeds. | Bu'd anillah | البعد عن الله | nearness,worship | Al-Maidah 5:35 | Sahih al-Bukhari 6502 |
| 129 | Thabat | الثبات | Positive | Firmness upon faith until death. | Taqallub | التقلب | firmness,steadfastness | Ibrahim 14:27 | Jami at-Tirmidhi 2140 (Sahih) |
| 130 | Tajrid | التجريد | Positive | Purifying intentions and dependence solely for Allah. | Shirk Khafi | الشرك الخفي | purification,sincerity | Az-Zumar 39:11 | Sahih al-Bukhari 1 |
| 131 | Ikhlas al-Qasd | إخلاص القصد | Positive | Purifying one's objectives solely for Allah. | Riya | الرياء | intention,sincerity | Al-Bayyinah 98:5 | Sahih al-Bukhari 1 |
| 132 | Futuwwah | الفتوة | Positive | Nobility, generosity and preferring others while maintaining righteousness. | Atharah | الأثرة | nobility,chivalry | Al-Hashr 59:9 | Sahih Muslim 2588 |
| 133 | Tawakkul al-Kamil | التوكل الكامل | Positive | Perfect reliance upon Allah while utilizing lawful means. | Ajz | العجز | trust,reliance | At-Talaq 65:3 | Sahih al-Bukhari 6470 |
| 134 | Jam'iyyat al-Qalb | جمعية القلب | Positive | The heart being focused upon Allah without distraction. | Tashattut | التشتت | focus,presence | Ar-Ra'd 13:28 | Sahih Muslim 2675 |
| 135 | Hudur al-Qalb | حضور القلب | Positive | Presence and attentiveness of the heart during worship. | Sahw | السهو | presence,attention | Al-Mu'minun 23:1-2 | Sahih Muslim 489 |
| 136 | Musharakah fi al-Khayr | المشاركة في الخير | Positive | Cooperating with others in righteousness and beneficial work. | Ta'awun ala al-Ithm | التعاون على الإثم | cooperation,goodness | Al-Maidah 5:2 | Sahih Muslim 2699 |
| 137 | Nasihah | النصيحة | Positive | Sincere concern and goodwill toward Allah, His Book and His creation. | Ghish | الغش | sincerity,advice | Al-Asr 103:3 | Sahih Muslim 55 |
| 138 | Islah | الإصلاح | Positive | Bringing reconciliation and improvement. | Ifsad | الإفساد | reform,reconciliation | Al-Hujurat 49:10 | Sahih al-Bukhari 2692 |
| 139 | Himmah Aliyah | الهمة العالية | Positive | High aspiration toward pleasing Allah and attaining excellence. | Daniyyah | الدنية | aspiration,excellence | Ash-Sharh 94:7-8 | Sahih Muslim 2664 |
| 140 | Mushahadah | المشاهدة | Positive | Worshipping Allah with profound awareness and certainty, as though seeing Him. | Ghaflah | الغفلة | ihsan,awareness | Qaf 50:16 | Sahih Muslim 8 |
| 141 | Yusr | اليسر | Positive | Moderation and ease in religion without negligence. | Tashdid | التشديد | ease,moderation | Al-Baqarah 2:185 | Sahih al-Bukhari 39 |
| 142 | Bashashah | البشاشة | Positive | Cheerfulness and pleasantness in dealing with people. | Abus | العبوس | cheerfulness,smile | Abasa 80:1-2 | Sahih Muslim 2626 |
| 143 | Tafa'ul | التفاؤل | Positive | Optimism and expecting goodness from Allah. | Tashaum | التشاؤم | optimism,hope | Az-Zumar 39:53 | Sahih al-Bukhari 5776 |
| 144 | Husn az-Zann bin-Nas | حسن الظن بالناس | Positive | Thinking well of fellow believers unless proven otherwise. | Su az-Zann | سوء الظن | good opinion,trust | Al-Hujurat 49:12 | Sahih Muslim 2563 |
| 145 | Adab | الأدب | Positive | Refined manners and proper conduct. | Su al-Adab | سوء الأدب | manners,etiquette | Al-Qalam 68:4 | Sahih Muslim 2321 |
| 146 | Hifz al-Lisan | حفظ اللسان | Positive | Protecting the tongue from harmful speech. | Fuhsh al-Kalam | فحش الكلام | speech,silence | Qaf 50:18 | Sahih al-Bukhari 6475 |
| 147 | Samahah | السماحة | Positive | Tolerance, leniency and ease in dealings. | Shiddah | الشدة | tolerance,leniency | Al-Araf 7:199 | Sahih al-Bukhari 2076 |
| 148 | Waqar | الوقار | Positive | Dignity, calmness and composed behavior. | Khiffah | الخفة | dignity,calmness | Al-Furqan 25:63 | Sahih al-Bukhari 6118 |
| 149 | Jud | الجود | Positive | Magnanimity and abundant generosity. | Bukhl | البخل | magnanimity,generosity | Al-Baqarah 2:261 | Sahih al-Bukhari 6035 |
| 150 | Tawazun | التوازن | Positive | Maintaining balance between worldly and spiritual responsibilities. | Ifrat wa Tafrit | الإفراط والتفريط | balance,moderation | Al-Qasas 28:77 | Sahih al-Bukhari 6139 |
| 151 | Rifq | الرفق | Positive | Gentleness and kindness in conduct. | Unf | العنف | gentleness,kindness | Ali Imran 3:159 | Sahih Muslim 2593 |
| 152 | Hilm | الحلم | Positive | Forbearance and self-control when provoked. | Safah | السفه | forbearance,patience | Al-Araf 7:199 | Sahih Muslim 17 |
| 153 | Anah | الأناة | Positive | Deliberation and avoiding haste. | Ajalah | العجلة | deliberation,calmness | Al-Isra 17:11 | Sahih Muslim 17 |
| 154 | Qana'ah | القناعة | Positive | Contentment with Allah's provision. | Tama' | الطمع | contentment,satisfaction | Ta-Ha 20:131 | Sahih Muslim 1054 |
| 155 | Satr | الستر | Positive | Concealing the faults of others. | Fadihah | الفضيحة | concealment,mercy | An-Nur 24:19 | Sahih Muslim 2590 |
| 156 | Rahmah lil-Khalq | الرحمة للخلق | Positive | Mercy and compassion toward creation. | Qaswah | القسوة | mercy,compassion | Al-Anbiya 21:107 | Sahih al-Bukhari 6013 |
| 157 | Tawadu fi al-Ilm | التواضع في العلم | Positive | Humility despite possessing knowledge. | Ujb | العجب | knowledge,humility | Al-Kahf 18:66 | Sahih Muslim 2865 |
| 158 | Wara | الورع | Positive | Avoiding doubtful matters to protect religion. | Tasahul | التساهل | scrupulousness,caution | Al-Baqarah 2:168 | Sahih al-Bukhari 52; Sahih Muslim 1599 |
| 159 | Zuhd fi ad-Dunya | الزهد في الدنيا | Positive | Detachment from excessive attachment to worldly life. | Hirs ala ad-Dunya | الحرص على الدنيا | asceticism,detachment | Al-Hadid 57:20 | Sunan Ibn Majah 4102 (Hasan) |
| 160 | Uns billah | الأنس بالله | Positive | Finding comfort and companionship in Allah. | Wahshah | الوحشة | intimacy,tranquility | Ar-Rad 13:28 | Sahih Muslim 2675 |
| 161 | Yaqzah | اليقظة | Positive | Spiritual awakening and awareness of one's purpose. | Ghaflah | الغفلة | awakening,awareness | Al-Hadid 57:16 | Sahih Muslim 2750 |
| 162 | Firasah Imaniyyah | الفراسة الإيمانية | Positive | Discernment granted through faith and taqwa. | Basarah Dunyawiyyah | البصيرة الدنيوية | discernment,insight | Al-Hijr 15:75 | Jami at-Tirmidhi 3127 (Hasan) |
| 163 | I'tisam billah | الاعتصام بالله | Positive | Holding firmly to Allah and His guidance. | Tafarruq | التفرق | holding fast,protection | Ali Imran 3:103 | Sahih Muslim 867 |
| 164 | Inabah Kamilah | الإنابة الكاملة | Positive | Complete return and surrender to Allah. | Irad anillah | الإعراض عن الله | return,repentance | Az-Zumar 39:54 | Sahih Muslim 2702 |
| 165 | Sabr Jamil | الصبر الجميل | Positive | Patience without complaint against Allah. | Jaza | الجزع | beautiful patience,endurance | Yusuf 12:18 | Sahih al-Bukhari 1469 |
| 166 | Hijrah ila Allah | الهجرة إلى الله | Positive | Migrating with the heart toward Allah through obedience. | Rukun ila ad-Dunya | الركون إلى الدنيا | migration,devotion | Adh-Dhariyat 51:50 | Sahih al-Bukhari 1 |
| 167 | Tadhallul | التذلل | Positive | Utter humility and brokenness before Allah. | Istikbar | الاستكبار | humility,submission | Al-Furqan 25:63 | Sahih Muslim 2865 |
| 168 | Khashyah | الخشية | Positive | Fear based upon knowledge of Allah. | Amn min Makrillah | الأمن من مكر الله | reverence,fear | Fatir 35:28 | Sahih al-Bukhari 6482 |
| 169 | Wajal | الوجل | Positive | A heart trembling out of awe and concern for acceptance. | Qaswah | القسوة | awe,sensitivity | Al-Anfal 8:2 | Sahih al-Bukhari 50 |
| 170 | Raghabah wa Rahabah | الرغبة والرهبة | Positive | Combining hope and fear in worship. | Ghurur | الغرور | hope,fear,balance | Al-Anbiya 21:90 | Sahih Muslim 2679 |
| 171 | Uns bil-Quran | الأنس بالقرآن | Positive | Finding comfort, companionship and guidance in the Quran. | Hijr al-Quran | هجر القرآن | Quran,companionship | Az-Zukhruf 43:36 | Sahih Muslim 804 |
| 172 | Ta'zim Allah | تعظيم الله | Positive | Magnifying Allah in the heart and honoring His greatness. | Istikhfaf | الاستخفاف | reverence,magnification | Al-Hajj 22:74 | Sahih al-Bukhari 7384 |
| 173 | Ta'zim Sha'air Allah | تعظيم شعائر الله | Positive | Honoring the symbols and sacred rites established by Allah. | Istihanah | الاستهانة | symbols,sanctity | Al-Hajj 22:32 | Sahih al-Bukhari 1610 |
| 174 | Muraqabah Kamilah | المراقبة الكاملة | Positive | Living with continuous awareness that Allah sees and knows everything. | Ghaflah | الغفلة | awareness,vigilance | Al-Hadid 57:4 | Sahih Muslim 8 |
| 175 | Ihsan | الإحسان | Positive | Worshipping Allah as though one sees Him and excelling in all deeds. | Isa'ah | الإساءة | excellence,perfection | An-Nahl 16:90 | Sahih Muslim 8 |
| 176 | Sidq at-Tawakkul | صدق التوكل | Positive | True and sincere reliance upon Allah. | Tawaakul Madhmum | التواكل | trust,reliance | At-Talaq 65:3 | Sahih al-Bukhari 6470 |
| 177 | Ridha bil-Qada | الرضا بالقضاء | Positive | Being pleased with Allah's decree and wisdom. | Sakhat | السخط | contentment,decree | Al-Baqarah 2:216 | Jami at-Tirmidhi 2396 (Hasan) |
| 178 | Mahabbah fillah | المحبة في الله | Positive | Loving others for the sake of Allah. | Mahabbah lid-Dunya | المحبة للدنيا | love,brotherhood | Al-Hashr 59:10 | Sahih Muslim 2566 |
| 179 | Bughd fillah | البغض في الله | Positive | Disliking disbelief and sin for Allah's sake without injustice. | Mudahanah | المداهنة | loyalty,principles | Al-Mumtahanah 60:4 | Sunan Abi Dawud 4681 (Hasan) |
| 180 | Ikhlas al-Mahabbah | إخلاص المحبة | Positive | Purifying love so that Allah becomes the highest beloved. | Shirk al-Mahabbah | شرك المحبة | love,sincerity | Al-Baqarah 2:165 | Sahih Muslim 2721 |
| 181 | Sidq al-Mahabbah | صدق المحبة | Positive | Truthfulness in one's love for Allah. | Da'wa al-Mahabbah | دعوى المحبة | love,sincerity | Ali Imran 3:31 | Sahih al-Bukhari 15 |
| 182 | Shawq ila Allah | الشوق إلى الله | Positive | Longing and yearning for meeting Allah. | Ghaflah | الغفلة | longing,yearning | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 183 | Tafwid | التفويض | Positive | Entrusting all affairs to Allah. | I'timad ala an-Nafs | الاعتماد على النفس | entrustment,surrender | Ghafir 40:44 | Sahih Muslim 2717 |
| 184 | Istiqamah Kamilah | الاستقامة الكاملة | Positive | Remaining steadfast until death. | Inhiraf | الانحراف | steadfastness,consistency | Fussilat 41:30 | Sahih Muslim 38 |
| 185 | Sakinah | السكينة | Positive | Inner tranquility sent by Allah. | Idtirab | الاضطراب | tranquility,peace | Al-Fath 48:4 | Sahih Muslim 2700 |
| 186 | Basirah | البصيرة | Positive | Deep spiritual insight and understanding. | Amy | العمى | insight,wisdom | Yusuf 12:108 | Sahih Muslim 2699 |
| 187 | Shukr al-Khalq | شكر الخلق | Positive | Showing gratitude to people for their kindness. | Kufran al-Jamil | كفران الجميل | gratitude,appreciation | Luqman 31:14 | Jami at-Tirmidhi 1954 (Sahih) |
| 188 | Falah | الفلاح | Positive | True success in this world and the Hereafter. | Khusran | الخسران | success,salvation | Al-Muminun 23:1 | Sahih Muslim 85 |
| 189 | Husn al-Khatimah | حسن الخاتمة | Positive | A good and blessed ending. | Su al-Khatimah | سوء الخاتمة | ending,death | Ali Imran 3:102 | Sahih al-Bukhari 6607 |
| 190 | Rifq billah | الرفق بالله | Positive | Experiencing Allah's gentleness in His decrees and dealings. | Su az-Zann billah | سوء الظن بالله | gentleness,hope | At-Talaq 65:7 | Sahih Muslim 2593 |
| 191 | Fawz al-Azim | الفوز العظيم | Positive | Attaining the supreme success of Paradise and Allah's pleasure. | Khusran | الخسران | success,salvation | At-Tawbah 9:72 | Sahih Muslim 2829 |
| 192 | Liqa Allah | لقاء الله | Positive | Longing and preparation for meeting Allah. | Karahiyat Liqa Allah | كراهية لقاء الله | meeting Allah,hope | Al-Ankabut 29:5 | Sahih al-Bukhari 6507 |
| 193 | Ridhwan Allah | رضوان الله | Positive | Seeking and attaining Allah's pleasure above everything. | Sakhat Allah | سخط الله | pleasure,acceptance | At-Tawbah 9:72 | Sahih Muslim 2829 |
| 194 | Darajat al-Ihsan | درجات الإحسان | Positive | Ascending in excellence and nearness to Allah. | Ghaflah | الغفلة | excellence,nearness | Al-Mutaffifin 83:28 | Sahih Muslim 8 |
| 195 | Ubudiyyah Kamilah | العبودية الكاملة | Positive | Complete servitude and submission to Allah. | Ubudiyyah li Ghayrillah | العبودية لغير الله | servitude,worship | Adh-Dhariyat 51:56 | Sahih Muslim 8 |
| 196 | Tawhid Kamil | التوحيد الكامل | Positive | Perfect realization of Allah's Oneness. | Shirk | الشرك | monotheism,faith | Al-Ikhlas 112:1 | Sahih al-Bukhari 7375 |
| 197 | Siddiqiyyah | الصديقية | Positive | Highest rank of truthfulness after Prophethood. | Takdhib | التكذيب | truthfulness,sincerity | An-Nisa 4:69 | Sahih al-Bukhari 6094 |
| 198 | Wilayah | الولاية | Positive | Nearness and friendship with Allah through obedience. | Adawah | العداوة | friendship,nearness | Yunus 10:62 | Sahih al-Bukhari 6502 |
| 199 | Talab al-Firdaws al-Ala | طلب الفردوس الأعلى | Positive | Aspiring for the highest level of Paradise. | Qana'ah bid-Dun | القناعة بالدون | paradise,aspiration | Al-Mutaffifin 83:26 | Sahih al-Bukhari 2790 |
| 200 | Jannat an-Naim Orientation | التطلع إلى جنة النعيم | Positive | Living with the Hereafter as the ultimate objective. | Ghurur bid-Dunya | الغرور بالدنيا | paradise,hereafter | Ash-Shura 42:20 | Sahih Muslim 2864 |

---

## See also

- `HeartOS/07_appendices/200_attributes.md` — full detail section with all 23 columns per attribute
- `HeartOS/01_core_tables/attributes.md` — schema discussion and distribution
- `HeartOS/assets/seeds/attributes_seed.sample.json` — JSON sample (2 rows)
- `200-Attributes.xlsx` (parent directory) — source of truth
- `NafsMutmainna-200-Attributes.docx` (parent directory) — narrative guide
- `HeartOS/AUDIT_REPORT.md` §3.1, §3.3 — known seed-level duplicates and field-alignment issues
