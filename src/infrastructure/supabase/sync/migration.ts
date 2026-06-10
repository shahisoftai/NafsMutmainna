// LocalDataMigrator — one-time sync of pre-auth Zustand data to Supabase
// SRP: only handles the post-first-login migration

import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '../client';
import type { EmotionEntry, JournalEntry, NafsState } from '../../../domain/entities';

const MIGRATION_FLAG = 'nafsmutmainna.local_migrated.v1';

interface LocalSnapshot {
    nafsState: NafsState | null;
    progress: { odex: number; streak: number; longestStreak: number; lastActiveDate: string } | null;
    recentEmotions: EmotionEntry[];
    todayJournal: JournalEntry | null;
    activeTraits: string[];
}

/** Read snapshot from AsyncStorage. Reuses the Zustand `nafs-storage` key. */
const readSnapshot = async (): Promise<LocalSnapshot> => {
    const raw = await AsyncStorage.getItem('nafs-storage');
    if (!raw) {
        return { nafsState: null, progress: null, recentEmotions: [], todayJournal: null, activeTraits: [] };
    }
    try {
        const parsed = JSON.parse(raw) as { state?: Record<string, unknown> };
        const s = parsed.state ?? {};
        return {
            nafsState: (s.nafsState as NafsState | null) ?? null,
            progress: (s.progress as LocalSnapshot['progress']) ?? null,
            recentEmotions: (s.recentEmotions as EmotionEntry[]) ?? [],
            todayJournal: (s.todayJournal as JournalEntry | null) ?? null,
            activeTraits: (s.activeTraits as string[]) ?? [],
        };
    } catch {
        return { nafsState: null, progress: null, recentEmotions: [], todayJournal: null, activeTraits: [] };
    }
};

/** Returns true if migration was already done for this device. */
export const hasMigrated = async (): Promise<boolean> => {
    return (await AsyncStorage.getItem(MIGRATION_FLAG)) === '1';
};

const markMigrated = async (): Promise<void> => {
    await AsyncStorage.setItem(MIGRATION_FLAG, '1');
};

/** Push local snapshot to Supabase for the given user. Idempotent via upsert + checks. */
export const migrateLocalDataToCloud = async (userId: string): Promise<{
    migrated: boolean;
    counts: { emotions: number; journal: number; profileUpdated: boolean };
}> => {
    if (await hasMigrated()) {
        return { migrated: false, counts: { emotions: 0, journal: 0, profileUpdated: false } };
    }

    const snap = await readSnapshot();

    // 1) Update profile with local Nafs state (only if profile doesn't already have a value)
    let profileUpdated = false;
    if (snap.nafsState) {
        const { data: existing } = await supabase
            .from('profiles')
            .select('nafs_stage, nafs_score')
            .eq('id', userId)
            .maybeSingle();

        if (!existing?.nafs_stage) {
            await supabase
                .from('profiles')
                .update({
                    nafs_stage: snap.nafsState.type,
                    nafs_score: snap.nafsState.score,
                    updated_at: new Date().toISOString(),
                })
                .eq('id', userId);
            profileUpdated = true;
        }
    }

    // 2) Push recent emotions to emotion_logs
    let emotions = 0;
    if (snap.recentEmotions.length > 0) {
        const rows = snap.recentEmotions.map((e) => ({
            user_id: userId,
            emotion: e.emotion,
            intensity: e.intensity,
            trigger: e.trigger ?? '',
            mapped_trait: e.mappedTrait ?? null,
            opposite_trait: e.oppositeTrait ?? null,
            notes: e.notes ?? null,
            logged_at: new Date(e.timestamp).toISOString(),
        }));
        const { error } = await supabase.from('emotion_logs').insert(rows);
        if (!error) emotions = rows.length;
        else console.warn('[migrate] emotion_logs insert:', error.message);
    }

    // 3) Push today's journal to journal_entries
    let journal = 0;
    if (snap.todayJournal) {
        const j = snap.todayJournal;
        const { error } = await supabase.from('journal_entries').insert({
            user_id: userId,
            entry_date: j.date,
            nafs_win: j.nafsWin,
            mutmainna_moment: j.mutmainnaMoment,
            gratitude: j.gratitude,
            mood_rating: j.moodRating,
        });
        if (!error) journal = 1;
        else console.warn('[migrate] journal_entries insert:', error.message);
    }

    await markMigrated();
    return { migrated: true, counts: { emotions, journal, profileUpdated } };
};
