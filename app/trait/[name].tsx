// Trait Detail Screen — app/trait/[name].tsx
// Dynamic route: /trait/Ghadab%20(Anger)
// Updates: theme + accessibility

import { View, Text, StyleSheet, ScrollView, Pressable, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useNafsAttributeByName } from '../../src/data/datasources/hooks';
import { useTheme } from '../../src/presentation/theme';
import { useSettingsStore } from '../../src/infrastructure/store/settingsStore';
import { getLocalizedName } from '../../src/shared/i18n/translations';

export default function TraitDetailScreen() {
    const { name } = useLocalSearchParams<{ name: string }>();
    const router = useRouter();
    const theme = useTheme();
    const language = useSettingsStore((s) => s.language);
    const { data: trait, isLoading, error } = useNafsAttributeByName(decodeURIComponent(name ?? ''));

    if (isLoading) {
        return (
            <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]}>
                <ActivityIndicator size="large" color={theme.colors.primary} style={{ marginTop: 40 }} />
            </SafeAreaView>
        );
    }

    if (error || !trait) {
        return (
            <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]}>
                <View style={styles.errorContainer}>
                    <Text style={[styles.errorText, { color: theme.colors.textSecondary }]}>Trait not found.</Text>
                    <Pressable
                        style={[styles.backButton, { backgroundColor: theme.colors.primary }]}
                        onPress={() => router.back()}
                        accessibilityRole="button"
                        accessibilityLabel="Go back"
                    >
                        <Text style={styles.backButtonText}>← Go Back</Text>
                    </Pressable>
                </View>
            </SafeAreaView>
        );
    }

    const isNegative = trait.category === 'negative';
    const categoryColor = isNegative ? theme.colors.ammarah : theme.colors.mutmainna;
    const localized = getLocalizedName(trait.name, language);
    const showLocalized = language !== 'en' && localized !== trait.name;

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
                <Pressable
                    style={styles.backRow}
                    onPress={() => router.back()}
                    accessibilityRole="button"
                    accessibilityLabel="Go back"
                    hitSlop={8}
                >
                    <Text style={[styles.backText, { color: theme.colors.primary }]}>← Back</Text>
                </Pressable>

                <View style={styles.header}>
                    <Text style={[styles.name, { color: theme.colors.text }]}>{trait.name}</Text>
                    {showLocalized && (
                        <Text
                            style={[
                                styles.localized,
                                {
                                    color: theme.colors.primary,
                                    writingDirection: language === 'ar' || language === 'ur' ? 'rtl' : 'ltr',
                                },
                            ]}
                        >
                            {localized}
                        </Text>
                    )}
                    <View style={[styles.badge, { backgroundColor: categoryColor + '25', borderColor: categoryColor }]}>
                        <Text style={[styles.badgeText, { color: categoryColor }]}>
                            {isNegative ? 'Blameworthy (Madhmum)' : 'Praiseworthy (Mahmud)'}
                        </Text>
                    </View>
                </View>

                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.textSecondary }]}>Description</Text>
                    <Text style={[styles.bodyText, { color: theme.colors.text }]}>{trait.description}</Text>
                </View>

                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.textSecondary }]}>
                        {isNegative ? 'Its Opposite Virtue' : 'Its Opposite Vice'}
                    </Text>
                    <View style={[styles.oppositeChip, { backgroundColor: theme.colors.surface }]}>
                        <Text style={[styles.oppositeText, { color: theme.colors.text }]}>{trait.opposite_to}</Text>
                    </View>
                </View>

                {trait.quran_ref.length > 0 && (
                    <View style={styles.section}>
                        <Text style={[styles.sectionTitle, { color: theme.colors.textSecondary }]}>Quranic References</Text>
                        {trait.quran_ref.map((ref, i) => (
                            <View key={i} style={styles.refRow}>
                                <Text style={styles.refIcon}>📖</Text>
                                <Text style={[styles.refText, { color: theme.colors.text }]}>{ref}</Text>
                            </View>
                        ))}
                    </View>
                )}

                {trait.hadith_ref.length > 0 && (
                    <View style={styles.section}>
                        <Text style={[styles.sectionTitle, { color: theme.colors.textSecondary }]}>Hadith References</Text>
                        {trait.hadith_ref.map((ref, i) => (
                            <View key={i} style={styles.refRow}>
                                <Text style={styles.refIcon}>📜</Text>
                                <Text style={[styles.refText, { color: theme.colors.text }]}>{ref}</Text>
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
        lineHeight: 34,
    },
    localized: {
        fontSize: 22,
        fontWeight: '600',
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
        textTransform: 'uppercase',
        letterSpacing: 0.8,
        marginBottom: 8,
    },
    bodyText: {
        fontSize: 16,
        lineHeight: 25,
    },
    oppositeChip: {
        borderRadius: 10,
        paddingVertical: 10,
        paddingHorizontal: 14,
        alignSelf: 'flex-start',
    },
    oppositeText: {
        fontSize: 15,
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
    },
    backButton: {
        paddingVertical: 10,
        paddingHorizontal: 20,
        borderRadius: 8,
    },
    backButtonText: {
        color: '#fff',
        fontWeight: '600',
    },
});
