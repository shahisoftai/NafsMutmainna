// Register Screen — Email/Password sign-up

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

export default function RegisterScreen() {
    const router = useRouter();
    const { signUp } = useAuth();

    const [fullName, setFullName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirm, setConfirm] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);

    const handleSubmit = useCallback(async () => {
        setError(null);
        if (!fullName.trim()) {
            setError('Please enter your name.');
            return;
        }
        if (!isValidEmail(email)) {
            setError('Please enter a valid email address.');
            return;
        }
        if (password.length < 6) {
            setError('Password must be at least 6 characters.');
            return;
        }
        if (password !== confirm) {
            setError('Passwords do not match.');
            return;
        }
        setLoading(true);
        const r = await signUp({ email, password, fullName: fullName.trim() });
        setLoading(false);
        if (!r.ok) {
            setError(r.error.message);
            return;
        }
        // Supabase sends a confirmation email; either session is returned or
        // user must verify. In both cases, route to home (the app handles
        // unauthenticated state via the guard).
        router.replace('/(tabs)');
    }, [fullName, email, password, confirm, signUp, router]);

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
                        title="Begin Your Journey"
                        subtitle="Create an account to sync across devices"
                    >
                        <ArabicText style={styles.arabic} text="بِسْمِ اللَّهِ" />

                        {error && <ErrorBanner message={error} />}

                        <AuthInput
                            label="Full Name"
                            value={fullName}
                            onChangeText={setFullName}
                            placeholder="e.g., Aisha Siddiqui"
                            autoCapitalize="words"
                            autoComplete="name"
                            textContentType="name"
                            editable={!loading}
                        />

                        <AuthInput
                            label="Email"
                            value={email}
                            onChangeText={setEmail}
                            placeholder="you@example.com"
                            keyboardType="email-address"
                            autoCapitalize="none"
                            autoComplete="email"
                            textContentType="emailAddress"
                            editable={!loading}
                        />

                        <AuthInput
                            label="Password"
                            value={password}
                            onChangeText={setPassword}
                            placeholder="At least 6 characters"
                            secureTextEntry={!showPassword}
                            autoCapitalize="none"
                            autoComplete="password-new"
                            textContentType="newPassword"
                            editable={!loading}
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

                        <AuthInput
                            label="Confirm Password"
                            value={confirm}
                            onChangeText={setConfirm}
                            placeholder="Re-enter password"
                            secureTextEntry={!showPassword}
                            autoCapitalize="none"
                            autoComplete="password-new"
                            textContentType="newPassword"
                            editable={!loading}
                        />

                        <Pressable
                            style={[styles.primaryButton, loading && styles.buttonDisabled]}
                            onPress={handleSubmit}
                            disabled={loading}
                            accessibilityRole="button"
                            accessibilityLabel="Create account"
                        >
                            {loading ? (
                                <ActivityIndicator color="#FFF" />
                            ) : (
                                <Text style={styles.primaryButtonText}>Create Account</Text>
                            )}
                        </Pressable>

                        <View style={styles.footer}>
                            <Text style={styles.footerText}>Already have an account? </Text>
                            <Link href="/auth/login" asChild>
                                <Pressable hitSlop={8}>
                                    <Text style={styles.footerLink}>Sign In</Text>
                                </Pressable>
                            </Link>
                        </View>
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
        marginTop: 16,
    },
    buttonDisabled: { opacity: 0.6 },
    primaryButtonText: { color: '#FFF', fontSize: 16, fontWeight: '700' },
    footer: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 24,
    },
    footerText: { color: COLORS.textSecondary, fontSize: 14 },
    footerLink: { color: COLORS.primary, fontSize: 14, fontWeight: '700' },
});
