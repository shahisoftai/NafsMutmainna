// useDeepLinkAuth — handles Supabase OAuth callback via app's deep-link scheme
// Listens to: (1) cold-start URL (2) warm-start URL events
// Exchanges the `code` query param for a session via the auth repository.

import { useEffect } from 'react';
import * as Linking from 'expo-linking';
import { authRepository } from '../../infrastructure/supabase/authRepository';

interface Options {
    /** Path (or full URL substring) that indicates an auth callback. */
    callbackPath: string;
    /** Called after a successful session exchange. */
    onSuccess?: (session: { userId: string; email: string | null }) => void;
    /** Called if the code exchange fails. */
    onError?: (message: string) => void;
}

export function useDeepLinkAuth({ callbackPath, onSuccess, onError }: Options): void {
    useEffect(() => {
        let cancelled = false;

        const handleUrl = async (url: string | null) => {
            if (!url || cancelled) return;
            if (!url.includes(callbackPath)) return;

            try {
                const code = new URL(url).searchParams.get('code');
                if (!code) return;
                const result = await authRepository.exchangeCodeForSession(code);
                if (cancelled) return;
                if (result.ok) {
                    onSuccess?.({ userId: result.data.userId, email: result.data.email });
                } else {
                    onError?.(result.error.message);
                }
            } catch (err) {
                onError?.(err instanceof Error ? err.message : 'Unknown error');
            }
        };

        // Cold start
        void Linking.getInitialURL().then((url) => handleUrl(url));

        // Warm start
        const sub = Linking.addEventListener('url', ({ url }) => {
            void handleUrl(url);
        });

        return () => {
            cancelled = true;
            sub.remove();
        };
    }, [callbackPath, onSuccess, onError]);
}
