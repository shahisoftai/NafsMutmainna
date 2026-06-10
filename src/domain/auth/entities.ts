// Auth domain entities — SRP: pure types, no behavior
// Mirrors the `profiles` table in Supabase

export type AuthProvider = 'email' | 'google' | 'anonymous';

export interface UserProfile {
    id: string;
    email: string | null;
    fullName: string | null;
    avatarUrl: string | null;
    provider: AuthProvider;
    nafsStage: 'ammarah' | 'lawwamah' | 'mutmainna' | null;
    nafsScore: number | null;
    createdAt: string;
    updatedAt: string;
    lastSyncedAt: string | null;
}

export interface AuthSession {
    userId: string;
    email: string | null;
    accessToken: string;
    refreshToken: string;
    expiresAt: number;
    provider: AuthProvider;
}

export interface SignUpCredentials {
    email: string;
    password: string;
    fullName?: string;
}

export interface SignInCredentials {
    email: string;
    password: string;
}

export type AuthResult<T> =
    | { ok: true; data: T }
    | { ok: false; error: AuthError };

export interface AuthError {
    code: AuthErrorCode;
    message: string;
}

export type AuthErrorCode =
    | 'invalid_credentials'
    | 'email_taken'
    | 'weak_password'
    | 'network'
    | 'session_expired'
    | 'oauth_cancelled'
    | 'unknown';

export const AUTH_CALLBACK_PATH = 'nafsmutmainna://auth/callback';
