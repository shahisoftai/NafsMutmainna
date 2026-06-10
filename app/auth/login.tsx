// Login Screen — Email/Password + Google OAuth

import { useState, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TextInput,
    Pressable,
    ActivityIndicator,
    KeyboardAvoidingView,
    Platform,
    ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter, Link } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../src/presentation/contexts/AuthContext';
import { COLORS } from '../../src/shared/constants';
import { ArabicText, AuthLayout, AuthInput, ErrorBanner } from '../../src/presentation/components';

const isValidEmail = (s: string) => /.+@.+\..+/.test(s);

export default function LoginScreen() {
    const router = useRouter();
    const { signIn, signInWithGoogle } = useAuth();

    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [googleLoading, setGoogleLoading] = useState(false);

    const handleEmailLogin = useCallback(async () => {
        setError(null);
        if (!isValidEmail(email)) {
            setError('Please enter a valid email address.');
            return;
        }
        if (password.length < 6) {
            setError('Password must be at least 6 characters.');
            return;
        }
        setLoading(true);
        const r = await signIn({ email, password });
        setLoading(false);
        if (!r.ok) {
            setError(r.error.message);
            return;
        }
        router.replace('/(tabs)');
    }, [email, password, signIn, router]);

    const handleGoogle = useCallback(async () => {
        setError(null);
        setGoogleLoading(true);
        const r = await signInWithGoogle();
        setGoogleLoading(false);
        if (!r.ok) {
            setError(r.error.message);
        }
        // On success the OAuth browser opens; session arrives via deep link.
    }, [signInWithGoogle]);

    return (
        <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
            <KeyboardAvoidingView
                style={styles.flex}
                behavior={Platform.OS === 'ios' ? 'padding' : undefined}
            >
                <ScrollView
                    contentContainerStyle={styles.scroll}
                    keyboardShouldPersistTaps="handled"
                    showsVerticalScrollIndicator={false}
                >
                    <AuthLayout
                        title="Welcome Back"
                        subtitle="Continue your Tazkiyah journey"
                    >
                        <ArabicText style={styles.arabic} text="بِسْمِ اللَّهِ" />

                        {error && <ErrorBanner message={error} />}

                        <AuthInput
                            label="Email"
                            value={email}
                            onChangeText={setEmail}
                            placeholder="you@example.com"
                            keyboardType="email-address"
                            autoCapitalize="none"
                            autoComplete="email"
                            textContentType="emailAddress"
                            editable={!loading && !googleLoading}
                        />

                        <AuthInput
                            label="Password"
                            value={password}
                            onChangeText={setPassword}
                            placeholder="Enter your password"
                            secureTextEntry={!showPassword}
                            autoCapitalize="none"
                            autoComplete="password"
                            textContentType="password"
                            editable={!loading && !googleLoading}
                            rightAdornment={
                                <Pressable
                                    onPress={() => setShowPassword((s) => !s)}
                                    accessibilityLabel={showPassword ? 'Hide password' : 'Show password'}
                                    accessibilityRole="button"
                                    hitSlop={10}
                                >
                                    <Ionicons
                                        name={showPassword ? 'eye-off-outline' : 'eye-outline'}
                                        size={20}
                                        color={COLORS.textSecondary}
                                    />
                                </Pressable>
                            }
                        />

                        <Pressable
                            style={[styles.primaryButton, loading && styles.buttonDisabled]}
                            onPress={handleEmailLogin}
                            disabled={loading || googleLoading}
                            accessibilityRole="button"
                            accessibilityLabel="Sign in with email"
                        >
                            {loading ? (
                                <ActivityIndicator color="#FFF" />
                            ) : (
                                <Text style={styles.primaryButtonText}>Sign In</Text>
                            )}
                        </Pressable>

                        <View style={styles.dividerRow}>
                            <View style={styles.divider} />
                            <Text style={styles.dividerText}>or</Text>
                            <View style={styles.divider} />
                        </View>

                        <Pressable
                            style={[styles.googleButton, googleLoading && styles.buttonDisabled]}
                            onPress={handleGoogle}
                            disabled={loading || googleLoading}
                            accessibilityRole="button"
                            accessibilityLabel="Sign in with Google"
                        >
                            {googleLoading ? (
                                <ActivityIndicator color={COLORS.text} />
                            ) : (
                                <>
                                    <Ionicons name="logo-google" size={20} color={COLORS.text} />
                                    <Text style={styles.googleButtonText}>Continue with Google</Text>
                                </>
                            )}
                        </Pressable>

                        <View style={styles.footer}>
                            <Text style={styles.footerText}>Don't have an account? </Text>
                            <Link href="/auth/register" asChild>
                                <Pressable hitSlop={8}>
                                    <Text style={styles.footerLink}>Sign Up</Text>
                                </Pressable>
                            </Link>
                        </View>

                        <Text style={styles.disclaimer}>
                            🔒 Your data is end-to-end encrypted and synced securely via Supabase.
                        </Text>
                    </AuthLayout>
                </ScrollView>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.background },
    flex: { flex: 1 },
    scroll: { flexGrow: 1, paddingVertical: 24 },
    arabic: { textAlign: 'center', marginBottom: 24, color: COLORS.primary },
    primaryButton: {
        backgroundColor: COLORS.primary,
        paddingVertical: 16,
        borderRadius: 12,
        alignItems: 'center',
        marginTop: 8,
    },
    buttonDisabled: { opacity: 0.6 },
    primaryButtonText: { color: '#FFF', fontSize: 16, fontWeight: '700' },
    dividerRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginVertical: 20,
        gap: 12,
    },
    divider: { flex: 1, height: 1, backgroundColor: '#E0E0E0' },
    dividerText: { color: COLORS.textSecondary, fontSize: 13 },
    googleButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 10,
        paddingVertical: 14,
        borderRadius: 12,
        borderWidth: 1,
        borderColor: '#D0D0D0',
        backgroundColor: COLORS.surface,
    },
    googleButtonText: { color: COLORS.text, fontSize: 15, fontWeight: '600' },
    footer: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 24,
    },
    footerText: { color: COLORS.textSecondary, fontSize: 14 },
    footerLink: { color: COLORS.primary, fontSize: 14, fontWeight: '700' },
    disclaimer: {
        textAlign: 'center',
        color: COLORS.textSecondary,
        fontSize: 12,
        marginTop: 24,
        lineHeight: 18,
    },
});
