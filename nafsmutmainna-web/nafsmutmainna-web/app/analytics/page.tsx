"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthProvider";

interface CheckinRow {
    checkin_date: string;
    overall_mood: number;
    nafs_stage_today: string;
}

interface EmotionRow {
    emotion: string;
    logged_at: string;
}

const MOOD_LABELS = ["", "Very Low", "Low", "Moderate", "Good", "Excellent"];
const MOOD_BAR_COLORS = ["", "bg-red-400", "bg-orange-400", "bg-amber-400", "bg-lime-500", "bg-emerald-500"];
const STAGE_COLORS: Record<string, string> = {
    ammarah: "text-red-500",
    lawwamah: "text-amber-500",
    mutmainna: "text-emerald-600",
};
const STAGE_BAR: Record<string, string> = {
    ammarah: "bg-red-400",
    lawwamah: "bg-amber-400",
    mutmainna: "bg-emerald-500",
};

function getLast7Days(): string[] {
    return Array.from({ length: 7 }, (_, i) => {
        const d = new Date();
        d.setDate(d.getDate() - (6 - i));
        return d.toISOString().slice(0, 10);
    });
}

function formatWeekday(dateStr: string) {
    return new Date(dateStr + "T12:00:00").toLocaleDateString("en-US", { weekday: "short" });
}

function formatDate(dateStr: string) {
    return new Date(dateStr + "T12:00:00").toLocaleDateString("en-US", { month: "short", day: "numeric" });
}

export default function AnalyticsPage() {
    const supabase = createClient();
    const router = useRouter();
    const { user, isLoading: authLoading } = useAuth();
    const [loading, setLoading] = useState(true);
    const [checkins, setCheckins] = useState<CheckinRow[]>([]);
    const [emotions, setEmotions] = useState<EmotionRow[]>([]);

    useEffect(() => {
        if (authLoading) return;
        if (!user) { router.push("/auth/login"); return; }
        async function load() {
            if (!user) return;

            const sevenDaysAgo = new Date();
            sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
            const sevenDaysAgoDate = sevenDaysAgo.toISOString().slice(0, 10);

            const [checkinsRes, emotionsRes] = await Promise.all([
                supabase
                    .from("daily_checkins")
                    .select("checkin_date, overall_mood, nafs_stage_today")
                    .eq("user_id", user.id)
                    .gte("checkin_date", sevenDaysAgoDate)
                    .order("checkin_date"),
                supabase
                    .from("emotion_logs")
                    .select("emotion, logged_at")
                    .eq("user_id", user.id)
                    .gte("logged_at", sevenDaysAgo.toISOString())
                    .order("logged_at", { ascending: false })
                    .limit(100),
            ]);

            setCheckins(checkinsRes.data ?? []);
            setEmotions(emotionsRes.data ?? []);
            setLoading(false);
        }
        load();
    }, [user, authLoading]);

    const last7 = getLast7Days();
    const checkinMap = Object.fromEntries(checkins.map((c) => [c.checkin_date, c]));

    // Mood average
    const moodValues = checkins.filter((c) => c.overall_mood > 0).map((c) => c.overall_mood);
    const avgMood = moodValues.length > 0
        ? (moodValues.reduce((a, b) => a + b, 0) / moodValues.length).toFixed(1)
        : null;

    // Stage distribution
    const stageCounts: Record<string, number> = {};
    for (const c of checkins) {
        const s = (c.nafs_stage_today ?? "").toLowerCase();
        if (s) stageCounts[s] = (stageCounts[s] ?? 0) + 1;
    }

    // Emotion frequency
    const emotionFreq: Record<string, number> = {};
    for (const e of emotions) {
        if (e.emotion) emotionFreq[e.emotion] = (emotionFreq[e.emotion] ?? 0) + 1;
    }
    const topEmotions = Object.entries(emotionFreq).sort((a, b) => b[1] - a[1]).slice(0, 8);
    const maxCount = Math.max(...topEmotions.map((e) => e[1]), 1);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-emerald-50 to-white dark:from-zinc-950 dark:to-zinc-900">
                <div className="text-emerald-600 animate-pulse">Loading analytics...</div>
            </div>
        );
    }

    const hasData = checkins.length > 0 || emotions.length > 0;

    return (
        <div className="min-h-screen bg-gradient-to-b from-emerald-50 to-white dark:from-zinc-950 dark:to-zinc-900">
            <header className="bg-white dark:bg-zinc-800 shadow-sm">
                <div className="container mx-auto px-4 py-4 flex items-center justify-between">
                    <Link href="/dashboard" className="text-xl font-bold text-emerald-800 dark:text-emerald-400">
                        NafsMutmainna
                    </Link>
                    <Link href="/dashboard" className="text-sm text-zinc-500 hover:text-emerald-600 transition-colors">
                        ← Dashboard
                    </Link>
                </div>
            </header>

            <main className="container mx-auto px-4 py-10 max-w-4xl">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-emerald-800 dark:text-emerald-400 mb-2">Analytics</h1>
                    <p className="text-zinc-500 dark:text-zinc-400">Your spiritual patterns over the last 7 days</p>
                </div>

                {!hasData ? (
                    <div className="bg-white dark:bg-zinc-800 rounded-2xl p-12 text-center shadow-sm">
                        <div className="text-5xl mb-4">📊</div>
                        <h2 className="text-xl font-bold text-zinc-700 dark:text-zinc-300 mb-2">No data yet</h2>
                        <p className="text-zinc-400 mb-6">Complete daily check-ins and log emotions to see your patterns here</p>
                        <Link href="/assessment" className="inline-block bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
                            Start Today&apos;s Check-in
                        </Link>
                    </div>
                ) : (
                    <div className="space-y-6">
                        {/* Summary stats */}
                        <div className="grid grid-cols-3 gap-4">
                            <div className="bg-white dark:bg-zinc-800 rounded-xl p-4 shadow-sm text-center">
                                <div className="text-3xl font-bold text-emerald-600">{checkins.length}<span className="text-sm text-zinc-400">/7</span></div>
                                <div className="text-xs text-zinc-500 mt-1">Check-ins this week</div>
                            </div>
                            <div className="bg-white dark:bg-zinc-800 rounded-xl p-4 shadow-sm text-center">
                                <div className="text-3xl font-bold text-amber-500">{avgMood ?? "—"}</div>
                                <div className="text-xs text-zinc-500 mt-1">Avg mood (out of 5)</div>
                            </div>
                            <div className="bg-white dark:bg-zinc-800 rounded-xl p-4 shadow-sm text-center">
                                <div className="text-3xl font-bold text-purple-500">{emotions.length}</div>
                                <div className="text-xs text-zinc-500 mt-1">Emotions logged</div>
                            </div>
                        </div>

                        {/* 7-Day Mood Chart */}
                        <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm">
                            <h2 className="font-bold text-zinc-800 dark:text-zinc-200 mb-1">7-Day Mood Chart</h2>
                            <p className="text-xs text-zinc-500 mb-6">Daily mood — 1 (very low) to 5 (excellent)</p>

                            <div className="flex items-end gap-2" style={{ height: "140px" }}>
                                {last7.map((date) => {
                                    const c = checkinMap[date];
                                    const mood = c?.overall_mood ?? 0;
                                    const stage = (c?.nafs_stage_today ?? "").toLowerCase();
                                    const barColor = mood ? MOOD_BAR_COLORS[mood] : "bg-zinc-100 dark:bg-zinc-700";
                                    const barHeight = mood ? `${mood * 20}%` : "6px";
                                    return (
                                        <div key={date} className="flex-1 flex flex-col items-center gap-1">
                                            {mood > 0 ? (
                                                <span className="text-xs font-bold text-zinc-600 dark:text-zinc-400">{mood}</span>
                                            ) : (
                                                <span className="text-xs text-transparent">0</span>
                                            )}
                                            <div className="w-full flex items-end" style={{ height: "100px" }}>
                                                <div
                                                    className={`w-full rounded-t-lg transition-all duration-700 ${barColor}`}
                                                    style={{ height: barHeight }}
                                                    title={mood ? `${MOOD_LABELS[mood]} — ${c?.nafs_stage_today ?? ""}` : "No check-in"}
                                                />
                                            </div>
                                            <span className="text-xs text-zinc-400 font-medium">{formatWeekday(date)}</span>
                                            {stage ? (
                                                <span className={`text-[10px] font-bold ${STAGE_COLORS[stage] ?? "text-zinc-400"}`}>
                                                    {stage.charAt(0).toUpperCase()}
                                                </span>
                                            ) : (
                                                <span className="text-[10px] text-transparent">–</span>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>

                            {/* Legend */}
                            <div className="mt-5 flex flex-wrap gap-x-4 gap-y-1">
                                {[1, 2, 3, 4, 5].map((m) => (
                                    <div key={m} className="flex items-center gap-1.5">
                                        <div className={`w-3 h-3 rounded-sm ${MOOD_BAR_COLORS[m]}`} />
                                        <span className="text-xs text-zinc-400">{MOOD_LABELS[m]}</span>
                                    </div>
                                ))}
                                <div className="flex items-center gap-1.5 ml-2 border-l border-zinc-200 dark:border-zinc-600 pl-2">
                                    <span className="text-[10px] text-red-500 font-bold">A</span>
                                    <span className="text-xs text-zinc-400">Ammarah</span>
                                    <span className="text-[10px] text-amber-500 font-bold ml-2">L</span>
                                    <span className="text-xs text-zinc-400">Lawwamah</span>
                                    <span className="text-[10px] text-emerald-600 font-bold ml-2">M</span>
                                    <span className="text-xs text-zinc-400">Mutmainna</span>
                                </div>
                            </div>
                        </div>

                        {/* Nafs Stage Distribution */}
                        {Object.keys(stageCounts).length > 0 && (
                            <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm">
                                <h2 className="font-bold text-zinc-800 dark:text-zinc-200 mb-4">Nafs Stage Distribution</h2>
                                <div className="space-y-4">
                                    {(["ammarah", "lawwamah", "mutmainna"] as const).map((stage) => {
                                        const count = stageCounts[stage] ?? 0;
                                        const pct = checkins.length > 0 ? Math.round((count / checkins.length) * 100) : 0;
                                        const labels = { ammarah: "Nafs Ammarah", lawwamah: "Nafs Lawwamah", mutmainna: "Nafs Mutmainna" };
                                        return (
                                            <div key={stage}>
                                                <div className="flex justify-between text-sm mb-1.5">
                                                    <span className={`font-semibold ${STAGE_COLORS[stage]}`}>{labels[stage]}</span>
                                                    <span className="text-zinc-500">{count} day{count !== 1 ? "s" : ""} &middot; {pct}%</span>
                                                </div>
                                                <div className="h-3 bg-zinc-100 dark:bg-zinc-700 rounded-full overflow-hidden">
                                                    <div
                                                        className={`h-full rounded-full transition-all duration-700 ${STAGE_BAR[stage]}`}
                                                        style={{ width: `${pct}%` }}
                                                    />
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}

                        {/* Emotion Patterns */}
                        {topEmotions.length > 0 ? (
                            <div className="bg-white dark:bg-zinc-800 rounded-2xl p-6 shadow-sm">
                                <h2 className="font-bold text-zinc-800 dark:text-zinc-200 mb-1">Emotion Patterns</h2>
                                <p className="text-xs text-zinc-500 mb-5">Most logged emotions in the last 7 days</p>
                                <div className="space-y-3">
                                    {topEmotions.map(([emotion, count]) => {
                                        const pct = Math.round((count / maxCount) * 100);
                                        return (
                                            <div key={emotion}>
                                                <div className="flex justify-between text-sm mb-1">
                                                    <span className="font-medium text-zinc-700 dark:text-zinc-300 capitalize">{emotion}</span>
                                                    <span className="text-zinc-400">{count}×</span>
                                                </div>
                                                <div className="h-2.5 bg-zinc-100 dark:bg-zinc-700 rounded-full overflow-hidden">
                                                    <div
                                                        className="h-full rounded-full bg-purple-400 transition-all duration-700"
                                                        style={{ width: `${pct}%` }}
                                                    />
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                                <div className="mt-5 flex gap-3">
                                    <Link href="/emotions" className="text-xs text-emerald-600 hover:text-emerald-700 font-medium">
                                        Log an emotion →
                                    </Link>
                                    <Link href="/toolkit" className="text-xs text-zinc-400 hover:text-zinc-600 font-medium">
                                        Explore remedies in Toolkit →
                                    </Link>
                                </div>
                            </div>
                        ) : (
                            <div className="bg-white dark:bg-zinc-800 rounded-2xl p-8 shadow-sm text-center">
                                <p className="text-zinc-400 text-sm">No emotions logged this week</p>
                                <Link href="/emotions" className="mt-3 inline-block text-sm text-emerald-600 hover:text-emerald-700 font-medium">
                                    Log an emotion →
                                </Link>
                            </div>
                        )}
                    </div>
                )}
            </main>
        </div>
    );
}
