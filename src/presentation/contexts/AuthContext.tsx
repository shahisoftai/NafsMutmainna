// AuthProvider — React context for auth state
// DIP: depends on IAuthRepository abstraction via `authRepository` instance

import React, { createContext, useContext, useEffect, useMemo, useState, useCallback } from 'react';
import { authRepository } from '../../infrastructure/supabase/authRepository';
import type {
    AuthSession,
    AuthError,
    SignInCredentials,
    SignUpCredentials,
    UserProfile,
} from '../../domain/auth/entities';

type AuthStatus = 'loading' | 'authenticated' | 'unauthenticated';

interface AuthContextValue {
    status: AuthStatus;
    session: AuthSession | null;
    profile: UserProfile | null;
    signIn: (creds: SignInCredentials) => Promise<{ ok: true } | { ok: false; error: AuthError }>;
    signUp: (creds: SignUpCredentials) => Promise<{ ok: true } | { ok: false; error: AuthError }>;
    signInWithGoogle: () => Promise<{ ok: true } | { ok: false; error: AuthError }>;
    signOut: () => Promise<{ ok: true } | { ok: false; error: AuthError }>;
    refreshProfile: () => Promise<void>;
    /** Replace the current session (used by deep-link handler). */
    setSession: (session: AuthSession) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

interface ProviderProps {
    children: React.ReactNode;
}

export const AuthProvider: React.FC<ProviderProps> = ({ children }) => {
    const [status, setStatus] = useState<AuthStatus>('loading');
    const [session, setSessionState] = useState<AuthSession | null>(null);
    const [profile, setProfile] = useState<UserProfile | null>(null);

    const loadProfile = useCallback(async (userId: string) => {
        const p = await authRepository.getProfile(userId);
        if (!p) {
            // First login — create profile row
            const created = await authRepository.upsertProfile({
                id: userId,
                email: session?.email ?? null,
                provider: session?.provider ?? 'email',
            });
            setProfile(created);
        } else {
            setProfile(p);
        }
    }, [session?.email, session?.provider]);

    useEffect(() => {
        let cancelled = false;

        // Initial session restore
        authRepository.getCurrentSession().then((s) => {
            if (cancelled) return;
            setSessionState(s);
            setStatus(s ? 'authenticated' : 'unauthenticated');
            if (s) void loadProfile(s.userId);
        });

        // Subscribe to future changes (login, logout, token refresh)
        const unsub = authRepository.onAuthStateChange((s) => {
            if (cancelled) return;
            setSessionState(s);
            setStatus(s ? 'authenticated' : 'unauthenticated');
            if (s) {
                void loadProfile(s.userId);
            } else {
                setProfile(null);
            }
        });

        return () => {
            cancelled = true;
            unsub();
        };
    }, [loadProfile]);

    const signIn = useCallback(async (creds: SignInCredentials) => {
        const r = await authRepository.signInWithPassword(creds);
        return r.ok ? { ok: true as const } : { ok: false as const, error: r.error };
    }, []);

    const signUp = useCallback(async (creds: SignUpCredentials) => {
        const r = await authRepository.signUpWithPassword(creds);
        return r.ok ? { ok: true as const } : { ok: false as const, error: r.error };
    }, []);

    const signInWithGoogle = useCallback(async () => {
        const r = await authRepository.signInWithGoogle('nafsmutmainna://auth/callback');
        if (!r.ok) return { ok: false as const, error: r.error };
        return { ok: true as const };
    }, []);

    const signOut = useCallback(async () => {
        const r = await authRepository.signOut();
        return r.ok ? { ok: true as const } : { ok: false as const, error: r.error };
    }, []);

    const refreshProfile = useCallback(async () => {
        if (session) await loadProfile(session.userId);
    }, [session, loadProfile]);

    const setSession = useCallback((s: AuthSession) => {
        setSessionState(s);
        setStatus('authenticated');
    }, []);

    const value = useMemo<AuthContextValue>(
        () => ({ status, session, profile, signIn, signUp, signInWithGoogle, signOut, refreshProfile, setSession }),
        [status, session, profile, signIn, signUp, signInWithGoogle, signOut, refreshProfile, setSession]
    );

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextValue => {
    const ctx = useContext(AuthContext);
    if (!ctx) throw new Error('useAuth must be used within AuthProvider');
    return ctx;
};
