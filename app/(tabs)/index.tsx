// Home Screen - Dashboard with daily content and quick actions
// Updates: streak, today's dhikr, focus traits, settings/profile nav, check-in CTA

import { useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { DAILY_VERSES, DAILY_HADITH, TRAITS } from '../../src/shared/constants';
import { useAppStore, useNafsState, useProgress, useLastSyncedAt } from '../../src/infrastructure/store';
import { useAuth } from '../../src/presentation/contexts/AuthContext';
import { cloudCheckinRepo, cloudEmotionRepo } from '../../src/infrastructure/supabase/sync';
import { useTheme } from '../../src/presentation/theme';
import { useSettingsStore } from '../../src/infrastructure/store/settingsStore';
import { getLocalizedName } from '../../src/shared/i18n/translations';
import { SectionHeader } from '../../src/presentation/components';

export default function HomeScreen() {
    const router = useRouter();
    const theme = useTheme();
    const language = useSettingsStore((s) => s.language);

    const nafsState = useNafsState();
    const progress = useProgress();
    const isOnboarded = useAppStore((s) => s.isOnboarded);
    const activeTraits = useAppStore((s) => s.activeTraits);
    const lastSyncedAt = useLastSyncedAt();
    const setLastSyncedAt = useAppStore((s) => s.setLastSyncedAt);
    const { profile, status } = useAuth();

    // Pull streak from cloud (replaces local-only streak)
    const streakQ = useQuery({
        queryKey: ['home', 'streak'],
        queryFn: () => cloudCheckinRepo.getStreak(),
        enabled: status === 'authenticated',
    });

    // Refresh local progress.streak from cloud result
    useEffect(() => {
        if (streakQ.data && progress) {
            const next = streakQ.data.current;
            if (next !== progress.streak) {
                useAppStore.setState((s) => ({
                    progress: s.progress ? { ...s.progress, streak: next, longestStreak: Math.max(s.progress.longestStreak, streakQ.data!.longest) } : null,
                }));
            }
        }
    }, [streakQ.data, progress]);

    // Today's check-in existence
    const checkinsQ = useQuery({
        queryKey: ['home', 'checkin-today'],
        queryFn: () => cloudCheckinRepo.getRecent(1),
        enabled: status === 'authenticated',
    });
    const hasCheckedInToday = (checkinsQ.data?.[0]?.checkinDate ?? '') === new Date().toISOString().split('T')[0];

    useEffect(() => {
        if (!isOnboarded) router.replace('/onboarding');
    }, [isOnboarded, router]);

    const todaysVerse = DAILY_VERSES[new Date().getDay() % DAILY_VERSES.length];
    const todaysHadith = DAILY_HADITH[new Date().getDay() % DAILY_HADITH.length];
    const displayName = profile?.fullName?.split(' ')[0] ?? 'Seeker';

    const getNafsColor = () => {
        switch (nafsState?.type) {
            case 'mutmainna':
                return theme.colors.mutmainna;
            case 'lawwamah':
                return theme.colors.lawwamah;
            default:
                return theme.colors.ammarah;
        }
    };

    const onRefresh = async () => {
        await Promise.all([streakQ.refetch(), checkinsQ.refetch()]);
        setLastSyncedAt(new Date().toISOString());
    };

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <ScrollView
                showsVerticalScrollIndicator={false}
                refreshControl={
                    <RefreshControl
                        refreshing={streakQ.isFetching || checkinsQ.isFetching}
                        onRefresh={onRefresh}
                        tintColor={theme.colors.primary}
                    />
                }
            >
                {/* Header */}
                <View style={styles.headerRow}>
                    <View style={{ flex: 1 }}>
                        <Text style={[styles.greeting, { color: theme.colors.primary }]}>
                            Assalamu Alaikum, {displayName}
                        </Text>
                        <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
                            How is your Nafs today?
                        </Text>
                        {lastSyncedAt ? (
                            <Text style={[styles.syncHint, { color: theme.colors.textSecondary }]}>
                                Last sync {new Date(lastSyncedAt).toLocaleTimeString()}
                            </Text>
                        ) : null}
                    </View>
                    <Pressable
                        style={styles.iconBtn}
                        onPress={() => router.push('/settings')}
                        accessibilityRole="button"
                        accessibilityLabel="Open settings"
                        hitSlop={8}
                    >
                        <Ionicons name="settings-outline" size={22} color={theme.colors.text} />
                    </Pressable>
                    <Pressable
                        style={styles.iconBtn}
                        onPress={() => router.push('/profile')}
                        accessibilityRole="button"
                        accessibilityLabel="Open profile"
                        hitSlop={8}
                    >
                        <Ionicons name="person-circle-outline" size={24} color={theme.colors.text} />
                    </Pressable>
                </View>

                {/* Streak + Nafs card */}
                <View style={styles.statsRow}>
                    <View
                        style={[
                            styles.streakCard,
                            { backgroundColor: theme.colors.primary, borderColor: theme.colors.primary },
                        ]}
                        accessibilityLabel={`Current streak: ${streakQ.data?.current ?? 0} days`}
                    >
                        <Text style={styles.streakEmoji}>🔥</Text>
                        <Text style={styles.streakValue}>{streakQ.data?.current ?? 0}</Text>
                        <Text style={styles.streakLabel}>Day Streak</Text>
                    </View>
                    <View
                        style={[
                            styles.nafsCard,
                            { backgroundColor: theme.colors.surface, borderLeftColor: getNafsColor(), borderColor: theme.colors.border },
                        ]}
                    >
                        <View style={styles.nafsHeaderRow}>
                            <Text style={[styles.nafsTitle, { color: theme.colors.text }]}>Your Nafs</Text>
                            <View style={[styles.nafsBadge, { backgroundColor: getNafsColor() }]}>
                                <Text style={styles.nafsBadgeText}>
                                    {nafsState?.type === 'mutmainna'
                                        ? 'Mutmainna ✨'
                                        : nafsState?.type === 'lawwamah'
                                            ? 'Lawwamah 🌱'
                                            : 'Ammarah ⚠️'}
                                </Text>
                            </View>
                        </View>
                        <View style={styles.progressContainer}>
                            <View style={[styles.progressBar, { backgroundColor: theme.colors.border }]}>
                                <View
                                    style={[
                                        styles.progressFill,
                                        {
                                            width: `${nafsState?.score ?? 30}%`,
                                            backgroundColor: getNafsColor(),
                                        },
                                    ]}
                                />
                            </View>
                            <Text style={[styles.progressText, { color: theme.colors.textSecondary }]}>
                                {nafsState?.score ?? 30}/100
                            </Text>
                        </View>
                    </View>
                </View>

                {/* Check-in CTA */}
                <Pressable
                    style={[
                        styles.checkinCta,
                        {
                            backgroundColor: hasCheckedInToday ? theme.colors.success : theme.colors.primary,
                        },
                    ]}
                    onPress={() => router.push('/checkin')}
                    accessibilityRole="button"
                    accessibilityLabel={hasCheckedInToday ? 'Update today\'s check-in' : 'Complete daily check-in'}
                >
                    <Ionicons
                        name={hasCheckedInToday ? 'checkmark-circle' : 'leaf-outline'}
                        size={20}
                        color="#FFF"
                    />
                    <Text style={styles.checkinCtaText}>
                        {hasCheckedInToday ? "Today's check-in complete" : 'Complete daily check-in'}
                    </Text>
                </Pressable>

                {/* Focus Traits */}
                {activeTraits.length > 0 && (
                    <>
                        <SectionHeader title="Focus Traits" />
                        <View style={styles.traitRow}>
                            {activeTraits.slice(0, 3).map((t) => {
                                const traitDef = TRAITS.find((x) => x.id === t);
                                if (!traitDef) return null;
                                const localized = getLocalizedName(traitDef.name.replace(/\s*\([^)]*\)/, ''), language);
                                return (
                                    <Pressable
                                        key={t}
                                        style={[
                                            styles.traitChip,
                                            { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                                        ]}
                                        onPress={() => router.push(`/trait/${encodeURIComponent(traitDef.name)}`)}
                                        accessibilityRole="button"
                                        accessibilityLabel={traitDef.name}
                                    >
                                        <Text style={[styles.traitChipText, { color: theme.colors.text }]} numberOfLines={1}>
                                            {traitDef.name.split(' ')[0]}
                                        </Text>
                                        {language !== 'en' && localized !== traitDef.name && (
                                            <Text
                                                style={[
                                                    styles.traitChipLocalized,
                                                    { color: theme.colors.primary },
                                                ]}
                                                numberOfLines={1}
                                            >
                                                {localized}
                                            </Text>
                                        )}
                                    </Pressable>
                                );
                            })}
                            <Pressable
                                style={[styles.traitChip, styles.traitChipMore, { borderColor: theme.colors.primary }]}
                                onPress={() => router.push('/(tabs)/toolkit')}
                                accessibilityRole="button"
                                accessibilityLabel="See all traits"
                            >
                                <Text style={[styles.traitChipMoreText, { color: theme.colors.primary }]}>
                                    All →
                                </Text>
                            </Pressable>
                        </View>
                    </>
                )}

                {/* Daily Content */}
                <SectionHeader title="Today's Reflection" />
                <View
                    style={[
                        styles.contentCard,
                        { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                    ]}
                >
                    <Text style={[styles.contentLabel, { color: theme.colors.primary }]}>📖 Quran</Text>
                    <Text style={[styles.arabicText, { color: theme.colors.primary }]}>{todaysVerse.arabic}</Text>
                    <Text style={[styles.verseRef, { color: theme.colors.accent }]}>
                        Surah {todaysVerse.surah} {todaysVerse.verseNumber}
                    </Text>
                    <Text style={[styles.translation, { color: theme.colors.text }]}>
                        {todaysVerse.translation}
                    </Text>
                    <Text style={[styles.source, { color: theme.colors.textSecondary }]}>
                        — Ibn Kathir Tafsir
                    </Text>
                </View>
                <View
                    style={[
                        styles.contentCard,
                        { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                    ]}
                >
                    <Text style={[styles.contentLabel, { color: theme.colors.primary }]}>📚 Hadith</Text>
                    <Text style={[styles.hadithText, { color: theme.colors.text }]}>{todaysHadith.text}</Text>
                    <Text style={[styles.hadithMeta, { color: theme.colors.textSecondary }]}>
                        Narrated by {todaysHadith.narrator}
                    </Text>
                    <Text style={[styles.hadithGrade, { color: theme.colors.primary }]}>
                        {todaysHadith.book.charAt(0).toUpperCase() + todaysHadith.book.slice(1)} •{' '}
                        {todaysHadith.grade.charAt(0).toUpperCase() + todaysHadith.grade.slice(1)}
                    </Text>
                </View>

                {/* Quick Actions */}
                <SectionHeader title="Quick Actions" />
                <View style={styles.quickActions}>
                    <QuickAction
                        icon="💭"
                        label="Log Feeling"
                        onPress={() => router.push('/emotions')}
                        theme={theme}
                    />
                    <QuickAction
                        icon="📝"
                        label="Journal"
                        onPress={() => router.push('/journal')}
                        theme={theme}
                    />
                    <QuickAction
                        icon="💬"
                        label="AI Coach"
                        onPress={() => router.push('/chat')}
                        theme={theme}
                    />
                </View>

                {/* Analytics link */}
                <Pressable
                    style={[
                        styles.analyticsCta,
                        { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                    ]}
                    onPress={() => router.push('/analytics')}
                    accessibilityRole="button"
                    accessibilityLabel="View analytics"
                >
                    <Ionicons name="analytics-outline" size={20} color={theme.colors.primary} />
                    <Text style={[styles.analyticsText, { color: theme.colors.text }]}>
                        View 7-day insights
                    </Text>
                    <Ionicons name="chevron-forward" size={18} color={theme.colors.textSecondary} />
                </Pressable>
            </ScrollView>
        </SafeAreaView>
    );
}

const QuickAction: React.FC<{
    icon: string;
    label: string;
    onPress: () => void;
    theme: ReturnType<typeof useTheme>;
}> = ({ icon, label, onPress, theme }) => (
    <Pressable
        style={[styles.actionButton, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}
        onPress={onPress}
        accessibilityRole="button"
        accessibilityLabel={label}
    >
        <Text style={styles.actionIcon}>{icon}</Text>
        <Text style={[styles.actionText, { color: theme.colors.text }]}>{label}</Text>
    </Pressable>
);

const styles = StyleSheet.create({
    container: { flex: 1 },
    headerRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingTop: 12,
        paddingBottom: 8,
        gap: 8,
    },
    greeting: { fontSize: 22, fontWeight: '700' },
    subtitle: { fontSize: 14, marginTop: 2 },
    syncHint: { fontSize: 10, marginTop: 2 },
    iconBtn: { padding: 6 },
    statsRow: { flexDirection: 'row', gap: 10, paddingHorizontal: 16, marginTop: 8 },
    streakCard: {
        flex: 1,
        alignItems: 'center',
        padding: 16,
        borderRadius: 16,
        borderWidth: 1,
    },
    streakEmoji: { fontSize: 24 },
    streakValue: { fontSize: 28, fontWeight: '800', color: '#FFF', marginTop: 4 },
    streakLabel: { fontSize: 12, color: '#FFFFFFCC', fontWeight: '600' },
    nafsCard: {
        flex: 1.4,
        padding: 16,
        borderRadius: 16,
        borderLeftWidth: 4,
        borderWidth: 1,
    },
    nafsHeaderRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 },
    nafsTitle: { fontSize: 13, fontWeight: '600' },
    nafsBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 14 },
    nafsBadgeText: { color: '#FFF', fontSize: 10, fontWeight: '700' },
    progressContainer: { flexDirection: 'row', alignItems: 'center', gap: 8 },
    progressBar: { flex: 1, height: 6, borderRadius: 3 },
    progressFill: { height: 6, borderRadius: 3 },
    progressText: { fontSize: 12, fontWeight: '600' },
    checkinCta: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        marginHorizontal: 16,
        marginTop: 12,
        paddingVertical: 14,
        borderRadius: 12,
    },
    checkinCtaText: { color: '#FFF', fontSize: 15, fontWeight: '700' },
    traitRow: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginBottom: 8 },
    traitChip: {
        flex: 1,
        paddingVertical: 10,
        paddingHorizontal: 8,
        borderRadius: 10,
        borderWidth: 1,
        alignItems: 'center',
    },
    traitChipText: { fontSize: 13, fontWeight: '600' },
    traitChipLocalized: { fontSize: 12, marginTop: 2 },
    traitChipMore: { backgroundColor: 'transparent' },
    traitChipMoreText: { fontSize: 13, fontWeight: '700' },
    contentCard: {
        marginHorizontal: 16,
        marginBottom: 12,
        padding: 16,
        borderRadius: 12,
        borderWidth: 1,
    },
    contentLabel: { fontSize: 12, fontWeight: '700', marginBottom: 8 },
    arabicText: { fontSize: 22, lineHeight: 36, textAlign: 'center', marginVertical: 8 },
    verseRef: { fontSize: 12, fontWeight: '600', textAlign: 'center', marginBottom: 8 },
    translation: { fontSize: 14, lineHeight: 22, textAlign: 'center' },
    source: { fontSize: 11, textAlign: 'center', marginTop: 8, fontStyle: 'italic' },
    hadithText: { fontSize: 14, lineHeight: 22, marginBottom: 8 },
    hadithMeta: { fontSize: 12 },
    hadithGrade: { fontSize: 12, fontWeight: '600', marginTop: 4 },
    quickActions: { flexDirection: 'row', justifyContent: 'space-around', paddingHorizontal: 16 },
    actionButton: {
        alignItems: 'center',
        padding: 16,
        borderRadius: 12,
        borderWidth: 1,
        width: 100,
    },
    actionIcon: { fontSize: 26, marginBottom: 8 },
    actionText: { fontSize: 12, fontWeight: '600' },
    analyticsCta: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        marginHorizontal: 16,
        marginTop: 16,
        padding: 14,
        borderRadius: 12,
        borderWidth: 1,
    },
    analyticsText: { flex: 1, fontSize: 14, fontWeight: '600' },
});
