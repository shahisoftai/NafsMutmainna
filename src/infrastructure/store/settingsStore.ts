// Settings store — user preferences (theme, language, notifications)
// Separate from main app store to keep concerns isolated (SRP)

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export type ThemePreference = 'auto' | 'light' | 'dark';
export type Language = 'en' | 'ur' | 'ar';

interface SettingsState {
    themePreference: ThemePreference;
    language: Language;
    notificationsEnabled: boolean;
    hapticsEnabled: boolean;

    setThemePreference: (pref: ThemePreference) => void;
    setLanguage: (lang: Language) => void;
    setNotificationsEnabled: (enabled: boolean) => void;
    setHapticsEnabled: (enabled: boolean) => void;
}

export const useSettingsStore = create<SettingsState>()(
    persist(
        (set) => ({
            themePreference: 'auto',
            language: 'en',
            notificationsEnabled: false,
            hapticsEnabled: true,

            setThemePreference: (pref) => set({ themePreference: pref }),
            setLanguage: (lang) => set({ language: lang }),
            setNotificationsEnabled: (enabled) => set({ notificationsEnabled: enabled }),
            setHapticsEnabled: (enabled) => set({ hapticsEnabled: enabled }),
        }),
        {
            name: 'nafs-settings',
            storage: createJSONStorage(() => AsyncStorage),
        }
    )
);
