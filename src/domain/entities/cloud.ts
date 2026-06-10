// Cloud-synced entities — mirror Supabase tables
// Local-only entities (with UUID) live in src/domain/entities/index.ts

import type { NafsType } from './index';

export interface DailyCheckin {
    id: string;
    userId: string;
    checkinDate: string; // YYYY-MM-DD
    mood: 1 | 2 | 3 | 4 | 5;
    nafsStage: NafsType;
    notes: string | null;
    createdAt: string;
    updatedAt: string;
}

export interface CloudEmotionEntry {
    id: string;
    userId: string;
    emotion: string;
    intensity: 1 | 2 | 3 | 4 | 5;
    trigger: string | null;
    mappedTrait: string | null;
    oppositeTrait: string | null;
    notes: string | null;
    loggedAt: string;
    lastSyncedAt: string | null;
}

export interface CloudJournalEntry {
    id: string;
    userId: string;
    entryDate: string;
    nafsWin: string;
    mutmainnaMoment: string;
    gratitude: string[];
    moodRating: 1 | 2 | 3 | 4 | 5;
    createdAt: string;
    updatedAt: string;
    lastSyncedAt: string | null;
}

export type SyncOp = 'insert' | 'update' | 'delete';

export interface SyncJob {
    id: string;
    table: 'daily_checkins' | 'emotion_logs' | 'journal_entries';
    op: SyncOp;
    payload: Record<string, unknown>;
    localId: string;
    createdAt: string;
    attempts: number;
    lastError: string | null;
}

export type SyncStatus = 'idle' | 'syncing' | 'error' | 'offline';
