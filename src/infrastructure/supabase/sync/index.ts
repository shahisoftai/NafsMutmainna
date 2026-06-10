// CloudRepositoryProvider — wires up the cloud repositories and binds userId
// SRP: lifecycle of cloud repos; not a UI concern
// DI: returns interfaces, not implementations

import { useEffect, useMemo } from 'react';
import { useAuth } from '../../../presentation/contexts/AuthContext';
import { CloudEmotionRepository } from './cloudEmotionRepository';
import { CloudJournalRepository } from './cloudJournalRepository';
import { CloudCheckinRepository } from './cloudCheckinRepository';
import { startSyncEngine, stopSyncEngine } from './queue';
import type { IEmotionRepository, IJournalRepository } from '../../../domain/repositories';

export interface CloudRepositories {
    emotion: IEmotionRepository;
    journal: IJournalRepository;
    checkin: CloudCheckinRepository;
}

export const cloudEmotionRepo = new CloudEmotionRepository();
export const cloudJournalRepo = new CloudJournalRepository();
export const cloudCheckinRepo = new CloudCheckinRepository();

/** Hook that returns repositories with `userId` bound to the active session. */
export function useCloudRepositories(): CloudRepositories {
    const { session, status } = useAuth();

    useEffect(() => {
        const userId = status === 'authenticated' && session ? session.userId : null;
        cloudEmotionRepo.setUserId(userId);
        cloudJournalRepo.setUserId(userId);
        cloudCheckinRepo.setUserId(userId);
    }, [session, status]);

    // Start the sync engine for the lifetime of the app
    useEffect(() => {
        startSyncEngine(30_000);
        return () => stopSyncEngine();
    }, []);

    return useMemo(
        () => ({
            emotion: cloudEmotionRepo,
            journal: cloudJournalRepo,
            checkin: cloudCheckinRepo,
        }),
        []
    );
}
