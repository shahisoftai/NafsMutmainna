// Educational Hub Screen - Learn about Nafs stages
// Updates: theme-aware styles, proper RTL container for Arabic, accessibility

import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, DAILY_VERSES, DAILY_HADITH } from '../../src/shared/constants';
import { useTheme } from '../../src/presentation/theme';

const NAFS_STAGES = [
    {
        id: 'ammarah',
        label: 'Nafs Ammarah',
        arabic: 'النَّفْسُ الأَمَّارَةُ',
        verse: 'إِنَّ النَّفْسَ لَأَمَّارَةٌ بِالسُّوءِ',
        verseRef: 'Surah Yusuf 12:53',
        verseTranslation: 'Indeed, the soul is a persistent enjoiner of evil.',
        color: COLORS.ammarah,
        description:
            'The lowest state of the nafs. It commands the person toward sin, heedlessness, and fulfillment of worldly desires. The person in this state rarely reflects on their actions.',
        characteristics: [
            'Dominated by desires and whims',
            'Heedless of Allah’s commands',
            'Ego-driven, impulsive, arrogant',
            'Blames others for problems',
            'Rarely makes tawbah (repentance)',
        ],
        sahabaExample: 'This is the state the Prophet ﷺ warned about. He said: "The most dangerous enemy you have is your nafs." (Ibn Hibban, Authentic)',
        remedy: 'Continuous Istighfar, Salah, and connection to righteous company.',
        source: 'Dr. Israr Ahmed — Bayan al-Quran',
    },
    {
        id: 'lawwamah',
        label: 'Nafs Lawwamah',
        arabic: 'النَّفْسُ اللَّوَّامَةُ',
        verse: 'وَلَا أُقْسِمُ بِالنَّفْسِ اللَّوَّامَةِ',
        verseRef: 'Surah Al-Qiyamah 75:2',
        verseTranslation: 'And I swear by the self-reproaching soul.',
        color: COLORS.lawwamah,
        description:
            'The intermediate state. The person sins but feels remorse and blames themselves. They are on a journey of improvement, swinging between good and bad. Allah swears by this soul, showing its value.',
        characteristics: [
            'Feels guilt after sins',
            'Strives toward good but struggles',
            'Makes tawbah regularly',
            'Inconsistent in worship',
            'Aware of their own shortcomings',
        ],
        sahabaExample: 'Most of the Companions (Sahabah) lived in this state. Umar ibn al-Khattab ؓ famously held himself accountable every night before sleep.',
        remedy: 'Consistency in dhikr, Muhasabah (self-accounting), and seeking Islamic knowledge.',
        source: 'Molana Maududi — Tafhim al-Quran',
    },
    {
        id: 'mutmainna',
        label: 'Nafs Mutmainna',
        arabic: 'النَّفْسُ الْمُطْمَئِنَّةُ',
        verse: 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ارْجِعِي إِلَى رَبِّكِ رَاضِيَةً مَّرْضِيَّةً',
        verseRef: 'Surah Al-Fajr 89:27-28',
        verseTranslation: 'O soul that has achieved equilibrium! Return to your Lord, well-pleased and well-pleasing.',
        color: COLORS.mutmainna,
        description:
            'The highest state — the peaceful, contented soul. It is secure, pleased with Allah’s decree, and pleasing to Allah. This is the goal of every believer’s life journey.',
        characteristics: [
            'Inner peace and contentment',
            'Strong Tawakkul in Allah',
            'Consistent in worship and character',
            'Humble, patient, sincere',
            'Pleased with Allah’s will (Rida)',
        ],
        sahabaExample: 'Abu Bakr al-Siddiq ؓ was described as having reached this station. His heart did not waver even in the Cave of Thawr, when he said: "What do you think of two, the third of whom is Allah?" (Sahih al-Bukhari)',
        remedy: 'Maintain all practices: daily adhkar, Tahajjud, Quran, and service to others.',
        source: 'Ibn Kathir — Tafsir al-Quran al-Azim',
    },
];

const DAILY_LESSONS = [
    {
        id: 1,
        title: 'What is Tazkiyah?',
        content: 'Tazkiyah (تزكية) means purification and growth of the soul. Allah says: "He who purifies it has succeeded." (Surah Ash-Shams 91:9). Molana Maududi explains this as the active process of removing blameworthy traits and replacing them with praiseworthy ones.',
        source: 'Molana Maududi — Towards Understanding Islam',
    },
    {
        id: 2,
        title: 'The Role of Dhikr',
        content: 'Dr. Israr Ahmed emphasizes that the primary tool of Tazkiyah is the remembrance of Allah. The Quran says: "Verily, in the remembrance of Allah do hearts find rest." (Surah Ar-Ra\'d 13:28). Dhikr purifies the nafs by keeping it connected to its Creator.',
        source: 'Dr. Israr Ahmed — Bayan al-Quran',
    },
    {
        id: 3,
        title: 'Muhasabah — Daily Accountability',
        content: 'Umar ibn al-Khattab ؓ said: "Hold yourself accountable before you are held accountable, weigh your deeds before they are weighed." (Hasan — Ibn Abi Shaybah). This is the practice of Muhasabah — reviewing your day before sleep.',
        source: 'Classical Islamic Ethics',
    },
];

export default function LearnScreen() {
    const theme = useTheme();
    const [selectedStage, setSelectedStage] = useState<string | null>(null);

    const stage = NAFS_STAGES.find((s) => s.id === selectedStage);

    return (
        <SafeAreaView style={[styles.container, { backgroundColor: theme.colors.background }]} edges={['top']}>
            <ScrollView showsVerticalScrollIndicator={false}>
                <View style={styles.header}>
                    <Text style={[styles.title, { color: theme.colors.text }]}>Educational Hub</Text>
                    <Text style={[styles.subtitle, { color: theme.colors.textSecondary }]}>
                        Learn from authentic Islamic scholarship
                    </Text>
                </View>

                {/* Nafs Stages */}
                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>The Three Stages of Nafs</Text>
                    {NAFS_STAGES.map((s) => (
                        <Pressable
                            key={s.id}
                            style={[styles.stageCard, { backgroundColor: theme.colors.surface }]}
                            onPress={() => setSelectedStage(selectedStage === s.id ? null : s.id)}
                            accessibilityRole="button"
                            accessibilityLabel={s.label}
                            accessibilityState={{ expanded: selectedStage === s.id }}
                        >
                            <View style={[styles.stageIndicator, { backgroundColor: s.color }]} />
                            <View style={styles.stageContent}>
                                <Text style={[styles.stageLabel, { color: theme.colors.text }]}>{s.label}</Text>
                                <Text style={[styles.stageArabic, { color: theme.colors.primary, writingDirection: 'rtl' as const }]}>
                                    {s.arabic}
                                </Text>
                                <Text style={[styles.stageVerseRef, { color: theme.colors.textSecondary }]}>
                                    {s.verseRef}
                                </Text>
                            </View>
                            <Text style={[styles.expandIcon, { color: theme.colors.textSecondary }]}>
                                {selectedStage === s.id ? '▲' : '▼'}
                            </Text>
                        </Pressable>
                    ))}

                    {/* Expanded Stage Detail */}
                    {stage && (
                        <View
                            style={[
                                styles.stageDetail,
                                { backgroundColor: theme.colors.surface, borderLeftColor: stage.color },
                            ]}
                        >
                            <View style={styles.rtlContainer}>
                                <Text style={[styles.detailArabic, { color: theme.colors.primary, writingDirection: 'rtl' as const }]}>{stage.verse}</Text>
                            </View>
                            <Text style={[styles.detailVerseRef, { color: theme.colors.accent }]}>{stage.verseRef}</Text>
                            <Text style={[styles.detailTranslation, { color: theme.colors.text }]}>
                                {stage.verseTranslation}
                            </Text>

                            <Text style={[styles.detailDescription, { color: theme.colors.textSecondary }]}>
                                {stage.description}
                            </Text>

                            <Text style={[styles.detailHeading, { color: theme.colors.text }]}>Characteristics</Text>
                            {stage.characteristics.map((c, i) => (
                                <View key={i} style={styles.charRow}>
                                    <Text style={[styles.charDot, { color: theme.colors.primary }]}>•</Text>
                                    <Text style={[styles.charText, { color: theme.colors.text }]}>{c}</Text>
                                </View>
                            ))}

                            <View style={[styles.sahabaBox, { backgroundColor: theme.colors.primary + '10' }]}>
                                <Text style={[styles.sahabaLabel, { color: theme.colors.primary }]}>📜 From the Sahaba</Text>
                                <Text style={[styles.sahabaText, { color: theme.colors.text }]}>{stage.sahabaExample}</Text>
                            </View>

                            <View style={[styles.remedyBox, { backgroundColor: theme.colors.success + '15' }]}>
                                <Text style={[styles.remedyLabel, { color: theme.colors.success }]}>💊 Remedy</Text>
                                <Text style={[styles.remedyText, { color: theme.colors.text }]}>{stage.remedy}</Text>
                            </View>

                            <Text style={[styles.sourceText, { color: theme.colors.textSecondary }]}>— {stage.source}</Text>
                        </View>
                    )}
                </View>

                {/* Daily Lessons */}
                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Daily Lessons</Text>
                    {DAILY_LESSONS.map((lesson) => (
                        <View key={lesson.id} style={[styles.lessonCard, { backgroundColor: theme.colors.surface }]}>
                            <Text style={[styles.lessonTitle, { color: theme.colors.primary }]}>{lesson.title}</Text>
                            <Text style={[styles.lessonContent, { color: theme.colors.text }]}>{lesson.content}</Text>
                            <Text style={[styles.lessonSource, { color: theme.colors.textSecondary }]}>— {lesson.source}</Text>
                        </View>
                    ))}
                </View>

                {/* Today's Reflection Verse */}
                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>Today's Reflection</Text>
                    <View style={[styles.verseCard, { backgroundColor: theme.colors.primary }]}>
                        <Text style={[styles.verseLabel, { color: theme.colors.accent }]}>Surah Al-Fajr 89:27-30</Text>
                        <View>
                            <Text style={[styles.verseArabic, { color: '#FFF', writingDirection: 'rtl' as const }]}>
                                يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ{'\n'}
                                ارْجِعِي إِلَى رَبِّكِ رَاضِيَةً مَّرْضِيَّةً{'\n'}
                                فَادْخُلِي فِي عَبَادِي{'\n'}
                                وَادْخُلِي جَنَّتِي
                            </Text>
                        </View>
                        <Text style={[styles.verseTranslation, { color: '#FFFFFFCC' }]}>
                            "O soul that has achieved equilibrium! Return to your Lord, well-pleased and well-pleasing. Enter among My servants. Enter My Paradise."
                        </Text>
                        <Text style={[styles.verseSource, { color: '#FFFFFF80' }]}>
                            Ibn Kathir Tafsir — The goal of every believer's journey.
                        </Text>
                    </View>
                </View>

                <View style={{ height: 32 }} />
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.background },
    header: { paddingHorizontal: 20, paddingTop: 16, paddingBottom: 8 },
    title: { fontSize: 24, fontWeight: '700', color: COLORS.text },
    subtitle: { fontSize: 14, color: COLORS.textSecondary, marginTop: 4 },
    section: { paddingHorizontal: 16, marginTop: 24 },
    sectionTitle: { fontSize: 18, fontWeight: '600', color: COLORS.text, marginBottom: 12 },
    stageCard: {
        flexDirection: 'row', alignItems: 'center',
        backgroundColor: COLORS.surface, borderRadius: 12, padding: 16, marginBottom: 8,
        shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05,
        shadowRadius: 4, elevation: 2,
    },
    stageIndicator: { width: 8, height: 48, borderRadius: 4, marginRight: 14 },
    stageContent: { flex: 1 },
    stageLabel: { fontSize: 16, fontWeight: '600', color: COLORS.text },
    stageArabic: { fontSize: 16, color: COLORS.primary, marginTop: 2 },
    stageVerseRef: { fontSize: 12, color: COLORS.textSecondary, marginTop: 2 },
    rtlContainer: { alignItems: 'center' },
    expandIcon: { fontSize: 12, color: COLORS.textSecondary },
    stageDetail: {
        backgroundColor: COLORS.surface, borderRadius: 16, padding: 20,
        marginBottom: 8, borderLeftWidth: 4,
    },
    detailArabic: { fontSize: 22, lineHeight: 40, textAlign: 'center', color: COLORS.primary },
    detailVerseRef: { textAlign: 'center', color: COLORS.accent, fontWeight: '600', marginTop: 8 },
    detailTranslation: { textAlign: 'center', color: COLORS.text, marginTop: 8, lineHeight: 22 },
    detailDescription: { color: COLORS.textSecondary, lineHeight: 22, marginTop: 16 },
    detailHeading: { fontWeight: '700', color: COLORS.text, marginTop: 16, marginBottom: 8 },
    charRow: { flexDirection: 'row', gap: 8, marginBottom: 4 },
    charDot: { color: COLORS.primary, fontWeight: '700' },
    charText: { flex: 1, color: COLORS.text, lineHeight: 20 },
    sahabaBox: { backgroundColor: COLORS.primary + '10', borderRadius: 10, padding: 14, marginTop: 16 },
    sahabaLabel: { fontWeight: '700', color: COLORS.primary, marginBottom: 6 },
    sahabaText: { color: COLORS.text, lineHeight: 20 },
    remedyBox: { backgroundColor: COLORS.success + '15', borderRadius: 10, padding: 14, marginTop: 12 },
    remedyLabel: { fontWeight: '700', color: COLORS.success, marginBottom: 6 },
    remedyText: { color: COLORS.text, lineHeight: 20 },
    sourceText: { marginTop: 12, fontStyle: 'italic', color: COLORS.textSecondary, fontSize: 12 },
    lessonCard: {
        backgroundColor: COLORS.surface, borderRadius: 12, padding: 16, marginBottom: 12,
        shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05, shadowRadius: 4, elevation: 2,
    },
    lessonTitle: { fontSize: 16, fontWeight: '700', color: COLORS.primary, marginBottom: 8 },
    lessonContent: { fontSize: 14, color: COLORS.text, lineHeight: 22 },
    lessonSource: { fontSize: 11, fontStyle: 'italic', color: COLORS.textSecondary, marginTop: 8 },
    verseCard: {
        backgroundColor: COLORS.primary, borderRadius: 16, padding: 24,
        alignItems: 'center', marginBottom: 16,
    },
    verseLabel: { color: COLORS.accent, fontWeight: '700', marginBottom: 16 },
    verseArabic: { fontSize: 20, lineHeight: 40, color: '#FFF', textAlign: 'center' },
    verseTranslation: { color: '#FFFFFFCC', textAlign: 'center', marginTop: 16, lineHeight: 22 },
    verseSource: { color: '#FFFFFF80', fontSize: 12, marginTop: 12, fontStyle: 'italic', textAlign: 'center' },
});