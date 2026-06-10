// CloudEmotionRepository — Supabase-backed, with offline fallback via sync queue
// SRP: only emotion I/O, depends only on the cloud client + sync queue

import { v4 as uuidv4 } from 'uuid';
import { supabase } from '../client';
import { enqueue, flushQueue } from './queue';
import type { CloudEmotionEntry } from '../../../domain/entities/cloud';
import type { EmotionEntry, EmotionInsights, DateFilter } from '../../../domain/entities';
import type { IEmotionRepository } from '../../../domain/repositories';

const toCloud = (row: any): CloudEmotionEntry => ({
    id: row.id,
    userId: row.user_id,
    emotion: row.emotion,
    intensity: row.intensity,
    trigger: row.trigger ?? null,
    mappedTrait: row.mapped_trait ?? null,
    oppositeTrait: row.opposite_trait ?? null,
    notes: row.notes ?? null,
    loggedAt: row.logged_at,
    lastSyncedAt: row.last_synced_at ?? null,
});

const toLocal = (row: CloudEmotionEntry): EmotionEntry => ({
    id: row.id,
    emotion: row.emotion,
    intensity: row.intensity,
    trigger: row.trigger ?? '',
    mappedTrait: row.mappedTrait ?? '',
    oppositeTrait: row.oppositeTrait ?? '',
    timestamp: new Date(row.loggedAt),
    notes: row.notes ?? undefined,
});

export class CloudEmotionRepository implements IEmotionRepository {
    private userId: string | null = null;

    setUserId(userId: string | null): void {
        this.userId = userId;
    }

    async logEmotion(entry: Omit<EmotionEntry, 'id'>): Promise<EmotionEntry> {
        const id = uuidv4();
        const localEntry: EmotionEntry = { id, ...entry };
        if (!this.userId) {
            // Offline / unauthenticated: caller uses local store only
            return localEntry;
        }
        const payload = {
            id,
            user_id: this.userId,
            emotion: entry.emotion,
            intensity: entry.intensity,
            trigger: entry.trigger ?? null,
            mapped_trait: entry.mappedTrait ?? null,
            opposite_trait: entry.oppositeTrait ?? null,
            notes: entry.notes ?? null,
            logged_at: entry.timestamp instanceof Date ? entry.timestamp.toISOString() : new Date(entry.timestamp).toISOString(),
            last_synced_at: new Date().toISOString(),
        };
        try {
            const { error } = await supabase.from('emotion_logs').insert(payload);
            if (error) throw new Error(error.message);
        } catch {
            // Queue for retry
            await enqueue('emotion_logs', 'insert', payload, id);
        }
        return localEntry;
    }

    async getEmotionHistory(filter?: DateFilter): Promise<EmotionEntry[]> {
        if (!this.userId) return [];
        let query = supabase
            .from('emotion_logs')
            .select('*')
            .eq('user_id', this.userId)
            .order('logged_at', { ascending: false });
        if (filter?.startDate) query = query.gte('logged_at', filter.startDate.toISOString());
        if (filter?.endDate) query = query.lte('logged_at', filter.endDate.toISOString());
        if (filter?.limit) query = query.limit(filter.limit);
        const { data, error } = await query;
        if (error) {
            console.warn('[emotionRepo] getEmotionHistory:', error.message);
            return [];
        }
        return (data ?? []).map(toCloud).map(toLocal);
    }

    async getEmotionInsights(): Promise<EmotionInsights> {
        const history = await this.getEmotionHistory({ limit: 100 });
        if (history.length === 0) {
            return {
                mostFrequentEmotion: 'none',
                highestIntensityEmotion: 'none',
                commonTriggers: [],
                progressTrend: 'stable',
            };
        }
        const counts: Record<string, number> = {};
        const triggers: Record<string, number> = {};
        for (const e of history) {
            counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
            if (e.trigger) triggers[e.trigger] = (triggers[e.trigger] ?? 0) + 1;
        }
        const mostFrequent = Object.entries(counts).sort((a, b) => b[1] - a[1])[0]?.[0] ?? 'none';
        const highestIntensity = [...history].sort((a, b) => b.intensity - a.intensity)[0]?.emotion ?? 'none';
        const commonTriggers = Object.entries(triggers)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 3)
            .map(([t]) => t);

        // Trend: compare last 7 days avg mood vs prior 7 days
        const now = Date.now();
        const last7 = history.filter((e) => now - e.timestamp.getTime() <= 7 * 86400000);
        const prior7 = history.filter((e) => {
            const d = now - e.timestamp.getTime();
            return d > 7 * 86400000 && d <= 14 * 86400000;
        });
        const avg = (arr: EmotionEntry[]) => (arr.length === 0 ? 0 : arr.reduce((s, e) => s + e.intensity, 0) / arr.length);
        const lastAvg = avg(last7);
        const priorAvg = avg(prior7);
        const progressTrend: EmotionInsights['progressTrend'] =
            lastAvg > priorAvg + 0.3 ? 'improving' : lastAvg < priorAvg - 0.3 ? 'declining' : 'stable';

        return { mostFrequentEmotion: mostFrequent, highestIntensityEmotion: highestIntensity, commonTriggers, progressTrend };
    }

    async deleteEmotion(id: string): Promise<void> {
        if (!this.userId) return;
        const { error } = await supabase.from('emotion_logs').delete().eq('id', id);
        if (error) {
            await enqueue('emotion_logs', 'delete', { id }, id);
        }
    }

    /** Best-effort sync of any pending writes. */
    async sync(): Promise<void> {
        await flushQueue();
    }
}
