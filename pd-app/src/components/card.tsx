import { StyleSheet } from 'react-native';

import { ThemedView, type ThemedViewProps } from '@/components/themed-view';
import { Spacing } from '@/constants/theme';

export function Card({ style, ...rest }: ThemedViewProps) {
  return <ThemedView type="backgroundElement" style={[styles.card, style]} {...rest} />;
}

const styles = StyleSheet.create({
  card: {
    gap: Spacing.two,
    padding: Spacing.three,
    borderRadius: Spacing.three,
  },
});
