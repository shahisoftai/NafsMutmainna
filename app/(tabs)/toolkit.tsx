// Rectification Toolkit — dynamic 200-trait browser
// Replaces the previous hard-coded 8-trait implementation.
// Features: search, category filter (all/negative/positive), detail navigation,
// cloud-driven trait data via the existing `useNafsAttributes` hook (DRY).

import { useState, useMemo, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    Pressable,
    TextInput,
    FlatList,
    RefreshControl,
    ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useQueryClient } from '@tanstack/react-query';
import { useNafsAttributes, QUERY_KEYS } from '../../src/data/datasources/hooks';
import { useTheme } from '../../src/presentation/theme';
import { useSettingsStore } from '../../src/infrastructure/store/settingsStore';
import { getLocalizedName } from '../../src/shared/i18n/translations';
import { EmptyState, ErrorBanner, SectionHeader } from '../../src/presentation/components';
import type { NafsAttribute, NafsAttributeCategory } from '../../src/domain/entities';

type Filter = 'all' | NafsAttributeCategory;

export default function ToolkitScreen() {
    const router = useRouter();
    const theme = useTheme();
    const qc = useQueryClient();
    const language = useSettingsStore((s) => s.language);

    const [filter, setFilter] = useState<Filter>('all');
    const [query, setQuery] = useState('');

    const { data, isLoading, error, refetch } = useNafsAttributes();

    const filtered = useMemo<NafsAttribute[]>(() => {
        const list = data ?? [];
        return list.filter((t) => {
            if (filter !== 'all' && t.category !== filter) return false;
            if (query.trim()) {
                const q = query.toLowerCase();
                if (!t.name.toLowerCase().includes(q) && !t.description.toLowerCase().includes(q)) {
                    return false;
                }
            }
            return true;
        });
    }, [data, filter, query]);

    const counts = useMemo(() => {
        const list = data ?? [];
        return {
            all: list.length,
            negative: list.filter((t) => t.category === 'negative').length,
            positive: list.filter((t) => t.category === 'positive').length,
        };
    }, [data]);

    const handleRefresh = useCallback(() => {
        qc.invalidateQueries({ queryKey: QUERY_KEYS.nafsAttributes });
        void refetch();
    }, [qc, refetch]);

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.colors.text }]}>Rectification Toolkit</Text>
                <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
                    {counts.all} authentic remedies from Quran & Sunnah
                </Text>
            </View>

            {/* Search */}
            <View
                style={[
                    styles.searchBar,
                    { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                ]}
            >
                <Ionicons name="search" size={18} color={theme.colors.textSecondary} />
                <TextInput
                    style={[styles.searchInput, { color: theme.colors.text }]}
                    placeholder="Search traits, descriptions…"
                    placeholderTextColor={theme.colors.textSecondary}
                    value={query}
                    onChangeText={setQuery}
                    accessibilityLabel="Search traits"
                />
                {query.length > 0 && (
                    <Pressable
                        onPress={() => setQuery('')}
                        accessibilityRole="button"
                        accessibilityLabel="Clear search"
                        hitSlop={8}
                    >
                        <Ionicons name="close-circle" size={18} color={theme.colors.textSecondary} />
                    </Pressable>
                )}
            </View>

            {/* Category filter chips */}
            <View style={styles.filterRow}>
                {(
                    [
                        { value: 'all', label: 'All' },
                        { value: 'negative', label: 'Negative' },
                        { value: 'positive', label: 'Positive' },
                    ] as { value: Filter; label: string }[]
                ).map((f) => (
                    <Pressable
                        key={f.value}
                        onPress={() => setFilter(f.value)}
                        style={[
                            styles.filterChip,
                            { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                            filter === f.value && {
                                backgroundColor: theme.colors.primary,
                                borderColor: theme.colors.primary,
                            },
                        ]}
                        accessibilityRole="button"
                        accessibilityLabel={`Filter: ${f.label}`}
                        accessibilityState={{ selected: filter === f.value }}
                    >
                        <Text
                            style={[
                                styles.filterChipText,
                                { color: filter === f.value ? '#FFF' : theme.colors.text },
                            ]}
                        >
                            {f.label} · {counts[f.value]}
                        </Text>
                    </Pressable>
                ))}
            </View>

            {error && <ErrorBanner message="Couldn't load traits. Pull to retry." />}

            <FlatList
                data={filtered}
                keyExtractor={(item) => item.id}
                contentContainerStyle={styles.list}
                showsVerticalScrollIndicator={false}
                refreshControl={
                    <RefreshControl
                        refreshing={isLoading}
                        onRefresh={handleRefresh}
                        tintColor={theme.colors.primary}
                    />
                }
                ListEmptyComponent={
                    isLoading ? (
                        <View style={styles.loadingWrap}>
                            <ActivityIndicator color={theme.colors.primary} />
                            <Text style={[styles.loadingText, { color: theme.colors.textSecondary }]}>
                                Loading traits…
                            </Text>
                        </View>
                    ) : (
                        <EmptyState
                            icon="🌿"
                            title={query ? 'No matches' : 'No traits yet'}
                            description={
                                query
                                    ? `No traits match "${query}"${filter !== 'all' ? ` in ${filter}` : ''}.`
                                    : 'Pull to refresh.'
                            }
                        />
                    )
                }
                renderItem={({ item }) => (
                    <TraitRow
                        trait={item}
                        language={language}
                        theme={theme}
                        onPress={() => router.push(`/trait/${encodeURIComponent(item.name)}`)}
                    />
                )}
            />
        </SafeAreaView>
    );
}

const TraitRow: React.FC<{
    trait: NafsAttribute;
    language: 'en' | 'ur' | 'ar';
    theme: ReturnType<typeof useTheme>;
    onPress: () => void;
}> = ({ trait, language, theme, onPress }) => {
    const isNegative = trait.category === 'negative';
    const accent = isNegative ? theme.colors.ammarah : theme.colors.mutmainna;
    const localized = getLocalizedName(trait.name, language);
    const showLocalized = language !== 'en' && localized !== trait.name;

    return (
        <Pressable
            style={({ pressed }) => [
                styles.row,
                { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
                pressed && { opacity: 0.7 },
            ]}
            onPress={onPress}
            accessibilityRole="button"
            accessibilityLabel={`${trait.name}, ${trait.category}`}
        >
            <View style={[styles.rowAccent, { backgroundColor: accent }]} />
            <View style={styles.rowContent}>
                <Text style={[styles.rowName, { color: theme.colors.text }]} numberOfLines={1}>
                    {trait.name}
                </Text>
                {showLocalized && (
                    <Text
                        style={[
                            styles.rowLocalized,
                            {
                                color: theme.colors.primary,
                                writingDirection: language === 'ar' || language === 'ur' ? 'rtl' : 'ltr',
                            },
                        ]}
                        numberOfLines={1}
                    >
                        {localized}
                    </Text>
                )}
                <Text
                    style={[styles.rowDescription, { color: theme.colors.textSecondary }]}
                    numberOfLines={2}
                >
                    {trait.description}
                </Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={theme.colors.textSecondary} />
        </Pressable>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { paddingHorizontal: 20, paddingTop: 16, paddingBottom: 8 },
    title: { fontSize: 24, fontWeight: '700' },
    subtitle: { fontSize: 13, marginTop: 4 },
    searchBar: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        marginHorizontal: 16,
        paddingHorizontal: 12,
        paddingVertical: 8,
        borderRadius: 10,
        borderWidth: 1,
    },
    searchInput: { flex: 1, fontSize: 14, paddingVertical: 4 },
    filterRow: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginTop: 12, marginBottom: 8 },
    filterChip: {
        paddingHorizontal: 14,
        paddingVertical: 8,
        borderRadius: 18,
        borderWidth: 1,
    },
    filterChipText: { fontSize: 12, fontWeight: '600' },
    list: { paddingHorizontal: 16, paddingBottom: 32, gap: 8 },
    row: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 12,
        borderRadius: 10,
        borderWidth: 1,
        gap: 10,
    },
    rowAccent: { width: 4, height: 36, borderRadius: 2 },
    rowContent: { flex: 1, gap: 2 },
    rowName: { fontSize: 15, fontWeight: '600' },
    rowLocalized: { fontSize: 14, fontWeight: '500' },
    rowDescription: { fontSize: 12, lineHeight: 17 },
    loadingWrap: { alignItems: 'center', paddingVertical: 60, gap: 12 },
    loadingText: { fontSize: 13 },
});
