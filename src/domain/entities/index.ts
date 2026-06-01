// Domain Entities - Core business objects following Single Responsibility Principle

export type NafsType = 'ammarah' | 'lawwamah' | 'mutmainna';

export interface NafsState {
    id: string;
    type: NafsType;
    score: number;
    percentage: {
        ammarah: number;
        lawwamah: number;
        mutmainna: number;
    };
    dominantTraits: string[];
    areasForImprovement: string[];
    lastUpdated: Date;
}

export interface AssessmentAnswer {
    questionId: string;
    answer: number; // 1-5 scale
}

export interface AssessmentResult {
    nafsState: NafsState;
    completedAt: Date;
    recommendations: string[];
}

export interface EmotionEntry {
    id: string;
    emotion: string;
    intensity: 1 | 2 | 3 | 4 | 5;
    trigger: string;
    mappedTrait: string;
    oppositeTrait: string; // The Mutmainna trait to develop
    timestamp: Date;
    notes?: string;
}

export interface EmotionInsights {
    mostFrequentEmotion: string;
    highestIntensityEmotion: string;
    commonTriggers: string[];
    progressTrend: 'improving' | 'stable' | 'declining';
}

// ─── NafsAttribute ───────────────────────────────────────────────────────────
// Mirrors the nafs_attributes table in Supabase

export interface NafsAttribute {
    id: string;
    name: string;
    category: 'negative' | 'positive';
    description: string;
    opposite_to: string;
    quran_ref: string[];
    hadith_ref: string[];
}

export type NafsAttributeCategory = 'negative' | 'positive';

export type TraitType = 'anger' | 'envy' | 'anxiety' | 'greed' | 'pride' | 'ostentation' | 'ignorance' | 'despair';

export interface Trait {
    id: TraitType;
    name: string;
    nameUr: string;
    description: string;
    oppositeTrait: string;
    severity: 'low' | 'medium' | 'high';
}

export interface RectificationTool {
    id: string;
    traitId: TraitType;
    type: 'immediate' | 'shortTerm' | 'longTerm';
    title: string;
    titleUr: string;
    description: string;
    dhikr?: string;
    dhikrCount?: number;
    dua?: string;
    quranVerse?: QuranVerse;
    hadees?: Hadith;
    action?: string;
    duration?: string; // e.g., "7 days", "40 days"
    evidenceBased: boolean; // Whether content is verified by Ulema
}

export interface QuranVerse {
    surah: string;
    verseNumber: number;
    arabic: string;
    translation: string;
    transliteration?: string;
    source: 'ibn_kathir' | 'khatib' | 'uthmani';
}

export interface Hadith {
    id: string;
    arabic?: string;
    text: string;
    translation: string;
    narrator: string;
    book: 'bukhari' | 'muslim' | 'tirmidhi' | 'abu_dawud' | 'nasai' | 'ibn_majah';
    grade: 'sahih' | 'hasan' | 'daif';
    source: string; // e.g., "Dr. Israr Ahmed", "Molana Maududi"
}

export interface JournalEntry {
    id: string;
    date: string; // YYYY-MM-DD
    nafsWin: string;
    mutmainnaMoment: string;
    gratitude: string[];
    moodRating: 1 | 2 | 3 | 4 | 5;
    createdAt: Date;
    updatedAt: Date;
}

export interface JournalPrompt {
    date: string;
    questions: {
        nafsWin: string;
        mutmainnaMoment: string;
        gratitude: string;
    };
}

export interface Badge {
    id: string;
    name: string;
    nameUr: string;
    description: string;
    icon: string;
    earnedAt?: Date;
    criteria: {
        type: 'streak' | 'emotions_logged' | 'journal_entries' | 'adhkar_completed' | 'special';
        value: number;
    };
}

export interface UserProgress {
    odex: number;
    streak: number;
    longestStreak: number;
    totalEmotionsLogged: number;
    totalJournalEntries: number;
    badges: Badge[];
    weeklyData: WeeklyMetric[];
    lastActiveDate: string;
}

export interface WeeklyMetric {
    week: string; // YYYY-WW
    moodAverage: number;
    emotionsLogged: number;
    journalEntries: number;
    odexEarned: number;
}

export interface EducationalContent {
    id: string;
    nafsStage: NafsType;
    title: string;
    titleUr: string;
    content: string;
    contentUr: string;
    source: string;
    category: 'explanation' | 'story' | 'practical_guide' | 'video';
    videoUrl?: string;
}

export interface AIChatContext {
    nafsState: NafsState;
    recentEmotions: EmotionEntry[];
    activeTraits: TraitType[];
    currentStreak: number;
    conversationHistory: ChatMessage[];
}

export interface ChatMessage {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    timestamp: Date;
}

export interface AIResponse {
    message: string;
    suggestions?: string[];
    relatedDuas?: string[];
    relatedVerse?: QuranVerse;
}

export interface DailyContent {
    date: string;
    verse: QuranVerse;
    hadees: Hadith;
    reflectionPrompt: string;
}

export interface DateFilter {
    startDate?: Date;
    endDate?: Date;
    limit?: number;
}