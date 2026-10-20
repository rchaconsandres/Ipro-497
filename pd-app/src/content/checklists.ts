// Pre- and post-treatment checklists (slide 6).
// Each clinic's protocol differs, so these must be reviewed by the clinical
// team and will later be customizable per patient.

export type ChecklistStep = {
  title: string;
  detail: string;
};

export type Checklist = {
  id: 'before' | 'after';
  label: string;
  heading: string;
  intro: string;
  steps: ChecklistStep[];
};

export const CHECKLIST_NOTE =
  'This list is a reminder, not training. Always follow the steps your care team taught you.';

export const CHECKLISTS: Checklist[] = [
  {
    id: 'before',
    label: 'Before treatment',
    heading: 'Before your exchange',
    intro: 'Check these for a clean, safe exchange.',
    steps: [
      { title: 'Clean your space', detail: 'Sanitize your work area and keep pets out of the room.' },
      { title: 'Clean your hands', detail: 'Wash your hands before touching any supplies.' },
      { title: 'Masks on', detail: 'Everyone in the room wears a mask.' },
      { title: 'Check your supplies', detail: 'Packages are sealed and the fluid is not cloudy.' },
      { title: 'Check your catheter site', detail: 'Make sure your drainage and catheter site look normal.' },
      { title: 'Take your vitals and weight', detail: 'Write them down so you can log them later.' },
    ],
  },
  {
    id: 'after',
    label: 'After treatment',
    heading: 'Before you finish',
    intro: 'Confirm these before marking your treatment complete.',
    steps: [
      { title: 'Catheter capped and secured', detail: 'Your catheter is capped and secured.' },
      {
        title: 'Site kept sterile',
        detail: 'The site was kept sterile and dressing care was done if needed.',
      },
      {
        title: 'Treatment logged',
        detail: 'Record your body weight before and after, your vitals, and the bag color used.',
      },
    ],
  },
];
