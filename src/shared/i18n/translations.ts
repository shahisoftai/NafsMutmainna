// Translations for nafs attribute names (Arabic + Urdu)
// Maps exact `name` (as stored in Supabase `nafs_attributes` table) → localized versions.
//
// Coverage:
//   - The 8 well-known traits (already in `TRAITS` constant) have full trilingual support.
//   - Other 192 attributes from `nafs_attributes` table should have their Arabic name stored
//     in the `name_arabic` column on Supabase. This map supplements Urdu translations for
//     the most-common 20 attributes; the rest fall back to the English `name`.
//
// When the `nafs_attributes` table gains a `name_ur` column, migrate this file into a DB table.

export interface NafsNameTranslations {
    arabic: string | null;
    urdu: string | null;
}

export const NAFS_NAME_TRANSLATIONS: Record<string, NafsNameTranslations> = {
    // The 8 primary traits
    'Ghadab (Anger)': { arabic: 'الغضب', urdu: 'غصہ' },
    'Hasad (Envy)': { arabic: 'الحسد', urdu: 'حسد' },
    'Jaza (Chronic Anxiety)': { arabic: 'الجزع', urdu: 'پریشانی' },
    'Tama (Covetousness)': { arabic: 'الطمع', urdu: 'لالچ' },
    'Kibr (Arrogance)': { arabic: 'الكبر', urdu: 'تکبر' },
    'Riya (Ostentation)': { arabic: 'الرياء', urdu: 'ریا' },
    'Jahl (Ignorance)': { arabic: 'الجهل', urdu: 'جہل' },
    'Yaqs (Despair)': { arabic: 'اليأس', urdu: 'مایوسی' },

    // Common secondary attributes
    'Huzn al-Mamduh (Paralyzing Despair)': { arabic: 'الحزن المذموم', urdu: 'مذموم غم' },
    'Malal (Spiritual Boredom)': { arabic: 'الملل', urdu: 'روحانی بیزاری' },
    'Khawf (Excessive Fear)': { arabic: 'الخوف المفرط', urdu: 'بہت زیادہ خوف' },
    'Ujb (Self-Admiration)': { arabic: 'العُجب', urdu: 'خود پسندی' },
    'Takabbur (Haughtiness)': { arabic: 'التكبر', urdu: 'گھمنڈ' },
    'Nifaq (Hypocrisy)': { arabic: 'النفاق', urdu: 'منافقانہ' },
    'Ghibah (Backbiting)': { arabic: 'الغيبة', urdu: 'غیبت' },
    'Namimah (Tale-Carrying)': { arabic: 'النميمة', urdu: 'چغل خوری' },
    'Bughd (Hate/Enmity)': { arabic: 'البغضاء', urdu: 'دشمنی' },
    'Zulm (Oppression)': { arabic: 'الظلم', urdu: 'ظلم' },
    'Ifsad (Corruption)': { arabic: 'الإفساد', urdu: 'فحاشی' },
    'Ghurur (Delusion)': { arabic: 'الغرور', urdu: 'دھوکا' },
    'Wahm (Baseless Suspicions)': { arabic: 'الوهم', urdu: 'وہم' },
};

/** Look up Arabic for a trait name; returns the English name as fallback. */
export const getArabic = (name: string): string =>
    NAFS_NAME_TRANSLATIONS[name]?.arabic ?? name;

/** Look up Urdu for a trait name; returns the English name as fallback. */
export const getUrdu = (name: string): string =>
    NAFS_NAME_TRANSLATIONS[name]?.urdu ?? name;

/** Returns the localized display name for the active language. */
import type { Language } from '../../infrastructure/store/settingsStore';

export const getLocalizedName = (name: string, lang: Language): string => {
    if (lang === 'ar') return getArabic(name);
    if (lang === 'ur') return getUrdu(name);
    return name;
};
