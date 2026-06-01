// React Query hooks - Data fetching layer
// Separates server state from UI state (no duplication)

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { repositories } from '../repositories';
import { useAppStore } from '../../infrastructure/store';
import type { DateFilter, TraitType, EmotionEntry, JournalEntry, NafsAttributeCategory } from '../../domain/entities';

// ─── Cache Keys ───────────────────────────────────────────────────────────────

export const QUERY_KEYS = {
    nafsState: ['nafs', 'state'],
    emotions: (filter?: DateFilter) => ['emotions', filter],
    emotionInsights: ['emotions', 'insights'],
    traits: ['traits'],
    traitById: (id: string) => ['traits', id],
    traitTools: (id: string) => ['traits', id, 'tools'],
    dailyContent: ['content', 'daily'],
    journalEntries: (filter?: DateFilter) => ['journal', filter],
    progress: ['progress'],
    badges: ['badges'],
    nafsAttributes: ['nafs', 'attributes'] as const,
    nafsAttributesByCategory: (category: NafsAttributeCategory) => ['nafs', 'attributes', category] as const,
    nafsAttributeByName: (name: string) => ['nafs', 'attribute', name] as const,
} as const;

// ─── Nafs Hooks ───────────────────────────────────────────────────────────────

export function useNafsStateQuery() {
    return useQuery({
        queryKey: QUERY_KEYS.nafsState,
        queryFn: () => repositories.nafs.getCurrentNafsState(),
        staleTime: 5 * 60 * 1000, // 5 minutes
    });
}

// ─── Emotion Hooks ────────────────────────────────────────────────────────────

export function useEmotionHistory(filter?: DateFilter) {
    return useQuery({
        queryKey: QUERY_KEYS.emotions(filter),
        queryFn: () => repositories.emotion.getEmotionHistory(filter),
        staleTime: 2 * 60 * 1000,
    });
}

export function useLogEmotion() {
    const qc = useQueryClient();
    const addEmotion = useAppStore((s) => s.addEmotion);

    return useMutation({
        mutationFn: repositories.emotion.logEmotion.bind(repositories.emotion),
        onSuccess: (data) => {
            addEmotion(data as EmotionEntry);
            qc.invalidateQueries({ queryKey: ['emotions'] });
        },
    });
}

// ─── Trait Hooks ──────────────────────────────────────────────────────────────

export function useTraits() {
    return useQuery({
        queryKey: QUERY_KEYS.traits,
        queryFn: () => repositories.rectification.getAllTraits(),
        staleTime: Infinity, // Static data — never refetch
    });
}

export function useTraitTools(traitId: TraitType) {
    return useQuery({
        queryKey: QUERY_KEYS.traitTools(traitId),
        queryFn: () => repositories.rectification.getToolsForTrait(traitId),
        staleTime: Infinity,
    });
}

// ─── Journal Hooks ────────────────────────────────────────────────────────────

export function useJournalEntries(filter?: DateFilter) {
    return useQuery({
        queryKey: QUERY_KEYS.journalEntries(filter),
        queryFn: () => repositories.journal.getEntries(filter),
        staleTime: 2 * 60 * 1000,
    });
}

export function useSaveJournalEntry() {
    const qc = useQueryClient();
    const setTodayJournal = useAppStore((s) => s.setTodayJournal);

    return useMutation({
        mutationFn: repositories.journal.saveEntry.bind(repositories.journal),
        onSuccess: (data) => {
            setTodayJournal(data as JournalEntry);
            qc.invalidateQueries({ queryKey: ['journal'] });
        },
    });
}

// ─── Progress Hooks ───────────────────────────────────────────────────────────

export function useProgress() {
    return useQuery({
        queryKey: QUERY_KEYS.progress,
        queryFn: () => repositories.progress.getProgress(),
        staleTime: 60 * 1000, // 1 minute
    });
}

export function useAllBadges() {
    return useQuery({
        queryKey: QUERY_KEYS.badges,
        queryFn: () => repositories.progress.getAllBadges(),
        staleTime: Infinity,
    });
}

// ─── NafsAttribute Hooks (Supabase) ───────────────────────────────────────────

/** All 200 traits from Supabase */
export function useNafsAttributes() {
    return useQuery({
        queryKey: QUERY_KEYS.nafsAttributes,
        queryFn: () => repositories.nafsAttribute.getAll(),
        staleTime: Infinity,
    });
}

/** 100 negative or 100 positive traits */
export function useNafsAttributesByCategory(category: NafsAttributeCategory) {
    return useQuery({
        queryKey: QUERY_KEYS.nafsAttributesByCategory(category),
        queryFn: () => repositories.nafsAttribute.getByCategory(category),
        staleTime: Infinity,
    });
}

/** Single trait by exact name, e.g. 'Ghadab (Anger)' */
export function useNafsAttributeByName(name: string) {
    return useQuery({
        queryKey: QUERY_KEYS.nafsAttributeByName(name),
        queryFn: () => repositories.nafsAttribute.getByName(name),
        staleTime: Infinity,
        enabled: !!name,
    });
}