import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';

const FEATURES = [
  { title: 'Discussion groups', description: 'Ask questions and share tips with other patients.' },
  { title: 'Patient stories', description: 'Read how others fit PD into their lives.' },
  { title: 'Local support', description: 'Find support groups near you.' },
];

export default function CommunityScreen() {
  return (
    <Screen title="Community" subtitle="Coming soon.">
      {FEATURES.map((feature) => (
        <Card key={feature.title}>
          <ThemedText type="smallBold">{feature.title}</ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            {feature.description}
          </ThemedText>
        </Card>
      ))}
    </Screen>
  );
}
