// Muhasabah Journal — cloud-synced with history
// Falls back to local store when offline / unauthenticated.

import { useState, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Pressable,
    TextInput,
    ActivityIndicator,
    RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { v4 as uuidv4 } from 'uuid';
import { JOURNAL_PROMPTS } from '../../src/shared/constants';
import { useAppStore } from '../../src/infrastructure/store';
import { useAuth } from '../../src/presentation/contexts/AuthContext';
import { useTheme } from '../../src/presentation/theme';
import { cloudJournalRepo } from '../../src/infrastructure/supabase/sync';
import { ErrorBanner, SectionHeader } from '../../src/presentation/components';
import type { JournalEntry } from '../../src/domain/entities';

const MOOD_OPTIONS: { value: 1 | 2 | 3 | 4 | 5; label: string; emoji: string }[] = [
    { value: 1, label: 'Very Hard', emoji: '😔' },
    { value: 2, label: 'Hard', emoji: '😕' },
    { value: 3, label: 'Okay', emoji: '😐' },
    { value: 4, label: 'Good', emoji: '🙂' },
    { value: 5, label: 'Peaceful', emoji: '😊' },
];

export default function JournalScreen() {
    const router = useRouter();
    const theme = useTheme();
    const { status } = useAuth();
    const qc = useQueryClient();

    const setTodayJournal = useAppStore((s) => s.setTodayJournal);
    const todayJournal = useAppStore((s) => s.todayJournal);
    const addOdex = useAppStore((s) => s.addOdex);
    const updateStreak = useAppStore((s) => s.updateStreak);

    const today = new Date().toISOString().split('T')[0];
    const isAlreadyJournaled = todayJournal?.date === today;

    const [nafsWin, setNafsWin] = useState(todayJournal?.nafsWin ?? '');
    const [mutmainnaMoment, setMutmainnaMoment] = useState(todayJournal?.mutmainnaMoment ?? '');
    const [gratitude1, setGratitude1] = useState(todayJournal?.gratitude[0] ?? '');
    const [gratitude2, setGratitude2] = useState(todayJournal?.gratitude[1] ?? '');
    const [gratitude3, setGratitude3] = useState(todayJournal?.gratitude[2] ?? '');
    const [mood, setMood] = useState<1 | 2 | 3 | 4 | 5>(todayJournal?.moodRating ?? 3);
    const [saved, setSaved] = useState(false);
    const [saving, setSaving] = useState(false);
    const [saveError, setSaveError] = useState<string | null>(null);

    const historyQ = useQuery({
        queryKey: ['journal', 'history', status],
        queryFn: () => cloudJournalRepo.getEntries({ limit: 30 }),
        enabled: status === 'authenticated',
    });

    const handleSave = useCallback(async () => {
        setSaveError(null);
        setSaving(true);
        try {
            const gratitude = [gratitude1, gratitude2, gratitude3].filter(Boolean);
            const entry: JournalEntry = {
                id: todayJournal?.id ?? uuidv4(),
                date: today,
                nafsWin,
                mutmainnaMoment,
                gratitude,
                moodRating: mood,
                createdAt: todayJournal?.createdAt ?? new Date(),
                updatedAt: new Date(),
            };

            // Optimistic local update
            setTodayJournal(entry);
            addOdex(10);
            updateStreak();

            if (status === 'authenticated') {
                await cloudJournalRepo.saveEntry({
                    date: entry.date,
                    nafsWin: entry.nafsWin,
                    mutmainnaMoment: entry.mutmainnaMoment,
                    gratitude: entry.gratitude,
                    moodRating: entry.moodRating,
                });
                qc.invalidateQueries({ queryKey: ['journal'] });
            }
            setSaved(true);
        } catch (e) {
            setSaveError(e instanceof Error ? e.message : 'Failed to save journal entry.');
        } finally {
            setSaving(false);
        }
    }, [nafsWin, mutmainnaMoment, gratitude1, gratitude2, gratitude3, mood, today, todayJournal, setTodayJournal, addOdex, updateStreak, status, qc]);

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <ScrollView
                showsVerticalScrollIndicator={false}
                keyboardShouldPersistTaps="handled"
                refreshControl={
                    <RefreshControl
                        refreshing={historyQ.isFetching}
                        onRefresh={() => historyQ.refetch()}
                        tintColor={theme.colors.primary}
                    />
                }
            >
                <View style={styles.header}>
                    <View style={{ flex: 1 }}>
                        <Text style={[styles.title, { color: theme.colors.primary }]}>Muhasabah</Text>
                        <Text style={[styles.subtitle, { color: theme.colors.text }]}>Daily Self-Accountability</Text>
                        <Text style={[styles.date, { color: theme.colors.textSecondary }]}>
                            {new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                        </Text>
                    </View>
                    <Pressable
                        onPress={() => router.push('/analytics')}
                        style={styles.iconBtn}
                        accessibilityRole="button"
                        accessibilityLabel="View analytics"
                        hitSlop={8}
                    >
                        <Ionicons name="analytics-outline" size={22} color={theme.colors.text} />
                    </Pressable>
                </View>

                <View style={[styles.quoteBox, { backgroundColor: theme.colors.primary + '12' }]}>
                    <Text style={[styles.quoteText, { color: theme.colors.text }]}>
                        "Hold yourself accountable before you are held accountable."
                    </Text>
                    <Text style={[styles.quoteSource, { color: theme.colors.textSecondary }]}>
                        — Umar ibn al-Khattab ؓ
                    </Text>
                </View>

                {saved && (
                    <View
                        style={[
                            styles.savedBanner,
                            { backgroundColor: theme.colors.success + '15', borderLeftColor: theme.colors.success },
                        ]}
                    >
                        <Text style={[styles.savedText, { color: theme.colors.success }]}>
                            ✅ Muhasabah saved! +10 ODEX earned. Jazakallahu khairan.
                        </Text>
                    </View>
                )}

                {saveError && <ErrorBanner message={saveError} />}

                {/* Mood */}
                <View style={styles.section}>
                    <Text style={[styles.prompt, { color: theme.colors.text }]}>How peaceful was your heart today?</Text>
                    <View style={styles.moodRow}>
                        {MOOD_OPTIONS.map((m) => (
                            <Pressable
                                key={m.value}
                                style={[
                                    styles.moodButton,
                                    { backgroundColor: theme.colors.surface },
                                    mood === m.value && { backgroundColor: theme.colors.primary },
                                ]}
                                onPress={() => setMood(m.value)}
                                accessibilityRole="button"
                                accessibilityLabel={`Mood: ${m.label}`}
                                accessibilityState={{ selected: mood === m.value }}
                            >
                                <Text style={styles.moodEmoji}>{m.emoji}</Text>
                                <Text
                                    style={[
                                        styles.moodLabel,
                                        { color: mood === m.value ? '#FFF' : theme.colors.textSecondary },
                                    ]}
                                >
                                    {m.label}
                                </Text>
                            </Pressable>
                        ))}
                    </View>
                </View>

                {/* Prompt 1 */}
                <View style={styles.section}>
                    <View style={styles.promptHeader}>
                        <Text style={[styles.promptNumber, { color: theme.colors.accent, backgroundColor: theme.colors.accent + '20' }]}>
                            01
                        </Text>
                        <Text style={[styles.prompt, { color: theme.colors.text }]}>{JOURNAL_PROMPTS.nafsWin}</Text>
                    </View>
                    <TextInput
                        style={[
                            styles.textInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        multiline
                        numberOfLines={4}
                        placeholder="Be honest with yourself…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={nafsWin}
                        onChangeText={setNafsWin}
                        textAlignVertical="top"
                    />
                </View>

                {/* Prompt 2 */}
                <View style={styles.section}>
                    <View style={styles.promptHeader}>
                        <Text style={[styles.promptNumber, { color: theme.colors.accent, backgroundColor: theme.colors.accent + '20' }]}>
                            02
                        </Text>
                        <Text style={[styles.prompt, { color: theme.colors.text }]}>{JOURNAL_PROMPTS.mutmainnaMoment}</Text>
                    </View>
                    <TextInput
                        style={[
                            styles.textInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        multiline
                        numberOfLines={4}
                        placeholder="Even small moments count…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={mutmainnaMoment}
                        onChangeText={setMutmainnaMoment}
                        textAlignVertical="top"
                    />
                </View>

                {/* Prompt 3 */}
                <View style={styles.section}>
                    <View style={styles.promptHeader}>
                        <Text style={[styles.promptNumber, { color: theme.colors.accent, backgroundColor: theme.colors.accent + '20' }]}>
                            03
                        </Text>
                        <Text style={[styles.prompt, { color: theme.colors.text }]}>{JOURNAL_PROMPTS.gratitude}</Text>
                    </View>
                    <TextInput
                        style={[
                            styles.textInput,
                            styles.gratitudeInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        placeholder="Blessing 1…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={gratitude1}
                        onChangeText={setGratitude1}
                    />
                    <TextInput
                        style={[
                            styles.textInput,
                            styles.gratitudeInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        placeholder="Blessing 2…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={gratitude2}
                        onChangeText={setGratitude2}
                    />
                    <TextInput
                        style={[
                            styles.textInput,
                            styles.gratitudeInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        placeholder="Blessing 3…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={gratitude3}
                        onChangeText={setGratitude3}
                    />
                    <Text style={[styles.gratitudeHint, { color: theme.colors.textSecondary }]}>
                        "If you are grateful, I will surely increase you in favor." — Surah Ibrahim 14:7
                    </Text>
                </View>

                <Pressable
                    style={[
                        styles.saveButton,
                        { backgroundColor: saved ? theme.colors.success : theme.colors.primary },
                        (saving || saved) && styles.saveDisabled,
                    ]}
                    onPress={handleSave}
                    disabled={saving || saved}
                    accessibilityRole="button"
                    accessibilityLabel={saved ? 'Journal entry saved' : 'Save today\'s muhasabah'}
                >
                    {saving ? (
                        <ActivityIndicator color="#FFF" />
                    ) : (
                        <Text style={styles.saveButtonText}>
                            {saved ? '✓ Muhasabah Complete' : 'Save Today\'s Muhasabah'}
                        </Text>
                    )}
                </Pressable>

                {isAlreadyJournaled && !saved && (
                    <Text style={[styles.alreadyDoneText, { color: theme.colors.textSecondary }]}>
                        You've already journaled today. You can update your entry.
                    </Text>
                )}

                {/* History */}
                {status === 'authenticated' && (historyQ.data?.length ?? 0) > 0 && (
                    <>
                        <SectionHeader title="Past Entries" subtitle={`${historyQ.data?.length} entries`} />
                        <View style={{ paddingHorizontal: 16, paddingBottom: 32, gap: 8 }}>
                            {(historyQ.data ?? []).slice(0, 10).map((entry) => (
                                <View
                                    key={entry.id}
                                    style={[
                                        styles.historyCard,
                                        { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                                    ]}
                                >
                                    <View style={styles.historyHeader}>
                                        <Text style={[styles.historyDate, { color: theme.colors.text }]}>
                                            {new Date(entry.createdAt).toLocaleDateString('en-US', {
                                                month: 'short',
                                                day: 'numeric',
                                                year: 'numeric',
                                            })}
                                        </Text>
                                        <View
                                            style={[
                                                styles.historyMood,
                                                { backgroundColor: theme.colors.primary + '20' },
                                            ]}
                                        >
                                            <Text style={[styles.historyMoodText, { color: theme.colors.primary }]}>
                                                {MOOD_OPTIONS.find((m) => m.value === entry.moodRating)?.emoji}
                                            </Text>
                                        </View>
                                    </View>
                                    {entry.nafsWin ? (
                                        <Text
                                            style={[styles.historySnippet, { color: theme.colors.textSecondary }]}
                                            numberOfLines={2}
                                        >
                                            {entry.nafsWin}
                                        </Text>
                                    ) : null}
                                </View>
                            ))}
                        </View>
                    </>
                )}
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingTop: 16,
        paddingBottom: 4,
        gap: 8,
    },
    iconBtn: { padding: 6 },
    title: { fontSize: 28, fontWeight: '700' },
    subtitle: { fontSize: 16, fontWeight: '500' },
    date: { fontSize: 13, marginTop: 4 },
    quoteBox: { marginHorizontal: 16, marginTop: 16, padding: 16, borderRadius: 12, borderLeftWidth: 3, borderLeftColor: '#C9A227' },
    quoteText: { fontSize: 14, lineHeight: 22, fontStyle: 'italic' },
    quoteSource: { fontSize: 12, marginTop: 6, fontWeight: '600' },
    savedBanner: { marginHorizontal: 16, marginTop: 8, padding: 14, borderRadius: 10, borderLeftWidth: 4 },
    savedText: { fontWeight: '600' },
    section: { paddingHorizontal: 16, marginTop: 24 },
    moodRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 12 },
    moodButton: { alignItems: 'center', paddingVertical: 12, paddingHorizontal: 8, borderRadius: 12, flex: 1, marginHorizontal: 3 },
    moodEmoji: { fontSize: 24 },
    moodLabel: { fontSize: 10, marginTop: 4, fontWeight: '500', textAlign: 'center' },
    promptHeader: { flexDirection: 'row', alignItems: 'flex-start', gap: 10, marginBottom: 10 },
    promptNumber: { fontSize: 11, fontWeight: '700', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 4 },
    prompt: { flex: 1, fontSize: 15, fontWeight: '600', lineHeight: 22 },
    textInput: { borderRadius: 12, padding: 16, fontSize: 14, borderWidth: 1, minHeight: 100 },
    gratitudeInput: { minHeight: 48, marginBottom: 8 },
    gratitudeHint: { fontSize: 12, fontStyle: 'italic', marginTop: 4, textAlign: 'center' },
    saveButton: { marginHorizontal: 16, marginTop: 32, paddingVertical: 18, borderRadius: 14, alignItems: 'center' },
    saveDisabled: { opacity: 0.7 },
    saveButtonText: { color: '#FFF', fontSize: 16, fontWeight: '700' },
    alreadyDoneText: { textAlign: 'center', fontSize: 12, marginTop: 12 },
    historyCard: { borderRadius: 12, padding: 14, borderWidth: 1, gap: 6 },
    historyHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    historyDate: { fontSize: 14, fontWeight: '600' },
    historyMood: { paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
    historyMoodText: { fontSize: 16 },
    historySnippet: { fontSize: 13, lineHeight: 18 },
});
