// Analytics Screen — 7-day mood chart, stage distribution, top emotions
// SRP: presentational + orchestration of hooks

import { useMemo, useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    RefreshControl,
    Pressable,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '../src/presentation/contexts/AuthContext';
import { useTheme } from '../src/presentation/theme';
import { useAppStore } from '../src/infrastructure/store';
import { cloudCheckinRepo, cloudEmotionRepo } from '../src/infrastructure/supabase/sync';
import { ArabicText, EmptyState, ErrorBanner, SectionHeader } from '../src/presentation/components';
import type { NafsType } from '../src/domain/entities';

type Range = 7 | 14 | 30;

export default function AnalyticsScreen() {
    const router = useRouter();
    const theme = useTheme();
    const { status } = useAuth();
    const nafsState = useAppStore((s) => s.nafsState);
    const [range, setRange] = useState<Range>(7);

    const checkinsQ = useQuery({
        queryKey: ['analytics', 'checkins', range],
        queryFn: () => cloudCheckinRepo.getRecent(range),
        enabled: status === 'authenticated',
    });

    const emotionsQ = useQuery({
        queryKey: ['analytics', 'emotions', range],
        queryFn: () => cloudEmotionRepo.getEmotionHistory({ limit: 100 }),
        enabled: status === 'authenticated',
    });

    const moodsByDay = useMemo(() => buildMoodSeries(checkinsQ.data ?? [], range), [checkinsQ.data, range]);
    const stageDistribution = useMemo(() => buildStageDistribution(checkinsQ.data ?? []), [checkinsQ.data]);
    const topEmotions = useMemo(() => buildTopEmotions(emotionsQ.data ?? []), [emotionsQ.data]);
    const averageMood = useMemo(() => {
        const m = moodsByDay.filter((d) => d.mood != null);
        if (m.length === 0) return null;
        return m.reduce((s, d) => s + (d.mood ?? 0), 0) / m.length;
    }, [moodsByDay]);

    const isLoading = checkinsQ.isLoading || emotionsQ.isLoading;
    const error = checkinsQ.error || emotionsQ.error;

    if (status === 'unauthenticated') {
        return (
            <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]}>
                <EmptyState
                    icon="🔒"
                    title="Sign in to view insights"
                    description="Your spiritual analytics sync across devices when you're signed in."
                />
            </SafeAreaView>
        );
    }

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <View style={styles.headerRow}>
                <Pressable
                    onPress={() => router.back()}
                    style={styles.backBtn}
                    accessibilityRole="button"
                    accessibilityLabel="Go back"
                    hitSlop={10}
                >
                    <Ionicons name="arrow-back" size={22} color={theme.colors.text} />
                </Pressable>
                <Text style={[styles.title, { color: theme.colors.text }]}>Analytics</Text>
                <View style={{ width: 32 }} />
            </View>

            <ScrollView
                contentContainerStyle={styles.scroll}
                showsVerticalScrollIndicator={false}
                refreshControl={
                    <RefreshControl
                        refreshing={isLoading}
                        onRefresh={() => {
                            checkinsQ.refetch();
                            emotionsQ.refetch();
                        }}
                        tintColor={theme.colors.primary}
                    />
                }
            >
                {error && <ErrorBanner message="Couldn't load some data. Pull to retry." />}

                {/* Range selector */}
                <View style={[styles.rangeRow, { backgroundColor: theme.colors.surface }]}>
                    {([7, 14, 30] as Range[]).map((r) => (
                        <Pressable
                            key={r}
                            onPress={() => setRange(r)}
                            style={[
                                styles.rangePill,
                                range === r && { backgroundColor: theme.colors.primary },
                            ]}
                            accessibilityRole="button"
                            accessibilityLabel={`Show last ${r} days`}
                            accessibilityState={{ selected: range === r }}
                        >
                            <Text
                                style={[
                                    styles.rangeText,
                                    { color: range === r ? '#FFF' : theme.colors.textSecondary },
                                ]}
                            >
                                {r} days
                            </Text>
                        </Pressable>
                    ))}
                </View>

                {/* Summary stats */}
                <View style={styles.statsRow}>
                    <StatCard
                        icon="🔥"
                        label="Avg Mood"
                        value={averageMood ? averageMood.toFixed(1) : '—'}
                        sub={averageMood ? moodLabel(averageMood) : 'No data yet'}
                        theme={theme}
                    />
                    <StatCard
                        icon="📝"
                        label="Check-ins"
                        value={String(checkinsQ.data?.length ?? 0)}
                        sub={`last ${range}d`}
                        theme={theme}
                    />
                </View>

                {/* Mood chart */}
                <SectionHeader
                    title="Mood Trend"
                    subtitle={`Last ${range} days`}
                />
                <View style={[styles.chartCard, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    {moodsByDay.every((d) => d.mood == null) ? (
                        <EmptyState
                            icon="📊"
                            title="No check-ins yet"
                            description="Complete a daily check-in to see your mood trend."
                        />
                    ) : (
                        <MoodChart data={moodsByDay} theme={theme} />
                    )}
                </View>

                {/* Stage distribution */}
                <SectionHeader title="Nafs Stage Distribution" />
                <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    {(['ammarah', 'lawwamah', 'mutmainna'] as NafsType[]).map((stage) => {
                        const pct = stageDistribution[stage] ?? 0;
                        return (
                            <View key={stage} style={styles.barRow}>
                                <Text style={[styles.barLabel, { color: theme.colors.text }]}>
                                    {stage.charAt(0).toUpperCase() + stage.slice(1)}
                                </Text>
                                <View style={[styles.barTrack, { backgroundColor: theme.colors.background }]}>
                                    <View
                                        style={[
                                            styles.barFill,
                                            {
                                                width: `${pct}%`,
                                                backgroundColor:
                                                    stage === 'ammarah'
                                                        ? theme.colors.ammarah
                                                        : stage === 'lawwamah'
                                                            ? theme.colors.lawwamah
                                                            : theme.colors.mutmainna,
                                            },
                                        ]}
                                    />
                                </View>
                                <Text style={[styles.barPct, { color: theme.colors.textSecondary }]}>
                                    {pct}%
                                </Text>
                            </View>
                        );
                    })}
                    {nafsState ? (
                        <Text style={[styles.currentStage, { color: theme.colors.textSecondary }]}>
                            Current: {nafsState.type.charAt(0).toUpperCase() + nafsState.type.slice(1)} • Score {nafsState.score}
                        </Text>
                    ) : null}
                </View>

                {/* Top emotions */}
                <SectionHeader title="Top Emotions" />
                <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
                    {topEmotions.length === 0 ? (
                        <Text style={[styles.emptyText, { color: theme.colors.textSecondary }]}>
                            No emotions logged in this range.
                        </Text>
                    ) : (
                        topEmotions.map(([emotion, count], i) => (
                            <View key={emotion} style={styles.emotionRow}>
                                <Text style={[styles.emotionRank, { color: theme.colors.primary }]}>
                                    #{i + 1}
                                </Text>
                                <Text style={[styles.emotionName, { color: theme.colors.text }]}>
                                    {emotion}
                                </Text>
                                <Text style={[styles.emotionCount, { color: theme.colors.textSecondary }]}>
                                    {count}×
                                </Text>
                            </View>
                        ))
                    )}
                </View>

                <ArabicText text="إِنَّ اللَّهَ مَعَ الصَّابِرِينَ" style={styles.dua} />
            </ScrollView>
        </SafeAreaView>
    );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

interface MoodPoint {
    date: string;
    mood: number | null;
    stage: NafsType | null;
}

function buildMoodSeries(checkins: { checkinDate: string; mood: number; nafsStage: NafsType }[], days: number): MoodPoint[] {
    const map = new Map<string, MoodPoint>();
    for (let i = days - 1; i >= 0; i--) {
        const d = new Date(Date.now() - i * 86400000).toISOString().split('T')[0];
        map.set(d, { date: d, mood: null, stage: null });
    }
    for (const c of checkins) {
        if (map.has(c.checkinDate)) {
            map.set(c.checkinDate, { date: c.checkinDate, mood: c.mood, stage: c.nafsStage });
        }
    }
    return Array.from(map.values());
}

function buildStageDistribution(checkins: { nafsStage: NafsType }[]): Record<NafsType, number> {
    const counts: Record<NafsType, number> = { ammarah: 0, lawwamah: 0, mutmainna: 0 };
    if (checkins.length === 0) return { ammarah: 0, lawwamah: 0, mutmainna: 0 };
    for (const c of checkins) counts[c.nafsStage] = (counts[c.nafsStage] ?? 0) + 1;
    const total = checkins.length;
    return {
        ammarah: Math.round((counts.ammarah / total) * 100),
        lawwamah: Math.round((counts.lawwamah / total) * 100),
        mutmainna: Math.round((counts.mutmainna / total) * 100),
    };
}

function buildTopEmotions(emotions: { emotion: string }[]): [string, number][] {
    const counts: Record<string, number> = {};
    for (const e of emotions) counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
    return Object.entries(counts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5);
}

function moodLabel(mood: number): string {
    if (mood >= 4.5) return 'Excellent';
    if (mood >= 3.5) return 'Good';
    if (mood >= 2.5) return 'Steady';
    if (mood >= 1.5) return 'Low';
    return 'Struggling';
}

// ─── Sub-components ───────────────────────────────────────────────────────────

const StatCard: React.FC<{
    icon: string;
    label: string;
    value: string;
    sub: string;
    theme: ReturnType<typeof useTheme>;
}> = ({ icon, label, value, sub, theme }) => (
    <View
        style={[
            styles.statCard,
            { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
        ]}
    >
        <Text style={styles.statIcon}>{icon}</Text>
        <Text style={[styles.statValue, { color: theme.colors.text }]}>{value}</Text>
        <Text style={[styles.statLabel, { color: theme.colors.textSecondary }]}>{label}</Text>
        <Text style={[styles.statSub, { color: theme.colors.textSecondary }]}>{sub}</Text>
    </View>
);

const MoodChart: React.FC<{ data: MoodPoint[]; theme: ReturnType<typeof useTheme> }> = ({ data, theme }) => {
    const max = 5;
    return (
        <View style={styles.chartInner}>
            <View style={styles.chartArea}>
                {data.map((d, i) => {
                    const h = d.mood ? (d.mood / max) * 120 : 4;
                    const color = d.mood
                        ? d.mood >= 4
                            ? theme.colors.mutmainna
                            : d.mood >= 3
                                ? theme.colors.lawwamah
                                : theme.colors.ammarah
                        : theme.colors.border;
                    return (
                        <View key={i} style={styles.barColumn}>
                            <View
                                style={[
                                    styles.chartBar,
                                    { height: h, backgroundColor: color },
                                ]}
                            />
                        </View>
                    );
                })}
            </View>
            <View style={styles.chartLabels}>
                {data.map((d, i) => (
                    <Text
                        key={i}
                        style={[styles.chartLabel, { color: theme.colors.textSecondary }]}
                    >
                        {d.date.slice(8)}
                    </Text>
                ))}
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1 },
    headerRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: 12,
    },
    backBtn: { padding: 6 },
    title: { fontSize: 18, fontWeight: '700' },
    scroll: { paddingHorizontal: 16, paddingBottom: 40, gap: 8 },
    rangeRow: {
        flexDirection: 'row',
        borderRadius: 10,
        padding: 4,
        marginVertical: 8,
    },
    rangePill: { flex: 1, paddingVertical: 8, borderRadius: 8, alignItems: 'center' },
    rangeText: { fontSize: 13, fontWeight: '600' },
    statsRow: { flexDirection: 'row', gap: 12, marginBottom: 8 },
    statCard: {
        flex: 1,
        borderRadius: 12,
        padding: 16,
        borderWidth: 1,
        alignItems: 'center',
    },
    statIcon: { fontSize: 24, marginBottom: 4 },
    statValue: { fontSize: 24, fontWeight: '800' },
    statLabel: { fontSize: 12, fontWeight: '600', marginTop: 2 },
    statSub: { fontSize: 11, marginTop: 2 },
    chartCard: { borderRadius: 12, padding: 16, borderWidth: 1 },
    chartInner: { gap: 6 },
    chartArea: { flexDirection: 'row', alignItems: 'flex-end', height: 130, gap: 4 },
    barColumn: { flex: 1, justifyContent: 'flex-end', alignItems: 'center' },
    chartBar: { width: '70%', borderTopLeftRadius: 3, borderTopRightRadius: 3, minHeight: 4 },
    chartLabels: { flexDirection: 'row', gap: 4 },
    chartLabel: { flex: 1, fontSize: 10, textAlign: 'center' },
    card: { borderRadius: 12, padding: 16, borderWidth: 1, gap: 10 },
    barRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
    barLabel: { width: 80, fontSize: 12, fontWeight: '600' },
    barTrack: { flex: 1, height: 8, borderRadius: 4, overflow: 'hidden' },
    barFill: { height: 8, borderRadius: 4 },
    barPct: { width: 40, fontSize: 12, textAlign: 'right' },
    currentStage: { fontSize: 12, marginTop: 8, textAlign: 'center', fontStyle: 'italic' },
    emotionRow: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
        paddingVertical: 4,
    },
    emotionRank: { fontSize: 14, fontWeight: '700', width: 30 },
    emotionName: { flex: 1, fontSize: 14, textTransform: 'capitalize' },
    emotionCount: { fontSize: 13, fontWeight: '600' },
    emptyText: { textAlign: 'center', paddingVertical: 16, fontSize: 13 },
    dua: { textAlign: 'center', marginTop: 24 },
});
