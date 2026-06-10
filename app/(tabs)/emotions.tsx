// Emotion Logger — cloud-synced via CloudEmotionRepository
// Falls back to local store when offline / unauthenticated (no data loss).

import { useState, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Pressable,
    TextInput,
    RefreshControl,
    ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useAuth } from '../../src/presentation/contexts/AuthContext';
import { useTheme } from '../../src/presentation/theme';
import { useAppStore } from '../../src/infrastructure/store';
import { cloudEmotionRepo } from '../../src/infrastructure/supabase/sync';
import { useNafsAttributeByName } from '../../src/data/datasources/hooks';
import { ErrorBanner } from '../../src/presentation/components';
import type { EmotionEntry } from '../../src/domain/entities';
import { v4 as uuidv4 } from 'uuid';

const EMOTION_OPTIONS = [
    { id: 'anger', label: '😤 Anger', color: '#E57373' },
    { id: 'envy', label: '😠 Envy', color: '#BA68C8' },
    { id: 'anxiety', label: '😰 Anxiety', color: '#FFB74D' },
    { id: 'sadness', label: '😢 Sadness', color: '#64B5F6' },
    { id: 'greed', label: '🤑 Greed', color: '#81C784' },
    { id: 'pride', label: '😏 Pride', color: '#F06292' },
    { id: 'frustration', label: '😤 Frustration', color: '#E57373' },
    { id: 'discontent', label: '😒 Discontent', color: '#90A4AE' },
];

const EMOTION_TO_NAFS_NAME: Record<string, string> = {
    anger: 'Ghadab (Anger)',
    envy: 'Hasad (Envy)',
    anxiety: 'Jaza (Chronic Anxiety)',
    sadness: 'Huzn al-Mamduh (Paralyzing Despair)',
    greed: 'Tama (Covetousness)',
    pride: 'Kibr (Arrogance)',
    frustration: 'Ghadab (Anger)',
    discontent: 'Malal (Spiritual Boredom)',
};

export default function EmotionsScreen() {
    const theme = useTheme();
    const { status } = useAuth();
    const qc = useQueryClient();
    const addEmotion = useAppStore((s) => s.addEmotion);
    const localRecent = useAppStore((s) => s.recentEmotions);

    const [selectedEmotion, setSelectedEmotion] = useState<string | null>(null);
    const [intensity, setIntensity] = useState<1 | 2 | 3 | 4 | 5>(3);
    const [trigger, setTrigger] = useState('');
    const [notes, setNotes] = useState('');
    const [showSuccess, setShowSuccess] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const [submitError, setSubmitError] = useState<string | null>(null);

    const nafsName = selectedEmotion ? (EMOTION_TO_NAFS_NAME[selectedEmotion] ?? '') : '';
    const { data: nafsAttribute } = useNafsAttributeByName(nafsName);

    // Cloud history (falls back to local when unauthenticated)
    const historyQ = useQuery({
        queryKey: ['emotions', 'history', status],
        queryFn: () => cloudEmotionRepo.getEmotionHistory({ limit: 20 }),
        enabled: status === 'authenticated',
    });

    const recentEmotions: EmotionEntry[] = status === 'authenticated' ? historyQ.data ?? [] : localRecent;

    const handleLogEmotion = useCallback(async () => {
        if (!selectedEmotion) return;
        setSubmitError(null);
        setSubmitting(true);
        try {
            const entry = {
                emotion: selectedEmotion,
                intensity,
                trigger,
                mappedTrait: nafsName,
                oppositeTrait: nafsAttribute?.opposite_to ?? 'Patience',
                timestamp: new Date(),
                notes,
            };
            // Always update local store first (optimistic) for instant feedback
            const optimistic: EmotionEntry = { id: uuidv4(), ...entry };
            addEmotion(optimistic);

            if (status === 'authenticated') {
                await cloudEmotionRepo.logEmotion(entry);
                qc.invalidateQueries({ queryKey: ['emotions'] });
            }

            setShowSuccess(true);
            setSelectedEmotion(null);
            setIntensity(3);
            setTrigger('');
            setNotes('');
            setTimeout(() => setShowSuccess(false), 3000);
        } catch (e) {
            setSubmitError(e instanceof Error ? e.message : 'Failed to log emotion.');
        } finally {
            setSubmitting(false);
        }
    }, [selectedEmotion, intensity, trigger, notes, nafsName, nafsAttribute, addEmotion, status, qc]);

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
                    <Text style={[styles.title, { color: theme.colors.text }]}>How are you feeling?</Text>
                    <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
                        Identify your emotion to find the right remedy
                    </Text>
                </View>

                {showSuccess && (
                    <View
                        style={[
                            styles.successBanner,
                            { backgroundColor: theme.colors.success + '20', borderLeftColor: theme.colors.success },
                        ]}
                    >
                        <Text style={[styles.successText, { color: theme.colors.success }]}>
                            ✅ Emotion logged! Check the Toolkit for guidance.
                        </Text>
                    </View>
                )}

                {submitError && <ErrorBanner message={submitError} />}

                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Select your emotion</Text>
                    <View style={styles.emotionGrid}>
                        {EMOTION_OPTIONS.map((emotion) => (
                            <Pressable
                                key={emotion.id}
                                style={[
                                    styles.emotionCard,
                                    {
                                        backgroundColor: theme.colors.surface,
                                        borderColor: selectedEmotion === emotion.id ? emotion.color : 'transparent',
                                    },
                                ]}
                                onPress={() => setSelectedEmotion(emotion.id)}
                                accessibilityRole="button"
                                accessibilityLabel={emotion.label}
                                accessibilityState={{ selected: selectedEmotion === emotion.id }}
                            >
                                <Text style={[styles.emotionLabel, { color: theme.colors.text }]}>
                                    {emotion.label}
                                </Text>
                            </Pressable>
                        ))}
                    </View>
                </View>

                {selectedEmotion && (
                    <>
                        <View style={styles.section}>
                            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Intensity (1-5)</Text>
                            <View
                                style={[
                                    styles.intensityContainer,
                                    { backgroundColor: theme.colors.surface },
                                ]}
                            >
                                {([1, 2, 3, 4, 5] as const).map((level) => (
                                    <Pressable
                                        key={level}
                                        style={[
                                            styles.intensityButton,
                                            { backgroundColor: theme.colors.background },
                                            intensity === level && { backgroundColor: theme.colors.primary },
                                        ]}
                                        onPress={() => setIntensity(level)}
                                        accessibilityRole="button"
                                        accessibilityLabel={`Intensity ${level}`}
                                        accessibilityState={{ selected: intensity === level }}
                                    >
                                        <Text
                                            style={[
                                                styles.intensityText,
                                                { color: intensity === level ? '#FFF' : theme.colors.textSecondary },
                                            ]}
                                        >
                                            {level}
                                        </Text>
                                    </Pressable>
                                ))}
                            </View>
                            <Text style={[styles.intensityHint, { color: theme.colors.textSecondary }]}>
                                {intensity <= 2
                                    ? 'Mild - Easily manageable'
                                    : intensity <= 4
                                        ? 'Moderate - Needs attention'
                                        : 'High - Urgent self-care needed'}
                            </Text>
                        </View>

                        <View style={styles.section}>
                            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>What triggered this?</Text>
                            <TextInput
                                style={[
                                    styles.textInput,
                                    {
                                        backgroundColor: theme.colors.surface,
                                        borderColor: theme.colors.border,
                                        color: theme.colors.text,
                                    },
                                ]}
                                placeholder="e.g., Got cut off in traffic…"
                                placeholderTextColor={theme.colors.textSecondary}
                                value={trigger}
                                onChangeText={setTrigger}
                                multiline
                                numberOfLines={2}
                            />
                        </View>

                        <View style={styles.section}>
                            <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Additional thoughts</Text>
                            <TextInput
                                style={[
                                    styles.textInput,
                                    styles.textArea,
                                    {
                                        backgroundColor: theme.colors.surface,
                                        borderColor: theme.colors.border,
                                        color: theme.colors.text,
                                    },
                                ]}
                                placeholder="Any other details…"
                                placeholderTextColor={theme.colors.textSecondary}
                                value={notes}
                                onChangeText={setNotes}
                                multiline
                                numberOfLines={4}
                            />
                        </View>

                        <Pressable
                            style={[
                                styles.submitButton,
                                { backgroundColor: theme.colors.primary },
                                submitting && styles.submitDisabled,
                            ]}
                            onPress={handleLogEmotion}
                            disabled={submitting}
                            accessibilityRole="button"
                            accessibilityLabel="Log emotion and get guidance"
                        >
                            {submitting ? (
                                <ActivityIndicator color="#FFF" />
                            ) : (
                                <Text style={styles.submitText}>
                                    {status === 'authenticated' ? 'Log & Sync' : 'Log Locally'}
                                </Text>
                            )}
                        </Pressable>
                    </>
                )}

                {recentEmotions.length > 0 && (
                    <View style={styles.section}>
                        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Recent Emotions</Text>
                        {recentEmotions.slice(0, 5).map((emotion) => (
                            <View
                                key={emotion.id}
                                style={[
                                    styles.recentCard,
                                    { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                                ]}
                            >
                                <View style={styles.recentHeader}>
                                    <Text style={[styles.recentEmotion, { color: theme.colors.text }]}>
                                        {emotion.emotion}
                                    </Text>
                                    <Text style={[styles.recentTime, { color: theme.colors.textSecondary }]}>
                                        {new Date(emotion.timestamp).toLocaleDateString()}
                                    </Text>
                                </View>
                                <Text style={[styles.recentTrigger, { color: theme.colors.textSecondary }]}>
                                    {emotion.trigger || 'No trigger recorded'}
                                </Text>
                            </View>
                        ))}
                    </View>
                )}
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { paddingHorizontal: 20, paddingTop: 16, paddingBottom: 8 },
    title: { fontSize: 24, fontWeight: '700' },
    subtitle: { fontSize: 14, marginTop: 4 },
    successBanner: {
        marginHorizontal: 16,
        marginTop: 8,
        padding: 12,
        borderRadius: 8,
        borderLeftWidth: 4,
    },
    successText: { fontWeight: '500' },
    section: { paddingHorizontal: 16, marginTop: 20 },
    sectionTitle: { fontSize: 16, fontWeight: '600', marginBottom: 12 },
    emotionGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
    emotionCard: {
        width: '47%',
        paddingVertical: 16,
        paddingHorizontal: 12,
        borderRadius: 12,
        borderWidth: 2,
        alignItems: 'center',
    },
    emotionLabel: { fontSize: 16, fontWeight: '500' },
    intensityContainer: { flexDirection: 'row', justifyContent: 'space-around', borderRadius: 12, padding: 8 },
    intensityButton: { width: 50, height: 50, borderRadius: 25, justifyContent: 'center', alignItems: 'center' },
    intensityText: { fontSize: 18, fontWeight: '600' },
    intensityHint: { textAlign: 'center', fontSize: 12, marginTop: 8 },
    textInput: { borderRadius: 12, padding: 16, fontSize: 16, borderWidth: 1 },
    textArea: { height: 100, textAlignVertical: 'top' },
    submitButton: {
        marginHorizontal: 16,
        marginTop: 24,
        marginBottom: 32,
        paddingVertical: 16,
        borderRadius: 12,
        alignItems: 'center',
    },
    submitDisabled: { opacity: 0.6 },
    submitText: { color: '#FFF', fontSize: 16, fontWeight: '600' },
    recentCard: { borderRadius: 12, padding: 16, marginBottom: 10, borderWidth: 1 },
    recentHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 4 },
    recentEmotion: { fontSize: 14, fontWeight: '600', textTransform: 'capitalize' },
    recentTime: { fontSize: 12 },
    recentTrigger: { fontSize: 13 },
});
