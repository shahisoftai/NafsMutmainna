// Root Layout — Providers + Deep Link + Auth Guard
// Order: SafeArea → QueryClient → Auth → AppStore → Stack

import { useEffect, useRef } from 'react';
import { StatusBar } from 'expo-status-bar';
import { Stack, useRouter, useSegments } from 'expo-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AppStoreProvider } from '../src/infrastructure/store/AppStoreProvider';
import { AuthProvider, useAuth } from '../src/presentation/contexts/AuthContext';
import { useDeepLinkAuth } from '../src/presentation/hooks/useDeepLinkAuth';
import { migrateLocalDataToCloud } from '../src/infrastructure/supabase/sync/migration';
import { View, ActivityIndicator } from 'react-native';
import { COLORS } from '../src/shared/constants';

const client = new QueryClient();

const CALLBACK_PATH = 'nafsmutmainna://auth/callback';

function AuthGuard({ children }: { children: React.ReactNode }) {
    const { status, session, profile } = useAuth();
    const router = useRouter();
    const segments = useSegments();
    const migratedRef = useRef<string | null>(null);

    // One-time local data migration after first authenticated session
    useEffect(() => {
        if (status !== 'authenticated' || !session) return;
        if (migratedRef.current === session.userId) return;
        migratedRef.current = session.userId;
        void migrateLocalDataToCloud(session.userId).catch((e) =>
            console.warn('[migration]', e)
        );
    }, [status, session]);

    // Route guard
    useEffect(() => {
        if (status === 'loading') return;
        const inAuthGroup = segments[0] === 'auth';
        if (status === 'unauthenticated' && !inAuthGroup) {
            router.replace('/auth/login');
        } else if (status === 'authenticated' && inAuthGroup) {
            router.replace('/(tabs)');
        }
    }, [status, segments, router]);

    if (status === 'loading') {
        return (
            <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: COLORS.background }}>
                <ActivityIndicator size="large" color={COLORS.primary} />
            </View>
        );
    }

    return <>{children}</>;
}

function DeepLinkBridge() {
    const router = useRouter();
    useDeepLinkAuth({
        callbackPath: CALLBACK_PATH,
        onSuccess: () => router.replace('/(tabs)'),
    });
    return null;
}

export default function RootLayout() {
    return (
        <SafeAreaProvider>
            <QueryClientProvider client={client}>
                <AuthProvider>
                    <AppStoreProvider>
                        <StatusBar style="dark" />
                        <AuthGuard>
                            <DeepLinkBridge />
                            <Stack screenOptions={{ headerShown: false }}>
                                <Stack.Screen name="(tabs)" />
                                <Stack.Screen name="onboarding" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="chat" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="auth" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="checkin" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="analytics" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="settings" options={{ presentation: 'modal' }} />
                                <Stack.Screen name="profile" options={{ presentation: 'modal' }} />
                            </Stack>
                        </AuthGuard>
                    </AppStoreProvider>
                </AuthProvider>
            </QueryClientProvider>
        </SafeAreaProvider>
    );
}
