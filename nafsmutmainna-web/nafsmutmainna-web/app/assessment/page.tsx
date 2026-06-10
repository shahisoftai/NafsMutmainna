"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { saveLocalCheckin } from "@/lib/localDB";
import { useAuth } from "@/contexts/AuthProvider";

const NAFS_STAGES = [
    {
        id: "ammarah",
        label: "Nafs Al-Ammarah",
        emoji: "🔥",
        desc: "Dominated by desires — anger, envy, pride feel very present",
        color: "red",
    },
    {
        id: "lawwamah",
        label: "Nafs Al-Lawwamah",
        emoji: "⚖️",
        desc: "Aware of flaws and actively working to improve — some struggle, some progress",
        color: "yellow",
    },
    {
        id: "mutmainna",
        label: "Nafs Al-Mutmainna",
        emoji: "🕊️",
        desc: "Feeling content, patient and close to Allah today",
        color: "emerald",
    },
];

const MOOD_LABELS: Record<number, string> = {
    1: "Very Low",
    2: "Low",
    3: "Neutral",
    4: "Good",
    5: "Excellent",
};

export default function AssessmentPage() {
    const router = useRouter();
    const supabase = createClient();
    const { user, isLoading: authLoading } = useAuth();

    const [step, setStep] = useState<"mood" | "stage" | "notes" | "done">("mood");
    const [mood, setMood] = useState<number | null>(null);
    const [stage, setStage] = useState<string | null>(null);
    const [notes, setNotes] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    useEffect(() => {
        if (authLoading) return;
        if (!user) { router.push("/auth/login"); }
    }, [user, authLoading]);

    const handleSubmit = async () => {
        if (!user) { router.push("/auth/login"); return; }
        setLoading(true);
        setError("");

        const today = new Date().toISOString().split("T")[0];

        // Save to Supabase for analytics
        const { error: err } = await supabase
            .from("daily_checkins")
            .upsert({
                user_id: user.id,
                checkin_date: today,
                overall_mood: mood,
                nafs_stage_today: stage,
                notes: notes.trim() || null,
            }, { onConflict: "user_id,checkin_date" });

        if (err) { setLoading(false); setError(err.message); return; }

        // Save to local DB (localDB.ts) — stays on device
        saveLocalCheckin(user.id, today, {
            mood,
            stage: stage!,
            notes: notes.trim(),
            time: new Date().toISOString(),
        });

        setLoading(false);
        setStep("done");
    };

    if (step === "done") {
        return (
            <PageShell>
                <div className="max-w-lg mx-auto text-center py-16">
                    <div className="text-6xl mb-6">✅</div>
                    <h2 className="text-2xl font-bold text-emerald-800 dark:text-emerald-400 mb-3">Check-in complete!</h2>
                    <p className="text-zinc-600 dark:text-zinc-400 mb-8">
                        JazakAllah khair for taking a moment to reflect on your Nafs today.
                    </p>
                    <div className="flex gap-4 justify-center">
                        <Link href="/dashboard" className="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-medium transition-colors">
                            Back to Dashboard
                        </Link>
                        <Link href="/journal" className="border border-emerald-600 text-emerald-600 hover:bg-emerald-50 px-6 py-3 rounded-lg font-medium transition-colors">
                            Write in Journal
                        </Link>
                    </div>
                </div>
            </PageShell>
        );
    }

    return (
        <PageShell>
            <div className="max-w-xl mx-auto">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-emerald-800 dark:text-emerald-400 mb-2">Daily Check-in</h1>
                    <p className="text-zinc-600 dark:text-zinc-400">Assess your Nafs state today — takes 1 minute</p>
                </div>

                {/* Progress */}
                <div className="flex gap-2 mb-8">
                    {["mood", "stage", "notes"].map((s, i) => (
                        <div key={s} className={`h-2 flex-1 rounded-full ${i <= ["mood", "stage", "notes"].indexOf(step) ? "bg-emerald-500" : "bg-zinc-200 dark:bg-zinc-700"}`} />
                    ))}
                </div>

                {error && <div className="mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-sm">{error}</div>}

                {/* Step 1: Mood */}
                {step === "mood" && (
                    <div className="bg-white dark:bg-zinc-800 rounded-xl p-8 shadow-sm">
                        <h2 className="text-xl font-semibold text-zinc-800 dark:text-zinc-200 mb-6">
                            How is your overall mood today?
                        </h2>
                        <div className="flex justify-between gap-2 mb-8">
                            {[1, 2, 3, 4, 5].map((n) => (
                                <button
                                    key={n}
                                    onClick={() => setMood(n)}
                                    className={`flex-1 py-4 rounded-xl border-2 text-center transition-all ${mood === n ? "border-emerald-500 bg-emerald-50 dark:bg-emerald-900/30" : "border-zinc-200 dark:border-zinc-600 hover:border-emerald-300"}`}
                                >
                                    <div className="text-2xl mb-1">{["😔", "😕", "😐", "🙂", "😊"][n - 1]}</div>
                                    <div className="text-xs text-zinc-500">{MOOD_LABELS[n]}</div>
                                </button>
                            ))}
                        </div>
                        <button
                            disabled={!mood}
                            onClick={() => setStep("stage")}
                            className="w-full bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 text-white py-3 rounded-lg font-medium transition-colors"
                        >
                            Next →
                        </button>
                    </div>
                )}

                {/* Step 2: Nafs Stage */}
                {step === "stage" && (
                    <div className="bg-white dark:bg-zinc-800 rounded-xl p-8 shadow-sm">
                        <h2 className="text-xl font-semibold text-zinc-800 dark:text-zinc-200 mb-6">
                            Which best describes your Nafs today?
                        </h2>
                        <div className="space-y-3 mb-8">
                            {NAFS_STAGES.map((s) => (
                                <button
                                    key={s.id}
                                    onClick={() => setStage(s.id)}
                                    className={`w-full text-left p-4 rounded-xl border-2 transition-all ${stage === s.id ? "border-emerald-500 bg-emerald-50 dark:bg-emerald-900/30" : "border-zinc-200 dark:border-zinc-600 hover:border-emerald-300"}`}
                                >
                                    <div className="flex items-start gap-3">
                                        <span className="text-2xl">{s.emoji}</span>
                                        <div>
                                            <div className="font-semibold text-zinc-800 dark:text-zinc-200">{s.label}</div>
                                            <div className="text-sm text-zinc-500 mt-1">{s.desc}</div>
                                        </div>
                                    </div>
                                </button>
                            ))}
                        </div>
                        <div className="flex gap-3">
                            <button onClick={() => setStep("mood")} className="flex-1 border border-zinc-300 dark:border-zinc-600 py-3 rounded-lg font-medium text-zinc-600 dark:text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-700 transition-colors">
                                ← Back
                            </button>
                            <button
                                disabled={!stage}
                                onClick={() => setStep("notes")}
                                className="flex-1 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 text-white py-3 rounded-lg font-medium transition-colors"
                            >
                                Next →
                            </button>
                        </div>
                    </div>
                )}

                {/* Step 3: Notes */}
                {step === "notes" && (
                    <div className="bg-white dark:bg-zinc-800 rounded-xl p-8 shadow-sm">
                        <h2 className="text-xl font-semibold text-zinc-800 dark:text-zinc-200 mb-2">
                            Anything specific on your heart? <span className="text-zinc-400 font-normal text-base">(optional)</span>
                        </h2>
                        <p className="text-sm text-zinc-500 mb-6">A struggle, a blessing, or a moment of clarity.</p>
                        <textarea
                            value={notes}
                            onChange={(e) => setNotes(e.target.value)}
                            placeholder="e.g., Felt impatient in the morning but made istighfar after..."
                            rows={5}
                            className="w-full border border-zinc-300 dark:border-zinc-600 rounded-lg p-4 text-zinc-800 dark:text-zinc-200 bg-white dark:bg-zinc-700 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 mb-6 resize-none"
                        />
                        <div className="flex gap-3">
                            <button onClick={() => setStep("stage")} className="flex-1 border border-zinc-300 dark:border-zinc-600 py-3 rounded-lg font-medium text-zinc-600 dark:text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-700 transition-colors">
                                ← Back
                            </button>
                            <button
                                onClick={handleSubmit}
                                disabled={loading}
                                className="flex-1 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 text-white py-3 rounded-lg font-medium transition-colors"
                            >
                                {loading ? "Saving..." : "Complete Check-in ✓"}
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </PageShell>
    );
}

function PageShell({ children }: { children: React.ReactNode }) {
    return (
        <div className="min-h-screen bg-gradient-to-b from-emerald-50 to-white dark:from-black dark:to-zinc-900">
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
            <main className="container mx-auto px-4 py-10">{children}</main>
        </div>
    );
}
