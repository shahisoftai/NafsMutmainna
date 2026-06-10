"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthProvider";

interface NafsAttribute {
    id: string;
    name: string;
    category: "negative" | "positive";
    description: string;
    opposite_to: string;
    quran_ref: string[];
    hadith_ref: string[];
}

const DHIKR_BY_TRAIT: Record<string, { dhikr: string; arabic: string; count: number; instruction: string }[]> = {
    "Ghadab (Anger)": [
        { dhikr: "Astaghfirullah", arabic: "أَسْتَغْفِرُ اللَّهَ", count: 33, instruction: "Sit down, take 3 deep breaths first" },
        { dhikr: "A'udhu billahi min ash-shaytan", arabic: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ", count: 3, instruction: "Seek refuge from Shaytan" },
    ],
    "Hasad (Envy)": [
        { dhikr: "Allahumma barik lahu", arabic: "اللَّهُمَّ بَارِكْ لَهُ", count: 7, instruction: "Pray for the person you feel envious of" },
        { dhikr: "Alhamdulillah ala kulli hal", arabic: "الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ", count: 33, instruction: "Count your own blessings" },
    ],
    "Jaza (Chronic Anxiety)": [
        { dhikr: "Hasbunallahu wa ni'mal wakeel", arabic: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ", count: 100, instruction: "Recite slowly, connect with meaning" },
        { dhikr: "La hawla wa la quwwata illa billah", arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", count: 33, instruction: "No power except through Allah" },
    ],
    "Kibr (Arrogance)": [
        { dhikr: "Subhanaka Allahumma wa bihamdik", arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ", count: 33, instruction: "Glorify Allah, remember your dependence" },
    ],
    "Tama (Covetousness)": [
        { dhikr: "Alhamdulillah", arabic: "الْحَمْدُ لِلَّهِ", count: 100, instruction: "Focus on what you already have" },
    ],
};

const DEFAULT_DHIKR = [
    { dhikr: "Subhanallah", arabic: "سُبْحَانَ اللَّهِ", count: 33, instruction: "Glorify Allah" },
    { dhikr: "Alhamdulillah", arabic: "الْحَمْدُ لِلَّهِ", count: 33, instruction: "Praise Allah" },
    { dhikr: "Allahu Akbar", arabic: "اللَّهُ أَكْبَرُ", count: 33, instruction: "Allah is the Greatest" },
];

export default function ToolkitPage() {
    const supabase = createClient();
    const router = useRouter();
    const { user, isLoading: authLoading } = useAuth();
    const [traits, setTraits] = useState<NafsAttribute[]>([]);
    const [loading, setLoading] = useState(true);
    const [selected, setSelected] = useState<NafsAttribute | null>(null);
    const [filter, setFilter] = useState<"all" | "negative" | "positive">("negative");
    const [search, setSearch] = useState("");

    useEffect(() => {
        if (authLoading) return;
        if (!user) { router.push("/auth/login"); return; }
        supabase
            .from("nafs_attributes")
            .select("id, name, category, description, opposite_to, quran_ref, hadith_ref")
            .order("name")
            .then(({ data }) => { setTraits(data ?? []); setLoading(false); });
    }, [user, authLoading]);

    const filtered = traits.filter((t) => {
        const matchCat = filter === "all" || t.category === filter;
        const matchSearch = search === "" || t.name.toLowerCase().includes(search.toLowerCase()) || t.description.toLowerCase().includes(search.toLowerCase());
        return matchCat && matchSearch;
    });

    const dhikrList = selected ? (DHIKR_BY_TRAIT[selected.name] ?? DEFAULT_DHIKR) : [];

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

            <main className="container mx-auto px-4 py-10">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-emerald-800 dark:text-emerald-400 mb-2">Rectification Toolkit</h1>
                    <p className="text-zinc-600 dark:text-zinc-400">Explore 200 nafs traits and their Islamic remedies</p>
                </div>

                <div className="flex flex-col lg:flex-row gap-6">
                    {/* Traits List */}
                    <div className="lg:w-2/5 xl:w-1/3">
                        {/* Filters */}
                        <div className="bg-white dark:bg-zinc-800 rounded-xl p-4 shadow-sm mb-4">
                            <input
                                type="text"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                placeholder="Search traits..."
                                className="w-full border border-zinc-200 dark:border-zinc-600 rounded-lg px-3 py-2 text-sm text-zinc-800 dark:text-zinc-200 bg-white dark:bg-zinc-700 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 mb-3"
                            />
                            <div className="flex gap-2">
                                {(["all", "negative", "positive"] as const).map((f) => (
                                    <button
                                        key={f}
                                        onClick={() => setFilter(f)}
                                        className={`flex-1 py-1.5 rounded-lg text-xs font-semibold capitalize transition-all ${filter === f ? "bg-emerald-600 text-white" : "bg-zinc-100 dark:bg-zinc-700 text-zinc-500 hover:bg-zinc-200 dark:hover:bg-zinc-600"}`}
                                    >
                                        {f === "negative" ? "🔴 Negative" : f === "positive" ? "🟢 Positive" : "All"}
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* List */}
                        <div className="bg-white dark:bg-zinc-800 rounded-xl shadow-sm overflow-hidden">
                            {loading ? (
                                <div className="p-4 space-y-3">
                                    {[1, 2, 3, 4, 5].map((i) => (
                                        <div key={i} className="h-12 bg-zinc-100 dark:bg-zinc-700 rounded-lg animate-pulse"></div>
                                    ))}
                                </div>
                            ) : filtered.length === 0 ? (
                                <div className="p-8 text-center text-zinc-400 text-sm">No traits found</div>
                            ) : (
                                <div className="divide-y divide-zinc-100 dark:divide-zinc-700 max-h-[65vh] overflow-y-auto">
                                    {filtered.map((t) => (
                                        <button
                                            key={t.id}
                                            onClick={() => setSelected(t)}
                                            className={`w-full text-left px-4 py-3 transition-colors ${selected?.id === t.id ? "bg-emerald-50 dark:bg-emerald-900/30" : "hover:bg-zinc-50 dark:hover:bg-zinc-700"}`}
                                        >
                                            <div className="flex items-center gap-2">
                                                <span className={`w-2 h-2 rounded-full flex-shrink-0 ${t.category === "negative" ? "bg-red-400" : "bg-emerald-500"}`}></span>
                                                <span className="text-sm font-medium text-zinc-800 dark:text-zinc-200">{t.name}</span>
                                            </div>
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Detail Panel */}
                    <div className="lg:flex-1">
                        {!selected ? (
                            <div className="bg-white dark:bg-zinc-800 rounded-xl p-12 shadow-sm text-center">
                                <div className="text-5xl mb-4">👈</div>
                                <p className="text-zinc-400">Select a trait to see its description, Quranic guidance, and dhikr remedies</p>
                            </div>
                        ) : (
                            <div className="space-y-5">
                                {/* Trait Header */}
                                <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm">
                                    <div className="flex items-start justify-between mb-3">
                                        <div>
                                            <span className={`inline-block text-xs font-bold px-3 py-1 rounded-full mb-3 ${selected.category === "negative" ? "bg-red-100 text-red-600 dark:bg-red-900/30 dark:text-red-400" : "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400"}`}>
                                                {selected.category === "negative" ? "Blameworthy (Madhmum)" : "Praiseworthy (Mahmud)"}
                                            </span>
                                            <h2 className="text-2xl font-bold text-zinc-800 dark:text-zinc-200">{selected.name}</h2>
                                        </div>
                                    </div>
                                    <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed mb-4">{selected.description}</p>
                                    <div className="flex items-center gap-2 p-3 bg-zinc-50 dark:bg-zinc-700 rounded-lg">
                                        <span className="text-sm text-zinc-500">Opposite virtue/vice:</span>
                                        <span className="text-sm font-semibold text-emerald-700 dark:text-emerald-400">{selected.opposite_to}</span>
                                    </div>
                                </div>

                                {/* Dhikr Remedies */}
                                <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm">
                                    <h3 className="font-bold text-zinc-800 dark:text-zinc-200 mb-4">
                                        {selected.category === "negative" ? "Dhikr Remedies" : "Dhikr to Strengthen This Trait"}
                                    </h3>
                                    <div className="space-y-4">
                                        {dhikrList.map((d, i) => (
                                            <div key={i} className="border border-emerald-100 dark:border-emerald-800 rounded-xl p-4 bg-emerald-50/50 dark:bg-emerald-900/10">
                                                <div className="flex items-center justify-between mb-2">
                                                    <span className="font-semibold text-zinc-800 dark:text-zinc-200">{d.dhikr}</span>
                                                    <span className="text-xs bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400 px-2 py-1 rounded-full font-bold">×{d.count}</span>
                                                </div>
                                                <p className="text-2xl text-right text-zinc-700 dark:text-zinc-300 font-arabic mb-2 leading-loose">{d.arabic}</p>
                                                <p className="text-xs text-zinc-500">{d.instruction}</p>
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                {/* Quran Refs */}
                                {selected.quran_ref.length > 0 && (
                                    <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm">
                                        <h3 className="font-bold text-zinc-800 dark:text-zinc-200 mb-4">📖 Quranic References</h3>
                                        <div className="space-y-3">
                                            {selected.quran_ref.map((ref, i) => (
                                                <div key={i} className="border-l-4 border-emerald-500 pl-4 py-1">
                                                    <p className="text-sm text-zinc-600 dark:text-zinc-400">{ref}</p>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Hadith Refs */}
                                {selected.hadith_ref.length > 0 && (
                                    <div className="bg-white dark:bg-zinc-800 rounded-xl p-6 shadow-sm">
                                        <h3 className="font-bold text-zinc-800 dark:text-zinc-200 mb-4">📜 Hadith References</h3>
                                        <div className="space-y-3">
                                            {selected.hadith_ref.map((ref, i) => (
                                                <div key={i} className="border-l-4 border-amber-400 pl-4 py-1">
                                                    <p className="text-sm text-zinc-600 dark:text-zinc-400 italic">{ref}</p>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </div>
            </main>
        </div>
    );
}
