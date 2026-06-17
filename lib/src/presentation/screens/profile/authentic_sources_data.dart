/// Static reference list of authentic Islamic sources used by HeartOS.
///
/// Sourced from `HeartOS/authentic-sources.md`. This list is for in-app
/// transparency only — the actual Quran / Hadith / Dhikr content is stored
/// in the SQLite database and seeded from `assets/data/`.
class SourceCategory {
  final String title;
  final String description;
  final List<String> works;

  const SourceCategory({
    required this.title,
    required this.description,
    required this.works,
  });
}

const List<SourceCategory> kAuthenticSources = [
  SourceCategory(
    title: '1. Primary Source',
    description: 'The Noble Quran',
    works: [
      'English: Saheeh International',
      'Urdu: Mufti Taqi Usmani',
    ],
  ),
  SourceCategory(
    title: '2. Highest Authentic Hadith Sources (Sahihayn)',
    description: '',
    works: [
      'Sahih al-Bukhari — Imam Muhammad ibn Ismail al-Bukhari',
      'Sahih Muslim — Imam Muslim ibn al-Hajjaj',
    ],
  ),
  SourceCategory(
    title: '3. Secondary Sources',
    description: 'Only narrations graded Sahih or Hasan by scholars',
    works: [
      'Jami\' at-Tirmidhi — Imam Abu Isa al-Tirmidhi',
      'Sunan Abi Dawud — Imam Abu Dawud al-Sijistani',
      'Sunan an-Nasa\'i — Imam Ahmad an-Nasa\'i',
      'Sunan Ibn Majah — Imam Ibn Majah (used sparingly)',
      'Muwatta Imam Malik — Imam Malik ibn Anas',
    ],
  ),
  SourceCategory(
    title: '4. Curated Authentic Collections',
    description: '',
    works: [
      'Riyad as-Salihin — Imam Yahya al-Nawawi (~1900 selected hadiths)',
      'Forty Hadith of Imam Nawawi — Imam al-Nawawi',
      'Al-Adab al-Mufrad — Imam al-Bukhari (used selectively)',
      'Bulugh al-Maram — Ibn Hajar al-Asqalani (used selectively)',
    ],
  ),
  SourceCategory(
    title: '5. Daily Adhkar',
    description: '',
    works: [
      'Hisn al-Muslim (Fortress of the Muslim) — Sa\'id ibn Ali al-Qahtani',
    ],
  ),
  SourceCategory(
    title: '6. Classical Tazkiyah References',
    description:
        'Used mainly for understanding relationships between attributes and emotions, not as primary evidence.',
    works: [
      'Imam Ibn al-Qayyim: Madarij al-Salikin, Al-Wabil al-Sayyib, Al-Da\' wa al-Dawa\', Ighathat al-Lahfan',
      'Imam al-Ghazali: Ihya Ulum al-Din (used cautiously)',
      'Imam Ibn Rajab: Jami\' al-\'Ulum wal-Hikam',
      'Ibn Taymiyyah: Majmu\' al-Fatawa',
    ],
  ),
  SourceCategory(
    title: '7. Tafsir Sources',
    description: 'Used only for understanding verses.',
    works: [
      'Tafsir Ibn Kathir (primary reference)',
      'Tafsir al-Sa\'di (for practical meanings)',
      'Maariful Quran — Mufti Muhammad Taqi Usmani (for Urdu understanding)',
    ],
  ),
];

/// Sources intentionally avoided in HeartOS content.
const List<String> kSourcesAvoided = [
  'Weak (Da\'if) narrations',
  'Fabricated (Mawdu\') narrations',
  'Dream stories',
  'Sufi anecdotes without chains',
  'Internet quotations without references',
  'Inspirational sayings falsely attributed to the Prophet ﷺ',
  'Unverified WhatsApp material',
];
