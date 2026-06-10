// Main Tab Navigation — themed, accessible

import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../../src/presentation/theme';

export default function TabLayout() {
    const theme = useTheme();

    return (
        <Tabs
            screenOptions={{
                tabBarActiveTintColor: theme.colors.primary,
                tabBarInactiveTintColor: theme.colors.textSecondary,
                tabBarStyle: {
                    backgroundColor: theme.colors.surface,
                    borderTopColor: theme.colors.border,
                    paddingBottom: 8,
                    paddingTop: 8,
                    height: 64,
                },
                tabBarLabelStyle: {
                    fontSize: 11,
                    fontWeight: '600',
                },
                headerShown: false,
            }}
        >
            <Tabs.Screen
                name="index"
                options={{
                    title: 'Home',
                    tabBarAccessibilityLabel: 'Home dashboard',
                    tabBarIcon: ({ color, size }) => <Ionicons name="home-outline" size={size} color={color} accessibilityLabel="Home" />,
                }}
            />
            <Tabs.Screen
                name="emotions"
                options={{
                    title: 'Feelings',
                    tabBarAccessibilityLabel: 'Log emotions',
                    tabBarIcon: ({ color, size }) => <Ionicons name="heart-outline" size={size} color={color} accessibilityLabel="Feelings" />,
                }}
            />
            <Tabs.Screen
                name="toolkit"
                options={{
                    title: 'Toolkit',
                    tabBarAccessibilityLabel: 'Rectification toolkit',
                    tabBarIcon: ({ color, size }) => <Ionicons name="construct-outline" size={size} color={color} accessibilityLabel="Toolkit" />,
                }}
            />
            <Tabs.Screen
                name="learn"
                options={{
                    title: 'Learn',
                    tabBarAccessibilityLabel: 'Learn about Nafs',
                    tabBarIcon: ({ color, size }) => <Ionicons name="book-outline" size={size} color={color} accessibilityLabel="Learn" />,
                }}
            />
            <Tabs.Screen
                name="journal"
                options={{
                    title: 'Journal',
                    tabBarAccessibilityLabel: 'Muhasabah journal',
                    tabBarIcon: ({ color, size }) => <Ionicons name="journal-outline" size={size} color={color} accessibilityLabel="Journal" />,
                }}
            />
        </Tabs>
    );
}
