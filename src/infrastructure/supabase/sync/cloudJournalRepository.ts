// CloudJournalRepository — Supabase-backed with offline fallback
// SRP: journal I/O only

import { v4 as uuidv4 } from 'uuid';
import { supabase } from '../client';
import { enqueue } from './queue';
import type { CloudJournalEntry } from '../../../domain/entities/cloud';
import type { JournalEntry, JournalPrompt, DateFilter } from '../../../domain/entities';
import { JOURNAL_PROMPTS } from '../../../shared/constants';
import type { IJournalRepository } from '../../../domain/repositories';

const toCloud = (row: any): CloudJournalEntry => ({
    id: row.id,
    userId: row.user_id,
    entryDate: row.entry_date,
    nafsWin: row.nafs_win ?? '',
    mutmainnaMoment: row.mutmainna_moment ?? '',
    gratitude: row.gratitude ?? [],
    moodRating: row.mood_rating,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    lastSyncedAt: row.last_synced_at ?? null,
});

const toLocal = (row: CloudJournalEntry): JournalEntry => ({
    id: row.id,
    date: row.entryDate,
    nafsWin: row.nafsWin,
    mutmainnaMoment: row.mutmainnaMoment,
    gratitude: row.gratitude,
    moodRating: row.moodRating,
    createdAt: new Date(row.createdAt),
    updatedAt: new Date(row.updatedAt),
});

export class CloudJournalRepository implements IJournalRepository {
    private userId: string | null = null;

    setUserId(userId: string | null): void {
        this.userId = userId;
    }

    async saveEntry(entry: Omit<JournalEntry, 'id' | 'createdAt' | 'updatedAt'>): Promise<JournalEntry> {
        const now = new Date().toISOString();
        const id = uuidv4();
        const local: JournalEntry = {
            id,
            ...entry,
            createdAt: new Date(now),
            updatedAt: new Date(now),
        };
        if (!this.userId) return local;

        const payload = {
            id,
            user_id: this.userId,
            entry_date: entry.date,
            nafs_win: entry.nafsWin,
            mutmainna_moment: entry.mutmainnaMoment,
            gratitude: entry.gratitude,
            mood_rating: entry.moodRating,
            created_at: now,
            updated_at: now,
            last_synced_at: now,
        };
        try {
            const { error } = await supabase.from('journal_entries').insert(payload);
            if (error) throw new Error(error.message);
        } catch {
            await enqueue('journal_entries', 'insert', payload, id);
        }
        return local;
    }

    async getEntries(filter?: DateFilter): Promise<JournalEntry[]> {
        if (!this.userId) return [];
        let q = supabase
            .from('journal_entries')
            .select('*')
            .eq('user_id', this.userId)
            .order('entry_date', { ascending: false });
        if (filter?.startDate) q = q.gte('entry_date', filter.startDate.toISOString().split('T')[0]);
        if (filter?.endDate) q = q.lte('entry_date', filter.endDate.toISOString().split('T')[0]);
        if (filter?.limit) q = q.limit(filter.limit);
        const { data, error } = await q;
        if (error) {
            console.warn('[journalRepo] getEntries:', error.message);
            return [];
        }
        return (data ?? []).map(toCloud).map(toLocal);
    }

    getTodayPrompt(): Promise<JournalPrompt> {
        return Promise.resolve({
            date: new Date().toISOString().split('T')[0],
            questions: {
                nafsWin: JOURNAL_PROMPTS.nafsWin,
                mutmainnaMoment: JOURNAL_PROMPTS.mutmainnaMoment,
                gratitude: JOURNAL_PROMPTS.gratitude,
            },
        });
    }

    async getEntryByDate(date: string): Promise<JournalEntry | null> {
        if (!this.userId) return null;
        const { data, error } = await supabase
            .from('journal_entries')
            .select('*')
            .eq('user_id', this.userId)
            .eq('entry_date', date)
            .maybeSingle();
        if (error || !data) return null;
        return toLocal(toCloud(data));
    }

    async updateEntry(id: string, updates: Partial<JournalEntry>): Promise<JournalEntry> {
        const now = new Date().toISOString();
        const payload: Record<string, unknown> = { updated_at: now, last_synced_at: now };
        if (updates.date) payload.entry_date = updates.date;
        if (updates.nafsWin !== undefined) payload.nafs_win = updates.nafsWin;
        if (updates.mutmainnaMoment !== undefined) payload.mutmainna_moment = updates.mutmainnaMoment;
        if (updates.gratitude) payload.gratitude = updates.gratitude;
        if (updates.moodRating) payload.mood_rating = updates.moodRating;

        if (this.userId) {
            const { error } = await supabase.from('journal_entries').update(payload).eq('id', id);
            if (error) {
                await enqueue('journal_entries', 'update', { id, ...payload }, id);
            }
        }
        return {
            id,
            date: updates.date ?? '',
            nafsWin: updates.nafsWin ?? '',
            mutmainnaMoment: updates.mutmainnaMoment ?? '',
            gratitude: updates.gratitude ?? [],
            moodRating: updates.moodRating ?? 3,
            createdAt: updates.createdAt ?? new Date(),
            updatedAt: new Date(now),
        };
    }

    async deleteEntry(id: string): Promise<void> {
        if (!this.userId) return;
        const { error } = await supabase.from('journal_entries').delete().eq('id', id);
        if (error) await enqueue('journal_entries', 'delete', { id }, id);
    }
}
