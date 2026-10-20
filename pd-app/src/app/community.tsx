import { useState } from 'react';
import { StyleSheet, TextInput, View } from 'react-native';

import { Card } from '@/components/card';
import { Chip } from '@/components/chip';
import { Icon } from '@/components/icon';
import { Notice } from '@/components/notice';
import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { COMMUNITY_NOTE, POSTS, TOPICS, type Topic } from '@/content/community';
import { useTheme } from '@/hooks/use-theme';

function initials(name: string) {
  return name
    .split(' ')
    .map((part) => part[0])
    .join('')
    .toUpperCase();
}

export default function CommunityScreen() {
  const theme = useTheme();
  const [query, setQuery] = useState('');
  const [topic, setTopic] = useState<Topic | null>(null);

  const search = query.trim().toLowerCase();
  const posts = POSTS.filter(
    (post) =>
      (topic === null || post.topic === topic) &&
      (search === '' || post.title.toLowerCase().includes(search)),
  );

  return (
    <Screen title="Community Board" subtitle="Questions, tips and wins from people living with PD.">
      <View style={[styles.search, { backgroundColor: theme.backgroundElement }]}>
        <Icon ios="magnifyingglass" md="search" color={theme.textSecondary} size={18} />
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder="Search posts and topics"
          placeholderTextColor={theme.textSecondary}
          accessibilityLabel="Search posts"
          style={[styles.searchInput, { color: theme.text }]}
        />
      </View>

      <View style={styles.topics}>
        <Chip label="All" selected={topic === null} onPress={() => setTopic(null)} />
        {TOPICS.map((item) => (
          <Chip
            key={item}
            label={item}
            selected={topic === item}
            onPress={() => setTopic(topic === item ? null : item)}
          />
        ))}
      </View>

      <View style={styles.sectionHeader}>
        <Icon
          ios="chart.line.uptrend.xyaxis"
          md="trending_up"
          color={theme.communityIcon}
          size={20}
        />
        <ThemedText type="smallBold" style={styles.sectionTitle}>
          Trending Discussions
        </ThemedText>
      </View>

      {posts.map((post) => (
        <Card key={post.id}>
          <View style={styles.postHeader}>
            <View style={[styles.avatar, { backgroundColor: theme.community }]}>
              <ThemedText type="smallBold" style={{ color: theme.communityIcon }}>
                {initials(post.author)}
              </ThemedText>
            </View>
            <View style={styles.flex}>
              <ThemedText type="smallBold">{post.author}</ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                {post.topic}
              </ThemedText>
            </View>
            <View style={[styles.ageBadge, { backgroundColor: theme.community }]}>
              <ThemedText type="small" style={{ color: theme.communityIcon }}>
                {post.age}
              </ThemedText>
            </View>
          </View>
          <ThemedText>{post.title}</ThemedText>
          <View style={styles.replies}>
            <Icon ios="bubble.left" md="chat_bubble_outline" color={theme.textSecondary} size={14} />
            <ThemedText type="small" themeColor="textSecondary">
              {post.replies} replies
            </ThemedText>
          </View>
        </Card>
      ))}

      {posts.length === 0 && (
        <ThemedText themeColor="textSecondary">No posts match your search.</ThemedText>
      )}

      <Notice>{COMMUNITY_NOTE}</Notice>

      {/* The board is read-only for now (Phase 4). Posting needs login and the API. */}
      <View style={[styles.createPost, { backgroundColor: theme.community }]}>
        <Icon ios="plus.circle.fill" md="add_circle" color={theme.communityIcon} size={22} />
        <ThemedText type="smallBold">Create Post</ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          (coming soon)
        </ThemedText>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  search: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.two,
    paddingHorizontal: Spacing.three,
    borderRadius: Spacing.three,
    minHeight: 48,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    paddingVertical: Spacing.two,
  },
  topics: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.two,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.two,
    paddingTop: Spacing.two,
  },
  sectionTitle: {
    fontSize: 18,
    lineHeight: 24,
  },
  postHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ageBadge: {
    paddingHorizontal: Spacing.two,
    paddingVertical: Spacing.half,
    borderRadius: Spacing.two,
  },
  replies: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.one,
  },
  createPost: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.two,
    minHeight: 56,
    borderRadius: Spacing.four,
  },
  flex: {
    flex: 1,
    gap: Spacing.half,
  },
});
