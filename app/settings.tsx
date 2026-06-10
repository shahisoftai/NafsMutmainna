// Settings Screen — language, theme, notifications, sign-out shortcut

import { View, Text, StyleSheet, ScrollView, Pressable, Switch, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../src/presentation/theme';
import { useSettingsStore, type Language, type ThemePreference } from '../src/infrastructure/store/settingsStore';
import { useAuth } from '../src/presentation/contexts/AuthContext';
import { SectionHeader } from '../src/presentation/components';

export default function SettingsScreen() {
    const router = useRouter();
    const theme = useTheme();
    const { signOut, status } = useAuth();
    const language = useSettingsStore((s) => s.language);
    const themePref = useSettingsStore((s) => s.themePreference);
    const notificationsEnabled = useSettingsStore((s) => s.notificationsEnabled);
    const hapticsEnabled = useSettingsStore((s) => s.hapticsEnabled);
    const setLanguage = useSettingsStore((s) => s.setLanguage);
    const setThemePreference = useSettingsStore((s) => s.setThemePreference);
    const setNotificationsEnabled = useSettingsStore((s) => s.setNotificationsEnabled);
    const setHapticsEnabled = useSettingsStore((s) => s.setHapticsEnabled);

    const handleSignOut = () => {
        Alert.alert('Sign out?', 'You can sign back in any time.', [
            { text: 'Cancel', style: 'cancel' },
            {
                text: 'Sign Out',
                style: 'destructive',
                onPress: async () => {
                    await signOut();
                    router.replace('/auth/login');
                },
            },
        ]);
    };

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top', 'bottom']}>
            <View style={styles.header}>
                <Pressable
                    onPress={() => router.back()}
                    style={styles.backBtn}
                    accessibilityRole="button"
                    accessibilityLabel="Close settings"
                    hitSlop={10}
                >
                    <Ionicons name="close" size={22} color={theme.colors.text} />
                </Pressable>
                <Text style={[styles.title, { color: theme.colors.text }]}>Settings</Text>
                <View style={{ width: 32 }} />
            </View>

            <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
                {/* Appearance */}
                <SectionHeader title="Appearance" />
                <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    <Text style={[styles.rowLabel, { color: theme.colors.text }]}>Theme</Text>
                    <View style={styles.segmentedRow}>
                        {(['auto', 'light', 'dark'] as ThemePreference[]).map((opt) => (
                            <Pressable
                                key={opt}
                                onPress={() => setThemePreference(opt)}
                                style={[
                                    styles.segmentedBtn,
                                    themePref === opt && { backgroundColor: theme.colors.primary },
                                ]}
                                accessibilityRole="button"
                                accessibilityLabel={`Theme: ${opt}`}
                                accessibilityState={{ selected: themePref === opt }}
                            >
                                <Text
                                    style={[
                                        styles.segmentedText,
                                        { color: themePref === opt ? '#FFF' : theme.colors.textSecondary },
                                    ]}
                                >
                                    {opt.charAt(0).toUpperCase() + opt.slice(1)}
                                </Text>
                            </Pressable>
                        ))}
                    </View>
                </View>

                {/* Language */}
                <SectionHeader title="Language" subtitle="UI translations for trait names" />
                <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    {(
                        [
                            { value: 'en', label: 'English' },
                            { value: 'ur', label: 'اردو (Urdu)' },
                            { value: 'ar', label: 'العربية (Arabic)' },
                        ] as { value: Language; label: string }[]
                    ).map((opt, i, arr) => (
                        <Pressable
                            key={opt.value}
                            onPress={() => setLanguage(opt.value)}
                            style={[
                                styles.langRow,
                                i < arr.length - 1 && { borderBottomWidth: 1, borderBottomColor: theme.colors.border },
                            ]}
                            accessibilityRole="button"
                            accessibilityLabel={`Language: ${opt.label}`}
                            accessibilityState={{ selected: language === opt.value }}
                        >
                            <Text
                                style={[
                                    styles.langLabel,
                                    {
                                        color: language === opt.value ? theme.colors.primary : theme.colors.text,
                                        fontWeight: language === opt.value ? '700' : '500',
                                    },
                                ]}
                            >
                                {opt.label}
                            </Text>
                            {language === opt.value && (
                                <Ionicons name="checkmark-circle" size={20} color={theme.colors.primary} />
                            )}
                        </Pressable>
                    ))}
                </View>

                {/* Preferences */}
                <SectionHeader title="Preferences" />
                <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    <View style={styles.toggleRow}>
                        <View style={{ flex: 1 }}>
                            <Text style={[styles.rowLabel, { color: theme.colors.text }]}>
                                Daily check-in reminder
                            </Text>
                            <Text style={[styles.rowHint, { color: theme.colors.textSecondary }]}>
                                Get a gentle nudge to log your mood each evening.
                            </Text>
                        </View>
                        <Switch
                            value={notificationsEnabled}
                            onValueChange={setNotificationsEnabled}
                            trackColor={{ true: theme.colors.primary, false: theme.colors.border }}
                            accessibilityLabel="Toggle daily reminders"
                        />
                    </View>
                    <View
                        style={[
                            styles.toggleRow,
                            { borderTopWidth: 1, borderTopColor: theme.colors.border },
                        ]}
                    >
                        <View style={{ flex: 1 }}>
                            <Text style={[styles.rowLabel, { color: theme.colors.text }]}>Haptic feedback</Text>
                            <Text style={[styles.rowHint, { color: theme.colors.textSecondary }]}>
                                Subtle vibrations on interactions.
                            </Text>
                        </View>
                        <Switch
                            value={hapticsEnabled}
                            onValueChange={setHapticsEnabled}
                            trackColor={{ true: theme.colors.primary, false: theme.colors.border }}
                            accessibilityLabel="Toggle haptics"
                        />
                    </View>
                </View>

                {/* Account */}
                {status === 'authenticated' && (
                    <>
                        <SectionHeader title="Account" />
                        <View
                            style={[
                                styles.card,
                                { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                            ]}
                        >
                            <Pressable
                                style={styles.row}
                                onPress={() => router.push('/profile')}
                                accessibilityRole="button"
                                accessibilityLabel="Open profile"
                            >
                                <Ionicons name="person-circle-outline" size={22} color={theme.colors.text} />
                                <Text style={[styles.rowLabel, { color: theme.colors.text, flex: 1, marginLeft: 12 }]}>
                                    View profile
                                </Text>
                                <Ionicons name="chevron-forward" size={18} color={theme.colors.textSecondary} />
                            </Pressable>
                            <Pressable
                                style={[styles.row, { borderTopWidth: 1, borderTopColor: theme.colors.border }]}
                                onPress={handleSignOut}
                                accessibilityRole="button"
                                accessibilityLabel="Sign out"
                            >
                                <Ionicons name="log-out-outline" size={22} color={theme.colors.error} />
                                <Text
                                    style={[
                                        styles.rowLabel,
                                        { color: theme.colors.error, flex: 1, marginLeft: 12 },
                                    ]}
                                >
                                    Sign out
                                </Text>
                            </Pressable>
                        </View>
                    </>
                )}

                <Text style={[styles.footer, { color: theme.colors.textSecondary }]}>
                    NafsMutmainna v1.0.0{'\n'}Built with reverence for the Tazkiyah path.
                </Text>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: 12,
    },
    backBtn: { padding: 6 },
    title: { fontSize: 18, fontWeight: '700' },
    scroll: { paddingHorizontal: 16, paddingBottom: 40, gap: 8 },
    card: { borderRadius: 12, borderWidth: 1, overflow: 'hidden' },
    row: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 14,
        paddingVertical: 14,
    },
    rowLabel: { fontSize: 15, fontWeight: '500' },
    rowHint: { fontSize: 12, marginTop: 2 },
    toggleRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 14,
        paddingVertical: 14,
        gap: 12,
    },
    segmentedRow: { flexDirection: 'row', padding: 6, gap: 6 },
    segmentedBtn: { flex: 1, paddingVertical: 8, borderRadius: 8, alignItems: 'center' },
    segmentedText: { fontSize: 13, fontWeight: '600' },
    langRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 14,
        paddingVertical: 14,
    },
    langLabel: { fontSize: 15 },
    footer: { textAlign: 'center', fontSize: 12, marginTop: 24, lineHeight: 18 },
});
