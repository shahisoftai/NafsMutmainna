import '../../../../domain/entities/nafs_history.dart';
import '../../../../domain/entities/vector4.dart';
import '../../../../domain/repositories/checkin_repository.dart';
import '../../../../domain/repositories/emotion_repository.dart';
import '../../../../domain/repositories/nafs_history_repository.dart';
import '../../../../domain/usecases/nafs/constants.dart';

/// Source of the dhikr shown in the "Today's Practice" hero card.
enum DhikrSource {
  /// Derived from today's most recent check-in emotion.
  todayCheckin,

  /// Curated fallback based on the user's dominant Nafs state.
  nafsStateBased,
}

/// Trend direction for Nafs movement.
enum NafsTrendDirection { up, down, flat }

/// 15-day Nafs trend data for the chart.
class NafsTrendData {
  /// Positive score per day (canonical 0-100 heart-health), for chart plotting.
  final List<int> dailyScores;

  /// Trend direction compared to 7 days ago.
  final NafsTrendDirection direction;

  /// Change in percentage points vs 7 days ago.
  final int deltaPercent;

  /// Whether we have enough data to show the chart.
  final bool hasEnoughData;

  const NafsTrendData({
    required this.dailyScores,
    required this.direction,
    required this.deltaPercent,
    required this.hasEnoughData,
  });

  static const NafsTrendData empty = NafsTrendData(
    dailyScores: [],
    direction: NafsTrendDirection.flat,
    deltaPercent: 0,
    hasEnoughData: false,
  );
}

const Map<String, Map<String, String>> _allahNamesData = {
  'ArRaḥmān': {'arabic': 'ٱلرَّحْمَٰنُ', 'transliteration': 'Ar-Raḥmān', 'meaning': 'The Most Merciful, The Entirely Merciful'},
  'ArRaḥīm': {'arabic': 'ٱلرَّحِيمُ', 'transliteration': 'Ar-Raḥīm', 'meaning': 'The Especially Merciful'},
  'AlMalik': {'arabic': 'ٱلْمَلِكُ', 'transliteration': 'Al-Malik', 'meaning': 'The King and Owner of Dominion'},
  'AlQuddūs': {'arabic': 'ٱلْقُدُّوسُ', 'transliteration': 'Al-Quddūs', 'meaning': 'The Absolutely Pure and Perfect'},
  'AsSalām': {'arabic': 'ٱلسَّلَامُ', 'transliteration': 'As-Salām', 'meaning': 'The Source of Peace, The Flawless'},
  'AlMu’min': {'arabic': 'ٱلْمُؤْمِنُ', 'transliteration': 'Al-Mu’min', 'meaning': 'The Granter of Security and Faith'},
  'AlMuhaymin': {'arabic': 'ٱلْمُهَيْمِنُ', 'transliteration': 'Al-Muhaymin', 'meaning': 'The Guardian, The Witness, The Overseer'},
  'Al‘Azīz': {'arabic': 'ٱلْعَزِيزُ', 'transliteration': 'Al-‘Azīz', 'meaning': 'The Almighty, The All-Powerful, The Invincible, The Honorable'},
  'AlJabbār': {'arabic': 'ٱلْجَبَّارُ', 'transliteration': 'Al-Jabbār', 'meaning': 'The Compeller, The Restorer'},
  'AlMutakabbir': {'arabic': 'ٱلْمُتَكَبِّرُ', 'transliteration': 'Al-Mutakabbir', 'meaning': 'The Supreme in Glory, The Rightfully Proud'},
  'AlKhāliq': {'arabic': 'ٱلْخَٰلِقُ', 'transliteration': 'Al-Khāliq', 'meaning': 'The Creator, The Maker'},
  'AlBāriʾ': {'arabic': 'ٱلْبَارِئُ', 'transliteration': 'Al-Bāriʾ', 'meaning': 'The Originator, The Inventor'},
  'AlMuṣawwir': {'arabic': 'ٱلْمُصَوِّرُ', 'transliteration': 'Al-Muṣawwir', 'meaning': 'The Fashioner, The Shaper'},
  'AlGhaffār': {'arabic': 'ٱلْغَفَّارُ', 'transliteration': 'Al-Ghaffār', 'meaning': 'The Constant Forgiver, The Great Forgiver'},
  'AlQahhār': {'arabic': 'ٱلْقَهَّارُ', 'transliteration': 'Al-Qahhār', 'meaning': 'The Subduer, The Ever-Dominating'},
  'AlWahhāb': {'arabic': 'ٱلْوَهَّابُ', 'transliteration': 'Al-Wahhāb', 'meaning': 'The Giver of Gifts, The Bestower'},
  'ArRazzāq': {'arabic': 'ٱلرَّزَّاقُ', 'transliteration': 'Ar-Razzāq', 'meaning': 'The Ever-Providing, The Constant Provider'},
  'AlFattāḥ': {'arabic': 'ٱلْفَتَّاحُ', 'transliteration': 'Al-Fattāḥ', 'meaning': 'The Opener, The Judge'},
  'AlʿAlīm': {'arabic': 'ٱلْعَلِيمُ', 'transliteration': 'Al-ʿAlīm', 'meaning': 'The All-Knowing, The Omniscient'},
  'AlQābiḍ': {'arabic': 'ٱلْقَابِضُ', 'transliteration': 'Al-Qābiḍ', 'meaning': 'The Withholder, The Restrainer'},
  'AlBāsiṭ': {'arabic': 'ٱلْبَاسِطُ', 'transliteration': 'Al-Bāsiṭ', 'meaning': 'The Extender, The Expander'},
  'AlKhāfiḍ': {'arabic': 'ٱلْخَافِضُ', 'transliteration': 'Al-Khāfiḍ', 'meaning': 'The Reducer, The Abaser'},
  'ArRāfiʿ': {'arabic': 'ٱلرَّافِعُ', 'transliteration': 'Ar-Rāfiʿ', 'meaning': 'The Exalter, The Elevator'},
  'AlMuʿizz': {'arabic': 'ٱلْمُعِزُّ', 'transliteration': 'Al-Muʿizz', 'meaning': 'The Honourer, The Bestower of Honor'},
  'AlMudhil': {'arabic': 'ٱلْمُذِلُّ', 'transliteration': 'Al-Mudhil', 'meaning': 'The Dishonourer, The Humiliator'},
  'AsSamīʿ': {'arabic': 'ٱلسَّمِيعُ', 'transliteration': 'As-Samīʿ', 'meaning': 'The All-Hearing'},
  'AlBaṣīr': {'arabic': 'ٱلْبَصِيرُ', 'transliteration': 'Al-Baṣīr', 'meaning': 'The All-Seeing'},
  'AlḤakam': {'arabic': 'ٱلْحَكَمُ', 'transliteration': 'Al-Ḥakam', 'meaning': 'The Judge, The Giver of Justice'},
  'Al‘Adl': {'arabic': 'ٱلْعَدْلُ', 'transliteration': 'Al-‘Adl', 'meaning': 'The Utterly Just'},
  'AlLaṭīf': {'arabic': 'ٱللَّطِيفُ', 'transliteration': 'Al-Laṭīf', 'meaning': 'The Most Gentle, The Subtle One'},
  'AlKhabīr': {'arabic': 'ٱلْخَبِيرُ', 'transliteration': 'Al-Khabīr', 'meaning': 'The All-Aware, The All-Acquainted'},
  'AlḤalīm': {'arabic': 'ٱلْحَلِيمُ', 'transliteration': 'Al-Ḥalīm', 'meaning': 'The Most Forbearing'},
  'AlʿAẓīm': {'arabic': 'ٱلْعَظِيمُ', 'transliteration': 'Al-ʿAẓīm', 'meaning': 'The Magnificent, The Supreme'},
  'AlGhafūr': {'arabic': 'ٱلْغَفُورُ', 'transliteration': 'Al-Ghafūr', 'meaning': 'The Forgiving, The Exceedingly Forgiving'},
  'AshShakūr': {'arabic': 'ٱلشَّكُورُ', 'transliteration': 'Ash-Shakūr', 'meaning': 'The Most Appreciative'},
  'AlʿAlī': {'arabic': 'ٱلْعَلِيُّ', 'transliteration': 'Al-ʿAlī', 'meaning': 'The Most High, The Exalted'},
  'AlKabīr': {'arabic': 'ٱلْكَبِيرُ', 'transliteration': 'Al-Kabīr', 'meaning': 'The Greatest, The Most Grand'},
  'AlḤafīẓ': {'arabic': 'ٱلْحَفِيظُ', 'transliteration': 'Al-Ḥafīẓ', 'meaning': 'The Preserver, The All-Heedful and All-Protecting'},
  'AlMuqīt': {'arabic': 'ٱلْمُقِيتُ', 'transliteration': 'Al-Muqīt', 'meaning': 'The Nourisher, The All-Powerful Maintainer'},
  'AlḤasīb': {'arabic': 'ٱلْحَسِيبُ', 'transliteration': 'Al-Ḥasīb', 'meaning': 'The Reckoner'},
  'AlJalīl': {'arabic': 'ٱلْجَلِيلُ', 'transliteration': 'Al-Jalīl', 'meaning': 'The Majestic'},
  'AlKarīm': {'arabic': 'ٱلْكَرِيمُ', 'transliteration': 'Al-Karīm', 'meaning': 'The Most Generous, The Most Noble'},
  'ArRaqīb': {'arabic': 'ٱلرَّقِيبُ', 'transliteration': 'Ar-Raqīb', 'meaning': 'The Watchful, The All-Watchful'},
  'AlMujīb': {'arabic': 'ٱلْمُجِيبُ', 'transliteration': 'Al-Mujīb', 'meaning': 'The Responsive, The Answerer'},
  'AlWāsiʿ': {'arabic': 'ٱلْوَاسِعُ', 'transliteration': 'Al-Wāsiʿ', 'meaning': 'The All-Encompassing, the Boundless'},
  'AlḤakīm': {'arabic': 'ٱلْحَكِيمُ', 'transliteration': 'Al-Ḥakīm', 'meaning': 'The All-Wise'},
  'AlWadūd': {'arabic': 'ٱلْوَدُودُ', 'transliteration': 'Al-Wadūd', 'meaning': 'The Most Loving'},
  'AlMajīd': {'arabic': 'ٱلْمَجِيدُ', 'transliteration': 'Al-Majīd', 'meaning': 'The All-Glorious, The Ever-Majestic'},
  'AlBāʿith': {'arabic': 'ٱلْبَاعِثُ', 'transliteration': 'Al-Bāʿith', 'meaning': 'The Infuser of New Life, The Resurrector'},
  'AsShahīd': {'arabic': 'ٱلشَّهِيدُ', 'transliteration': 'As-Shahīd', 'meaning': 'The All-Witnessing'},
  'AlḤaqq': {'arabic': 'ٱلْحَقُّ', 'transliteration': 'Al-Ḥaqq', 'meaning': 'The Absolute Truth'},
  'AlWakīl': {'arabic': 'ٱلْوَكِيلُ', 'transliteration': 'Al-Wakīl', 'meaning': 'The Trustee, The Disposer of Affairs'},
  'AlQawiyy': {'arabic': 'ٱلْقَوِيُّ', 'transliteration': 'Al-Qawiyy', 'meaning': 'The All-Strong'},
  'AlMatīn': {'arabic': 'ٱلْمَتِينُ', 'transliteration': 'Al-Matīn', 'meaning': 'The Firm, The Steadfast'},
  'AlWaliyy': {'arabic': 'ٱلْوَلِيُّ', 'transliteration': 'Al-Waliyy', 'meaning': 'The Protector, The Guardian'},
  'AlḤamīd': {'arabic': 'ٱلْحَمِيدُ', 'transliteration': 'Al-Ḥamīd', 'meaning': 'The Praiseworthy, The Most Praised'},
  'AlMuḥṣī': {'arabic': 'ٱلْمُحْصِي', 'transliteration': 'Al-Muḥṣī', 'meaning': 'The All-Enumerating, The Counter'},
  'AlMubdiʾ': {'arabic': 'ٱلْمُبْدِئُ', 'transliteration': 'Al-Mubdiʾ', 'meaning': 'The Originator, The Initiator'},
  'AlMuʿīd': {'arabic': 'ٱلْمُعِيدُ', 'transliteration': 'Al-Muʿīd', 'meaning': 'The Restorer, The Reviver'},
  'AlMuḥyī': {'arabic': 'ٱلْمُحْيِي', 'transliteration': 'Al-Muḥyī', 'meaning': 'The Giver of Life'},
  'AlMumīt': {'arabic': 'ٱلْمُمِيتُ', 'transliteration': 'Al-Mumīt', 'meaning': 'The Taker of Life, The Causer of Death'},
  'AlḤayy': {'arabic': 'ٱلْحَيُّ', 'transliteration': 'Al-Ḥayy', 'meaning': 'The Ever-Living'},
  'AlQayyūm': {'arabic': 'ٱلْقَيُّومُ', 'transliteration': 'Al-Qayyūm', 'meaning': 'The Sustainer, The Self-Subsisting'},
  'AlWājid': {'arabic': 'ٱلْوَاجِدُ', 'transliteration': 'Al-Wājid', 'meaning': 'The Ever-Wealthy, The Self-Sufficient'},
  'AlMājid': {'arabic': 'ٱلْمَاجِدُ', 'transliteration': 'Al-Mājid', 'meaning': 'The Noble, The Generous'},
  'AlWāḥid': {'arabic': 'ٱلْوَاحِدُ', 'transliteration': 'Al-Wāḥid', 'meaning': 'The One, The Indivisible'},
  'AlAḥad': {'arabic': 'ٱلْأَحَدُ', 'transliteration': 'Al-Aḥad', 'meaning': 'The Unique, The Only One'},
  'AṣṢamad': {'arabic': 'ٱلصَّمَدُ', 'transliteration': 'Aṣ-Ṣamad', 'meaning': 'The Self-Subsisting, The One Upon Whom All Depend'},
  'AlQādir': {'arabic': 'ٱلْقَادِرُ', 'transliteration': 'Al-Qādir', 'meaning': 'The Omnipotent, The All-Able'},
  'AlMuqtadir': {'arabic': 'ٱلْمُقْتَدِرُ', 'transliteration': 'Al-Muqtadir', 'meaning': 'The All-Powerful, The Dominant'},
  'AlMuqaddim': {'arabic': 'ٱلْمُقَدِّمُ', 'transliteration': 'Al-Muqaddim', 'meaning': 'The Expediter, The Promoter'},
  'AlMuʾakhkhir': {'arabic': 'ٱلْمُؤَخِّرُ', 'transliteration': 'Al-Muʾakhkhir', 'meaning': 'The Delayer, The Postponer'},
  'AlAwwal': {'arabic': 'ٱلْأَوَّلُ', 'transliteration': 'Al-Awwal', 'meaning': 'The First, The Pre-Existing'},
  'AlĀkhir': {'arabic': 'ٱلْآخِرُ', 'transliteration': 'Al-Ākhir', 'meaning': 'The Last, The Ever-Remaining'},
  'AẓẒāhir': {'arabic': 'ٱلظَّاهِرُ', 'transliteration': 'Aẓ-Ẓāhir', 'meaning': 'The Manifest, The Highest'},
  'AlBāṭin': {'arabic': 'ٱلْبَاطِنُ', 'transliteration': 'Al-Bāṭin', 'meaning': 'The Hidden One, Knower of the Hidden'},
  'AlWālī': {'arabic': 'ٱلْوَالِي', 'transliteration': 'Al-Wālī', 'meaning': 'The Sole Governor'},
  'AlMutaʿālī': {'arabic': 'ٱلْمُتَعَالِي', 'transliteration': 'Al-Mutaʿālī', 'meaning': 'The Self-Exalted'},
  'AlBarr': {'arabic': 'ٱلْبَرُّ', 'transliteration': 'Al-Barr', 'meaning': 'The Source of All Goodness'},
  'AtTawwāb': {'arabic': 'ٱلتَّوَابُ', 'transliteration': 'At-Tawwāb', 'meaning': 'The Accepter of Repentance, The Ever-Relenting'},
  'AlMuntaqim': {'arabic': 'ٱلْمُنْتَقِمُ', 'transliteration': 'Al-Muntaqim', 'meaning': 'The Avenger'},
  'AlʿAfūw': {'arabic': 'ٱلْعَفُوُّ', 'transliteration': 'Al-ʿAfūw', 'meaning': 'The Pardoner'},
  'ArRaʾūf': {'arabic': 'ٱلرَّءُوفُ', 'transliteration': 'Ar-Raʾūf', 'meaning': 'The Most Kind'},
  'MālikalMulk': {'arabic': 'مَالِكُ ٱلْمُلْكِ', 'transliteration': 'Mālik al-Mulk', 'meaning': 'Master of the Dominion, Owner of the Kingdom'},
  'DhūalJalāliwa’lIkrām': {'arabic': 'ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ', 'transliteration': 'Dhū al-Jalāli wa’l-Ikrām', 'meaning': 'Possessor of Glory and Honour'},
  'AlMuqsiṭ': {'arabic': 'ٱلْمُقْسِطُ', 'transliteration': 'Al-Muqsiṭ', 'meaning': 'The Just One'},
  'AlJāmiʿ': {'arabic': 'ٱلْجَامِعُ', 'transliteration': 'Al-Jāmiʿ', 'meaning': 'The Gatherer, the Uniter'},
  'AlGhaniyy': {'arabic': 'ٱلْغَنِيُّ', 'transliteration': 'Al-Ghaniyy', 'meaning': 'The Self-Sufficient, The Free of All Need'},
  'AlMughnī': {'arabic': 'ٱلْمُغْنِيُ', 'transliteration': 'Al-Mughnī', 'meaning': 'The Enricher'},
  'AlMāniʿ': {'arabic': 'ٱلْمَانِعُ', 'transliteration': 'Al-Māniʿ', 'meaning': 'The Withholder'},
  'AḍḌārr': {'arabic': 'ٱلضَّارُّ', 'transliteration': 'Aḍ-Ḍārr', 'meaning': 'The Creator of Harm'},
  'AnNāfiʿ': {'arabic': 'ٱلنَّافِعُ', 'transliteration': 'An-Nāfiʿ', 'meaning': 'The Propitious, The Benefactor'},
  'AnNūr': {'arabic': 'ٱلنُّورُ', 'transliteration': 'An-Nūr', 'meaning': 'The Light'},
  'AlHādī': {'arabic': 'ٱلْهَادِي', 'transliteration': 'Al-Hādī', 'meaning': 'The Guide'},
  'AlBadīʿ': {'arabic': 'ٱلْبَدِيعُ', 'transliteration': 'Al-Badīʿ', 'meaning': 'The Incomparable Originator'},
  'AlBāqī': {'arabic': 'ٱلْبَاقِي', 'transliteration': 'Al-Bāqī', 'meaning': 'The Ever-Lasting'},
  'AlWāriṯ': {'arabic': 'ٱلْوَارِثُ', 'transliteration': 'Al-Wāriṯ', 'meaning': 'The Inheritor'},
  'ArRashīd': {'arabic': 'ٱلرَّشِيدُ', 'transliteration': 'Ar-Rashīd', 'meaning': 'The Guide to the Right Path'},
  'AṣṢabūr': {'arabic': 'ٱلصَّبُورُ', 'transliteration': 'Aṣ-Ṣabūr', 'meaning': 'The Patient'},
};

/// Maps the English transliteration forms used in the seed JSON
/// (e.g. "Al-Halim", "Ar-Rahim") to the camelCase keys used in
/// [_allahNamesData] (e.g. "AlḤalīm", "ArRaḥīm"). This is needed because
/// the seed data uses a hyphenated English transliteration, while the
/// lookup table uses Arabic-style camelCase keys.
const Map<String, String> _englishNameToKey = {
  'Ar-Rahman': 'ArRaḥmān',
  'Ar-Raheem': 'ArRaḥīm',
  'Ar-Rahim': 'ArRaḥīm',
  'Al-Malik': 'AlMalik',
  'Al-Quddus': 'AlQuddūs',
  'As-Salam': 'AsSalām',
  'As-Salaam': 'AsSalām',
  'Al-Mumin': 'AlMu’min',
  'Al-Mu\'min': 'AlMu’min',
  'Al-Muhaymin': 'AlMuhaymin',
  'Al-Aziz': 'Al‘Azīz',
  'Al-\'Aziz': 'Al‘Azīz',
  'Al-Jabbar': 'AlJabbār',
  'Al-Mutakabbir': 'AlMutakabbir',
  'Al-Khaliq': 'AlKhāliq',
  'Al-Bari': 'AlBāriʾ',
  'Al-Bari\'': 'AlBāriʾ',
  'Al-Musawwir': 'AlMuṣawwir',
  'Al-Ghaffar': 'AlGhaffār',
  'Al-Qahhar': 'AlQahhār',
  'Al-Wahhab': 'AlWahhāb',
  'Ar-Razzaq': 'ArRazzāq',
  'Ar-Razzzaq': 'ArRazzāq',
  'Al-Fattah': 'AlFattāḥ',
  'Al-Alim': 'AlʿAlīm',
  'Al-\'Alim': 'AlʿAlīm',
  'Al-Qabid': 'AlQābiḍ',
  'Al-Basit': 'AlBāsiṭ',
  'Al-Khafid': 'AlKhāfiḍ',
  'Al-Rafi': 'ArRāfiʿ',
  'Al-Rafi\'': 'ArRāfiʿ',
  'Al-Mu\'izz': 'AlMuʿizz',
  'Al-Muizz': 'AlMuʿizz',
  'Al-Mudhill': 'AlMudhil',
  'Al-Mudhil': 'AlMudhil',
  'As-Sami': 'AsSamīʿ',
  'As-Sami\'': 'AsSamīʿ',
  'Al-Basir': 'AlBaṣīr',
  'Al-Hakam': 'AlḤakam',
  'Al-Adl': 'Al‘Adl',
  'Al-\'Adl': 'Al‘Adl',
  'Al-Latif': 'AlLaṭīf',
  'Al-Khabir': 'AlKhabīr',
  'Al-Halim': 'AlḤalīm',
  'Al-Azim': 'AlʿAẓīm',
  'Al-\'Azim': 'AlʿAẓīm',
  'Al-Ghafor': 'AlGhafūr',
  'Al-Ghafur': 'AlGhafūr',
  'Ash-Shakur': 'AshShakūr',
  'Al-Aliyy': 'AlʿAlī',
  'Al-Ali': 'AlʿAlī',
  'Al-Kabir': 'AlKabīr',
  'Al-Hafiz': 'AlḤafīẓ',
  'Al-Muqeet': 'AlMuqīt',
  'Al-Haseeb': 'AlḤasīb',
  'Al-Jalil': 'AlJalīl',
  'Al-Karim': 'AlKarīm',
  'Ar-Raqib': 'ArRaqīb',
  'Al-Mujeeb': 'AlMujīb',
  'Al-Wasi': 'AlWāsiʿ',
  'Al-Hakim': 'AlḤakīm',
  'Al-Wadud': 'AlWadūd',
  'Al-Majeed': 'AlMajīd',
  'Al-Baith': 'AlBāʿith',
  'As-Shahid': 'AsShahīd',
  'Ash-Shahid': 'AsShahīd',
  'Al-Haqq': 'AlḤaqq',
  'Al-Wakeel': 'AlWakīl',
  'Al-Wakil': 'AlWakīl',
  'Al-Qawiyy': 'AlQawiyy',
  'Al-Matin': 'AlMatīn',
  'Al-Waliyy': 'AlWaliyy',
  'Al-Wali': 'AlWālī',
  'Al-Hameed': 'AlḤamīd',
  'Al-Muhsi': 'AlMuḥṣī',
  'Al-Mubdi': 'AlMubdiʾ',
  'Al-Mueed': 'AlMuʿīd',
  'Al-Muhyi': 'AlMuḥyī',
  'Al-Mumeet': 'AlMumīt',
  'Al-Hayy': 'AlḤayy',
  'Al-Qayyum': 'AlQayyūm',
  'Al-Qayyuum': 'AlQayyūm',
  'Al-Wajid': 'AlWājid',
  'Al-Majid': 'AlMājid',
  'Al-Wahid': 'AlWāḥid',
  'Al-Ahad': 'AlAḥad',
  'As-Samad': 'AṣṢamad',
  'Al-Qadir': 'AlQādir',
  'Al-Muqtadir': 'AlMuqtadir',
  'Al-Muqaddim': 'AlMuqaddim',
  'Al-Muakhkhir': 'AlMuʾakhkhir',
  'Al-Mu\'akhkhir': 'AlMuʾakhkhir',
  'Al-Awwal': 'AlAwwal',
  'Al-Akhir': 'AlĀkhir',
  'Az-Zahir': 'AẓẒāhir',
  'Al-Batin': 'AlBāṭin',
  'Al-Mutaali': 'AlMutaʿālī',
  'Al-Muta\'ali': 'AlMutaʿālī',
  'Al-Barr': 'AlBarr',
  'At-Tawwab': 'AtTawwāb',
  'Al-Muntaqim': 'AlMuntaqim',
  'Al-Afuww': 'AlʿAfūw',
  'Al-Afuw': 'AlʿAfūw',
  'Ar-Rauf': 'ArRaʾūf',
  'Ar-Ra\'uf': 'ArRaʾūf',
  'Malik-ul-Mulk': 'MālikalMulk',
  'Dhul-Jalali-Wal-Ikram': 'DhūalJalāliwa’lIkrām',
  'Al-Muqsit': 'AlMuqsiṭ',
  'Al-Jami': 'AlJāmiʿ',
  'Al-Ghani': 'AlGhaniyy',
  'Al-Mughni': 'AlMughnī',
  'Al-Mani': 'AlMāniʿ',
  'Ad-Darr': 'AḍḌārr',
  'An-Nafi': 'AnNāfiʿ',
  'An-Nur': 'AnNūr',
  'Al-Hadi': 'AlHādī',
  'Al-Badi': 'AlBadīʿ',
  'Al-Baqi': 'AlBāqī',
  'Al-Warith': 'AlWāriṯ',
  'Ar-Rasheed': 'ArRashīd',
  'As-Sabur': 'AṣṢabūr',
  'Ar-Rafiq': 'ArRāfiʿ',
  'Al-Haakim': 'AlḤakīm',
  'An-Noor': 'AnNūr',
  'Al-Warithh': 'AlWāriṯ',
};

/// A single dhikr / remembrance item.
class DhikrItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final DhikrSource source;
  final String sourceLabel;

  /// Optional recommended daily count (e.g. 101). When set, the counter sheet
  /// shows progress against this target and the remaining count. Null means
  /// no target is tracked (legacy / open-ended counter).
  final int? target;

  const DhikrItem({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
    required this.sourceLabel,
    this.target,
  });
}

/// A single dhikr occurrence within a [JourneyDay].
class JourneyDhikrItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final String emotionName;
  final int intensity;

  const JourneyDhikrItem({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.emotionName,
    required this.intensity,
  });
}

/// All data for one day in the 15-day journey timeline.
class JourneyDay {
  final DateTime date;
  final NafsType dominantNafs;
  final int positiveScore;
  final List<JourneyDhikrItem> dhikrItems;
  final bool hasCheckin;

  const JourneyDay({
    required this.date,
    required this.dominantNafs,
    required this.positiveScore,
    required this.dhikrItems,
    required this.hasCheckin,
  });
}

/// The full 15-day journey data passed to the journey screen.
class JourneyData {
  final List<JourneyDay> days;
  final NafsTrendData trend;
  final Map<String, int> nameFrequency;

  const JourneyData({
    required this.days,
    required this.trend,
    required this.nameFrequency,
  });

  static const JourneyData empty = JourneyData(
    days: [],
    trend: NafsTrendData.empty,
    nameFrequency: {},
  );
}

/// A historical aggregation of an Allah Name across a time window.
class DhikrHistoryItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final int timesSuggested;
  final DateTime lastSuggested;
  final String lastEmotionContext;

  const DhikrHistoryItem({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.timesSuggested,
    required this.lastSuggested,
    required this.lastEmotionContext,
  });
}

/// The full result rendered by the Daily Dhikr section.
class DailyDhikr {
  final DhikrItem? today;
  final List<DhikrHistoryItem> history;
  final bool hasAnyCheckins;
  final NafsTrendData nafsTrend;

  const DailyDhikr({
    required this.today,
    required this.history,
    required this.hasAnyCheckins,
    required this.nafsTrend,
  });

  static const DailyDhikr empty = DailyDhikr(
    today: null,
    history: [],
    hasAnyCheckins: false,
    nafsTrend: NafsTrendData.empty,
  );
}

/// Pure resolver for the Daily Dhikr section.
///
/// Single Responsibility: given the user's check-in history, emotions, and
/// current Nafs state, compute today's dhikr + the 15-day aggregation of
/// Allah Names. All side effects (DB / network) are abstracted behind the
/// repository interfaces passed in.
class DailyDhikrResolver {
  final CheckinRepositoryInterface _checkins;
  final EmotionRepositoryInterface _emotions;
  final NafsHistoryRepositoryInterface? _history;
  final int historyWindowDays;
  final int maxHistoryItems;

  const DailyDhikrResolver({
    required CheckinRepositoryInterface checkins,
    required EmotionRepositoryInterface emotions,
    NafsHistoryRepositoryInterface? history,
    this.historyWindowDays = 15,
    this.maxHistoryItems = 5,
  })  : _checkins = checkins,
        _emotions = emotions,
        _history = history;

  /// Build the full [DailyDhikr] for [today].
  Future<DailyDhikr> resolve({
    required DateTime today,
    required NafsType dominantNafs,
  }) async {
    final todayItem = await _resolveToday(today: today, dominantNafs: dominantNafs);
    final (history, hasAny) = await _resolveHistory(today: today);
    final nafsTrend = await _resolveNafsTrend(today: today);
    return DailyDhikr(
      today: todayItem,
      history: history,
      hasAnyCheckins: hasAny,
      nafsTrend: nafsTrend,
    );
  }

  /// Build the full 15-day [JourneyData] for the journey screen.
  Future<JourneyData> resolveJourney({required DateTime today}) async {
    // historyWindowDays-1 to get exactly historyWindowDays days in the window.
    final start = today.subtract(Duration(days: historyWindowDays - 1));
    final checkins = await _checkins.findBetween(start, today);
    List<NafsHistory> histories;
    if (_history == null) {
      histories = [];
    } else {
      histories = await _history.findBetween(start, today);
    }
    final histMap = {for (final h in histories) _dateOnly(h.date): h};

    final allNames = <String, int>{};
    final days = <JourneyDay>[];

    for (var i = historyWindowDays - 1; i >= 0; i--) {
      final date = _dateOnly(today.subtract(Duration(days: i)));
      final dayCheckins = checkins.where((c) => _dateOnly(c.date) == date).toList();
      final history = histMap[date];

      final dominantNafs = _dominantFromHistory(history);
      final positiveScore = history != null
          ? Vector4(history.ammarah, history.lawwamah, history.mulhamah,
                  history.mutmainnah)
              .heartHealthScore
          : 0;

      final dhikrItems = <JourneyDhikrItem>[];
      for (final c in dayCheckins) {
        final emotion = await _emotions.getById(c.emotionId);
        if (emotion == null) continue;
        final names = parseAllahNames(emotion.recommendedAllahNames);
        for (final n in names) {
          final key = n.arabic.isNotEmpty ? n.arabic : n.transliteration;
          if (key.isEmpty) continue;
          allNames[key] = (allNames[key] ?? 0) + 1;
        }
        if (emotion.recommendedDhikr.trim().isNotEmpty) {
          dhikrItems.add(JourneyDhikrItem(
            arabic: emotion.recommendedDhikr,
            transliteration: _transliterate(emotion.recommendedDhikr),
            meaning: _meaningFromEmotion(emotion),
            emotionName: emotion.name,
            intensity: c.intensity,
          ));
        }
      }

      days.add(JourneyDay(
        date: date,
        dominantNafs: dominantNafs,
        positiveScore: positiveScore,
        dhikrItems: dhikrItems,
        hasCheckin: dayCheckins.isNotEmpty,
      ));
    }

    final trend = await _resolveNafsTrend(today: today);
    return JourneyData(days: days, trend: trend, nameFrequency: allNames);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Look up today's NafsHistory and return its dominant Nafs type.
  /// Falls back to Lawwamah (the most common baseline) if no history exists.
  Future<NafsType> resolveDominantNafs({required DateTime today}) async {
    if (_history == null) return NafsType.lawwamah;
    final h = await _history.findForDate(today);
    return _dominantFromHistory(h);
  }

  static NafsType _dominantFromHistory(NafsHistory? h) {
    if (h == null) return NafsType.lawwamah;
    final v = Vector4(h.ammarah, h.lawwamah, h.mulhamah, h.mutmainnah);
    return v.dominant;
  }

  // ---------------------------------------------------------------------------
  // Today's practice
  // ---------------------------------------------------------------------------

  Future<DhikrItem?> _resolveToday({
    required DateTime today,
    required NafsType dominantNafs,
  }) async {
    final todayCheckins = await _checkins.findForDate(today);
    if (todayCheckins.isNotEmpty) {
      // Use the most recent check-in's emotion.
      final latest = todayCheckins.last;
      final emotion = await _emotions.getById(latest.emotionId);
      if (emotion != null && emotion.recommendedDhikr.trim().isNotEmpty) {
        return DhikrItem(
          arabic: emotion.recommendedDhikr,
          transliteration: _transliterate(emotion.recommendedDhikr),
          meaning: _meaningFromEmotion(emotion),
          source: DhikrSource.todayCheckin,
          sourceLabel: 'From ${emotion.name.toLowerCase()}',
          target: NafsConstants.defaultDhikrTarget,
        );
      }
    }
    // Fallback: derive from dominant Nafs state.
    return nafsStateDhikr(dominantNafs);
  }

  // ---------------------------------------------------------------------------
  // 15-day history aggregation
  // ---------------------------------------------------------------------------

  Future<(List<DhikrHistoryItem>, bool)> _resolveHistory({
    required DateTime today,
  }) async {
    final start = today.subtract(Duration(days: historyWindowDays - 1));
    final recent = await _checkins.findBetween(start, today);
    if (recent.isEmpty) {
      return (const <DhikrHistoryItem>[], false);
    }

    // Aggregate by Arabic key (falling back to transliteration when Arabic
    // is missing), tracking count + most-recent context.
    final Map<String, _HistAccumulator> acc = {};
    for (final c in recent) {
      final emotion = await _emotions.getById(c.emotionId);
      if (emotion == null) continue;
      final names = parseAllahNames(emotion.recommendedAllahNames);
      for (final n in names) {
        final key = n.arabic.isNotEmpty ? n.arabic : n.transliteration;
        if (key.isEmpty) continue;
        final existing = acc[key];
        if (existing == null) {
          acc[key] = _HistAccumulator(
            name: n,
            count: 1,
            last: c.date,
            lastEmotion: emotion.name,
          );
        } else {
          existing.count += 1;
          if (c.date.isAfter(existing.last)) {
            existing.last = c.date;
            existing.lastEmotion = emotion.name;
          }
        }
      }
    }

    final sorted = acc.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final history = sorted
        .take(maxHistoryItems)
        .map((a) => DhikrHistoryItem(
              arabic: a.name.arabic,
              transliteration: a.name.transliteration,
              meaning: a.name.meaning,
              timesSuggested: a.count,
              lastSuggested: a.last,
              lastEmotionContext: a.lastEmotion,
            ))
        .toList();
    return (history, true);
  }

  Future<NafsTrendData> _resolveNafsTrend({required DateTime today}) async {
    if (_history == null) return NafsTrendData.empty;
    // Subtract (historyWindowDays - 1) to get exactly historyWindowDays days.
    // e.g. today=Aug 10, historyWindowDays=15 → start=Jul 27 (14 days back),
    // findBetween(Jul 27, Aug 10) = 15 days (Jul 27 through Aug 10).
    final start = today.subtract(Duration(days: historyWindowDays - 1));
    final recent = await _history.findBetween(start, today);
    if (recent.isEmpty) return NafsTrendData.empty;
    final sorted = recent.toList()..sort((a, b) => a.date.compareTo(b.date));

    // Build a full 15-element array aligned to correct calendar positions so
    // the sparkline painter draws each score at its true day position.
    final dayScoreMap = <String, int>{};
    for (final h in sorted) {
      final score = Vector4(h.ammarah, h.lawwamah, h.mulhamah, h.mutmainnah)
          .heartHealthScore;
      dayScoreMap[_dateOnly(h.date).toIso8601String()] = score;
    }
    final dailyScores = <int>[];
    for (var i = 0; i < historyWindowDays; i++) {
      final d = _dateOnly(start.add(Duration(days: i)));
      dailyScores.add(dayScoreMap[d.toIso8601String()] ?? 0);
    }

    if (dailyScores.where((s) => s > 0).length < 2) {
      return NafsTrendData(
        dailyScores: dailyScores,
        direction: NafsTrendDirection.flat,
        deltaPercent: 0,
        hasEnoughData: false,
      );
    }
    // Bucket rows by calendar week (last 7 vs the 7 days before that), averaging
    // only the rows actually present so missing days don't skew the average.
    final dayScores = <String, int>{for (final h in sorted)
        _dateOnly(h.date).toIso8601String(): Vector4(
                h.ammarah, h.lawwamah, h.mulhamah, h.mutmainnah)
            .heartHealthScore,
    };
    final thisWeek = _avgWeek(dayScores, today, 1);
    final prevWeek = _avgWeek(dayScores, today, 2);
    if (thisWeek == null || prevWeek == null) {
      return NafsTrendData(
        dailyScores: dailyScores,
        direction: NafsTrendDirection.flat,
        deltaPercent: 0,
        hasEnoughData: false,
      );
    }
    final delta = (thisWeek - prevWeek).round();
    NafsTrendDirection direction;
    if (delta > 2) {
      direction = NafsTrendDirection.up;
    } else if (delta < -2) {
      direction = NafsTrendDirection.down;
    } else {
      direction = NafsTrendDirection.flat;
    }
    return NafsTrendData(
      dailyScores: dailyScores,
      direction: direction,
      deltaPercent: delta,
      hasEnoughData: true,
    );
  }

  /// Average the canonical scores over the [weekOffset] calendar week counting
  /// back from [today] (1 = most recent 7 days, 2 = the 7 days before). Returns
  /// null when fewer than 5 of the 7 days have data.
  double? _avgWeek(
    Map<String, int> dayScores,
    DateTime today,
    int weekOffset,
  ) {
    final values = <int>[];
    for (var i = 0; i < 7; i++) {
      final day = today.subtract(
          Duration(days: (weekOffset - 1) * 7 + i + 1));
      final v = dayScores[_dateOnly(day).toIso8601String()];
      if (v != null) values.add(v);
    }
    if (values.length < 5) return null;
    return values.fold<int>(0, (a, b) => a + b) / values.length;
  }
}

// =============================================================================
// Internal helpers
// =============================================================================

class _HistAccumulator {
  final AllahName name;
  int count;
  DateTime last;
  String lastEmotion;
  _HistAccumulator({
    required this.name,
    required this.count,
    required this.last,
    required this.lastEmotion,
  });
}

class AllahName {
  final String arabic;
  final String transliteration;
  final String meaning;
  const AllahName(this.arabic, this.transliteration, this.meaning);
}

/// Parse a delimited `recommendedAllahNames` string into a list of names.
///
/// The seed data uses a mix of separators (commas, semicolons, newlines, pipes).
/// We split on any of them, trim whitespace, and drop empties.
String _normalizeAllahNameKey(String s) {
  final t = s
      .replaceAll(RegExp(r"['`\u2018\u2019]"), "'")
      .replaceAll(RegExp(r'[\- ]+'), '');
  return t
      .replaceAll(RegExp(r'[\u0300-\u030F\u0311\u0321-\u032F]'), '')
      .toLowerCase();
}

List<AllahName> parseAllahNames(String raw) {
  if (raw.trim().isEmpty) return const [];
  final parts = raw.split(RegExp(r'[,;\n|]'));
  final result = <AllahName>[];
  for (final p in parts) {
    final trimmed = p.trim();
    if (trimmed.isEmpty) continue;
    // Look up the English transliteration form (as it appears in the seed
    // data, e.g. "Al-Halim") in [_englishNameToKey] to get the camelCase
    // key used in [_allahNamesData] (e.g. "AlḤalīm"). Fall back to a
    // normalized lookup and finally to using the raw transliteration so we
    // never silently drop a name from the history.
    final camelKey = _englishNameToKey[trimmed];
    final normalized = _normalizeAllahNameKey(trimmed);
    final key = camelKey ??
        (_allahNamesData.containsKey(trimmed)
            ? trimmed
            : (_allahNamesData.containsKey(normalized) ? normalized : null));
    final entry = key != null ? _allahNamesData[key] : null;
    if (entry != null) {
      result.add(AllahName(
        entry['arabic']!,
        entry['transliteration']!,
        entry['meaning']!,
      ));
    } else {
      // Graceful fallback: still surface the name even if we don't have a
      // rich record for it, so users always see *something* in the
      // "From your last 15 days" section.
      result.add(AllahName('', trimmed, ''));
    }
  }
  return result;
}

/// Best-effort transliteration. The Arabic text itself is the canonical
/// representation; this is shown as a hint when the user can't read Arabic.
String _bestEffortTransliterate(String arabic) {
  // Strip diacritics for display.
  return arabic
      .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '')
      .trim();
}

String _transliterate(String arabic) => _bestEffortTransliterate(arabic);

String _meaningFromEmotion(dynamic emotion) {
  // The emotion carries `recommendedDhikr` (Arabic) and `dailyAction` (English).
  // We surface the daily action as the practical "what to do" for this dhikr.
  try {
    final action = (emotion.dailyAction as String?) ?? '';
    if (action.trim().isNotEmpty) return action;
  } catch (_) {
    // ignore — emotion may not have dailyAction
  }
  return '';
}

// =============================================================================
// Nafs-state-based curated dhikr (public, testable)
// =============================================================================

/// Curated dhikr per dominant Nafs station. Each was chosen to *move* the
/// user toward the next station on the Nafs journey:
///
/// - Ammarah   → Astaghfirullah (turning back to Allah)
/// - Lawwamah  → Dua of Yunus (seeking peace in self-criticism)
/// - Mulhamah  → Alhamdulillah (gratitude, the gateway to inspiration)
/// - Mutmainnah → SubhanAllahi wa bihamdihi (tranquil remembrance)
DhikrItem nafsStateDhikr(NafsType nafs) {
  switch (nafs) {
    case NafsType.ammarah:
      return const DhikrItem(
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Ammarah (turning back)',
        target: NafsConstants.defaultDhikrTarget,
      );
    case NafsType.lawwamah:
      return const DhikrItem(
        arabic: 'لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        transliteration: "La ilaha illa Anta, Subhanaka, inni kuntu min adh-dhalimin",
        meaning: 'There is no deity except You; glory be to You; I was among the wrongdoers',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Lawwamah (Dua of Yunus)',
        target: NafsConstants.defaultDhikrTarget,
      );
    case NafsType.mulhamah:
      return const DhikrItem(
        arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: 'Alhamdulillah rabbil alameen',
        meaning: 'All praise is for Allah, Lord of all worlds',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Mulhamah (gratitude)',
        target: NafsConstants.defaultDhikrTarget,
      );
    case NafsType.mutmainnah:
      return const DhikrItem(
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        transliteration: 'SubhanAllahi wa bihamdihi',
        meaning: 'Glory be to Allah and praise be to Him',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Mutmainnah (tranquility)',
        target: NafsConstants.defaultDhikrTarget,
      );
  }
}
