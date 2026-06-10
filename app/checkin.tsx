// Daily Check-in Modal — mood (1-5) + Nafs stage + notes → daily_checkins
// Stored in cloud via CloudCheckinRepository; updates local nafsState too.

import { useState, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Pressable,
    TextInput,
    ActivityIndicator,
    KeyboardAvoidingView,
    Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useQueryClient } from '@tanstack/react-query';
import { useAuth } from '../src/presentation/contexts/AuthContext';
import { useTheme } from '../src/presentation/theme';
import { useAppStore } from '../src/infrastructure/store';
import { cloudCheckinRepo } from '../src/infrastructure/supabase/sync';
import { ErrorBanner } from '../src/presentation/components';
import type { NafsType } from '../src/domain/entities';

const MOODS: { value: 1 | 2 | 3 | 4 | 5; label: string; emoji: string }[] = [
    { value: 1, label: 'Very Hard', emoji: '😔' },
    { value: 2, label: 'Hard', emoji: '😕' },
    { value: 3, label: 'Okay', emoji: '😐' },
    { value: 4, label: 'Good', emoji: '🙂' },
    { value: 5, label: 'Peaceful', emoji: '😊' },
];

const STAGES: { value: NafsType; label: string; color: string }[] = [
    { value: 'ammarah', label: 'Ammarah', color: '#E57373' },
    { value: 'lawwamah', label: 'Lawwamah', color: '#FFB74D' },
    { value: 'mutmainna', label: 'Mutmainna', color: '#81C784' },
];

export default function CheckinScreen() {
    const router = useRouter();
    const theme = useTheme();
    const { status } = useAuth();
    const setNafsState = useAppStore((s) => s.setNafsState);
    const currentNafs = useAppStore((s) => s.nafsState);
    const qc = useQueryClient();

    const [mood, setMood] = useState<1 | 2 | 3 | 4 | 5>(3);
    const [stage, setStage] = useState<NafsType>(currentNafs?.type ?? 'lawwamah');
    const [notes, setNotes] = useState('');
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const handleSave = useCallback(async () => {
        setSaving(true);
        setError(null);
        try {
            await cloudCheckinRepo.submitCheckin({ mood, nafsStage: stage, notes: notes.trim() });
            // Update local nafs score as a mood reflection
            setNafsState({
                id: currentNafs?.id ?? 'local',
                type: stage,
                score: currentNafs?.score ?? 50,
                percentage: currentNafs?.percentage ?? { ammarah: 30, lawwamah: 50, mutmainna: 20 },
                dominantTraits: currentNafs?.dominantTraits ?? [],
                areasForImprovement: currentNafs?.areasForImprovement ?? [],
                lastUpdated: new Date(),
            });
            qc.invalidateQueries({ queryKey: ['analytics'] });
            router.back();
        } catch (e) {
            setError(e instanceof Error ? e.message : 'Failed to save check-in.');
        } finally {
            setSaving(false);
        }
    }, [mood, stage, notes, currentNafs, setNafsState, qc, router]);

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top', 'bottom']}>
            <KeyboardAvoidingView
                style={styles.flex}
                behavior={Platform.OS === 'ios' ? 'padding' : undefined}
            >
                <View style={styles.header}>
                    <Pressable
                        onPress={() => router.back()}
                        style={styles.backBtn}
                        accessibilityRole="button"
                        accessibilityLabel="Close check-in"
                        hitSlop={10}
                    >
                        <Ionicons name="close" size={22} color={theme.colors.text} />
                    </Pressable>
                    <Text style={[styles.title, { color: theme.colors.text }]}>Daily Check-in</Text>
                    <View style={{ width: 32 }} />
                </View>

                <ScrollView
                    contentContainerStyle={styles.scroll}
                    keyboardShouldPersistTaps="handled"
                    showsVerticalScrollIndicator={false}
                >
                    {error && <ErrorBanner message={error} />}

                    <Text style={[styles.intro, { color: theme.colors.textSecondary }]}>
                        How is your heart today? A moment of honest reflection shapes your journey.
                    </Text>

                    {/* Mood */}
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
                        1. How peaceful is your heart?
                    </Text>
                    <View style={styles.moodRow}>
                        {MOODS.map((m) => (
                            <Pressable
                                key={m.value}
                                onPress={() => setMood(m.value)}
                                style={[
                                    styles.moodButton,
                                    { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                                    mood === m.value && { borderColor: theme.colors.primary, backgroundColor: theme.colors.primary + '15' },
                                ]}
                                accessibilityRole="button"
                                accessibilityLabel={`Mood: ${m.label}`}
                                accessibilityState={{ selected: mood === m.value }}
                            >
                                <Text style={styles.moodEmoji}>{m.emoji}</Text>
                                <Text
                                    style={[
                                        styles.moodLabel,
                                        { color: mood === m.value ? theme.colors.primary : theme.colors.textSecondary },
                                    ]}
                                >
                                    {m.label}
                                </Text>
                            </Pressable>
                        ))}
                    </View>

                    {/* Nafs stage */}
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
                        2. Which stage do you feel you are in?
                    </Text>
                    <View style={styles.stageRow}>
                        {STAGES.map((s) => (
                            <Pressable
                                key={s.value}
                                onPress={() => setStage(s.value)}
                                style={[
                                    styles.stageButton,
                                    { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                                    stage === s.value && { borderColor: s.color, backgroundColor: s.color + '20' },
                                ]}
                                accessibilityRole="button"
                                accessibilityLabel={`Stage: ${s.label}`}
                                accessibilityState={{ selected: stage === s.value }}
                            >
                                <View style={[styles.stageDot, { backgroundColor: s.color }]} />
                                <Text style={[styles.stageLabel, { color: theme.colors.text }]}>{s.label}</Text>
                            </Pressable>
                        ))}
                    </View>

                    {/* Notes */}
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>
                        3. Reflection notes (optional)
                    </Text>
                    <TextInput
                        style={[
                            styles.notesInput,
                            {
                                backgroundColor: theme.colors.surface,
                                borderColor: theme.colors.border,
                                color: theme.colors.text,
                            },
                        ]}
                        placeholder="What shaped your mood today? A verse, a moment, a struggle…"
                        placeholderTextColor={theme.colors.textSecondary}
                        value={notes}
                        onChangeText={setNotes}
                        multiline
                        numberOfLines={4}
                        textAlignVertical="top"
                    />

                    <Pressable
                        style={[
                            styles.saveButton,
                            { backgroundColor: theme.colors.primary },
                            (saving || status === 'unauthenticated') && styles.saveDisabled,
                        ]}
                        onPress={handleSave}
                        disabled={saving || status === 'unauthenticated'}
                        accessibilityRole="button"
                        accessibilityLabel="Save daily check-in"
                    >
                        {saving ? (
                            <ActivityIndicator color="#FFF" />
                        ) : (
                            <Text style={styles.saveText}>
                                {status === 'unauthenticated' ? 'Sign in to sync' : 'Save Check-in'}
                            </Text>
                        )}
                    </Pressable>
                </ScrollView>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    flex: { flex: 1 },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: 12,
    },
    backBtn: { padding: 6 },
    title: { fontSize: 18, fontWeight: '700' },
    scroll: { padding: 16, paddingBottom: 40, gap: 8 },
    intro: { fontSize: 14, lineHeight: 22, marginBottom: 16 },
    sectionTitle: { fontSize: 14, fontWeight: '700', marginTop: 16, marginBottom: 10 },
    moodRow: { flexDirection: 'row', gap: 8 },
    moodButton: {
        flex: 1,
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 4,
        borderRadius: 10,
        borderWidth: 2,
    },
    moodEmoji: { fontSize: 24 },
    moodLabel: { fontSize: 11, fontWeight: '600', marginTop: 4, textAlign: 'center' },
    stageRow: { gap: 8 },
    stageButton: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
        paddingVertical: 14,
        paddingHorizontal: 14,
        borderRadius: 10,
        borderWidth: 2,
    },
    stageDot: { width: 14, height: 14, borderRadius: 7 },
    stageLabel: { fontSize: 15, fontWeight: '600' },
    notesInput: {
        borderWidth: 1,
        borderRadius: 10,
        padding: 14,
        fontSize: 14,
        minHeight: 110,
    },
    saveButton: {
        marginTop: 24,
        paddingVertical: 16,
        borderRadius: 12,
        alignItems: 'center',
    },
    saveDisabled: { opacity: 0.5 },
    saveText: { color: '#FFF', fontSize: 16, fontWeight: '700' },
});
