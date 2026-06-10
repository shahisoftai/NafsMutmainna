// Theme system — provides a dark/light palette with `useTheme()` hook
// SRP: theme tokens only; no business logic

import { useColorScheme } from 'react-native';
import { useSettingsStore } from '../../infrastructure/store/settingsStore';

export interface Theme {
    name: 'light' | 'dark';
    colors: {
        primary: string;
        secondary: string;
        accent: string;
        background: string;
        surface: string;
        text: string;
        textSecondary: string;
        border: string;
        success: string;
        warning: string;
        error: string;
        ammarah: string;
        lawwamah: string;
        mutmainna: string;
    };
}

const light: Theme = {
    name: 'light',
    colors: {
        primary: '#1B4D3E',
        secondary: '#4A7C59',
        accent: '#C9A227',
        background: '#F5F5DC',
        surface: '#FFFFFF',
        text: '#1A1A1A',
        textSecondary: '#666666',
        border: '#E0E0E0',
        success: '#2E7D32',
        warning: '#F57C00',
        error: '#D32F2F',
        ammarah: '#E57373',
        lawwamah: '#FFB74D',
        mutmainna: '#81C784',
    },
};

const dark: Theme = {
    name: 'dark',
    colors: {
        primary: '#4A7C59',
        secondary: '#7FB48F',
        accent: '#E0BC3A',
        background: '#0F1F18',
        surface: '#1A2E26',
        text: '#F0F0F0',
        textSecondary: '#B5B5B5',
        border: '#2E3E37',
        success: '#66BB6A',
        warning: '#FFA726',
        error: '#EF5350',
        ammarah: '#EF9A9A',
        lawwamah: '#FFCC80',
        mutmainna: '#A5D6A7',
    },
};

/**
 * Resolves the active theme from:
 *  1. User preference in settings (auto | light | dark)
 *  2. OS color scheme (when auto)
 */
export function useTheme(): Theme {
    const system = useColorScheme();
    const pref = useSettingsStore((s) => s.themePreference);
    const resolved: 'light' | 'dark' =
        pref === 'auto' ? (system === 'dark' ? 'dark' : 'light') : pref;
    return resolved === 'dark' ? dark : light;
}
