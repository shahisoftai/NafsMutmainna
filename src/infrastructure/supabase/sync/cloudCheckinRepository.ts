// CloudCheckinRepository — Supabase daily_checkins (mood + stage + notes)
// SRP: only check-in I/O

import { v4 as uuidv4 } from 'uuid';
import { supabase } from '../client';
import { enqueue } from './queue';
import type { DailyCheckin } from '../../../domain/entities/cloud';
import type { NafsType } from '../../../domain/entities';

const toCheckin = (row: any): DailyCheckin => ({
    id: row.id,
    userId: row.user_id,
    checkinDate: row.checkin_date,
    mood: row.mood,
    nafsStage: row.nafs_stage as NafsType,
    notes: row.notes ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
});

export class CloudCheckinRepository {
    private userId: string | null = null;

    setUserId(userId: string | null): void {
        this.userId = userId;
    }

    async submitCheckin(input: {
        mood: 1 | 2 | 3 | 4 | 5;
        nafsStage: NafsType;
        notes: string;
    }): Promise<DailyCheckin> {
        const id = uuidv4();
        const now = new Date().toISOString();
        const today = now.split('T')[0];
        const local: DailyCheckin = {
            id,
            userId: this.userId ?? 'local',
            checkinDate: today,
            mood: input.mood,
            nafsStage: input.nafsStage,
            notes: input.notes || null,
            createdAt: now,
            updatedAt: now,
        };

        if (!this.userId) return local;

        const payload = {
            id,
            user_id: this.userId,
            checkin_date: today,
            mood: input.mood,
            nafs_stage: input.nafsStage,
            notes: input.notes || null,
            created_at: now,
            updated_at: now,
        };
        try {
            // Upsert so multiple check-ins per day collapse to the latest
            const { error } = await supabase
                .from('daily_checkins')
                .upsert(payload, { onConflict: 'user_id,checkin_date' });
            if (error) throw new Error(error.message);
        } catch {
            await enqueue('daily_checkins', 'insert', payload, id);
        }
        return local;
    }

    async getRecent(days = 7): Promise<DailyCheckin[]> {
        if (!this.userId) return [];
        const since = new Date(Date.now() - days * 86400000).toISOString().split('T')[0];
        const { data, error } = await supabase
            .from('daily_checkins')
            .select('*')
            .eq('user_id', this.userId)
            .gte('checkin_date', since)
            .order('checkin_date', { ascending: false });
        if (error) {
            console.warn('[checkinRepo] getRecent:', error.message);
            return [];
        }
        return (data ?? []).map(toCheckin);
    }

    async getStreak(): Promise<{ current: number; longest: number }> {
        if (!this.userId) return { current: 0, longest: 0 };
        const { data, error } = await supabase
            .from('daily_checkins')
            .select('checkin_date')
            .eq('user_id', this.userId)
            .order('checkin_date', { ascending: false })
            .limit(365);
        if (error || !data) return { current: 0, longest: 0 };

        const dates = data.map((d) => d.checkin_date as string);
        if (dates.length === 0) return { current: 0, longest: 0 };

        // Current streak — consecutive days ending today or yesterday
        const today = new Date().toISOString().split('T')[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
        const dateSet = new Set(dates);
        let current = 0;
        let cursor = dateSet.has(today) ? today : dateSet.has(yesterday) ? yesterday : null;
        while (cursor && dateSet.has(cursor)) {
            current++;
            const prev = new Date(cursor);
            prev.setDate(prev.getDate() - 1);
            cursor = prev.toISOString().split('T')[0];
        }

        // Longest streak — scan all dates
        const sorted = [...dateSet].sort();
        let longest = 1;
        let run = 1;
        for (let i = 1; i < sorted.length; i++) {
            const a = new Date(sorted[i - 1]);
            const b = new Date(sorted[i]);
            const diff = Math.round((b.getTime() - a.getTime()) / 86400000);
            if (diff === 1) {
                run++;
                longest = Math.max(longest, run);
            } else {
                run = 1;
            }
        }

        return { current, longest };
    }
}
