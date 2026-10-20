import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

// Placeholder steps. Replace with the procedure approved by the clinical team.
const STEPS = [
  'Clean your work area',
  'Wash and dry your hands',
  'Gather your supplies',
  'Check the new bag (strength, volume, expiry date, clear fluid, no leaks)',
  'Connect, drain, and fill as your nurse taught you',
  'Check that the drained fluid is clear',
  'Record the exchange in your log',
];

export default function ChecklistScreen() {
  const [done, setDone] = useState<boolean[]>(() => STEPS.map(() => false));
  const theme = useTheme();

  const toggle = (index: number) =>
    setDone((current) => current.map((value, i) => (i === index ? !value : value)));

  return (
    <Screen title="Checklist" subtitle="Placeholder steps for a manual exchange.">
      {STEPS.map((step, index) => (
        <Pressable
          key={step}
          onPress={() => toggle(index)}
          accessibilityRole="checkbox"
          accessibilityState={{ checked: done[index] }}
          style={({ pressed }) => pressed && styles.pressed}>
          <Card style={styles.row}>
            <View
              style={[
                styles.box,
                { borderColor: theme.text },
                done[index] && { backgroundColor: theme.text },
              ]}
            />
            <ThemedText type="small" style={styles.label}>
              {step}
            </ThemedText>
          </Card>
        </Pressable>
      ))}

      <Pressable
        onPress={() => setDone(STEPS.map(() => false))}
        style={({ pressed }) => pressed && styles.pressed}>
        <ThemedText type="linkPrimary">Reset checklist</ThemedText>
      </Pressable>
    </Screen>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
  },
  box: {
    width: 22,
    height: 22,
    borderWidth: 2,
    borderRadius: 6,
  },
  label: {
    flex: 1,
  },
  pressed: {
    opacity: 0.7,
  },
});
