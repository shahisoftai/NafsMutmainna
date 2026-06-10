// Reusable presentation components — DRY: shared by auth + other screens
// Single-responsibility: each component does one thing, no business logic.

import React, { ReactNode } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TextInput,
    TextInputProps,
    StyleProp,
    ViewStyle,
    TextStyle,
} from 'react-native';
import { COLORS } from '../../shared/constants';

// ─── ArabicText ──────────────────────────────────────────────────────────────
// Renders Arabic content in a font/size that supports RTL + Naskh-style glyphs.

interface ArabicTextProps {
    text: string;
    style?: StyleProp<TextStyle>;
}

export const ArabicText: React.FC<ArabicTextProps> = ({ text, style }) => (
    <Text style={[styles.arabic, style]} allowFontScaling>
        {text}
    </Text>
);

// ─── ErrorBanner ─────────────────────────────────────────────────────────────

interface ErrorBannerProps {
    message: string;
}

export const ErrorBanner: React.FC<ErrorBannerProps> = ({ message }) => (
    <View
        style={styles.errorBanner}
        accessibilityRole="alert"
        accessibilityLiveRegion="polite"
    >
        <Text style={styles.errorIcon}>⚠️</Text>
        <Text style={styles.errorText}>{message}</Text>
    </View>
);

// ─── AuthLayout ──────────────────────────────────────────────────────────────

interface AuthLayoutProps {
    title: string;
    subtitle?: string;
    children: ReactNode;
}

export const AuthLayout: React.FC<AuthLayoutProps> = ({ title, subtitle, children }) => (
    <View style={styles.authLayout}>
        <View style={styles.authHeader}>
            <Text style={styles.authTitle}>{title}</Text>
            {subtitle ? <Text style={styles.authSubtitle}>{subtitle}</Text> : null}
        </View>
        <View style={styles.authContent}>{children}</View>
    </View>
);

// ─── AuthInput ───────────────────────────────────────────────────────────────

interface AuthInputProps extends TextInputProps {
    label: string;
    rightAdornment?: ReactNode;
}

export const AuthInput: React.FC<AuthInputProps> = ({
    label,
    rightAdornment,
    style,
    ...rest
}) => (
    <View style={styles.inputContainer}>
        <Text style={styles.inputLabel}>{label}</Text>
        <View style={styles.inputRow}>
            <TextInput
                style={[styles.input, style]}
                placeholderTextColor={COLORS.textSecondary}
                {...rest}
            />
            {rightAdornment && <View style={styles.adornment}>{rightAdornment}</View>}
        </View>
    </View>
);

// ─── EmptyState ──────────────────────────────────────────────────────────────

interface EmptyStateProps {
    icon?: string;
    title: string;
    description?: string;
    action?: ReactNode;
}

export const EmptyState: React.FC<EmptyStateProps> = ({ icon, title, description, action }) => (
    <View style={styles.emptyState}>
        {icon ? <Text style={styles.emptyIcon}>{icon}</Text> : null}
        <Text style={styles.emptyTitle}>{title}</Text>
        {description ? <Text style={styles.emptyDescription}>{description}</Text> : null}
        {action ? <View style={{ marginTop: 16 }}>{action}</View> : null}
    </View>
);

// ─── SectionHeader ───────────────────────────────────────────────────────────

interface SectionHeaderProps {
    title: string;
    subtitle?: string;
    right?: ReactNode;
}

export const SectionHeader: React.FC<SectionHeaderProps> = ({ title, subtitle, right }) => (
    <View style={styles.sectionHeader}>
        <View style={{ flex: 1 }}>
            <Text style={styles.sectionTitle}>{title}</Text>
            {subtitle ? <Text style={styles.sectionSubtitle}>{subtitle}</Text> : null}
        </View>
        {right}
    </View>
);

const styles = StyleSheet.create({
    arabic: {
        fontSize: 22,
        lineHeight: 38,
        color: COLORS.primary,
        textAlign: 'center',
        writingDirection: 'rtl',
    },
    errorBanner: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
        backgroundColor: '#FDECEA',
        borderLeftWidth: 4,
        borderLeftColor: COLORS.error,
        padding: 12,
        borderRadius: 8,
        marginBottom: 12,
    },
    errorIcon: { fontSize: 18 },
    errorText: { flex: 1, color: COLORS.error, fontSize: 13, fontWeight: '500' },

    authLayout: { paddingHorizontal: 24, flex: 1 },
    authHeader: { marginBottom: 24 },
    authTitle: { fontSize: 28, fontWeight: '800', color: COLORS.text },
    authSubtitle: { fontSize: 14, color: COLORS.textSecondary, marginTop: 6 },
    authContent: { flex: 1 },

    inputContainer: { marginBottom: 14 },
    inputLabel: {
        fontSize: 12,
        fontWeight: '700',
        color: COLORS.textSecondary,
        textTransform: 'uppercase',
        letterSpacing: 0.6,
        marginBottom: 6,
    },
    inputRow: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: COLORS.surface,
        borderRadius: 12,
        borderWidth: 1,
        borderColor: '#E0E0E0',
    },
    input: {
        flex: 1,
        paddingHorizontal: 14,
        paddingVertical: 14,
        fontSize: 15,
        color: COLORS.text,
    },
    adornment: { paddingHorizontal: 12 },

    emptyState: { alignItems: 'center', paddingVertical: 32, paddingHorizontal: 16 },
    emptyIcon: { fontSize: 40, marginBottom: 8 },
    emptyTitle: { fontSize: 16, fontWeight: '700', color: COLORS.text, textAlign: 'center' },
    emptyDescription: {
        fontSize: 13,
        color: COLORS.textSecondary,
        textAlign: 'center',
        marginTop: 6,
        lineHeight: 20,
    },

    sectionHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 4,
        marginBottom: 12,
    },
    sectionTitle: { fontSize: 18, fontWeight: '700', color: COLORS.text },
    sectionSubtitle: { fontSize: 12, color: COLORS.textSecondary, marginTop: 2 },
});
