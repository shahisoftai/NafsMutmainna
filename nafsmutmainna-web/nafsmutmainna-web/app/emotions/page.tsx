"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { appendLocalEmotionLog } from "@/lib/localDB";
import { useAuth } from "@/contexts/AuthProvider";

const EMOTION_OPTIONS = [
    { id: "anger", label: "😤 Anger", nafsName: "Ghadab (Anger)", color: "#E57373" },
    { id: "envy", label: "😠 Envy", nafsName: "Hasad (Envy)", color: "#BA68C8" },
    { id: "anxiety", label: "😰 Anxiety", nafsName: "Jaza (Chronic Anxiety)", color: "#FFB74D" },
    { id: "sadness", label: "😢 Sadness", nafsName: "Huzn al-Mamduh (Paralyzing Despair)", color: "#64B5F6" },
    { id: "greed", label: "🤑 Greed", nafsName: "Tama (Covetousness)", color: "#81C784" },
    { id: "pride", label: "😏 Pride", nafsName: "Kibr (Arrogance)", color: "#F06292" },
    { id: "frustration", label: "😤 Frustration", nafsName: "Ghadab (Anger)", color: "#E57373" },
    { id: "discontent", label: "😒 Discontent", nafsName: "Malal (Spiritual Boredom)", color: "#90A4AE" },
];

const INTENSITY_LABELS: Record<number, string> = {
    1: "Barely noticeable",
    2: "Mild",
    3: "Moderate",
    4: "Strong",
    5: "Overwhelming",
};

interface NafsAttribute {
    id: string;
    name: string;
    description: string;
    opposite_to: string;
    quran_ref: string[];
    hadith_ref: string[];
}

export default function EmotionsPage() {
    const router = useRouter();
    const supabase = createClient();
    const { user, isLoading: authLoading } = useAuth();

    const [selectedEmotion, setSelectedEmotion] = useState<(typeof EMOTION_OPTIONS)[0] | null>(null);
    const [intensity, setIntensity] = useState(3);
    const [trigger, setTrigger] = useState("");
    const [reflection, setReflection] = useState("");
    const [nafsAttr, setNafsAttr] = useState<NafsAttribute | null>(null);
    const [loadingAttr, setLoadingAttr] = useState(false);
    const [saving, setSaving] = useState(false);
    const [done, setDone] = useState(false);
    const [error, setError] = useState("");

    // Fetch matched nafs_attribute when emotion is selected
    useEffect(() => {
        if (!selectedEmotion) { setNafsAttr(null); return; }
        setLoadingAttr(true);
        supabase
            .from("nafs_attributes")
            .select("id, name, description, opposite_to, quran_ref, hadith_ref")
            .eq("name", selectedEmotion.nafsName)
            .maybeSingle()
            .then(({ data }) => { setNafsAttr(data); setLoadingAttr(false); });
    }, [selectedEmotion]);

    useEffect(() => {
        if (authLoading) return;
        if (!user) { router.push("/auth/login"); }
    }, [user, authLoading]);

    const handleSubmit = async () => {
        if (!selectedEmotion) return;
        if (!user) { router.push("/auth/login"); return; }
        setSaving(true);
        setError("");

        // Save to local DB — stays on device, never leaves browser
        appendLocalEmotionLog(user.id, new Date().toISOString().split("T")[0], {
            emotion: selectedEmotion.id,
            intensity,
            trigger: trigger.trim(),
            reflection: reflection.trim(),
            time: new Date().toISOString(),
        });

        setSaving(false);
        setDone(true);
    };

    if (done) {
        return (
            <PageShell>
                <div className="max-w-lg mx-auto text-center py-16">
                    <div className="text-6xl mb-6">✅</div>
                    <h2 className="text-2xl font-bold text-emerald-800 dark:text-emerald-400 mb-3">Emotion logged</h2>
                    <p className="text-zinc-600 dark:text-zinc-400 mb-8">
                        JazakAllah khair for reflecting on your inner state. Small awareness is the beginning of tazkiyah.
                    </p>
                    <div className="flex gap-4 justify-center flex-wrap">
                        <Link href="/dashboard" className="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-3 rounded-lg font-medium transition-colors">
                            Dashboard
                        </Link>
                        <button onClick={() => { setDone(false); setSelectedEmotion(null); setTrigger(""); setReflection(""); setIntensity(3); }} className="border border-emerald-600 text-emerald-600 hover:bg-emerald-50 px-6 py-3 rounded-lg font-medium transition-colors">
                            Log Another
                        </button>
                        <Link href="/toolkit" className="border border-zinc-300 text-zinc-600 hover:bg-zinc-50 px-6 py-3 rounded-lg font-medium transition-colors">
                            Open Toolkit
                        </Link>
                    </div>
                </div>
            </PageShell>
        );
    }

    return (
        <PageShell>
            <div className="max-w-2xl mx-auto">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-emerald-800 dark:text-emerald-400 mb-2">Log Emotion</h1>
                    <p className="text-zinc-600 dark:text-zinc-400">Identify what you're feeling and understand its root in the Nafs</p>
                </div>

                {error && <div className="mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-sm">{error}</div>}

                {/* Emotion Grid */}
                <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm mb-6">
                    <h2 className="font-semibold text-zinc-800 dark:text-zinc-200 mb-4">What are you feeling?</h2>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                        {EMOTION_OPTIONS.map((e) => (
                            <button
                                key={e.id}
                                onClick={() => setSelectedEmotion(e)}
                                className={`p-3 rounded-xl border-2 text-center transition-all text-sm font-medium ${selectedEmotion?.id === e.id ? "border-emerald-500 bg-emerald-50 dark:bg-emerald-900/30" : "border-zinc-200 dark:border-zinc-600 hover:border-emerald-300"}`}
                            >
                                {e.label}
                            </button>
                        ))}
                    </div>
                </div>

                {selectedEmotion && (
                    <>
                        {/* Intensity */}
                        <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm mb-6">
                            <h2 className="font-semibold text-zinc-800 dark:text-zinc-200 mb-4">
                                Intensity — <span className="text-emerald-600 font-normal">{INTENSITY_LABELS[intensity]}</span>
                            </h2>
                            <div className="flex gap-2">
                                {[1, 2, 3, 4, 5].map((n) => (
                                    <button
                                        key={n}
                                        onClick={() => setIntensity(n)}
                                        className={`flex-1 py-3 rounded-lg border-2 font-bold transition-all ${intensity === n ? "border-emerald-500 bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700" : "border-zinc-200 dark:border-zinc-600 text-zinc-500 hover:border-emerald-300"}`}
                                    >
                                        {n}
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* Nafs Insight Card */}
                        {loadingAttr && (
                            <div className="bg-emerald-50 dark:bg-emerald-900/20 rounded-xl p-6 mb-6 animate-pulse">
                                <div className="h-4 bg-emerald-200 rounded w-1/3 mb-3"></div>
                                <div className="h-3 bg-emerald-100 rounded w-full mb-2"></div>
                                <div className="h-3 bg-emerald-100 rounded w-3/4"></div>
                            </div>
                        )}
                        {nafsAttr && !loadingAttr && (
                            <div className="bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 rounded-xl p-6 mb-6">
                                <p className="text-xs font-bold text-emerald-600 uppercase tracking-wider mb-2">Root Trait in Nafs</p>
                                <h3 className="text-lg font-bold text-emerald-800 dark:text-emerald-300 mb-2">{nafsAttr.name}</h3>
                                <p className="text-sm text-zinc-600 dark:text-zinc-400 mb-4">{nafsAttr.description}</p>
                                <div className="flex items-center gap-2 text-sm">
                                    <span className="text-zinc-500">Its opposite virtue:</span>
                                    <span className="font-semibold text-emerald-700 dark:text-emerald-400">{nafsAttr.opposite_to}</span>
                                </div>
                                {nafsAttr.quran_ref.length > 0 && (
                                    <div className="mt-3 pt-3 border-t border-emerald-200 dark:border-emerald-700">
                                        <p className="text-xs text-zinc-400 mb-1">Quranic Reference</p>
                                        <p className="text-sm italic text-zinc-600 dark:text-zinc-400">{nafsAttr.quran_ref[0]}</p>
                                    </div>
                                )}
                            </div>
                        )}

                        {/* Trigger */}
                        <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm mb-6">
                            <h2 className="font-semibold text-zinc-800 dark:text-zinc-200 mb-2">What triggered this? <span className="text-zinc-400 font-normal text-sm">(optional)</span></h2>
                            <textarea
                                value={trigger}
                                onChange={(e) => setTrigger(e.target.value)}
                                placeholder="e.g., Saw someone's success on social media..."
                                rows={3}
                                className="w-full border border-zinc-300 dark:border-zinc-600 rounded-lg p-3 text-sm text-zinc-800 dark:text-zinc-200 bg-white dark:bg-zinc-700 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none"
                            />
                        </div>

                        {/* Reflection */}
                        <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm mb-6">
                            <h2 className="font-semibold text-zinc-800 dark:text-zinc-200 mb-2">Quick reflection <span className="text-zinc-400 font-normal text-sm">(optional)</span></h2>
                            <textarea
                                value={reflection}
                                onChange={(e) => setReflection(e.target.value)}
                                placeholder="How did you respond? What could you have done differently?"
                                rows={3}
                                className="w-full border border-zinc-300 dark:border-zinc-600 rounded-lg p-3 text-sm text-zinc-800 dark:text-zinc-200 bg-white dark:bg-zinc-700 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 resize-none"
                            />
                        </div>

                        <button
                            onClick={handleSubmit}
                            disabled={saving}
                            className="w-full bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 text-white py-4 rounded-xl font-semibold text-lg transition-colors"
                        >
                            {saving ? "Saving..." : "Log Emotion & Reflect"}
                        </button>
                    </>
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
