// Community board sample data (slides 9-12, Layout III).
// Every name and post here is made up. Never add real patient information.

export const TOPICS = [
  'New to PD',
  'Daily life',
  'Supplies',
  'Food & fluids',
  'Support',
  'Milestones',
  'Caregivers',
] as const;

export type Topic = (typeof TOPICS)[number];

export type Post = {
  id: string;
  author: string;
  topic: Topic;
  /** How long ago it was posted, e.g. '17h' or '2d'. */
  age: string;
  title: string;
  replies: number;
};

export const COMMUNITY_NOTE =
  'Tips here come from other patients. Ask your care team before changing your treatment.';

export const POSTS: Post[] = [
  {
    id: '1',
    author: 'Jimmy R.',
    topic: 'New to PD',
    age: '17h',
    title: "Hi everyone! I'm Jimmy and I'm a bit nervous about starting PD",
    replies: 29,
  },
  {
    id: '2',
    author: 'Maria L.',
    topic: 'Daily life',
    age: '2d',
    title: 'How do you pack all your supplies when you travel?',
    replies: 36,
  },
  {
    id: '3',
    author: 'Dana K.',
    topic: 'Milestones',
    age: '4h',
    title: '1 year on manual PD today! Thanks for all the support',
    replies: 24,
  },
  {
    id: '4',
    author: 'Henry T.',
    topic: 'Support',
    age: '23h',
    title: "I'm so proud of everyone here. Keep going!",
    replies: 18,
  },
  {
    id: '5',
    author: 'Priya S.',
    topic: 'Supplies',
    age: '1d',
    title: 'Finally organized my supply closet! Here is what worked for me',
    replies: 12,
  },
];
