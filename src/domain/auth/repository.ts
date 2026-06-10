// Auth repository interface — ISP: focused on auth concerns only
// Implementation lives in src/infrastructure/supabase/

import type {
    AuthSession,
    SignInCredentials,
    SignUpCredentials,
    AuthResult,
    UserProfile,
} from './entities';

export interface IAuthRepository {
    /** Subscribe to auth state changes. Returns unsubscribe fn. */
    onAuthStateChange(listener: (session: AuthSession | null) => void): () => void;

    /** Get the currently cached session, if any. */
    getCurrentSession(): Promise<AuthSession | null>;

    /** Get the profile for the given user, or null if not found. */
    getProfile(userId: string): Promise<UserProfile | null>;

    /** Upsert profile row keyed on user.id (first-login or updates). */
    upsertProfile(profile: Partial<UserProfile> & { id: string }): Promise<UserProfile>;

    /** Sign in with email + password. */
    signInWithPassword(creds: SignInCredentials): Promise<AuthResult<AuthSession>>;

    /** Sign up new user with email + password. */
    signUpWithPassword(creds: SignUpCredentials): Promise<AuthResult<AuthSession>>;

    /** Begin Google OAuth (web: redirect, native: opens browser). */
    signInWithGoogle(redirectTo: string): Promise<AuthResult<{ url: string | null }>>;

    /** Exchange OAuth code for session (deep-link callback). */
    exchangeCodeForSession(code: string): Promise<AuthResult<AuthSession>>;

    /** Sign out and clear the local session. */
    signOut(): Promise<AuthResult<void>>;
}
