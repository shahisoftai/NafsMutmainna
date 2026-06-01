// Repository Interfaces - Interface Segregation Principle
// Each repository has a focused, specific interface

import type {
    NafsState,
    AssessmentAnswer,
    AssessmentResult,
    EmotionEntry,
    EmotionInsights,
    Trait,
    TraitType,
    RectificationTool,
    JournalEntry,
    JournalPrompt,
    UserProgress,
    Badge,
    DailyContent,
    AIChatContext,
    AIResponse,
    DateFilter,
    ChatMessage,
    NafsAttribute,
    NafsAttributeCategory,
} from '../entities';

export interface INafsAttributeRepository {
    /** Fetch all 200 nafs attributes from Supabase */
    getAll(): Promise<NafsAttribute[]>;
    /** Fetch only negative (100) or positive (100) traits */
    getByCategory(category: NafsAttributeCategory): Promise<NafsAttribute[]>;
    /** Fetch a single trait by its exact name */
    getByName(name: string): Promise<NafsAttribute | null>;
    /** Fetch the positive counterpart of a negative trait by name */
    getOpposite(oppositeName: string): Promise<NafsAttribute | null>;
}

export interface INafsRepository {
    /**
     * Submit initial assessment and get Nafs state
     */
    assessNafsState(answers: AssessmentAnswer[]): Promise<AssessmentResult>;

    /**
     * Get current user's Nafs state
     */
    getCurrentNafsState(): Promise<NafsState | null>;

    /**
     * Perform quick daily Nafs check-in
     */
    performDailyCheckin(mood: 1 | 2 | 3 | 4 | 5): Promise<NafsState>;
}

export interface IEmotionRepository {
    /**
     * Log a new emotion entry
     */
    logEmotion(entry: Omit<EmotionEntry, 'id'>): Promise<EmotionEntry>;

    /**
     * Get emotion history with optional filters
     */
    getEmotionHistory(filter?: DateFilter): Promise<EmotionEntry[]>;

    /**
     * Get insights based on emotion patterns
     */
    getEmotionInsights(): Promise<EmotionInsights>;

    /**
     * Delete an emotion entry
     */
    deleteEmotion(id: string): Promise<void>;
}

export interface IRectificationRepository {
    /**
     * Get all available traits
     */
    getAllTraits(): Promise<Trait[]>;

    /**
     * Get specific trait by ID
     */
    getTraitById(traitId: TraitType): Promise<Trait | null>;

    /**
     * Get rectification tools for a specific trait
     */
    getToolsForTrait(traitId: TraitType): Promise<RectificationTool[]>;

    /**
     * Get immediate tools (breathing, dhikr) for a trait
     */
    getImmediateTools(traitId: TraitType): Promise<RectificationTool[]>;

    /**
     * Get short-term actions (dua, reflection) for a trait
     */
    getShortTermActions(traitId: TraitType): Promise<RectificationTool[]>;

    /**
     * Get long-term habits for a trait
     */
    getLongTermHabits(traitId: TraitType): Promise<RectificationTool[]>;
}

export interface IContentRepository {
    /**
     * Get daily Quran verse and Hadith
     */
    getDailyContent(): Promise<DailyContent>;

    /**
     * Get educational content for a Nafs stage
     */
    getEducationalContent(nafsStage: string): Promise<DailyContent['hadees'][]>;

    /**
     * Get all educational content for a specific stage
     */
    getStageContent(stage: 'ammarah' | 'lawwamah' | 'mutmainna'): Promise<import('../entities').EducationalContent[]>;
}

export interface IJournalRepository {
    /**
     * Save a journal entry
     */
    saveEntry(entry: Omit<JournalEntry, 'id' | 'createdAt' | 'updatedAt'>): Promise<JournalEntry>;

    /**
     * Get journal entries with optional filters
     */
    getEntries(filter?: DateFilter): Promise<JournalEntry[]>;

    /**
     * Get today's journal prompt
     */
    getTodayPrompt(): Promise<JournalPrompt>;

    /**
     * Get a specific journal entry by date
     */
    getEntryByDate(date: string): Promise<JournalEntry | null>;

    /**
     * Update an existing journal entry
     */
    updateEntry(id: string, updates: Partial<JournalEntry>): Promise<JournalEntry>;

    /**
     * Delete a journal entry
     */
    deleteEntry(id: string): Promise<void>;
}

export interface IProgressRepository {
    /**
     * Get user's current progress
     */
    getProgress(): Promise<UserProgress>;

    /**
     * Update progress with new data
     */
    updateProgress(updates: Partial<UserProgress>): Promise<UserProgress>;

    /**
     * Award a badge to the user
     */
    awardBadge(badgeId: string): Promise<Badge>;

    /**
     * Get all available badges
     */
    getAllBadges(): Promise<Badge[]>;

    /**
     * Get earned badges
     */
    getEarnedBadges(): Promise<Badge[]>;

    /**
     * Update streak
     */
    updateStreak(): Promise<{ streak: number; isNewRecord: boolean }>;

    /**
     * Add ODEX points
     */
    addOdex(points: number): Promise<number>;

    /**
     * Get leaderboard (future feature)
     */
    // getLeaderboard(): Promise<LeaderboardEntry[]>;
}

export interface IAIRepository {
    /**
     * Send a chat message to the AI coach
     */
    chat(
        message: string,
        context: AIChatContext
    ): Promise<AIResponse>;

    /**
     * Get reflection questions based on emotion
     */
    getReflectionQuestions(emotion: string): Promise<string[]>;

    /**
     * Get follow-up questions based on conversation
     */
    getFollowUpQuestions(
        conversationHistory: ChatMessage[],
        currentTopic: string
    ): Promise<string[]>;

    /**
     * Generate a personalized spiritual action plan
     */
    generateActionPlan(
        traits: TraitType[],
        duration: string
    ): Promise<RectificationTool[]>;
}

export interface IStorageRepository {
    /**
     * Get anonymous user ID
     */
    getAnonymousId(): Promise<string | null>;

    /**
     * Create anonymous user
     */
    createAnonymousUser(): Promise<string>;

    /**
     * Store data locally
     */
    set<T>(key: string, value: T): Promise<void>;

    /**
     * Get data from local storage
     */
    get<T>(key: string): Promise<T | null>;

    /**
     * Remove data from local storage
     */
    remove(key: string): Promise<void>;

    /**
     * Clear all local data
     */
    clear(): Promise<void>;
}