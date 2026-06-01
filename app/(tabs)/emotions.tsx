// Emotion Logger Screen

import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, TextInput } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS } from '../../src/shared/constants';
import { useAppStore } from '../../src/infrastructure/store';
import { useNafsAttributeByName } from '../../src/data/datasources/hooks';
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

/** Maps emotion IDs to exact nafs_attribute names in Supabase */
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
    const addEmotion = useAppStore((s) => s.addEmotion);
    const recentEmotions = useAppStore((s) => s.recentEmotions);

    const [selectedEmotion, setSelectedEmotion] = useState<string | null>(null);
    const [intensity, setIntensity] = useState<1 | 2 | 3 | 4 | 5>(3);
    const [trigger, setTrigger] = useState('');
    const [notes, setNotes] = useState('');
    const [showSuccess, setShowSuccess] = useState(false);

    // Fetch the matched nafs_attribute from Supabase for the selected emotion
    const nafsName = selectedEmotion ? (EMOTION_TO_NAFS_NAME[selectedEmotion] ?? '') : '';
    const { data: nafsAttribute } = useNafsAttributeByName(nafsName);

    const handleLogEmotion = () => {
        if (!selectedEmotion) return;

        const entry: EmotionEntry = {
            id: uuidv4(),
            emotion: selectedEmotion,
            intensity,
            trigger,
            mappedTrait: nafsName,
            oppositeTrait: nafsAttribute?.opposite_to ?? 'Patience',
            timestamp: new Date(),
            notes,
        };

        addEmotion(entry);
        setShowSuccess(true);
        setSelectedEmotion(null);
        setIntensity(3);
        setTrigger('');
        setNotes('');

        setTimeout(() => setShowSuccess(false), 3000);
    };

    return (
        <SafeAreaView style={styles.container} edges={['top']}>
            <ScrollView showsVerticalScrollIndicator={false}>
                {/* Header */}
                <View style={styles.header}>
                    <Text style={styles.title}>How are you feeling?</Text>
                    <Text style={styles.subtitle}>Identify your emotion to find the right remedy</Text>
                </View>

                {/* Success Message */}
                {showSuccess && (
                    <View style={styles.successBanner}>
                        <Text style={styles.successText}>✅ Emotion logged! Check the Toolkit for guidance.</Text>
                    </View>
                )}

                {/* Emotion Selection */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Select your emotion</Text>
                    <View style={styles.emotionGrid}>
                        {EMOTION_OPTIONS.map((emotion) => (
                            <Pressable
                                key={emotion.id}
                                style={[
                                    styles.emotionCard,
                                    selectedEmotion === emotion.id && { borderColor: emotion.color, borderWidth: 2 },
                                ]}
                                onPress={() => setSelectedEmotion(emotion.id)}
                            >
                                <Text style={styles.emotionLabel}>{emotion.label}</Text>
                            </Pressable>
                        ))}
                    </View>
                </View>

                {/* Intensity Slider */}
                {selectedEmotion && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Intensity (1-5)</Text>
                        <View style={styles.intensityContainer}>
                            {[1, 2, 3, 4, 5].map((level) => (
                                <Pressable
                                    key={level}
                                    style={[
                                        styles.intensityButton,
                                        intensity === level && styles.intensityButtonActive,
                                    ]}
                                    onPress={() => setIntensity(level as 1 | 2 | 3 | 4 | 5)}
                                >
                                    <Text
                                        style={[
                                            styles.intensityText,
                                            intensity === level && styles.intensityTextActive,
                                        ]}
                                    >
                                        {level}
                                    </Text>
                                </Pressable>
                            ))}
                        </View>
                        <Text style={styles.intensityHint}>
                            {intensity <= 2 ? 'Mild - Easily manageable' : intensity <= 4 ? 'Moderate - Needs attention' : 'High - Urgent self-care needed'}
                        </Text>
                    </View>
                )}

                {/* Trigger Input */}
                {selectedEmotion && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>What triggered this?</Text>
                        <TextInput
                            style={styles.textInput}
                            placeholder="e.g., Got cut off in traffic, Friend's success on social media..."
                            placeholderTextColor={COLORS.textSecondary}
                            value={trigger}
                            onChangeText={setTrigger}
                            multiline
                            numberOfLines={2}
                        />
                    </View>
                )}

                {/* Notes Input */}
                {selectedEmotion && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Additional thoughts (optional)</Text>
                        <TextInput
                            style={[styles.textInput, styles.textArea]}
                            placeholder="Any other details you'd like to remember..."
                            placeholderTextColor={COLORS.textSecondary}
                            value={notes}
                            onChangeText={setNotes}
                            multiline
                            numberOfLines={4}
                        />
                    </View>
                )}

                {/* Submit Button */}
                {selectedEmotion && (
                    <Pressable style={styles.submitButton} onPress={handleLogEmotion}>
                        <Text style={styles.submitText}>Log Emotion & Get Guidance</Text>
                    </Pressable>
                )}

                {/* Recent Emotions */}
                {recentEmotions.length > 0 && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Recent Emotions</Text>
                        {recentEmotions.slice(0, 5).map((emotion) => (
                            <View key={emotion.id} style={styles.recentCard}>
                                <View style={styles.recentHeader}>
                                    <Text style={styles.recentEmotion}>{emotion.emotion}</Text>
                                    <Text style={styles.recentTime}>
                                        {new Date(emotion.timestamp).toLocaleDateString()}
                                    </Text>
                                </View>
                                <Text style={styles.recentTrigger}>{emotion.trigger || 'No trigger recorded'}</Text>
                            </View>
                        ))}
                    </View>
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
    header: {
        paddingHorizontal: 20,
        paddingTop: 16,
        paddingBottom: 8,
    },
    title: {
        fontSize: 24,
        fontWeight: '700',
        color: COLORS.text,
    },
    subtitle: {
        fontSize: 14,
        color: COLORS.textSecondary,
        marginTop: 4,
    },
    successBanner: {
        marginHorizontal: 16,
        marginTop: 8,
        padding: 12,
        backgroundColor: COLORS.success + '20',
        borderRadius: 8,
        borderLeftWidth: 4,
        borderLeftColor: COLORS.success,
    },
    successText: {
        color: COLORS.success,
        fontWeight: '500',
    },
    section: {
        paddingHorizontal: 16,
        marginTop: 20,
    },
    sectionTitle: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text,
        marginBottom: 12,
    },
    emotionGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 10,
    },
    emotionCard: {
        width: '47%',
        paddingVertical: 16,
        paddingHorizontal: 12,
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        borderWidth: 2,
        borderColor: 'transparent',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 2,
    },
    emotionLabel: {
        fontSize: 16,
        fontWeight: '500',
        color: COLORS.text,
    },
    intensityContainer: {
        flexDirection: 'row',
        justifyContent: 'space-around',
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        padding: 8,
    },
    intensityButton: {
        width: 50,
        height: 50,
        borderRadius: 25,
        backgroundColor: COLORS.background,
        justifyContent: 'center',
        alignItems: 'center',
    },
    intensityButtonActive: {
        backgroundColor: COLORS.primary,
    },
    intensityText: {
        fontSize: 18,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    intensityTextActive: {
        color: '#FFF',
    },
    intensityHint: {
        textAlign: 'center',
        color: COLORS.textSecondary,
        fontSize: 12,
        marginTop: 8,
    },
    textInput: {
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        padding: 16,
        fontSize: 16,
        color: COLORS.text,
        borderWidth: 1,
        borderColor: '#E0E0E0',
    },
    textArea: {
        height: 100,
        textAlignVertical: 'top',
    },
    submitButton: {
        marginHorizontal: 16,
        marginTop: 24,
        marginBottom: 32,
        backgroundColor: COLORS.primary,
        paddingVertical: 16,
        borderRadius: 12,
        alignItems: 'center',
    },
    submitText: {
        color: '#FFF',
        fontSize: 16,
        fontWeight: '600',
    },
    recentCard: {
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        padding: 16,
        marginBottom: 10,
    },
    recentHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 4,
    },
    recentEmotion: {
        fontSize: 14,
        fontWeight: '600',
        color: COLORS.text,
        textTransform: 'capitalize',
    },
    recentTime: {
        fontSize: 12,
        color: COLORS.textSecondary,
    },
    recentTrigger: {
        fontSize: 13,
        color: COLORS.textSecondary,
    },
});