// Offline write queue — persists writes to AsyncStorage and flushes when online
// SRP: queue management, no domain logic
// No external NetInfo dependency — uses try/catch on actual Supabase calls

import AsyncStorage from '@react-native-async-storage/async-storage';
import { v4 as uuidv4 } from 'uuid';
import { supabase } from '../client';
import type { SyncJob, SyncOp, SyncStatus } from '../../../domain/entities/cloud';

const QUEUE_KEY = 'nafsmutmainna.sync_queue.v1';
const listeners = new Set<(status: SyncStatus) => void>();
let currentStatus: SyncStatus = 'idle';
let flushing = false;

const setStatus = (s: SyncStatus) => {
    currentStatus = s;
    listeners.forEach((l) => l(s));
};

export const onSyncStatusChange = (listener: (s: SyncStatus) => void): (() => void) => {
    listeners.add(listener);
    listener(currentStatus);
    return () => {
        listeners.delete(listener);
    };
};

const readQueue = async (): Promise<SyncJob[]> => {
    const raw = await AsyncStorage.getItem(QUEUE_KEY);
    if (!raw) return [];
    try {
        return JSON.parse(raw) as SyncJob[];
    } catch {
        return [];
    }
};

const writeQueue = async (jobs: SyncJob[]): Promise<void> => {
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(jobs));
};

export const enqueue = async (
    table: SyncJob['table'],
    op: SyncOp,
    payload: Record<string, unknown>,
    localId: string
): Promise<SyncJob> => {
    const job: SyncJob = {
        id: uuidv4(),
        table,
        op,
        payload,
        localId,
        createdAt: new Date().toISOString(),
        attempts: 0,
        lastError: null,
    };
    const queue = await readQueue();
    queue.push(job);
    await writeQueue(queue);
    return job;
};

const performJob = async (job: SyncJob): Promise<void> => {
    if (job.op === 'insert') {
        const { error } = await supabase.from(job.table).insert(job.payload);
        if (error) throw new Error(error.message);
    } else if (job.op === 'update') {
        const { id, ...rest } = job.payload as { id: string };
        const { error } = await supabase.from(job.table).update(rest).eq('id', id);
        if (error) throw new Error(error.message);
    } else if (job.op === 'delete') {
        const { id } = job.payload as { id: string };
        const { error } = await supabase.from(job.table).delete().eq('id', id);
        if (error) throw new Error(error.message);
    }
};

export const flushQueue = async (): Promise<{ succeeded: number; failed: number; remaining: number }> => {
    if (flushing) return { succeeded: 0, failed: 0, remaining: 0 };
    flushing = true;
    setStatus('syncing');
    let succeeded = 0;
    let failed = 0;
    try {
        const queue = await readQueue();
        const remaining: SyncJob[] = [];
        for (const job of queue) {
            try {
                await performJob(job);
                succeeded++;
            } catch (e) {
                const msg = e instanceof Error ? e.message : 'unknown';
                // Network failures should keep the job for retry
                const isNetwork = /network|fetch|timeout/i.test(msg);
                if (!isNetwork) {
                    failed++;
                }
                remaining.push({
                    ...job,
                    attempts: job.attempts + 1,
                    lastError: msg,
                });
            }
        }
        await writeQueue(remaining);
        if (remaining.length === 0) {
            setStatus('idle');
        } else if (remaining.every((j) => j.attempts >= 5)) {
            setStatus('error');
        } else {
            setStatus('offline');
        }
        return { succeeded, failed, remaining: remaining.length };
    } finally {
        flushing = false;
    }
};

export const getQueueSize = async (): Promise<number> => {
    return (await readQueue()).length;
};

export const clearQueue = async (): Promise<void> => {
    await AsyncStorage.removeItem(QUEUE_KEY);
    setStatus('idle');
};

/**
 * Periodically attempts to flush the queue.
 * Call once at app start. Safe to call multiple times (idempotent).
 */
let intervalHandle: ReturnType<typeof setInterval> | null = null;
export const startSyncEngine = (intervalMs: number = 30_000): void => {
    if (intervalHandle) return;
    void flushQueue();
    intervalHandle = setInterval(() => {
        void flushQueue();
    }, intervalMs);
};

export const stopSyncEngine = (): void => {
    if (intervalHandle) {
        clearInterval(intervalHandle);
        intervalHandle = null;
    }
};
