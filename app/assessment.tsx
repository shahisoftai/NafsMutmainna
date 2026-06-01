// Nafs Self-Assessment Screen — app/assessment.tsx
// Presents 100 negative traits as a questionnaire (5-point Likert scale).
// Grouped by domain; scores each domain after completion.

import { useState, useMemo } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Pressable,
    ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useNafsAttributesByCategory } from '../src/data/datasources/hooks';
import { COLORS } from '../src/shared/constants';
import type { NafsAttribute } from '../src/domain/entities';

const LIKERT_LABELS: Record<number, string> = {
    1: 'Never',
    2: 'Rarely',
    3: 'Sometimes',
    4: 'Often',
    5: 'Always',
};

/** Infer domain from trait name prefix patterns */
function inferDomain(name: string): string {
    const n = name.toLowerCase();
    if (n.includes('kibr') || n.includes('ujb') || n.includes('takabbur') || n.includes('nifaq') || n.includes('riya')) return 'Spiritual Core';
    if (n.includes('ghadab') || n.includes('hasad') || n.includes('huzn') || n.includes('jaza') || n.includes('malal') || n.includes('khawf')) return 'Emotional';
    if (n.includes('ghibah') || n.includes('namima') || n.includes('bughd') || n.includes('zulm') || n.includes('ifsad')) return 'Social';
    if (n.includes('jahl') || n.includes('ghurur') || n.includes('wahm') || n.includes('ta\'assub')) return 'Cognitive';
    return 'Behavioral';
}

type Answers = Record<string, number>; // traitId → 1-5

export default function AssessmentScreen() {
    const router = useRouter();
    const { data: negativeTraits, isLoading } = useNafsAttributesByCategory('negative');

    const [currentIndex, setCurrentIndex] = useState(0);
    const [answers, setAnswers] = useState<Answers>({});
    const [done, setDone] = useState(false);

    const traits = negativeTraits ?? [];
    const current = traits[currentIndex];

    const handleAnswer = (score: number) => {
        const updated = { ...answers, [current.id]: score };
        setAnswers(updated);

        if (currentIndex < traits.length - 1) {
            setCurrentIndex((i) => i + 1);
        } else {
            setDone(true);
        }
    };

    const handleBack = () => {
        if (currentIndex > 0) setCurrentIndex((i) => i - 1);
    };

    const domainScores = useMemo(() => {
        if (!done || traits.length === 0) return {};

        const counts: Record<string, { total: number; count: number }> = {};
        traits.forEach((t) => {
            const domain = inferDomain(t.name);
            const score = answers[t.id] ?? 0;
            if (!counts[domain]) counts[domain] = { total: 0, count: 0 };
            counts[domain].total += score;
            counts[domain].count += 1;
        });

        const result: Record<string, number> = {};
        for (const [domain, { total, count }] of Object.entries(counts)) {
            result[domain] = Math.round((total / (count * 5)) * 100);
        }
        return result;
    }, [done, traits, answers]);

    if (isLoading) {
        return (
            <SafeAreaView style={styles.container}>
                <ActivityIndicator size="large" color={COLORS.primary} style={{ marginTop: 60 }} />
                <Text style={styles.loadingText}>Loading assessment…</Text>
            </SafeAreaView>
        );
    }

    if (done) {
        return (
            <SafeAreaView style={styles.container} edges={['top']}>
                <ScrollView contentContainerStyle={styles.resultContent}>
                    <Text style={styles.resultTitle}>Your Nafs Assessment</Text>
                    <Text style={styles.resultSubtitle}>
                        Domain scores below reflect your self-reported tendency toward each category of negative traits.
                        Higher scores indicate more area for growth.
                    </Text>

                    {Object.entries(domainScores)
                        .sort((a, b) => b[1] - a[1])
                        .map(([domain, score]) => (
                            <View key={domain} style={styles.domainCard}>
                                <View style={styles.domainHeader}>
                                    <Text style={styles.domainName}>{domain}</Text>
                                    <Text style={styles.domainScore}>{score}%</Text>
                                </View>
                                <View style={styles.barTrack}>
                                    <View
                                        style={[
                                            styles.barFill,
                                            {
                                                width: `${score}%` as any,
                                                backgroundColor: score > 60 ? '#E57373' : score > 30 ? '#FFB74D' : '#81C784',
                                            },
                                        ]}
                                    />
                                </View>
                                <Text style={styles.domainHint}>
                                    {score > 60
                                        ? 'Significant area for tazkiyah'
                                        : score > 30
                                            ? 'Moderate — mindful attention needed'
                                            : 'Relatively sound — keep nurturing'}
                                </Text>
                            </View>
                        ))}

                    <Pressable style={styles.doneButton} onPress={() => router.back()}>
                        <Text style={styles.doneButtonText}>Back to Home</Text>
                    </Pressable>
                </ScrollView>
            </SafeAreaView>
        );
    }

    if (!current) return null;

    const progress = traits.length > 0 ? (currentIndex / traits.length) * 100 : 0;

    return (
        <SafeAreaView style={styles.container} edges={['top']}>
            {/* Progress bar */}
            <View style={styles.progressTrack}>
                <View style={[styles.progressFill, { width: `${progress}%` as any }]} />
            </View>

            <ScrollView contentContainerStyle={styles.questionContent}>
                {/* Counter */}
                <Text style={styles.counter}>
                    {currentIndex + 1} / {traits.length}
                </Text>

                {/* Trait name */}
                <Text style={styles.traitName}>{current.name}</Text>

                {/* Question */}
                <Text style={styles.question}>How often do you experience or exhibit this tendency?</Text>

                {/* Description for context */}
                <View style={styles.descriptionBox}>
                    <Text style={styles.descriptionText}>{current.description}</Text>
                </View>

                {/* Likert options */}
                <View style={styles.options}>
                    {([1, 2, 3, 4, 5] as const).map((score) => {
                        const selected = answers[current.id] === score;
                        return (
                            <Pressable
                                key={score}
                                style={[styles.optionButton, selected && styles.optionButtonSelected]}
                                onPress={() => handleAnswer(score)}
                            >
                                <Text style={[styles.optionScore, selected && styles.optionScoreSelected]}>
                                    {score}
                                </Text>
                                <Text style={[styles.optionLabel, selected && styles.optionLabelSelected]}>
                                    {LIKERT_LABELS[score]}
                                </Text>
                            </Pressable>
                        );
                    })}
                </View>

                {/* Back nav */}
                {currentIndex > 0 && (
                    <Pressable style={styles.backButton} onPress={handleBack}>
                        <Text style={styles.backButtonText}>← Previous</Text>
                    </Pressable>
                )}
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    loadingText: {
        textAlign: 'center',
        marginTop: 12,
        color: COLORS.textSecondary,
        fontSize: 15,
    },
    progressTrack: {
        height: 4,
        backgroundColor: COLORS.surface,
    },
    progressFill: {
        height: 4,
        backgroundColor: COLORS.primary,
    },
    questionContent: {
        paddingHorizontal: 20,
        paddingTop: 20,
        paddingBottom: 40,
        gap: 16,
    },
    counter: {
        fontSize: 13,
        color: COLORS.textSecondary,
        fontWeight: '600',
    },
    traitName: {
        fontSize: 22,
        fontWeight: '700',
        color: COLORS.text,
        lineHeight: 30,
    },
    question: {
        fontSize: 16,
        color: COLORS.textSecondary,
        lineHeight: 24,
    },
    descriptionBox: {
        backgroundColor: COLORS.surface,
        borderRadius: 10,
        padding: 14,
    },
    descriptionText: {
        fontSize: 14,
        color: COLORS.text,
        lineHeight: 22,
    },
    options: {
        gap: 10,
        marginTop: 4,
    },
    optionButton: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 14,
        backgroundColor: COLORS.surface,
        borderRadius: 10,
        paddingVertical: 14,
        paddingHorizontal: 16,
        borderWidth: 2,
        borderColor: 'transparent',
    },
    optionButtonSelected: {
        borderColor: COLORS.primary,
        backgroundColor: COLORS.primary + '15',
    },
    optionScore: {
        fontSize: 18,
        fontWeight: '700',
        color: COLORS.textSecondary,
        width: 24,
        textAlign: 'center',
    },
    optionScoreSelected: {
        color: COLORS.primary,
    },
    optionLabel: {
        fontSize: 15,
        color: COLORS.text,
    },
    optionLabelSelected: {
        color: COLORS.primary,
        fontWeight: '600',
    },
    backButton: {
        alignSelf: 'flex-start',
        paddingVertical: 10,
        marginTop: 4,
    },
    backButtonText: {
        fontSize: 15,
        color: COLORS.primary,
        fontWeight: '500',
    },
    // Results
    resultContent: {
        paddingHorizontal: 20,
        paddingTop: 32,
        paddingBottom: 40,
        gap: 16,
    },
    resultTitle: {
        fontSize: 26,
        fontWeight: '700',
        color: COLORS.text,
    },
    resultSubtitle: {
        fontSize: 14,
        color: COLORS.textSecondary,
        lineHeight: 22,
    },
    domainCard: {
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        padding: 16,
        gap: 8,
    },
    domainHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    domainName: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text,
    },
    domainScore: {
        fontSize: 16,
        fontWeight: '700',
        color: COLORS.text,
    },
    barTrack: {
        height: 8,
        backgroundColor: COLORS.background,
        borderRadius: 4,
        overflow: 'hidden',
    },
    barFill: {
        height: 8,
        borderRadius: 4,
    },
    domainHint: {
        fontSize: 13,
        color: COLORS.textSecondary,
    },
    doneButton: {
        backgroundColor: COLORS.primary,
        borderRadius: 12,
        paddingVertical: 16,
        alignItems: 'center',
        marginTop: 8,
    },
    doneButtonText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '700',
    },
});
