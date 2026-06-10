// SupabaseAuthRepository — concrete implementation of IAuthRepository
// SRP: only auth concerns, delegates profile writes to Supabase client

import { supabase } from './client';
import type {
    AuthSession,
    SignInCredentials,
    SignUpCredentials,
    AuthResult,
    AuthErrorCode,
    UserProfile,
    AuthProvider,
} from '../../domain/auth/entities';
import type { IAuthRepository } from '../../domain/auth/repository';

const PROVIDERS: Record<string, AuthProvider> = {
    email: 'email',
    google: 'google',
};

const mapError = (message: string): { code: AuthErrorCode; message: string } => {
    const lower = message.toLowerCase();
    if (lower.includes('invalid login') || lower.includes('invalid credentials')) {
        return { code: 'invalid_credentials', message: 'Invalid email or password.' };
    }
    if (lower.includes('already registered') || lower.includes('already been registered')) {
        return { code: 'email_taken', message: 'An account with this email already exists.' };
    }
    if (lower.includes('password') && lower.includes('6')) {
        return { code: 'weak_password', message: 'Password must be at least 6 characters.' };
    }
    if (lower.includes('network') || lower.includes('fetch')) {
        return { code: 'network', message: 'Network error. Please check your connection.' };
    }
    if (lower.includes('expired')) {
        return { code: 'session_expired', message: 'Your session has expired. Please sign in again.' };
    }
    return { code: 'unknown', message };
};

const toSession = (s: NonNullable<Awaited<ReturnType<typeof supabase.auth.getSession>>['data']['session']>): AuthSession => ({
    userId: s.user.id,
    email: s.user.email ?? null,
    accessToken: s.access_token,
    refreshToken: s.refresh_token,
    expiresAt: s.expires_at ?? 0,
    provider: PROVIDERS[(s.user.app_metadata?.provider as string) ?? 'email'] ?? 'email',
});

const toProfile = (row: any): UserProfile => ({
    id: row.id,
    email: row.email ?? null,
    fullName: row.full_name ?? null,
    avatarUrl: row.avatar_url ?? null,
    provider: (PROVIDERS[row.provider] ?? 'email') as AuthProvider,
    nafsStage: row.nafs_stage ?? null,
    nafsScore: row.nafs_score ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    lastSyncedAt: row.last_synced_at ?? null,
});

export class SupabaseAuthRepository implements IAuthRepository {
    onAuthStateChange(listener: (session: AuthSession | null) => void): () => void {
        const { data } = supabase.auth.onAuthStateChange((_event, session) => {
            listener(session ? toSession(session) : null);
        });
        return () => data.subscription.unsubscribe();
    }

    async getCurrentSession(): Promise<AuthSession | null> {
        const { data, error } = await supabase.auth.getSession();
        if (error || !data.session) return null;
        return toSession(data.session);
    }

    async getProfile(userId: string): Promise<UserProfile | null> {
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();
        if (error) {
            console.error('[auth] getProfile failed:', error.message);
            return null;
        }
        return data ? toProfile(data) : null;
    }

    async upsertProfile(profile: Partial<UserProfile> & { id: string }): Promise<UserProfile> {
        const now = new Date().toISOString();
        const row = {
            id: profile.id,
            email: profile.email ?? null,
            full_name: profile.fullName ?? null,
            avatar_url: profile.avatarUrl ?? null,
            provider: profile.provider ?? 'email',
            nafs_stage: profile.nafsStage ?? null,
            nafs_score: profile.nafsScore ?? null,
            updated_at: now,
        };
        const { data, error } = await supabase
            .from('profiles')
            .upsert(row, { onConflict: 'id' })
            .select('*')
            .single();
        if (error) throw new Error(`Profile upsert failed: ${error.message}`);
        return toProfile(data);
    }

    async signInWithPassword(creds: SignInCredentials): Promise<AuthResult<AuthSession>> {
        const { data, error } = await supabase.auth.signInWithPassword(creds);
        if (error) return { ok: false, error: mapError(error.message) };
        if (!data.session) return { ok: false, error: { code: 'unknown', message: 'No session returned' } };
        return { ok: true, data: toSession(data.session) };
    }

    async signUpWithPassword(creds: SignUpCredentials): Promise<AuthResult<AuthSession>> {
        const { data, error } = await supabase.auth.signUp({
            email: creds.email,
            password: creds.password,
            options: { data: { full_name: creds.fullName } },
        });
        if (error) return { ok: false, error: mapError(error.message) };
        if (!data.session) {
            return { ok: true, data: undefined as unknown as AuthSession };
        }
        return { ok: true, data: toSession(data.session) };
    }

    async signInWithGoogle(redirectTo: string): Promise<AuthResult<{ url: string | null }>> {
        const { data, error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: { redirectTo },
        });
        if (error) return { ok: false, error: mapError(error.message) };
        return { ok: true, data: { url: data.url ?? null } };
    }

    async exchangeCodeForSession(code: string): Promise<AuthResult<AuthSession>> {
        const { data, error } = await supabase.auth.exchangeCodeForSession(code);
        if (error) return { ok: false, error: mapError(error.message) };
        if (!data.session) return { ok: false, error: { code: 'unknown', message: 'No session returned' } };
        return { ok: true, data: toSession(data.session) };
    }

    async signOut(): Promise<AuthResult<void>> {
        const { error } = await supabase.auth.signOut();
        if (error) return { ok: false, error: mapError(error.message) };
        return { ok: true, data: undefined };
    }
}

export const authRepository = new SupabaseAuthRepository();
