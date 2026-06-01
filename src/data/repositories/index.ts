// Data Repository Implementations
// Open/Closed Principle: Add new data sources without modifying consumers

import type {
    INafsRepository,
    IEmotionRepository,
    IRectificationRepository,
    IJournalRepository,
    IProgressRepository,
} from '../../domain/repositories';
import type {
    AssessmentAnswer,
    AssessmentResult,
    NafsState,
    EmotionEntry,
    EmotionInsights,
    Trait,
    TraitType,
    RectificationTool,
    JournalEntry,
    JournalPrompt,
    UserProgress,
    Badge,
    DateFilter,
    NafsAttribute,
    NafsAttributeCategory,
} from '../../domain/entities';
import type { INafsAttributeRepository } from '../../domain/repositories';
import { apiGet, apiPost } from '../../infrastructure/api/client';
import { TRAITS, BADGES, JOURNAL_PROMPTS } from '../../shared/constants';
import { supabase } from '../../infrastructure/supabase/client';

// ─── Nafs Repository ──────────────────────────────────────────────────────────

export class NafsRepository implements INafsRepository {
    async assessNafsState(answers: AssessmentAnswer[]): Promise<AssessmentResult> {
        return apiPost<AssessmentResult>('/assessment', { answers });
    }

    async getCurrentNafsState(): Promise<NafsState | null> {
        try {
            return await apiGet<NafsState>('/nafs/state');
        } catch {
            return null;
        }
    }

    async performDailyCheckin(mood: 1 | 2 | 3 | 4 | 5): Promise<NafsState> {
        return apiPost<NafsState>('/nafs/checkin', { mood });
    }
}

// ─── Emotion Repository ────────────────────────────────────────────────────────

export class EmotionRepository implements IEmotionRepository {
    async logEmotion(entry: Omit<EmotionEntry, 'id'>): Promise<EmotionEntry> {
        return apiPost<EmotionEntry>('/emotions', entry);
    }

    async getEmotionHistory(filter?: DateFilter): Promise<EmotionEntry[]> {
        return apiGet<EmotionEntry[]>('/emotions', {
            startDate: filter?.startDate?.toISOString(),
            endDate: filter?.endDate?.toISOString(),
            limit: filter?.limit,
        });
    }

    async getEmotionInsights(): Promise<EmotionInsights> {
        return apiGet<EmotionInsights>('/emotions/insights');
    }

    async deleteEmotion(id: string): Promise<void> {
        await apiPost(`/emotions/${id}/delete`, {});
    }
}

// ─── Rectification Repository ─────────────────────────────────────────────────

export class RectificationRepository implements IRectificationRepository {
    // Uses local constants for performance — no network required
    getAllTraits(): Promise<Trait[]> {
        return Promise.resolve([...TRAITS] as Trait[]);
    }

    getTraitById(traitId: TraitType): Promise<Trait | null> {
        const trait = TRAITS.find((t) => t.id === traitId) as Trait | undefined;
        return Promise.resolve(trait ?? null);
    }

    async getToolsForTrait(traitId: TraitType): Promise<RectificationTool[]> {
        return apiGet<RectificationTool[]>(`/traits/${traitId}/tools`);
    }

    async getImmediateTools(traitId: TraitType): Promise<RectificationTool[]> {
        return apiGet<RectificationTool[]>(`/traits/${traitId}/tools?type=immediate`);
    }

    async getShortTermActions(traitId: TraitType): Promise<RectificationTool[]> {
        return apiGet<RectificationTool[]>(`/traits/${traitId}/tools?type=shortTerm`);
    }

    async getLongTermHabits(traitId: TraitType): Promise<RectificationTool[]> {
        return apiGet<RectificationTool[]>(`/traits/${traitId}/tools?type=longTerm`);
    }
}

// ─── Journal Repository ────────────────────────────────────────────────────────

export class JournalRepository implements IJournalRepository {
    async saveEntry(
        entry: Omit<JournalEntry, 'id' | 'createdAt' | 'updatedAt'>
    ): Promise<JournalEntry> {
        return apiPost<JournalEntry>('/journal', entry);
    }

    async getEntries(filter?: DateFilter): Promise<JournalEntry[]> {
        return apiGet<JournalEntry[]>('/journal', {
            startDate: filter?.startDate?.toISOString(),
            endDate: filter?.endDate?.toISOString(),
            limit: filter?.limit,
        });
    }

    getTodayPrompt(): Promise<JournalPrompt> {
        const today = new Date().toISOString().split('T')[0];
        return Promise.resolve({
            date: today,
            questions: {
                nafsWin: JOURNAL_PROMPTS.nafsWin,
                mutmainnaMoment: JOURNAL_PROMPTS.mutmainnaMoment,
                gratitude: JOURNAL_PROMPTS.gratitude,
            },
        });
    }

    async getEntryByDate(date: string): Promise<JournalEntry | null> {
        try {
            return await apiGet<JournalEntry>(`/journal/${date}`);
        } catch {
            return null;
        }
    }

    async updateEntry(id: string, updates: Partial<JournalEntry>): Promise<JournalEntry> {
        return apiPost<JournalEntry>(`/journal/${id}`, updates);
    }

    async deleteEntry(id: string): Promise<void> {
        await apiPost(`/journal/${id}/delete`, {});
    }
}

// ─── Progress Repository ───────────────────────────────────────────────────────

export class ProgressRepository implements IProgressRepository {
    async getProgress(): Promise<UserProgress> {
        return apiGet<UserProgress>('/progress');
    }

    async updateProgress(updates: Partial<UserProgress>): Promise<UserProgress> {
        return apiPost<UserProgress>('/progress', updates);
    }

    async awardBadge(badgeId: string): Promise<Badge> {
        return apiPost<Badge>('/progress/badges', { badgeId });
    }

    getAllBadges(): Promise<Badge[]> {
        return Promise.resolve([...BADGES] as Badge[]);
    }

    async getEarnedBadges(): Promise<Badge[]> {
        return apiGet<Badge[]>('/progress/badges');
    }

    async updateStreak(): Promise<{ streak: number; isNewRecord: boolean }> {
        return apiPost<{ streak: number; isNewRecord: boolean }>('/progress/streak', {});
    }

    async addOdex(points: number): Promise<number> {
        const result = await apiPost<{ total: number }>('/progress/odex', { points });
        return result.total;
    }
}

// ─── NafsAttribute Repository ─────────────────────────────────────────────────
// Reads directly from Supabase — no backend proxy needed

export class NafsAttributeRepository implements INafsAttributeRepository {
    async getAll(): Promise<NafsAttribute[]> {
        const { data, error } = await supabase
            .from('nafs_attributes')
            .select('*')
            .order('name');
        if (error) throw new Error(error.message);
        return data as NafsAttribute[];
    }

    async getByCategory(category: NafsAttributeCategory): Promise<NafsAttribute[]> {
        const { data, error } = await supabase
            .from('nafs_attributes')
            .select('*')
            .eq('category', category)
            .order('name');
        if (error) throw new Error(error.message);
        return data as NafsAttribute[];
    }

    async getByName(name: string): Promise<NafsAttribute | null> {
        const { data, error } = await supabase
            .from('nafs_attributes')
            .select('*')
            .eq('name', name)
            .maybeSingle();
        if (error) throw new Error(error.message);
        return data as NafsAttribute | null;
    }

    async getOpposite(oppositeName: string): Promise<NafsAttribute | null> {
        const { data, error } = await supabase
            .from('nafs_attributes')
            .select('*')
            .eq('name', oppositeName)
            .maybeSingle();
        if (error) throw new Error(error.message);
        return data as NafsAttribute | null;
    }
}

// ─── Repository Factory (Dependency Inversion) ────────────────────────────────

export const repositories = {
    nafs: new NafsRepository(),
    emotion: new EmotionRepository(),
    rectification: new RectificationRepository(),
    journal: new JournalRepository(),
    progress: new ProgressRepository(),
    nafsAttribute: new NafsAttributeRepository(),
} as const;