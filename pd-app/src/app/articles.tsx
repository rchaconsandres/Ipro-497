import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';

const ARTICLES = [
  { title: 'Living well on PD', minutes: 5 },
  { title: 'Planning meals with your dietitian', minutes: 4 },
  { title: 'Traveling with dialysis supplies', minutes: 6 },
  { title: 'Staying active during treatment', minutes: 3 },
];

export default function ArticlesScreen() {
  return (
    <Screen title="Articles" subtitle="Placeholder reading list.">
      {ARTICLES.map((article) => (
        <Card key={article.title}>
          <ThemedText type="smallBold">{article.title}</ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            {article.minutes} min read
          </ThemedText>
        </Card>
      ))}
    </Screen>
  );
}
