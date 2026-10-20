import { Screen } from '@/components/screen';
import { ThemedText } from '@/components/themed-text';
import { Collapsible } from '@/components/ui/collapsible';

const LESSONS = [
  {
    title: 'What is peritoneal dialysis?',
    body: 'Placeholder: a plain-language overview of how PD uses the lining of your belly to clean your blood.',
  },
  {
    title: 'How a manual exchange works',
    body: 'Placeholder: the drain, fill, and dwell steps of a manual (CAPD) exchange.',
  },
  {
    title: 'Preventing infection',
    body: 'Placeholder: hand washing, catheter exit-site care, and keeping your space clean.',
  },
  {
    title: 'Diet and fluids',
    body: 'Placeholder: general guidance to discuss with your dietitian.',
  },
  {
    title: 'When to call your care team',
    body: 'Placeholder: warning signs your clinic wants to hear about right away.',
  },
];

export default function LearnScreen() {
  return (
    <Screen title="Learn" subtitle="Tap a topic to read the lesson.">
      {LESSONS.map((lesson) => (
        <Collapsible key={lesson.title} title={lesson.title}>
          <ThemedText type="small">{lesson.body}</ThemedText>
        </Collapsible>
      ))}
    </Screen>
  );
}
