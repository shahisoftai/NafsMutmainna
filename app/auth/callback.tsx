// Auth Callback Screen — shown briefly while the deep-link code is exchanged
// The actual exchange happens in the root layout's deep-link hook. This screen
// is a safe landing target in case the user lands here directly.

import { useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/presentation/contexts/AuthContext';
import { COLORS } from '../../src/shared/constants';

export default function AuthCallbackScreen() {
    const router = useRouter();
    const { status } = useAuth();

    useEffect(() => {
        if (status === 'authenticated') {
            router.replace('/(tabs)');
        } else if (status === 'unauthenticated') {
            router.replace('/auth/login');
        }
    }, [status, router]);

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.content}>
                <ActivityIndicator size="large" color={COLORS.primary} />
                <Text style={styles.text}>Completing sign in…</Text>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.background },
    content: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 16 },
    text: { color: COLORS.textSecondary, fontSize: 15 },
});
