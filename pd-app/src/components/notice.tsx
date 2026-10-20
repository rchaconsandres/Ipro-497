import { StyleSheet, View } from 'react-native';

import { Icon } from '@/components/icon';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

type NoticeProps = {
  children: string;
  /** `info` for general guidance, `warning` for drafts and safety reminders. */
  tone?: 'info' | 'warning';
};

export function Notice({ children, tone = 'info' }: NoticeProps) {
  const theme = useTheme();
  const isWarning = tone === 'warning';

  return (
    <View
      style={[styles.notice, { backgroundColor: isWarning ? theme.warningSoft : theme.tintSoft }]}>
      <Icon
        ios={isWarning ? 'exclamationmark.triangle.fill' : 'info.circle.fill'}
        md={isWarning ? 'warning' : 'info'}
        color={isWarning ? theme.warning : theme.tint}
        size={20}
      />
      <ThemedText type="small" style={styles.text}>
        {children}
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  notice: {
    flexDirection: 'row',
    gap: Spacing.two,
    padding: Spacing.three,
    borderRadius: Spacing.three,
  },
  text: {
    flex: 1,
  },
});
