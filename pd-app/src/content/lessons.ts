// Lesson plan from the Education Group status update (slide 5).
// Wording is draft and must be reviewed by the clinical team.

export type Lesson = {
  id: string;
  title: string;
  objective: string;
  /** The hands-on part of the lesson, built in a later phase. */
  activity: string;
  minutes: number;
};

export const JOURNEY = ['Learn', 'Practice', 'Recognize'];

export const KEY_TAKEAWAY =
  'PD uses the lining of your abdomen (the peritoneum) to help remove waste and extra fluid from your body.';

export const LESSONS: Lesson[] = [
  {
    id: 'kidneys',
    title: 'Understanding Your Kidneys',
    objective: 'Explain what your kidneys do and why dialysis may be needed.',
    activity: 'Labeled kidney diagram',
    minutes: 4,
  },
  {
    id: 'pd',
    title: 'Understanding PD',
    objective: 'Describe how peritoneal dialysis works and what it is for.',
    activity: 'Visual explanation of the process',
    minutes: 5,
  },
  {
    id: 'getting-ready',
    title: 'Getting Ready for Treatment',
    objective: 'Identify the supplies and preparation steps your care team taught you.',
    activity: 'Preparation checklist',
    minutes: 4,
  },
  {
    id: 'exchange',
    title: 'Understanding an Exchange',
    objective: 'Understand the purpose and order of the steps in an exchange.',
    activity: 'Step-by-step walkthrough (video demonstration)',
    minutes: 6,
  },
  {
    id: 'infection',
    title: 'Preventing Infection',
    objective: 'Understand hygiene, keeping things sterile, and preventing contamination.',
    activity: 'Safety scenarios',
    minutes: 5,
  },
  {
    id: 'problems',
    title: 'Recognizing Problems',
    objective: 'Identify warning signs and know when to contact your care team.',
    activity: '"What would you do?" scenarios',
    minutes: 5,
  },
  {
    id: 'tracking',
    title: 'Tracking Your Treatment',
    objective: 'Understand what information to record and why it matters.',
    activity: 'Sample treatment log',
    minutes: 3,
  },
  {
    id: 'confidence',
    title: 'Building Confidence at Home',
    objective: 'Apply what you have learned to everyday situations.',
    activity: 'Knowledge check and confidence rating',
    minutes: 4,
  },
];
