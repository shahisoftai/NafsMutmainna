// Trait Detail Screen — app/trait/[name].tsx
// Dynamic route: /trait/Ghadab%20(Anger)

import { View, Text, StyleSheet, ScrollView, Pressable, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useNafsAttributeByName } from '../../src/data/datasources/hooks';
import { COLORS } from '../../src/shared/constants';

export default function TraitDetailScreen() {
    const { name } = useLocalSearchParams<{ name: string }>();
    const router = useRouter();
    const { data: trait, isLoading, error } = useNafsAttributeByName(decodeURIComponent(name ?? ''));

    if (isLoading) {
        return (
            <SafeAreaView style={styles.container}>
                <ActivityIndicator size="large" color={COLORS.primary} style={{ marginTop: 40 }} />
            </SafeAreaView>
        );
    }

    if (error || !trait) {
        return (
            <SafeAreaView style={styles.container}>
                <View style={styles.errorContainer}>
                    <Text style={styles.errorText}>Trait not found.</Text>
                    <Pressable style={styles.backButton} onPress={() => router.back()}>
                        <Text style={styles.backButtonText}>← Go Back</Text>
                    </Pressable>
                </View>
            </SafeAreaView>
        );
    }

    const isNegative = trait.category === 'negative';
    const categoryColor = isNegative ? '#E57373' : '#81C784';

    return (
        <SafeAreaView style={styles.container} edges={['top']}>
            <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
                {/* Back Nav */}
                <Pressable style={styles.backRow} onPress={() => router.back()}>
                    <Text style={styles.backText}>← Back</Text>
                </Pressable>

                {/* Name & Category Badge */}
                <View style={styles.header}>
                    <Text style={styles.name}>{trait.name}</Text>
                    <View style={[styles.badge, { backgroundColor: categoryColor + '25', borderColor: categoryColor }]}>
                        <Text style={[styles.badgeText, { color: categoryColor }]}>
                            {isNegative ? 'Blameworthy (Madhmum)' : 'Praiseworthy (Mahmud)'}
                        </Text>
                    </View>
                </View>

                {/* Description */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Description</Text>
                    <Text style={styles.bodyText}>{trait.description}</Text>
                </View>

                {/* Opposite Virtue / Vice */}
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>
                        {isNegative ? 'Its Opposite Virtue' : 'Its Opposite Vice'}
                    </Text>
                    <View style={styles.oppositeChip}>
                        <Text style={styles.oppositeText}>{trait.opposite_to}</Text>
                    </View>
                </View>

                {/* Quranic References */}
                {trait.quran_ref.length > 0 && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Quranic References</Text>
                        {trait.quran_ref.map((ref, i) => (
                            <View key={i} style={styles.refRow}>
                                <Text style={styles.refIcon}>📖</Text>
                                <Text style={styles.refText}>{ref}</Text>
                            </View>
                        ))}
                    </View>
                )}

                {/* Hadith References */}
                {trait.hadith_ref.length > 0 && (
                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Hadith References</Text>
                        {trait.hadith_ref.map((ref, i) => (
                            <View key={i} style={styles.refRow}>
                                <Text style={styles.refIcon}>📜</Text>
                                <Text style={styles.refText}>{ref}</Text>
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
    content: {
        paddingBottom: 40,
    },
    backRow: {
        paddingHorizontal: 16,
        paddingVertical: 12,
    },
    backText: {
        fontSize: 16,
        color: COLORS.primary,
        fontWeight: '500',
    },
    header: {
        paddingHorizontal: 16,
        paddingBottom: 8,
        gap: 10,
    },
    name: {
        fontSize: 26,
        fontWeight: '700',
        color: COLORS.text,
        lineHeight: 34,
    },
    badge: {
        alignSelf: 'flex-start',
        paddingVertical: 4,
        paddingHorizontal: 12,
        borderRadius: 20,
        borderWidth: 1,
    },
    badgeText: {
        fontSize: 13,
        fontWeight: '600',
    },
    section: {
        paddingHorizontal: 16,
        marginTop: 24,
    },
    sectionTitle: {
        fontSize: 13,
        fontWeight: '700',
        color: COLORS.textSecondary,
        textTransform: 'uppercase',
        letterSpacing: 0.8,
        marginBottom: 8,
    },
    bodyText: {
        fontSize: 16,
        color: COLORS.text,
        lineHeight: 25,
    },
    oppositeChip: {
        backgroundColor: COLORS.surface,
        borderRadius: 10,
        paddingVertical: 10,
        paddingHorizontal: 14,
        alignSelf: 'flex-start',
    },
    oppositeText: {
        fontSize: 15,
        color: COLORS.text,
        fontWeight: '500',
    },
    refRow: {
        flexDirection: 'row',
        gap: 10,
        marginBottom: 8,
        alignItems: 'flex-start',
    },
    refIcon: {
        fontSize: 16,
        marginTop: 1,
    },
    refText: {
        flex: 1,
        fontSize: 14,
        color: COLORS.text,
        lineHeight: 22,
    },
    errorContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        gap: 16,
    },
    errorText: {
        fontSize: 16,
        color: COLORS.textSecondary,
    },
    backButton: {
        paddingVertical: 10,
        paddingHorizontal: 20,
        backgroundColor: COLORS.primary,
        borderRadius: 8,
    },
    backButtonText: {
        color: '#fff',
        fontWeight: '600',
    },
});
