import { Link, type Href } from 'expo-router';
import { Pressable, StyleSheet } from 'react-native';

import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';

const SECTIONS: { href: Href; title: string; description: string }[] = [
  { href: '/learn', title: 'Learn', description: 'Short lessons about manual PD.' },
  { href: '/checklist', title: 'Checklist', description: 'Step-by-step exchange checklist.' },
  { href: '/articles', title: 'Articles', description: 'Reading on diet, fluids, and daily life.' },
  { href: '/community', title: 'Community', description: 'Connect with other PD patients.' },
];

export default function HomeScreen() {
  return (
    <Screen title="Welcome" subtitle="Your guide to manual peritoneal dialysis.">
      <Card>
        <ThemedText type="smallBold">Placeholder notice</ThemedText>
        <ThemedText type="small">
          This app is for education only. Always follow the instructions from your PD nurse and
          doctor. In an emergency, call your local emergency number.
        </ThemedText>
      </Card>

      {SECTIONS.map((section) => (
        <Link key={section.title} href={section.href} asChild>
          <Pressable style={({ pressed }) => pressed && styles.pressed}>
            <Card>
              <ThemedText type="smallBold">{section.title}</ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                {section.description}
              </ThemedText>
            </Card>
          </Pressable>
        </Link>
      ))}
    </Screen>
  );
}

const styles = StyleSheet.create({
  pressed: {
    opacity: 0.7,
  },
});
