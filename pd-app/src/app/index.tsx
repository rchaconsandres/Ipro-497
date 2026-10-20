import { Link, type Href } from 'expo-router';
import { Pressable, StyleSheet, View } from 'react-native';

import { Icon } from '@/components/icon';
import { Notice } from '@/components/notice';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing, type Section } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

type IconName = Parameters<typeof Icon>[0];

const SECTIONS: {
  section: Section;
  href: Href;
  title: string;
  description: string;
  icon: Pick<IconName, 'ios' | 'md'>;
}[] = [
  {
    section: 'learn',
    href: '/learn',
    title: 'Learn',
    description: 'Build your PD knowledge at your own pace',
    icon: { ios: 'book.fill', md: 'menu_book' },
  },
  {
    section: 'checklist',
    href: '/checklist',
    title: 'Checklist',
    description: 'Step-by-step support for your treatments',
    icon: { ios: 'checklist', md: 'checklist' },
  },
  {
    section: 'articles',
    href: '/articles',
    title: 'Articles',
    description: 'Helpful reads and tips for everyday living',
    icon: { ios: 'newspaper.fill', md: 'article' },
  },
  {
    section: 'community',
    href: '/community',
    title: 'Community',
    description: 'Connect, share, and learn from others',
    icon: { ios: 'person.3.fill', md: 'groups' },
  },
];

function getGreeting() {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good morning!';
  if (hour < 18) return 'Good afternoon!';
  return 'Good evening!';
}

export default function HomeScreen() {
  const theme = useTheme();

  return (
    <Screen title={getGreeting()} subtitle="You're taking an important step for your health.">
      {SECTIONS.map((item) => (
        <Link key={item.title} href={item.href} asChild>
          <Pressable
            accessibilityRole="link"
            style={({ pressed }) => [
              styles.sectionCard,
              { backgroundColor: theme[item.section] },
              pressed && styles.pressed,
            ]}>
            <View style={[styles.iconCircle, { backgroundColor: theme[`${item.section}Icon`] }]}>
              <Icon {...item.icon} color="#FFFFFF" size={26} />
            </View>
            <View style={styles.sectionText}>
              <ThemedText type="smallBold" style={styles.sectionTitle}>
                {item.title}
              </ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                {item.description}
              </ThemedText>
            </View>
            <Icon ios="chevron.right" md="chevron_right" color={theme.textSecondary} size={18} />
          </Pressable>
        </Link>
      ))}

      <Notice>
        This app is for education only. Always follow the instructions from your PD nurse and
        doctor. In an emergency, call your local emergency number.
      </Notice>
    </Screen>
  );
}

const styles = StyleSheet.create({
  sectionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
    padding: Spacing.three,
    borderRadius: Spacing.four,
    minHeight: 88,
  },
  iconCircle: {
    width: 52,
    height: 52,
    borderRadius: 26,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sectionText: {
    flex: 1,
    gap: Spacing.half,
  },
  sectionTitle: {
    fontSize: 18,
    lineHeight: 24,
  },
  pressed: {
    opacity: 0.7,
  },
});
