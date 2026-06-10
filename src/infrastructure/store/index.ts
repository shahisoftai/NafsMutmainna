// Zustand Store - Following Dependency Inversion Principle
// The store depends on repository interfaces, not implementations

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type {
    NafsState,
    EmotionEntry,
    UserProgress,
    JournalEntry,
    TraitType,
    ChatMessage,
    NafsType,
} from '../../domain/entities';

interface AppState {
    // User State
    anonymousId: string | null;
    isOnboarded: boolean;
    lastSyncedAt: string | null;

    // Nafs State
    nafsState: NafsState | null;

    // Progress
    progress: UserProgress | null;

    // Recent Data (for quick access)
    recentEmotions: EmotionEntry[];
    todayJournal: JournalEntry | null;
    activeTraits: TraitType[];

    // Chat
    chatHistory: ChatMessage[];

    // Actions - User
    setAnonymousId: (id: string) => void;
    setOnboarded: (value: boolean) => void;
    setLastSyncedAt: (iso: string) => void;

    // Actions - Nafs
    setNafsState: (state: NafsState) => void;
    updateNafsFromCheckin: (mood: 1 | 2 | 3 | 4 | 5) => void;

    // Actions - Emotions
    addEmotion: (emotion: EmotionEntry) => void;
    clearRecentEmotions: () => void;

    // Actions - Journal
    setTodayJournal: (entry: JournalEntry) => void;
    updateTodayJournal: (updates: Partial<JournalEntry>) => void;

    // Actions - Progress
    setProgress: (progress: UserProgress) => void;
    updateProgress: (updates: Partial<UserProgress>) => void;
    addOdex: (points: number) => void;
    updateStreak: () => void;

    // Actions - Traits
    setActiveTraits: (traits: TraitType[]) => void;

    // Actions - Chat
    addChatMessage: (message: ChatMessage) => void;
    clearChatHistory: () => void;

    // Computed (selectors)
    getCurrentStreak: () => number;
    isNewUser: () => boolean;
    getDominantNafsType: () => NafsType;
}

export const useAppStore = create<AppState>()(
    persist(
        (set, get) => ({
            // Initial State
            anonymousId: null,
            isOnboarded: false,
            lastSyncedAt: null,
            nafsState: null,
            progress: null,
            recentEmotions: [],
            todayJournal: null,
            activeTraits: ['anger', 'envy', 'anxiety'],
            chatHistory: [],

            // User Actions
            setAnonymousId: (id) => set({ anonymousId: id }),
            setOnboarded: (value) => set({ isOnboarded: value }),
            setLastSyncedAt: (iso) => set({ lastSyncedAt: iso }),

            // Nafs Actions
            setNafsState: (state) => set({ nafsState: state }),
            updateNafsFromCheckin: (mood) =>
                set((s) => {
                    if (!s.nafsState) return s;
                    const moodImpact = (mood - 3) * 5; // -10 to +10
                    const newScore = Math.max(0, Math.min(100, s.nafsState.score + moodImpact));
                    return {
                        nafsState: { ...s.nafsState, score: newScore, lastUpdated: new Date() },
                    };
                }),

            // Emotion Actions
            addEmotion: (emotion) =>
                set((s) => ({
                    recentEmotions: [emotion, ...s.recentEmotions].slice(0, 50),
                })),
            clearRecentEmotions: () => set({ recentEmotions: [] }),

            // Journal Actions
            setTodayJournal: (entry) => set({ todayJournal: entry }),
            updateTodayJournal: (updates) =>
                set((s) => ({
                    todayJournal: s.todayJournal
                        ? { ...s.todayJournal, ...updates, updatedAt: new Date() }
                        : null,
                })),

            // Progress Actions
            setProgress: (progress) => set({ progress }),
            updateProgress: (updates) =>
                set((s) => ({
                    progress: s.progress ? { ...s.progress, ...updates } : null,
                })),
            addOdex: (points) =>
                set((s) => ({
                    progress: s.progress
                        ? { ...s.progress, odex: s.progress.odex + points }
                        : null,
                })),
            updateStreak: () =>
                set((s) => {
                    if (!s.progress) return s;
                    const today = new Date().toISOString().split('T')[0];
                    const lastActive = s.progress.lastActiveDate;
                    const yesterday = new Date(Date.now() - 86400000)
                        .toISOString()
                        .split('T')[0];

                    let newStreak = s.progress.streak;
                    if (lastActive === today) return s;
                    newStreak = lastActive === yesterday ? s.progress.streak + 1 : 1;

                    return {
                        progress: {
                            ...s.progress,
                            streak: newStreak,
                            longestStreak: Math.max(s.progress.longestStreak, newStreak),
                            lastActiveDate: today,
                        },
                    };
                }),

            // Trait Actions
            setActiveTraits: (traits) => set({ activeTraits: traits }),

            // Chat Actions
            addChatMessage: (message) =>
                set((s) => ({
                    chatHistory: [...s.chatHistory, message].slice(-100),
                })),
            clearChatHistory: () => set({ chatHistory: [] }),

            // Computed Selectors
            getCurrentStreak: () => get().progress?.streak ?? 0,
            isNewUser: () => !get().isOnboarded,
            getDominantNafsType: () => get().nafsState?.type ?? 'ammarah',
        }),
        {
            name: 'nafs-storage',
            storage: createJSONStorage(() => AsyncStorage),
            partialize: (state) => ({
                anonymousId: state.anonymousId,
                isOnboarded: state.isOnboarded,
                nafsState: state.nafsState,
                progress: state.progress,
                activeTraits: state.activeTraits,
                lastSyncedAt: state.lastSyncedAt,
            }),
        }
    )
);

// Selector hooks for optimized re-renders
export const useNafsState = () => useAppStore((s) => s.nafsState);
export const useProgress = () => useAppStore((s) => s.progress);
export const useRecentEmotions = () => useAppStore((s) => s.recentEmotions);
export const useIsOnboarded = () => useAppStore((s) => s.isOnboarded);
export const useChatHistory = () => useAppStore((s) => s.chatHistory);
export const useActiveTraits = () => useAppStore((s) => s.activeTraits);
export const useLastSyncedAt = () => useAppStore((s) => s.lastSyncedAt);