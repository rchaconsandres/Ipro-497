/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://unistyl.es/), etc.
 */

import '@/global.css';

import { Platform } from 'react-native';

export const Colors = {
  light: {
    text: '#13233A',
    background: '#EEF5FB',
    backgroundElement: '#FFFFFF',
    backgroundSelected: '#DCEAF7',
    textSecondary: '#5B6B7C',
    tint: '#2A6FDB',
    tintSoft: '#DCE9FB',
    success: '#2E9E6A',
    warning: '#B86E00',
    warningSoft: '#FFF1DC',
    // One soft background + strong icon color per app section.
    learn: '#DCEBFB',
    learnIcon: '#2A6FDB',
    checklist: '#DDF3EA',
    checklistIcon: '#2E9E6A',
    articles: '#ECE6FB',
    articlesIcon: '#7B5CD6',
    community: '#FDE8D7',
    communityIcon: '#D9702A',
  },
  dark: {
    text: '#F2F6FA',
    background: '#0B1520',
    backgroundElement: '#16222F',
    backgroundSelected: '#22303F',
    textSecondary: '#A3B1C0',
    tint: '#6EA8FF',
    tintSoft: '#1D3350',
    success: '#4CC38A',
    warning: '#F2B259',
    warningSoft: '#3A2A12',
    learn: '#1A2E48',
    learnIcon: '#6EA8FF',
    checklist: '#16352A',
    checklistIcon: '#4CC38A',
    articles: '#2A2445',
    articlesIcon: '#A68CFF',
    community: '#3A2718',
    communityIcon: '#F2A066',
  },
} as const;

export type Section = 'learn' | 'checklist' | 'articles' | 'community';

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = Platform.select({
  ios: {
    /** iOS `UIFontDescriptorSystemDesignDefault` */
    sans: 'system-ui',
    /** iOS `UIFontDescriptorSystemDesignSerif` */
    serif: 'ui-serif',
    /** iOS `UIFontDescriptorSystemDesignRounded` */
    rounded: 'ui-rounded',
    /** iOS `UIFontDescriptorSystemDesignMonospaced` */
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: 'var(--font-display)',
    serif: 'var(--font-serif)',
    rounded: 'var(--font-rounded)',
    mono: 'var(--font-mono)',
  },
});

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const BottomTabInset = Platform.select({ ios: 50, android: 80 }) ?? 0;
export const MaxContentWidth = 800;
