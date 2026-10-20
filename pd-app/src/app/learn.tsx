import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Card } from '@/components/card';
import { Icon } from '@/components/icon';
import { ProgressBar } from '@/components/progress-bar';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { JOURNEY, KEY_TAKEAWAY, LESSONS } from '@/content/lessons';
import { useTheme } from '@/hooks/use-theme';

export default function LearnScreen() {
  const theme = useTheme();
  // Progress lives only in memory for now; saving it per user comes with the API in Phase 2.
  const [completed, setCompleted] = useState<string[]>([]);
  const [openId, setOpenId] = useState<string | null>(null);

  const toggleComplete = (id: string) =>
    setCompleted((current) =>
      current.includes(id) ? current.filter((value) => value !== id) : [...current, id],
    );

  return (
    <Screen title="Learn" subtitle="Your personalized PD learning journey.">
      <Card style={{ backgroundColor: theme.learn }}>
        <View style={styles.journey}>
          {JOURNEY.map((step, index) => (
            <View key={step} style={styles.journeyStep}>
              {index > 0 && (
                <Icon ios="arrow.right" md="arrow_forward" color={theme.learnIcon} size={14} />
              )}
              <ThemedText type="smallBold" style={{ color: theme.learnIcon }}>
                {step}
              </ThemedText>
            </View>
          ))}
        </View>
        <ThemedText type="small">
          {completed.length} of {LESSONS.length} lessons complete
        </ThemedText>
        <ProgressBar progress={completed.length / LESSONS.length} />
      </Card>

      {LESSONS.map((lesson, index) => {
        const isDone = completed.includes(lesson.id);
        const isOpen = openId === lesson.id;

        return (
          <Card key={lesson.id}>
            <Pressable
              onPress={() => setOpenId(isOpen ? null : lesson.id)}
              accessibilityRole="button"
              accessibilityState={{ expanded: isOpen }}
              style={({ pressed }) => [styles.lessonRow, pressed && styles.pressed]}>
              <View
                style={[
                  styles.numberCircle,
                  { backgroundColor: isDone ? theme.success : theme.learn },
                ]}>
                {isDone ? (
                  <Icon ios="checkmark" md="check" color="#FFFFFF" size={18} />
                ) : (
                  <ThemedText type="smallBold" style={{ color: theme.learnIcon }}>
                    {index + 1}
                  </ThemedText>
                )}
              </View>
              <View style={styles.lessonText}>
                <ThemedText type="smallBold">{lesson.title}</ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  {lesson.minutes} min · {isDone ? 'Completed' : 'Not started'}
                </ThemedText>
              </View>
              <Icon
                ios={isOpen ? 'chevron.up' : 'chevron.down'}
                md={isOpen ? 'expand_less' : 'expand_more'}
                color={theme.textSecondary}
                size={18}
              />
            </Pressable>

            {isOpen && (
              <View style={styles.lessonBody}>
                <ThemedText>{lesson.objective}</ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  Coming soon: {lesson.activity}
                </ThemedText>
                <Pressable
                  onPress={() => toggleComplete(lesson.id)}
                  style={({ pressed }) => [
                    styles.button,
                    { backgroundColor: isDone ? theme.backgroundSelected : theme.tint },
                    pressed && styles.pressed,
                  ]}>
                  <ThemedText
                    type="smallBold"
                    style={{ color: isDone ? theme.text : theme.backgroundElement }}>
                    {isDone ? 'Mark as not complete' : 'Mark as complete'}
                  </ThemedText>
                </Pressable>
              </View>
            )}
          </Card>
        );
      })}

      <Card style={[styles.takeaway, { backgroundColor: theme.learn }]}>
        <Icon ios="lightbulb.fill" md="lightbulb" color={theme.warning} size={24} />
        <View style={styles.lessonText}>
          <ThemedText type="smallBold">Key Takeaway</ThemedText>
          <ThemedText type="small">{KEY_TAKEAWAY}</ThemedText>
        </View>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  journey: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    gap: Spacing.two,
  },
  journeyStep: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.two,
  },
  lessonRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
    minHeight: 48,
  },
  numberCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  lessonText: {
    flex: 1,
    gap: Spacing.half,
  },
  lessonBody: {
    gap: Spacing.three,
    paddingTop: Spacing.two,
  },
  button: {
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: Spacing.three,
  },
  takeaway: {
    flexDirection: 'row',
    gap: Spacing.three,
  },
  pressed: {
    opacity: 0.7,
  },
});
