// Articles and resources (slides 7 and 8).

export type ArticleSection = {
  heading: string;
  points: string[];
};

export type Article = {
  id: string;
  title: string;
  summary: string;
  minutes: number;
  /** Shown as a warning banner until the article is reviewed. Remove once approved. */
  reviewNote?: string;
  sections: ArticleSection[];
  /** Full web addresses starting with https:// */
  sources: `https://${string}`[];
};

export const ARTICLES: Article[] = [
  {
    id: 'benefits-risks',
    title: 'Benefits and Risks of PD',
    summary: 'What PD can offer, and the problems to watch for.',
    minutes: 5,
    reviewNote: 'Draft: the numbers in this article still need sources and clinician review.',
    sections: [
      {
        heading: 'Benefits',
        points: [
          'Home-based and flexible: treatment fits around work, school, and travel.',
          'Greater independence.',
          'Gentler on the body: slow, continuous removal of fluid and waste means fewer swings in blood pressure than in-center hemodialysis.',
          'Can help preserve the kidney function you still have (about 2.9% decline per month on PD vs 5.8% on hemodialysis).',
          'No needles or access to your blood vessels.',
          'Fewer diet restrictions.',
          'Less large equipment.',
          'Less exposure to germs carried in blood.',
        ],
      },
      {
        heading: 'Risks',
        points: [
          'Infection: peritonitis is the most serious problem (about 0.26 episodes per patient each year in the US).',
          'Catheter problems: infection, leaks, blockage, or the catheter moving out of place.',
          'Missed treatments can lead to fluid and waste building up in your body.',
          'Pressure in your abdomen.',
          'Sugar in the fluid can cause weight gain and make blood sugar harder to control. It can also lead to low potassium.',
          'Over time, the lining of the abdomen can work less well (ultrafiltration failure).',
          'Learning PD takes time and effort.',
          'Small amounts of protein can be lost into the fluid.',
        ],
      },
    ],
    sources: [],
  },
  {
    id: 'exercise',
    title: 'Exercise and Dialysis',
    summary: 'What research says about staying active during treatment.',
    minutes: 3,
    reviewNote:
      'Draft: this research studied hemodialysis patients. Confirm with clinicians what applies to manual PD.',
    sections: [
      {
        heading: 'Possible benefits',
        points: [
          'May improve how well dialysis clears waste, by increasing blood flow to muscles.',
          'Improved fitness and physical quality of life.',
          'Lower blood pressure.',
        ],
      },
      {
        heading: 'Types of exercise studied',
        points: ['Stationary bike', 'Light resistance work with bands or ankle weights'],
      },
      {
        heading: 'What we don’t know yet',
        points: [
          'Long-term effects have not been well studied.',
          'The best intensity, length, and type of exercise is still unclear.',
        ],
      },
    ],
    sources: [
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC6588711',
      'https://pubmed.ncbi.nlm.nih.gov/25504020/',
      'https://pubmed.ncbi.nlm.nih.gov/30659520/',
    ],
  },
];
