"use client";

import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { getLocalCheckin, getAllCheckinDates, getEmotionFrequency, type LocalCheckin } from "@/lib/localDB";
import { useAuth } from "@/contexts/AuthProvider";

type NafsStage = "ammarah" | "lawwamah" | "mutmainna";

interface Profile {
    full_name: string | null;
    nafs_stage: string | null;
}

interface NafsAttribute {
    id: string;
    name: string;
    description: string;
    category: "negative" | "positive";
}

// Emotion → Nafs attribute name mapping for Option C
const EMOTION_NAFS_MAP: Record<string, string[]> = {
    anger: ["Ghadab (Anger)"],
    envy: ["Hasad (Envy)"],
    anxiety: ["Jaza (Chronic Anxiety)"],
    sadness: ["Huzn al-Mamduh (Paralyzing Despair)"],
    greed: ["Tama (Covetousness)"],
    pride: ["Kibr (Arrogance)"],
    frustration: ["Ghadab (Anger)"],
    discontent: ["Malal (Spiritual Boredom)"],
};

const STAGE_DHIKR: Record<NafsStage, { dhikr: string; arabic: string; count: number; note: string }[]> = {
    ammarah: [
        {
            dhikr: "Astaghfirullah al-Adheem wa atubu ilayh",
            arabic: "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ",
            count: 100,
            note: "Seek heavy repentance for the commanding soul",
        },
        {
            dhikr: "Rabbi inni dhalamtu nafsi faghfir li",
            arabic: "رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي",
            count: 40,
            note: "Supplication of turning back to Allah",
        },
    ],
    lawwamah: [
        {
            dhikr: "Hasbunallahu wa ni'mal wakeel",
            arabic: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
            count: 70,
            note: "For self-accountability and reliance on Allah",
        },
        {
            dhikr: "La ilaha illa anta subhanaka inni kuntu min adh-dhalimeen",
            arabic: "لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
            count: 40,
            note: "Dua of Yunus — repentance and recognition",
        },
    ],
    mutmainna: [
        {
            dhikr: "Alhamdulillahi Rabbil Alameen",
            arabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
            count: 33,
            note: "Gratitude dhikr to sustain your tranquil state",
        },
        {
            dhikr: "Subhanallahi wa bihamdihi Subhanallahil Adheem",
            arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
            count: 100,
            note: "The two phrases heaviest on the Scale",
        },
    ],
};

interface StageInfo {
    label: string; colorClass: string; bgClass: string; borderClass: string; emoji: string; desc: string;
}

const STAGE_INFO: Record<NafsStage, StageInfo> = {
    ammarah: {
        label: "Nafs Ammarah",
        colorClass: "text-red-600 dark:text-red-400",
        bgClass: "bg-red-50 dark:bg-red-900/20",
        borderClass: "border-red-200 dark:border-red-800",
        emoji: "🔴",
        desc: "The commanding soul — prone to base desires",
    },
    lawwamah: {
        label: "Nafs Lawwamah",
        colorClass: "text-amber-600 dark:text-amber-400",
        bgClass: "bg-amber-50 dark:bg-amber-900/20",
        borderClass: "border-amber-200 dark:border-amber-800",
        emoji: "🟡",
        desc: "The self-reproaching soul — aware and striving",
    },
    mutmainna: {
        label: "Nafs Mutmainna",
        colorClass: "text-emerald-600 dark:text-emerald-400",
        bgClass: "bg-emerald-50 dark:bg-emerald-900/20",
        borderClass: "border-emerald-200 dark:border-emerald-800",
        emoji: "🟢",
        desc: "The tranquil soul — at peace with Allah",
    },
};

const NAV_ITEMS = [
    { href: "/assessment", icon: "📊", label: "Daily Check-in" },
    { href: "/emotions", icon: "💭", label: "Emotions" },
    { href: "/journal", icon: "📝", label: "Journal" },
    { href: "/toolkit", icon: "🛠️", label: "Toolkit" },
    { href: "/analytics", icon: "📈", label: "Analytics" },
];

function getGreeting() {
    const h = new Date().getHours();
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
}

function normalizeStage(s: string | null | undefined): NafsStage {
    const lower = (s ?? "").toLowerCase();
    if (lower === "lawwamah") return "lawwamah";
    if (lower === "mutmainna") return "mutmainna";
    return "ammarah";
}

// Stage → Nafs meter position (0-100). Maps the user's resolved stage
// to the gradient track position. mutmainna = far right, ammarah = far left.
function stageToMeterPct(stage: NafsStage): number {
    return { ammarah: 18, lawwamah: 50, mutmainna: 84 }[stage];
}

export default function DashboardPage() {
    const supabase = useMemo(() => createClient(), []);
    const router = useRouter();
    const { user, isLoading: authLoading, signOut } = useAuth();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [profile, setProfile] = useState<Profile | null>(null);
    const [todayCheckin, setTodayCheckin] = useState<LocalCheckin | null>(null);
    const [focusTraits, setFocusTraits] = useState<NafsAttribute[]>([]);
    const [journalStreak, setJournalStreak] = useState(0);
    const [showSignOutConfirm, setShowSignOutConfirm] = useState(false);

    useEffect(() => {
        if (authLoading) return;
        if (!user) { router.push("/auth/login"); return; }

        let cancelled = false;
        async function load() {
            if (!user) return;

            const today = new Date().toISOString().slice(0, 10);

            const [profileRes, traitsRes] = await Promise.all([
                supabase.from("profiles").select("full_name, nafs_stage").eq("user_id", user.id).maybeSingle(),
                supabase.from("nafs_attributes").select("id, name, description, category"),
            ]);

            if (cancelled) return;

            if (profileRes.error) {
                console.error("[Dashboard] profile error:", profileRes.error);
                setError("Failed to load profile");
            }
            if (traitsRes.error) {
                console.error("[Dashboard] traits error:", traitsRes.error);
            }

            setProfile(profileRes.data as Profile | null);

            // ── Journal streak from localDB ─────────────────────────────────
            const allCheckinDates = getAllCheckinDates(user.id);
            if (allCheckinDates.length > 0) {
                let streak = 0;
                const todayMs = new Date(today + "T00:00:00").getTime();
                const sorted = allCheckinDates.slice().sort().reverse();
                // Streak counts back from the most recent check-in. If the most
                // recent is more than 1 day old, streak is broken (0).
                const mostRecent = new Date(sorted[0] + "T00:00:00").getTime();
                const gapFromToday = Math.round((todayMs - mostRecent) / 86400000);
                if (gapFromToday <= 1) {
                    streak = 1;
                    for (let i = 1; i < sorted.length; i++) {
                        const cur = new Date(sorted[i] + "T00:00:00").getTime();
                        const prev = new Date(sorted[i - 1] + "T00:00:00").getTime();
                        const diff = Math.round((prev - cur) / 86400000);
                        if (diff === 1) streak++;
                        else break;
                    }
                }
                setJournalStreak(streak);
            }

            // ── Determine active stage (local check-in wins, then profile) ──
            const localCheckin = getLocalCheckin(user.id, today);
            const activeStage = normalizeStage(
                localCheckin?.stage ?? profileRes.data?.nafs_stage ?? null
            );

            setTodayCheckin(localCheckin);

            // ── Build focus traits list ────────────────────────────────────
            // Option C (14+ days of emotion data): top emotions → mapped traits
            // Option A (default): stage-appropriate traits, rotated daily
            if (traitsRes.data) {
                const allTraits = traitsRes.data as NafsAttribute[];
                const today_seed = Math.floor(Date.now() / 86400000);

                const last14: string[] = [];
                for (let i = 13; i >= 0; i--) {
                    const d = new Date();
                    d.setDate(d.getDate() - i);
                    last14.push(d.toISOString().slice(0, 10));
                }
                const emotionFreq = getEmotionFrequency(user.id, last14);
                const emotionDaysCount = Object.keys(emotionFreq).length;

                let traits: NafsAttribute[] = [];

                if (emotionDaysCount >= 14) {
                    const sortedEmotions = Object.entries(emotionFreq)
                        .sort((a, b) => b[1] - a[1])
                        .map(([emotion]) => emotion)
                        .slice(0, 3);

                    const matchedTraitNames = new Set<string>();
                    for (const emotion of sortedEmotions) {
                        const nafsNames = EMOTION_NAFS_MAP[emotion] ?? [];
                        for (const name of nafsNames) {
                            const t = allTraits.find((tr) => tr.name === name);
                            if (t) matchedTraitNames.add(name);
                        }
                    }
                    if (matchedTraitNames.size < 3) {
                        const stageTraits = allTraits.filter(
                            (t) => t.category === "negative"
                        );
                        for (const t of stageTraits) {
                            if (matchedTraitNames.size >= 3) break;
                            matchedTraitNames.add(t.name);
                        }
                    }
                    traits = allTraits.filter((t) => matchedTraitNames.has(t.name)).slice(0, 3);
                } else {
                    // Stage-appropriate: ammarah/lawwamah → negative traits,
                    // mutmainna → positive traits. Rotated daily by a date seed.
                    const preferredCategory = activeStage === "mutmainna" ? "positive" : "negative";
                    let pool = allTraits.filter((t) => t.category === preferredCategory);
                    if (pool.length < 3) {
                        // Fallback: mix in traits from the other category
                        pool = [...pool, ...allTraits.filter((t) => t.category !== preferredCategory)];
                    }
                    const start = (today_seed * 3) % Math.max(1, pool.length - 2);
                    traits = pool.slice(start, start + 3);
                    if (traits.length < 3) {
                        traits = [...traits, ...pool.slice(0, 3 - traits.length)];
                    }
                }

                setFocusTraits(traits);
            }

            setLoading(false);
        }
        load();
        return () => { cancelled = true; };
    }, [user, authLoading, supabase, router]);

    const handleSignOut = async () => {
        setShowSignOutConfirm(false);
        await signOut();
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-emerald-50 to-white dark:from-zinc-950 dark:to-zinc-900">
                <div className="text-emerald-600 text-lg animate-pulse">Loading...</div>
            </div>
        );
    }

    if (!user) return null;

    const activeStage = normalizeStage(todayCheckin?.stage ?? profile?.nafs_stage ?? null);
    const stageInfo = STAGE_INFO[activeStage];
    const dhikrList = STAGE_DHIKR[activeStage];
    // Privacy-safe: only show the user's profile name, never the email.
    const displayName = profile?.full_name?.trim() || "Friend";
    const moodScore = todayCheckin?.mood ?? 0;
    const meterPct = stageToMeterPct(activeStage);

    return (
        <div className="min-h-screen bg-gradient-to-b from-emerald-50 to-white dark:from-zinc-950 dark:to-zinc-900">
            {/* Header */}
            <header className="bg-white dark:bg-zinc-800 shadow-sm sticky top-0 z-10">
                <div className="container mx-auto px-4 py-3 flex items-center justify-between">
                    <span className="text-lg font-bold text-emerald-800 dark:text-emerald-400">NafsMutmainna</span>
                    <div className="flex items-center gap-3">
                        <span className={`hidden sm:inline-block text-xs font-semibold px-2.5 py-1 rounded-full border ${stageInfo.bgClass} ${stageInfo.colorClass} ${stageInfo.borderClass}`}>
                            {stageInfo.emoji} {stageInfo.label}
                        </span>
                        {showSignOutConfirm ? (
                            <div className="flex items-center gap-2">
                                <span className="text-xs text-zinc-500">Sign out?</span>
                                <button
                                    onClick={handleSignOut}
                                    className="text-xs bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded font-medium transition-colors"
                                >
                                    Yes
                                </button>
                                <button
                                    onClick={() => setShowSignOutConfirm(false)}
                                    className="text-xs bg-zinc-200 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-300 px-2 py-1 rounded font-medium transition-colors"
                                >
                                    No
                                </button>
                            </div>
                        ) : (
                            <button
                                onClick={() => setShowSignOutConfirm(true)}
                                className="text-xs text-zinc-400 hover:text-red-500 transition-colors"
                            >
                                Sign out
                            </button>
                        )}
                    </div>
                </div>

                {/* Compact nav menu */}
                <div className="border-t border-zinc-100 dark:border-zinc-700">
                    <div className="container mx-auto px-4">
                        <nav className="flex overflow-x-auto gap-1 py-2" style={{ scrollbarWidth: "none" }}>
                            {NAV_ITEMS.map((item) => (
                                <Link
                                    key={item.href}
                                    href={item.href}
                                    className="flex-shrink-0 flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm text-zinc-600 dark:text-zinc-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:text-emerald-700 dark:hover:text-emerald-400 transition-colors whitespace-nowrap"
                                >
                                    <span>{item.icon}</span>
                                    <span>{item.label}</span>
                                </Link>
                            ))}
                        </nav>
                    </div>
                </div>
            </header>

            {error && (
                <div className="container mx-auto px-4 max-w-5xl mt-4">
                    <div className="bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 p-3 rounded-lg text-sm">
                        {error}
                    </div>
                </div>
            )}

            <main className="container mx-auto px-4 py-8 max-w-5xl">
                {/* Greeting + streak */}
                <div className="flex items-center justify-between mb-8">
                    <div>
                        <h1 className="text-2xl font-bold text-zinc-800 dark:text-zinc-200">
                            {getGreeting()}, {displayName} 🌙
                        </h1>
                        <p className="text-sm text-zinc-500 mt-1">Track your spiritual journey — one day at a time</p>
                    </div>
                    {journalStreak > 0 && (
                        <div className="flex items-center gap-2 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-xl px-4 py-2 flex-shrink-0">
                            <span className="text-2xl">🔥</span>
                            <div className="text-center">
                                <div className="text-xl font-bold text-amber-600 dark:text-amber-400 leading-tight">{journalStreak}</div>
                                <div className="text-xs text-amber-500">day streak</div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Nafs Meter */}
                <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm mb-6">
                    <div className="flex items-center justify-between mb-5">
                        <h2 className="font-bold text-zinc-800 dark:text-zinc-200 text-lg">Today&apos;s Nafs Meter</h2>
                        {!todayCheckin && (
                            <Link href="/assessment" className="text-sm text-emerald-600 hover:text-emerald-700 font-medium">
                                Do check-in →
                            </Link>
                        )}
                    </div>

                    {/* Gradient track */}
                    <div className="relative mb-5">
                        <div className="h-5 rounded-full bg-gradient-to-r from-red-400 via-amber-400 to-emerald-500 shadow-inner">
                            <div
                                className="absolute top-1/2 -translate-y-1/2 w-7 h-7 rounded-full bg-white border-4 border-zinc-700 dark:border-zinc-200 shadow-lg transition-all duration-700"
                                style={{ left: `calc(${meterPct}% - 14px)` }}
                            />
                        </div>
                        <div className="flex justify-between mt-2.5 text-xs font-semibold">
                            <span className="text-red-500">Ammarah</span>
                            <span className="text-amber-500">Lawwamah</span>
                            <span className="text-emerald-600">Mutmainna</span>
                        </div>
                    </div>

                    <div className="flex items-center justify-between">
                        <div>
                            <p className={`font-semibold text-base ${stageInfo.colorClass}`}>{stageInfo.label}</p>
                            <p className="text-sm text-zinc-500 mt-0.5">{stageInfo.desc}</p>
                        </div>
                        <div className="text-right">
                            {moodScore > 0 ? (
                                <>
                                    <div className="flex gap-0.5 justify-end">
                                        {[1, 2, 3, 4, 5].map((n) => (
                                            <span key={n} className={`text-xl ${n <= moodScore ? "text-amber-400" : "text-zinc-200 dark:text-zinc-600"}`}>★</span>
                                        ))}
                                    </div>
                                    <p className="text-xs text-zinc-400 mt-0.5">Today&apos;s mood</p>
                                </>
                            ) : (
                                <span className="text-xs text-zinc-400">No check-in yet</span>
                            )}
                        </div>
                    </div>

                    {!todayCheckin && (
                        <div className={`mt-4 p-3 rounded-xl border flex items-center justify-between ${stageInfo.bgClass} ${stageInfo.borderClass}`}>
                            <p className={`text-sm ${stageInfo.colorClass}`}>Complete today&apos;s check-in to personalize your dashboard</p>
                            <Link href="/assessment" className="ml-3 flex-shrink-0 text-sm bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-1.5 rounded-lg font-medium transition-colors">
                                Start →
                            </Link>
                        </div>
                    )}
                </div>

                {/* Azkār + Focus Traits */}
                <div className="grid md:grid-cols-2 gap-6">
                    {/* Today's Azkār */}
                    <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm">
                        <h2 className="font-bold text-zinc-800 dark:text-zinc-200 mb-1">Today&apos;s Azkār</h2>
                        <p className="text-xs text-zinc-500 mb-4">Recommended for your {stageInfo.label} stage</p>
                        <div className="space-y-4">
                            {dhikrList.map((d, i) => (
                                <div key={i} className={`rounded-xl p-4 border ${stageInfo.bgClass} ${stageInfo.borderClass}`}>
                                    <div className="flex items-start justify-between gap-2 mb-2">
                                        <span className="text-sm font-semibold text-zinc-700 dark:text-zinc-300 leading-snug">{d.dhikr}</span>
                                        <span className={`flex-shrink-0 text-xs font-bold px-2 py-0.5 rounded-full bg-white dark:bg-zinc-700 ${stageInfo.colorClass}`}>×{d.count}</span>
                                    </div>
                                    <p className="text-2xl text-right mb-2 text-zinc-700 dark:text-zinc-300 leading-loose">{d.arabic}</p>
                                    <p className="text-xs text-zinc-500 italic">{d.note}</p>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Focus Traits */}
                    <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm">
                        <h2 className="font-bold text-zinc-800 dark:text-zinc-200 mb-1">Traits to Work On Today</h2>
                        <p className="text-xs text-zinc-500 mb-4">Rotates daily — explore in Toolkit</p>
                        <div className="space-y-3">
                            {focusTraits.length === 0 ? (
                                <div className="space-y-3">
                                    {[1, 2, 3].map((i) => (
                                        <div key={i} className="h-16 bg-zinc-100 dark:bg-zinc-700 rounded-xl animate-pulse" />
                                    ))}
                                </div>
                            ) : (
                                focusTraits.map((t, i) => (
                                    <Link
                                        key={t.id}
                                        href="/toolkit"
                                        className="flex items-start gap-3 p-3.5 rounded-xl border border-zinc-100 dark:border-zinc-700 hover:border-emerald-200 dark:hover:border-emerald-800 hover:bg-emerald-50/50 dark:hover:bg-emerald-900/10 transition-all group"
                                    >
                                        <span className="flex-shrink-0 w-6 h-6 rounded-full bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 text-xs font-bold flex items-center justify-center">
                                            {i + 1}
                                        </span>
                                        <div className="flex-1 min-w-0">
                                            <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200 group-hover:text-emerald-700 dark:group-hover:text-emerald-400 transition-colors">{t.name}</p>
                                            <p className="text-xs text-zinc-500 mt-0.5 line-clamp-2">{t.description}</p>
                                        </div>
                                    </Link>
                                ))
                            )}
                        </div>
                        <Link href="/toolkit" className="mt-4 inline-block text-xs text-emerald-600 hover:text-emerald-700 font-medium">
                            Browse all 200 traits →
                        </Link>
                    </div>
                </div>
            </main>
        </div>
    );
}
