import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Card } from '@/components/card';
import { ExternalLink } from '@/components/external-link';
import { Icon } from '@/components/icon';
import { Notice } from '@/components/notice';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { ARTICLES } from '@/content/articles';
import { useTheme } from '@/hooks/use-theme';

export default function ArticlesScreen() {
  const theme = useTheme();
  const [openId, setOpenId] = useState<string | null>(null);

  return (
    <Screen title="Articles" subtitle="Helpful reads and tips for everyday living.">
      {ARTICLES.map((article) => {
        const isOpen = openId === article.id;

        return (
          <Card key={article.id}>
            <Pressable
              onPress={() => setOpenId(isOpen ? null : article.id)}
              accessibilityRole="button"
              accessibilityState={{ expanded: isOpen }}
              style={({ pressed }) => [styles.header, pressed && styles.pressed]}>
              <View style={[styles.iconTile, { backgroundColor: theme.articles }]}>
                <Icon ios="doc.text.fill" md="article" color={theme.articlesIcon} size={24} />
              </View>
              <View style={styles.flex}>
                <ThemedText type="smallBold">{article.title}</ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  {article.summary}
                </ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  {article.minutes} min read
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
              <View style={styles.body}>
                {article.reviewNote && <Notice tone="warning">{article.reviewNote}</Notice>}

                {article.sections.map((section) => (
                  <View key={section.heading} style={styles.section}>
                    <ThemedText type="smallBold" style={{ color: theme.articlesIcon }}>
                      {section.heading}
                    </ThemedText>
                    {section.points.map((point) => (
                      <View key={point} style={styles.bullet}>
                        <ThemedText type="small">•</ThemedText>
                        <ThemedText type="small" style={styles.flex}>
                          {point}
                        </ThemedText>
                      </View>
                    ))}
                  </View>
                ))}

                {article.sources.length > 0 && (
                  <View style={styles.section}>
                    <ThemedText type="smallBold">Sources</ThemedText>
                    {article.sources.map((source) => (
                      <ExternalLink key={source} href={source}>
                        <ThemedText type="linkPrimary">{source}</ThemedText>
                      </ExternalLink>
                    ))}
                  </View>
                )}
              </View>
            )}
          </Card>
        );
      })}
    </Screen>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
  },
  iconTile: {
    width: 48,
    height: 48,
    borderRadius: Spacing.three,
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: {
    gap: Spacing.three,
    paddingTop: Spacing.two,
  },
  section: {
    gap: Spacing.one,
  },
  bullet: {
    flexDirection: 'row',
    gap: Spacing.two,
  },
  flex: {
    flex: 1,
    gap: Spacing.half,
  },
  pressed: {
    opacity: 0.7,
  },
});
