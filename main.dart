import 'package:flutter/material.dart';

// PD Guide: patient education about peritoneal dialysis. INFORMATION ONLY.
// Single-file version. No dependencies beyond Flutter. No network, no storage, no PHI.
// Quiz answers and progress are kept in memory only and reset when the app closes.

void main() => runApp(const PdGuideApp());

class PdGuideApp extends StatefulWidget {
  const PdGuideApp({super.key});
  @override
  State<PdGuideApp> createState() => _PdGuideAppState();
}

class _PdGuideAppState extends State<PdGuideApp> {
  // Kept in memory only, so the notice appears on every launch (nothing is stored).
  bool _acknowledged = false;
  final ProgressModel _progress = ProgressModel();

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      model: _progress,
      child: MaterialApp(
        title: 'PD Guide',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: _acknowledged
            ? const HomeShell()
            : DisclaimerGate(onAccepted: () => setState(() => _acknowledged = true)),
      ),
    );
  }
}

// ===== theme.dart =====
class Palette {
  static const ink = Color(0xFF12313D); // deep blue-teal text
  static const primary = Color(0xFF0E6E7E); // dialysate teal
  static const mist = Color(0xFFEAF4F5); // pale background
  static const amber = Color(0xFFB45309); // caution text
  static const amberBg = Color(0xFFFFF4DC); // caution background
  static const alert = Color(0xFFB3261E); // urgent / wrong
  static const alertBg = Color(0xFFFDECEA);
  static const good = Color(0xFF1B7F3B); // correct
  static const goodBg = Color(0xFFE7F5EC);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.primary,
    primary: Palette.primary,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.mist,
    // System font on purpose: runtime font downloads (e.g. google_fonts)
    // would make network requests, which this app avoids.
    textTheme: Typography.material2021().black.apply(
          bodyColor: Palette.ink,
          displayColor: Palette.ink,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.mist,
      foregroundColor: Palette.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD3E3E6)),
      ),
    ),
  );
}

// ===== data/progress.dart =====
/// In-memory progress tracking. Nothing is written to disk.
class QuizResult {
  const QuizResult(this.correct, this.total);
  final int correct;
  final int total;
  double get fraction => total == 0 ? 0 : correct / total;
}

class ProgressModel extends ChangeNotifier {
  final Map<String, QuizResult> _results = {};

  /// Best result for a topic, or null if the knowledge check was never completed.
  QuizResult? resultFor(String topicTitle) => _results[topicTitle];

  int get completedCount => _results.length;

  /// Average of best scores across completed modules (0 to 1).
  double get averageFraction {
    if (_results.isEmpty) return 0;
    final sum = _results.values.fold<double>(0, (a, r) => a + r.fraction);
    return sum / _results.length;
  }

  /// Keeps the best score so retrying can only improve the record.
  void record(String topicTitle, int correct, int total) {
    final old = _results[topicTitle];
    if (old == null || correct > old.correct) {
      _results[topicTitle] = QuizResult(correct, total);
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void reset() {
    _results.clear();
    notifyListeners();
  }
}

class ProgressScope extends InheritedNotifier<ProgressModel> {
  const ProgressScope({super.key, required ProgressModel model, required super.child})
      : super(notifier: model);

  /// Use in build methods: rebuilds when progress changes.
  static ProgressModel of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;

  /// Use in event handlers: does not subscribe to changes.
  static ProgressModel read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}

// ===== data/content.dart =====
/// All educational content lives here so clinical reviewers can edit one file.
/// IMPORTANT: Have a nephrologist / PD nurse educator review all text AND all
/// knowledge-check questions and answers before release.

class Section {
  const Section(this.heading, {this.body, this.bullets = const []});
  final String heading;
  final String? body;
  final List<String> bullets;
}

/// A "select all that apply" question. [correct] holds the indexes of the
/// options that are right. The answer is correct only if the person selects
/// exactly those options.
class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correct,
    required this.explanation,
  });
  final String prompt;
  final List<String> options;
  final List<int> correct;
  final String explanation;
}

class Topic {
  const Topic({
    required this.title,
    required this.summary,
    required this.icon,
    required this.sections,
    this.quiz = const [],
    this.urgent = false,
  });
  final String title;
  final String summary;
  final IconData icon;
  final List<Section> sections;
  final List<QuizQuestion> quiz;
  final bool urgent;
}

const topics = <Topic>[
  Topic(
    title: 'Warning signs: when to call',
    summary: 'Problems that need a call to your PD team right away.',
    icon: Icons.warning_amber_rounded,
    urgent: true,
    sections: [
      Section(
        'Call your PD clinic the same day if you notice',
        bullets: [
          'Drained fluid that looks cloudy or has white strands',
          'Belly pain or tenderness',
          'Fever or chills',
          'Redness, swelling, pain, or pus where the catheter leaves your skin',
          'Fluid that will not drain in, or will not drain out',
          'Fluid leaking around the catheter',
          'Blood in the drained fluid',
        ],
      ),
      Section(
        'Call emergency services (911 in the US) if you have',
        bullets: [
          'Trouble breathing or chest pain',
          'Severe belly pain with vomiting or a hard, swollen belly',
          'Fainting or confusion',
        ],
      ),
      Section(
        'After hours',
        body: 'Your care team will give you a phone number to use at night and on '
            'weekends. Write it down and keep it where you can find it quickly. '
            'Do not wait until the next day if you think you might have an infection.',
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which of these should you call your PD clinic about the same day?',
        options: [
          'Drained fluid that looks cloudy',
          'Redness or pus where the catheter leaves your skin',
          'Fluid that will not drain out',
          'Feeling a little hungry before dinner',
        ],
        correct: [0, 1, 2],
        explanation: 'Cloudy fluid, exit site changes, and drainage problems all need a '
            'same-day call. Feeling hungry is not a PD warning sign.',
      ),
      QuizQuestion(
        prompt: 'Which of these means you should call emergency services (911 in the US)?',
        options: [
          'Trouble breathing or chest pain',
          'Severe belly pain with vomiting or a hard, swollen belly',
          'Fainting or confusion',
          'A mild headache that goes away after resting',
        ],
        correct: [0, 1, 2],
        explanation: 'These are emergency signs. Do not wait for a call back from the clinic.',
      ),
    ],
  ),
  Topic(
    title: 'Kidney failure basics',
    summary: 'What kidneys do and why treatment is needed.',
    icon: Icons.water_drop_outlined,
    sections: [
      Section(
        'What healthy kidneys do',
        bullets: [
          'Filter waste and extra water from your blood',
          'Help balance minerals such as potassium and sodium',
          'Help control blood pressure',
          'Help make red blood cells and keep bones strong',
        ],
      ),
      Section(
        'What happens in kidney failure',
        body: 'When kidneys can no longer do enough of this work, waste and fluid '
            'build up in the body. Treatment options include dialysis, a kidney '
            'transplant, or conservative (comfort-focused) care. Peritoneal dialysis '
            '(PD) is one type of dialysis.',
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'What do healthy kidneys do?',
        options: [
          'Filter waste and extra water from the blood',
          'Help balance minerals such as potassium and sodium',
          'Help control blood pressure',
          'Digest the food you eat',
        ],
        correct: [0, 1, 2],
        explanation: 'Kidneys filter blood, balance minerals, and help control blood '
            'pressure. Digestion is done by the stomach and intestines.',
      ),
      QuizQuestion(
        prompt: 'Which are treatment options for kidney failure?',
        options: [
          'Dialysis',
          'Kidney transplant',
          'Conservative (comfort-focused) care',
          'Drinking extra water to flush out the kidneys',
        ],
        correct: [0, 1, 2],
        explanation: 'Dialysis, transplant, and conservative care are the options covered '
            'here. Drinking extra water does not treat kidney failure.',
      ),
    ],
  ),
  Topic(
    title: 'What is peritoneal dialysis?',
    summary: 'How PD cleans your blood using your own belly lining.',
    icon: Icons.help_outline,
    sections: [
      Section(
        'The idea',
        body: 'Inside your belly is a thin lining called the peritoneum. It has '
            'many tiny blood vessels. In PD, a clean cleaning fluid called dialysate '
            'is moved into your belly through a soft tube (catheter). Waste and '
            'extra water pass from your blood into the fluid. After some hours, the '
            'used fluid is drained out and replaced with fresh fluid.',
      ),
      Section(
        'Key words',
        bullets: [
          'Exchange: one cycle of draining used fluid and filling with fresh fluid',
          'Dwell: the time the fluid stays in your belly',
          'Catheter: the soft tube that stays in place for PD',
          'Exit site: where the catheter comes out of your skin',
        ],
      ),
      Section(
        'Where it is done',
        body: 'Most people do PD at home after training from a PD nurse. This can '
            'give more flexibility in your schedule than treatment at a center.',
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which statements about how PD works are true?',
        options: [
          'The lining of your belly (peritoneum) acts as the filter',
          'Dialysate is moved into your belly through a catheter',
          'Used fluid is drained out and replaced with fresh fluid',
          'PD can only be done in a hospital',
        ],
        correct: [0, 1, 2],
        explanation: 'Most people do PD at home after training from a PD nurse.',
      ),
      QuizQuestion(
        prompt: 'Which key words are matched with the right meaning?',
        options: [
          'Dwell: the time fluid stays in your belly',
          'Exit site: where the catheter comes out of your skin',
          'Exchange: the name of the soft tube',
          'Catheter: one cycle of draining and filling',
        ],
        correct: [0, 1],
        explanation: 'An exchange is one cycle of draining and filling. The catheter is '
            'the soft tube.',
      ),
    ],
  ),
  Topic(
    title: 'Two types: CAPD and APD',
    summary: 'Doing exchanges by hand or with a machine.',
    icon: Icons.sync_alt,
    sections: [
      Section(
        'CAPD (continuous ambulatory PD)',
        body: 'You do exchanges by hand during the day, using gravity. Each '
            'exchange takes about 30 to 40 minutes, and you can move around during '
            'the dwell. No machine is needed.',
      ),
      Section(
        'APD (automated PD)',
        body: 'A machine called a cycler does exchanges while you sleep. You '
            'connect at bedtime and disconnect in the morning.',
      ),
      Section(
        'Which is right for you?',
        body: 'Your kidney doctor and PD nurse will help choose based on your body, '
            'test results, home, and daily routine. Your plan can change over time.',
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which statements about CAPD are true?',
        options: [
          'Exchanges are done by hand during the day',
          'It uses gravity and needs no machine',
          'A cycler does the exchanges while you sleep',
        ],
        correct: [0, 1],
        explanation: 'A cycler is used for APD, not CAPD.',
      ),
      QuizQuestion(
        prompt: 'Which statements about APD and choosing a type are true?',
        options: [
          'A machine called a cycler does the exchanges',
          'You usually connect at bedtime and disconnect in the morning',
          'Your care team helps you choose based on your body and routine',
          'Once chosen, your plan can never change',
        ],
        correct: [0, 1, 2],
        explanation: 'Your plan can change over time as your needs change.',
      ),
    ],
  ),
  Topic(
    title: 'The catheter and exit site',
    summary: 'How the catheter is placed and how to keep it healthy.',
    icon: Icons.healing_outlined,
    sections: [
      Section(
        'Placement',
        body: 'A surgeon or specialist places the catheter in a short procedure. '
            'It usually needs a few weeks to heal before regular use. Your team '
            'will tell you how to care for the area during that time.',
      ),
      Section(
        'Everyday care (general)',
        body: 'Your nurse will teach you the exact routine to follow. In general:',
        bullets: [
          'Wash your hands before touching the catheter or exit site',
          'Keep the catheter secured so it does not get pulled',
          'Keep the exit site clean and dry as taught by your team',
          'Check the site every day for redness, swelling, or drainage',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which are part of everyday catheter care?',
        options: [
          'Wash your hands before touching the catheter or exit site',
          'Keep the catheter secured so it does not get pulled',
          'Check the exit site every day',
          'Tug on the catheter to test that it is strong',
        ],
        correct: [0, 1, 2],
        explanation: 'Pulling on the catheter can injure the exit site. Keep it secured.',
      ),
      QuizQuestion(
        prompt: 'Which statements about catheter placement are true?',
        options: [
          'A surgeon or specialist places it in a short procedure',
          'It usually needs a few weeks to heal before regular use',
          'You can start exchanges the same day with no healing time',
        ],
        correct: [0, 1],
        explanation: 'Healing time matters. Your team will tell you how to care for the '
            'area during that time.',
      ),
    ],
  ),
  Topic(
    title: 'Preventing infection',
    summary: 'Clean technique is the most important PD skill.',
    icon: Icons.clean_hands_outlined,
    sections: [
      Section(
        'Why it matters',
        body: 'An infection of the peritoneum is called peritonitis. It is the '
            'most common serious problem with PD, and it is often preventable.',
      ),
      Section(
        'Habits that help',
        bullets: [
          'Wash your hands the way you were taught, every time',
          'Use a clean, dry, well-lit space for exchanges',
          'Keep pets and others away during exchanges',
          'Check supplies for damage and expiry dates before use',
          'Never skip steps, even when you are tired or in a hurry',
        ],
      ),
      Section(
        'If you make a mistake',
        body: 'If you think something touched that should not have (for example, '
            'a connection was dropped), call your PD clinic. It is better to ask.',
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'What is true about peritonitis?',
        options: [
          'It is an infection of the peritoneum',
          'It is the most common serious problem with PD',
          'It is often preventable',
          'It is harmless and can be ignored',
        ],
        correct: [0, 1, 2],
        explanation: 'Peritonitis is serious. Call your PD clinic if you think you have it.',
      ),
      QuizQuestion(
        prompt: 'Which habits help prevent infection?',
        options: [
          'Wash your hands the way you were taught, every time',
          'Check supplies for damage and expiry dates',
          'Skip a step when you are tired or in a hurry',
          'Call your PD clinic if a connection may have touched something it should not',
          'Let pets stay close during exchanges',
        ],
        correct: [0, 1, 3],
        explanation: 'Never skip steps, and keep pets and others away during exchanges.',
      ),
    ],
  ),
  Topic(
    title: 'A typical exchange (overview)',
    summary: 'A general picture of what training will cover.',
    icon: Icons.format_list_numbered,
    sections: [
      Section(
        'Important',
        body: 'This is a general overview only. Do not use it as instructions. '
            'Your PD nurse will train you on your exact supplies and steps.',
      ),
      Section(
        'The general flow',
        bullets: [
          'Prepare a clean space and wash your hands',
          'Gather and check your supplies',
          'Connect to your catheter using clean technique',
          'Drain the used fluid and look at its color and clarity',
          'Fill with fresh fluid',
          'Disconnect and cap the catheter',
          'Record what your team asked you to record',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which are part of the general flow of an exchange?',
        options: [
          'Prepare a clean space and wash your hands',
          'Drain the used fluid and look at its color and clarity',
          'Fill with fresh fluid',
          'Skip hand washing if the supplies look clean',
        ],
        correct: [0, 1, 2],
        explanation: 'Hand washing and clean technique are never optional.',
      ),
      QuizQuestion(
        prompt: 'How should you use this overview?',
        options: [
          'As a general picture of what training will cover',
          'Remember that your PD nurse will train you on your exact supplies and steps',
          'As step-by-step instructions to do exchanges at home',
        ],
        correct: [0, 1],
        explanation: 'This overview is not instructions. Follow the training from your PD nurse.',
      ),
    ],
  ),
  Topic(
    title: 'Eating, drinking, and daily life',
    summary: 'Diet and lifestyle topics to discuss with your team.',
    icon: Icons.restaurant_outlined,
    sections: [
      Section(
        'Food and fluids',
        body: 'Needs differ from person to person. A kidney dietitian will build a '
            'plan for you. Topics they commonly cover:',
        bullets: [
          'Protein (PD can remove some protein, so needs are often higher)',
          'Potassium, phosphorus, and sodium',
          'How much to drink',
          'Managing blood sugar if you have diabetes',
        ],
      ),
      Section(
        'Daily life',
        bullets: [
          'Work and school: many people continue them on PD',
          'Travel: your team can help arrange supplies',
          'Showering and swimming: ask what is safe for your exit site',
          'Physical activity: ask what is right for you',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which topics does a kidney dietitian commonly cover?',
        options: [
          'Protein',
          'Potassium, phosphorus, and sodium',
          'How much to drink',
          'Popular celebrity diets',
        ],
        correct: [0, 1, 2],
        explanation: 'A kidney dietitian builds a plan for you. Needs differ from person to person.',
      ),
      QuizQuestion(
        prompt: 'Which statements about daily life on PD are true?',
        options: [
          'Many people continue work and school',
          'Your team can help arrange supplies for travel',
          'Ask your team what is safe for showering and swimming',
          'PD means you can never travel',
        ],
        correct: [0, 1, 2],
        explanation: 'Many people travel on PD with planning. Talk with your team first.',
      ),
    ],
  ),
  Topic(
    title: 'Questions to ask your care team',
    summary: 'Ideas to bring to your next visit.',
    icon: Icons.question_answer_outlined,
    sections: [
      Section(
        'Getting started',
        bullets: [
          'Is PD a good option for me, and why?',
          'Which type (CAPD or APD) do you suggest?',
          'How long is training, and where does it happen?',
          'Who do I call, and when, including after hours?',
        ],
      ),
      Section(
        'Living with PD',
        bullets: [
          'How do I get and store supplies at home?',
          'What should I eat and drink?',
          'Can I travel, work, or swim?',
          'What happens if PD stops working well for me?',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        prompt: 'Which are good questions when getting started?',
        options: [
          'Which type (CAPD or APD) do you suggest?',
          'Who do I call after hours?',
          'How long is training, and where does it happen?',
          'Which TV show should I watch during dwells?',
        ],
        correct: [0, 1, 2],
        explanation: 'Bring questions about your own care to your team.',
      ),
      QuizQuestion(
        prompt: 'Which are good questions about living with PD?',
        options: [
          'How do I get and store supplies at home?',
          'Can I travel, work, or swim?',
          'What happens if PD stops working well for me?',
          'Is it okay to ignore warning signs?',
        ],
        correct: [0, 1, 2],
        explanation: 'Never ignore warning signs. Call your PD clinic.',
      ),
    ],
  ),
];

class GlossaryEntry {
  const GlossaryEntry(this.term, this.meaning);
  final String term;
  final String meaning;
}

const glossary = <GlossaryEntry>[
  GlossaryEntry('APD', 'Automated peritoneal dialysis. A machine (cycler) does the exchanges, usually overnight.'),
  GlossaryEntry('CAPD', 'Continuous ambulatory peritoneal dialysis. You do exchanges by hand during the day.'),
  GlossaryEntry('Catheter', 'A soft tube placed in your belly that carries fluid in and out.'),
  GlossaryEntry('Cycler', 'The machine used for APD.'),
  GlossaryEntry('Dialysate', 'The cleaning fluid used in PD.'),
  GlossaryEntry('Dwell', 'The time fluid stays in your belly before it is drained.'),
  GlossaryEntry('Effluent', 'The used fluid drained out of your belly.'),
  GlossaryEntry('Exchange', 'One cycle of draining used fluid and filling with fresh fluid.'),
  GlossaryEntry('Exit site', 'The spot where the catheter comes out through your skin.'),
  GlossaryEntry('Nephrologist', 'A doctor who specializes in kidneys.'),
  GlossaryEntry('Peritoneum', 'The thin lining inside your belly used as the filter in PD.'),
  GlossaryEntry('Peritonitis', 'Infection or inflammation of the peritoneum.'),
];

// ===== widgets/disclaimer_bar.dart =====
/// Persistent label shown at the bottom of every screen.
class DisclaimerBar extends StatelessWidget {
  const DisclaimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Notice. Information only. Not medical advice. '
          'Ask your kidney care team about your own situation.',
      child: Material(
        color: Palette.amberBg,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Palette.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Information only. Not medical advice. '
                    'Ask your kidney care team about your own situation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Palette.amber,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== widgets/quiz_section.dart =====
/// Knowledge check shown under the text of a module.
/// Checkboxes are "select all that apply". After "Check answers", every option
/// is marked Correct / Not correct / Missed, with an explanation per question.
class QuizSection extends StatefulWidget {
  const QuizSection({super.key, required this.topic});
  final Topic topic;

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  late List<Set<int>> _selected;
  bool _checked = false;

  List<QuizQuestion> get _qs => widget.topic.quiz;

  @override
  void initState() {
    super.initState();
    _clear();
  }

  void _clear() {
    _selected = List.generate(_qs.length, (_) => <int>{});
    _checked = false;
  }

  bool _isRight(int q) {
    final correct = _qs[q].correct.toSet();
    return _selected[q].length == correct.length && _selected[q].containsAll(correct);
  }

  int get _score => List.generate(_qs.length, (i) => i).where(_isRight).length;

  bool get _ready => _selected.every((s) => s.isNotEmpty);

  void _toggle(int q, int o, bool on) {
    if (_checked) return;
    setState(() => on ? _selected[q].add(o) : _selected[q].remove(o));
  }

  void _check() {
    setState(() => _checked = true);
    ProgressScope.read(context).record(widget.topic.title, _score, _qs.length);
  }

  void _retry() => setState(_clear);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3E3E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.fact_check_outlined, color: Palette.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Check your knowledge',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            'Select all answers that apply. This is for learning only and is not '
            'saved when you close the app.',
            style: t.bodyMedium,
          ),
          for (var q = 0; q < _qs.length; q++) ..._buildQuestion(context, q),
          const SizedBox(height: 20),
          if (_checked) _buildResult(context) else _buildCheckButton(),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _ready ? _check : null,
            child: const Text('Check answers'),
          ),
        ),
        if (!_ready)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Select at least one answer for each question.',
                textAlign: TextAlign.center),
          ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final perfect = _score == _qs.length;
    final color = perfect ? Palette.good : Palette.amber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: perfect ? Palette.goodBg : Palette.amberBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Row(children: [
            Icon(perfect ? Icons.check_circle : Icons.info_outline, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                perfect
                    ? 'All $_score of ${_qs.length} correct. Nice work!'
                    : 'You got $_score of ${_qs.length} correct. Review the notes above and try again.',
                style: t.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuestion(BuildContext context, int q) {
    final t = Theme.of(context).textTheme;
    final question = _qs[q];
    final right = _checked && _isRight(q);
    return [
      const SizedBox(height: 20),
      Text('Question ${q + 1} of ${_qs.length}',
          style: t.labelLarge?.copyWith(color: Palette.primary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(question.prompt, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      for (var o = 0; o < question.options.length; o++) _buildOption(context, q, o),
      if (_checked) ...[
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(right ? Icons.check_circle : Icons.cancel,
                size: 20, color: right ? Palette.good : Palette.alert),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${right ? 'Correct.' : 'Not quite.'} ${question.explanation}',
                style: t.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  Widget _buildOption(BuildContext context, int q, int o) {
    final t = Theme.of(context).textTheme;
    final question = _qs[q];
    final selected = _selected[q].contains(o);
    final isCorrect = question.correct.contains(o);

    // Result styling (only after "Check answers").
    Color border = const Color(0xFFD3E3E6);
    Color bg = Colors.white;
    Color checkColor = Palette.primary;
    String? label;
    IconData? icon;
    Color? iconColor;
    if (_checked) {
      if (selected && isCorrect) {
        border = Palette.good;
        bg = Palette.goodBg;
        checkColor = Palette.good;
        label = 'Correct';
        icon = Icons.check_circle;
        iconColor = Palette.good;
      } else if (selected && !isCorrect) {
        border = Palette.alert;
        bg = Palette.alertBg;
        checkColor = Palette.alert;
        label = 'Not correct';
        icon = Icons.cancel;
        iconColor = Palette.alert;
      } else if (!selected && isCorrect) {
        border = Palette.good;
        bg = Colors.white;
        label = 'Missed: this one was also correct';
        icon = Icons.check_circle_outline;
        iconColor = Palette.good;
      }
    } else if (selected) {
      border = Palette.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: _checked && label != null ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _checked ? null : () => _toggle(q, o, !selected),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: _checked ? null : (v) => _toggle(q, o, v ?? false),
                  // Keep the colour even when locked after checking.
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => selected ? checkColor : null,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.options[o], style: t.bodyLarge?.copyWith(height: 1.3)),
                        if (label != null) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(icon, size: 18, color: iconColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(label,
                                  style: t.labelLarge?.copyWith(
                                      color: iconColor, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== screens/disclaimer_gate.dart =====
/// Shown on first launch. User must acknowledge before using the app.
class DisclaimerGate extends StatefulWidget {
  const DisclaimerGate({super.key, required this.onAccepted});
  final VoidCallback onAccepted;

  @override
  State<DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<DisclaimerGate> {
  bool _checked = false;

  void _accept() => widget.onAccepted();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('PD Guide', style: t.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Learning about peritoneal dialysis', style: t.titleMedium),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Palette.amberBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Palette.amber, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.info_outline, color: Palette.amber),
                          const SizedBox(width: 8),
                          Text('Information only',
                              style: t.titleLarge?.copyWith(color: Palette.amber, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          'This app is for education. It is not medical advice and does '
                          'not diagnose or treat any condition.\n\n'
                          'Your health needs are unique. For anything about your own care, '
                          'including symptoms, medicines, diet, and how to do your exchanges, '
                          'talk with your kidney doctor, PD nurse, or other health professional.\n\n'
                          'If you think you have a medical emergency, call 911 (or your '
                          'local emergency number) right away.',
                          style: t.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Your privacy', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    'This app has no accounts and does not ask for your name, health '
                    'details, or contact information. Please do not enter personal '
                    'health information anywhere in the app.',
                    style: t.bodyMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _checked,
                    onChanged: (v) => setState(() => _checked = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'I understand this app is information only and does not replace '
                      'advice from my health care team.',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _checked ? _accept : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== screens/home_shell.dart =====
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Learn about PD', 'My progress', 'Glossary', 'Privacy and about'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [LearnScreen(), ProgressScreen(), GlossaryScreen(), PrivacyScreen()],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DisclaimerBar(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
              NavigationDestination(icon: Icon(Icons.task_alt), label: 'Progress'),
              NavigationDestination(icon: Icon(Icons.abc), label: 'Glossary'),
              NavigationDestination(icon: Icon(Icons.lock_outline), label: 'Privacy'),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== screens/learn_screen.dart =====
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final topic = topics[i];
        final accent = topic.urgent ? Palette.alert : Palette.primary;
        final done = progress.resultFor(topic.title) != null;
        return Card(
          color: topic.urgent ? Palette.alertBg : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TopicScreen(topic: topic)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(topic.icon, color: accent, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: topic.urgent ? Palette.alert : Palette.ink,
                                )),
                        const SizedBox(height: 2),
                        Text(topic.summary, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  if (done)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check_circle, color: Palette.good, semanticLabel: 'Completed'),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===== screens/topic_screen.dart =====
class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key, required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(topic.title, style: t.titleMedium)),
      bottomNavigationBar: const DisclaimerBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final s in topic.sections) ...[
            const SizedBox(height: 16),
            Text(s.heading, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            if (s.body != null) ...[
              const SizedBox(height: 6),
              Text(s.body!, style: t.bodyLarge?.copyWith(height: 1.45)),
            ],
            for (final b in s.bullets)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7, right: 10),
                      child: Icon(Icons.circle, size: 7),
                    ),
                    Expanded(child: Text(b, style: t.bodyLarge?.copyWith(height: 1.4))),
                  ],
                ),
              ),
          ],
          if (topic.quiz.isNotEmpty) QuizSection(topic: topic),
        ],
      ),
    );
  }
}

// ===== screens/progress_screen.dart =====
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This clears your knowledge-check scores for this session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && context.mounted) ProgressScope.read(context).reset();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final progress = ProgressScope.of(context);
    final quizTopics = topics.where((e) => e.quiz.isNotEmpty).toList();
    final total = quizTopics.length;
    final done = progress.completedCount;
    final pct = total == 0 ? 0.0 : done / total;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done of $total modules completed',
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Semantics(
                  label: '$done of $total modules completed',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 12,
                      backgroundColor: Palette.mist,
                      color: Palette.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  done == 0
                      ? 'Finish a knowledge check at the bottom of a module to see your progress here.'
                      : 'Average score on completed modules: '
                          '${(progress.averageFraction * 100).round()}%',
                  style: t.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Modules', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final topic in quizTopics) ...[
          _ModuleTile(topic: topic, result: progress.resultFor(topic.title)),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Progress is kept only while the app is open. Nothing is saved to your device.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (done > 0)
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset progress'),
          ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.topic, required this.result});
  final Topic topic;
  final QuizResult? result;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final done = result != null;
    final perfect = done && result!.correct == result!.total;
    final statusColor = !done
        ? Palette.ink
        : perfect
            ? Palette.good
            : Palette.amber;
    final status = !done
        ? 'Not started'
        : perfect
            ? 'Mastered: ${result!.correct} of ${result!.total} correct'
            : 'Best score: ${result!.correct} of ${result!.total} correct';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TopicScreen(topic: topic)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? statusColor : Colors.grey,
                semanticLabel: done ? 'Completed' : 'Not started',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title,
                        style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(status,
                        style: t.bodyMedium?.copyWith(
                            color: statusColor, fontWeight: done ? FontWeight.w600 : null)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== screens/glossary_screen.dart =====
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final items = glossary
        .where((e) => e.term.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            // Search text stays in memory only; autocorrect/suggestions are off
            // so the keyboard does not learn or store what is typed.
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search a word',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No matching words. Try a different spelling.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => Card(
                    child: ListTile(
                      title: Text(items[i].term,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(items[i].meaning),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ===== screens/privacy_screen.dart =====
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget h(String s) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(s, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        h('Information only'),
        Text(
          'PD Guide teaches general facts about peritoneal dialysis. It does not give '
          'medical advice, diagnose, or replace your care team. For specifics about '
          'you, always ask a health professional.',
          style: t.bodyLarge,
        ),
        h('What this app does with your data'),
        Text(
          '• No accounts or sign-in\n'
          '• Does not ask for or store your name, health details, or contact information\n'
          '• No ads, no analytics, no tracking\n'
          '• Does not connect to the internet to work\n'
          '• Does not save anything to your device. Your knowledge-check answers and '
          'progress are kept only while the app is open',
          style: t.bodyLarge?.copyWith(height: 1.5),
        ),
        h('Please do not enter personal health information'),
        Text(
          'There is nowhere in this app to enter it, and the glossary search is not '
          'saved. Share health details only with your care team, through the channels '
          'they provide.',
          style: t.bodyLarge,
        ),
        h('Content review'),
        Text(
          'Content version 1.0. Reviewed by: [clinical reviewer name and date].',
          style: t.bodyMedium,
        ),
      ],
    );
  }
}