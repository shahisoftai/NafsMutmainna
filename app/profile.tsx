// Profile Screen — view profile, edit name, sign out

import { useState, useCallback, useEffect } from 'react';
import {
    View,
    Text,
    StyleSheet,
    Pressable,
    ActivityIndicator,
    Alert,
    ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../src/presentation/contexts/AuthContext';
import { COLORS } from '../src/shared/constants';
import { useAppStore } from '../src/infrastructure/store';
import { AuthInput, ErrorBanner } from '../src/presentation/components';
import { authRepository } from '../src/infrastructure/supabase/authRepository';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function ProfileScreen() {
    const router = useRouter();
    const { profile, signOut, refreshProfile, status } = useAuth();
    const localOnboarded = useAppStore((s) => s.isOnboarded);

    const [editing, setEditing] = useState(false);
    const [fullName, setFullName] = useState('');
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (profile?.fullName) setFullName(profile.fullName);
    }, [profile?.fullName]);

    useEffect(() => {
        if (status === 'unauthenticated') {
            router.replace('/auth/login');
        }
    }, [status, router]);

    const handleSave = useCallback(async () => {
        if (!profile) return;
        setSaving(true);
        setError(null);
        try {
            await authRepository.upsertProfile({
                id: profile.id,
                email: profile.email,
                fullName: fullName.trim() || null,
                avatarUrl: profile.avatarUrl,
                provider: profile.provider,
                nafsStage: profile.nafsStage,
                nafsScore: profile.nafsScore,
            });
            await refreshProfile();
            setEditing(false);
        } catch (e) {
            setError(e instanceof Error ? e.message : 'Failed to save profile.');
        } finally {
            setSaving(false);
        }
    }, [fullName, profile, refreshProfile]);

    const handleSignOut = useCallback(() => {
        Alert.alert(
            'Sign out?',
            'Your local data will remain on this device. Cloud data stays in your account.',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Sign Out',
                    style: 'destructive',
                    onPress: async () => {
                        await signOut();
                        router.replace('/auth/login');
                    },
                },
            ]
        );
    }, [signOut, router]);

    const handleClearLocal = useCallback(() => {
        Alert.alert(
            'Clear local data?',
            'This removes the on-device cache. Your cloud data is unaffected.',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Clear',
                    style: 'destructive',
                    onPress: async () => {
                        await AsyncStorage.clear();
                        Alert.alert('Local data cleared. Please restart the app.');
                    },
                },
            ]
        );
    }, []);

    if (!profile) {
        return (
            <SafeAreaView style={styles.container}>
                <ActivityIndicator size="large" color={COLORS.primary} style={{ marginTop: 60 }} />
            </SafeAreaView>
        );
    }

    const initial = (profile.fullName || profile.email || '?').charAt(0).toUpperCase();

    return (
        <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
            <ScrollView contentContainerStyle={styles.scroll}>
                {/* Header */}
                <View style={styles.header}>
                    <Pressable
                        onPress={() => router.back()}
                        style={styles.backBtn}
                        accessibilityRole="button"
                        accessibilityLabel="Go back"
                        hitSlop={10}
                    >
                        <Ionicons name="arrow-back" size={22} color={COLORS.text} />
                    </Pressable>
                    <Text style={styles.title}>Profile</Text>
                    <View style={{ width: 32 }} />
                </View>

                {/* Avatar + name */}
                <View style={styles.identityBlock}>
                    <View style={styles.avatar}>
                        <Text style={styles.avatarText}>{initial}</Text>
                    </View>

                    {error && <ErrorBanner message={error} />}

                    {editing ? (
                        <>
                            <AuthInput
                                label="Display Name"
                                value={fullName}
                                onChangeText={setFullName}
                                placeholder="Enter your name"
                                autoCapitalize="words"
                            />
                            <View style={styles.editActions}>
                                <Pressable
                                    style={[styles.btn, styles.btnSecondary]}
                                    onPress={() => {
                                        setEditing(false);
                                        setFullName(profile.fullName ?? '');
                                    }}
                                    disabled={saving}
                                >
                                    <Text style={styles.btnSecondaryText}>Cancel</Text>
                                </Pressable>
                                <Pressable
                                    style={[styles.btn, styles.btnPrimary, saving && styles.btnDisabled]}
                                    onPress={handleSave}
                                    disabled={saving}
                                >
                                    {saving ? <ActivityIndicator color="#FFF" /> : <Text style={styles.btnPrimaryText}>Save</Text>}
                                </Pressable>
                            </View>
                        </>
                    ) : (
                        <>
                            <Text style={styles.nameText}>{profile.fullName || 'Anonymous Seeker'}</Text>
                            {profile.email ? <Text style={styles.emailText}>{profile.email}</Text> : null}
                            <View style={styles.providerRow}>
                                <Ionicons
                                    name={profile.provider === 'google' ? 'logo-google' : 'mail-outline'}
                                    size={14}
                                    color={COLORS.textSecondary}
                                />
                                <Text style={styles.providerText}>
                                    Signed in with {profile.provider === 'google' ? 'Google' : 'Email'}
                                </Text>
                            </View>
                            <Pressable
                                style={[styles.btn, styles.btnSecondary, { marginTop: 16 }]}
                                onPress={() => setEditing(true)}
                                accessibilityRole="button"
                            >
                                <Ionicons name="pencil-outline" size={16} color={COLORS.text} />
                                <Text style={styles.btnSecondaryText}>  Edit Profile</Text>
                            </Pressable>
                        </>
                    )}
                </View>

                {/* Cloud sync status */}
                {profile.nafsStage ? (
                    <View style={styles.card}>
                        <Text style={styles.cardTitle}>Spiritual State</Text>
                        <View style={styles.nafsRow}>
                            <Text style={styles.nafsLabel}>
                                {profile.nafsStage.charAt(0).toUpperCase() + profile.nafsStage.slice(1)}
                            </Text>
                            <Text style={styles.nafsScore}>{profile.nafsScore ?? 0}/100</Text>
                        </View>
                    </View>
                ) : null}

                {/* Actions */}
                <View style={styles.card}>
                    <Text style={styles.cardTitle}>Account</Text>
                    <RowAction
                        icon="cloud-offline-outline"
                        label="Clear local cache"
                        onPress={handleClearLocal}
                    />
                    <RowAction
                        icon="log-out-outline"
                        label="Sign out"
                        onPress={handleSignOut}
                        destructive
                    />
                </View>

                <Text style={styles.version}>NafsMutmainna v1.0.0</Text>
            </ScrollView>
        </SafeAreaView>
    );
}

interface RowActionProps {
    icon: keyof typeof Ionicons.glyphMap;
    label: string;
    onPress: () => void;
    destructive?: boolean;
}

const RowAction: React.FC<RowActionProps> = ({ icon, label, onPress, destructive }) => (
    <Pressable
        style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}
        onPress={onPress}
        accessibilityRole="button"
        accessibilityLabel={label}
    >
        <Ionicons
            name={icon}
            size={20}
            color={destructive ? COLORS.error : COLORS.text}
        />
        <Text style={[styles.rowText, destructive && { color: COLORS.error }]}>
            {label}
        </Text>
        <Ionicons name="chevron-forward" size={18} color={COLORS.textSecondary} />
    </Pressable>
);

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.background },
    scroll: { paddingBottom: 40 },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: 12,
    },
    backBtn: { padding: 6 },
    title: { fontSize: 18, fontWeight: '700', color: COLORS.text },
    identityBlock: {
        alignItems: 'center',
        paddingVertical: 24,
        paddingHorizontal: 24,
    },
    avatar: {
        width: 80,
        height: 80,
        borderRadius: 40,
        backgroundColor: COLORS.primary,
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 16,
    },
    avatarText: { color: '#FFF', fontSize: 32, fontWeight: '800' },
    nameText: { fontSize: 22, fontWeight: '700', color: COLORS.text, textAlign: 'center' },
    emailText: { fontSize: 14, color: COLORS.textSecondary, marginTop: 4 },
    providerRow: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 6 },
    providerText: { fontSize: 12, color: COLORS.textSecondary },
    editActions: { flexDirection: 'row', gap: 12, marginTop: 12, width: '100%' },
    btn: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 12,
        borderRadius: 10,
    },
    btnPrimary: { backgroundColor: COLORS.primary },
    btnPrimaryText: { color: '#FFF', fontWeight: '700' },
    btnSecondary: {
        backgroundColor: COLORS.surface,
        borderWidth: 1,
        borderColor: '#E0E0E0',
    },
    btnSecondaryText: { color: COLORS.text, fontWeight: '600' },
    btnDisabled: { opacity: 0.6 },
    card: {
        backgroundColor: COLORS.surface,
        marginHorizontal: 16,
        marginTop: 16,
        borderRadius: 12,
        overflow: 'hidden',
    },
    cardTitle: {
        fontSize: 12,
        fontWeight: '700',
        color: COLORS.textSecondary,
        textTransform: 'uppercase',
        letterSpacing: 0.6,
        paddingHorizontal: 16,
        paddingTop: 14,
        paddingBottom: 8,
    },
    nafsRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 16,
        paddingBottom: 16,
    },
    nafsLabel: { fontSize: 16, fontWeight: '600', color: COLORS.text },
    nafsScore: { fontSize: 16, fontWeight: '700', color: COLORS.primary },
    row: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
        paddingHorizontal: 16,
        paddingVertical: 14,
        borderTopWidth: 1,
        borderTopColor: '#F0F0F0',
    },
    rowPressed: { backgroundColor: '#F5F5F5' },
    rowText: { flex: 1, fontSize: 15, color: COLORS.text },
    version: {
        textAlign: 'center',
        color: COLORS.textSecondary,
        fontSize: 12,
        marginTop: 24,
    },
});
