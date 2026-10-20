import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Card } from '@/components/card';
import { Chip } from '@/components/chip';
import { Icon } from '@/components/icon';
import { Notice } from '@/components/notice';
import { ProgressBar } from '@/components/progress-bar';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { CHECKLIST_NOTE, CHECKLISTS, type Checklist } from '@/content/checklists';
import { useTheme } from '@/hooks/use-theme';

type ListId = Checklist['id'];

const emptyProgress = () =>
  Object.fromEntries(CHECKLISTS.map((list) => [list.id, list.steps.map(() => false)])) as Record<
    ListId,
    boolean[]
  >;

export default function ChecklistScreen() {
  const theme = useTheme();
  const [activeId, setActiveId] = useState<ListId>(CHECKLISTS[0].id);
  const [done, setDone] = useState(emptyProgress);

  const list = CHECKLISTS.find((item) => item.id === activeId) ?? CHECKLISTS[0];
  const checked = done[list.id];
  const checkedCount = checked.filter(Boolean).length;
  const allDone = checkedCount === list.steps.length;

  const toggle = (index: number) =>
    setDone((current) => ({
      ...current,
      [list.id]: current[list.id].map((value, i) => (i === index ? !value : value)),
    }));

  const reset = () =>
    setDone((current) => ({ ...current, [list.id]: list.steps.map(() => false) }));

  return (
    <Screen title="Treatment Checklist">
      <View style={styles.tabs}>
        {CHECKLISTS.map((item) => (
          <Chip
            key={item.id}
            label={item.label}
            selected={item.id === activeId}
            onPress={() => setActiveId(item.id)}
          />
        ))}
      </View>

      <Card style={{ backgroundColor: theme.checklist }}>
        <View style={styles.headingRow}>
          <Icon ios="checklist" md="checklist" color={theme.checklistIcon} size={28} />
          <View style={styles.flex}>
            <ThemedText type="smallBold" style={styles.heading}>
              {list.heading}
            </ThemedText>
            <ThemedText type="small">{list.intro}</ThemedText>
          </View>
        </View>
        <ThemedText type="small" themeColor="textSecondary">
          {checkedCount} of {list.steps.length} done
        </ThemedText>
        <ProgressBar progress={checkedCount / list.steps.length} />
      </Card>

      {list.steps.map((step, index) => (
        <Pressable
          key={step.title}
          onPress={() => toggle(index)}
          accessibilityRole="checkbox"
          accessibilityState={{ checked: checked[index] }}
          style={({ pressed }) => pressed && styles.pressed}>
          <Card style={styles.stepRow}>
            <View style={[styles.numberCircle, { backgroundColor: theme.checklist }]}>
              <ThemedText type="smallBold" style={{ color: theme.checklistIcon }}>
                {index + 1}
              </ThemedText>
            </View>
            <View style={styles.flex}>
              <ThemedText type="smallBold">{step.title}</ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                {step.detail}
              </ThemedText>
            </View>
            <View
              style={[
                styles.checkCircle,
                checked[index]
                  ? { backgroundColor: theme.success, borderColor: theme.success }
                  : { borderColor: theme.textSecondary },
              ]}>
              {checked[index] && <Icon ios="checkmark" md="check" color="#FFFFFF" size={16} />}
            </View>
          </Card>
        </Pressable>
      ))}

      {allDone && (
        <Card style={[styles.headingRow, { backgroundColor: theme.checklist }]}>
          <Icon ios="checkmark.seal.fill" md="verified" color={theme.success} size={28} />
          <ThemedText type="smallBold" style={styles.flex}>
            All steps checked. Nice work!
          </ThemedText>
        </Card>
      )}

      <Pressable onPress={reset} style={({ pressed }) => pressed && styles.pressed}>
        <ThemedText type="linkPrimary">Reset this checklist</ThemedText>
      </Pressable>

      <Notice tone="warning">{CHECKLIST_NOTE}</Notice>
    </Screen>
  );
}

const styles = StyleSheet.create({
  tabs: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.two,
  },
  headingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
  },
  heading: {
    fontSize: 18,
    lineHeight: 24,
  },
  stepRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
    minHeight: 72,
  },
  numberCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkCircle: {
    width: 28,
    height: 28,
    borderRadius: 14,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  flex: {
    flex: 1,
    gap: Spacing.half,
  },
  pressed: {
    opacity: 0.7,
  },
});
