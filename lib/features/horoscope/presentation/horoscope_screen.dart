import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/horoscope_repository.dart';
import '../domain/horoscope_models.dart';

// ─── Sign data ────────────────────────────────────────────────────────────

class _Sign {
  const _Sign(this.symbol, this.name, this.dates, this.slug, this.element);
  final String symbol;
  final String name;
  final String dates;
  final String slug;
  final String element; // fire | earth | air | water
}

const _signs = [
  _Sign('♈', 'Aries', 'Mar 21 – Apr 19', 'aries', 'fire'),
  _Sign('♉', 'Taurus', 'Apr 20 – May 20', 'taurus', 'earth'),
  _Sign('♊', 'Gemini', 'May 21 – Jun 20', 'gemini', 'air'),
  _Sign('♋', 'Cancer', 'Jun 21 – Jul 22', 'cancer', 'water'),
  _Sign('♌', 'Leo', 'Jul 23 – Aug 22', 'leo', 'fire'),
  _Sign('♍', 'Virgo', 'Aug 23 – Sep 22', 'virgo', 'earth'),
  _Sign('♎', 'Libra', 'Sep 23 – Oct 22', 'libra', 'air'),
  _Sign('♏', 'Scorpio', 'Oct 23 – Nov 21', 'scorpio', 'water'),
  _Sign('♐', 'Sagittarius', 'Nov 22 – Dec 21', 'sagittarius', 'fire'),
  _Sign('♑', 'Capricorn', 'Dec 22 – Jan 19', 'capricorn', 'earth'),
  _Sign('♒', 'Aquarius', 'Jan 20 – Feb 18', 'aquarius', 'air'),
  _Sign('♓', 'Pisces', 'Feb 19 – Mar 20', 'pisces', 'water'),
];

// Element → two gradient stop colors
List<Color> _elementGradient(String element) => switch (element) {
      'fire' => const [Color(0xFFB71C1C), Color(0xFFFF6D00)],
      'earth' => const [Color(0xFF1B5E20), Color(0xFF00695C)],
      'air' => const [Color(0xFF0D47A1), Color(0xFF00ACC1)],
      'water' => const [Color(0xFF311B92), Color(0xFF4A148C)],
      _ => const [Color(0xFF3949AB), Color(0xFF7B1FA2)],
    };

Color _elementAccent(String element) => switch (element) {
      'fire' => const Color(0xFFFF6D00),
      'earth' => const Color(0xFF69F0AE),
      'air' => const Color(0xFF40C4FF),
      'water' => const Color(0xFFEA80FC),
      _ => AppColors.accent,
    };

const _periods = ['daily', 'weekly', 'yearly'];
const _periodLabels = ['Today', 'This Week', 'This Year'];
const _periodIcons = [Icons.wb_sunny_outlined, Icons.calendar_view_week_outlined, Icons.calendar_today_outlined];

// ─── Screen ───────────────────────────────────────────────────────────────

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  int _signIndex = 0;
  int _periodIndex = 0;
  late final TabController _periodTab;

  @override
  void initState() {
    super.initState();
    _periodTab = TabController(length: _periods.length, vsync: this);
    _periodTab.addListener(() {
      if (!_periodTab.indexIsChanging) {
        setState(() => _periodIndex = _periodTab.index);
      }
    });
  }

  @override
  void dispose() {
    _periodTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sign = _signs[_signIndex];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _HoroscopeAppBar(
            sign: sign,
            periodTab: _periodTab,
          ),
          // ── Sign selector
          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _signs.length,
              itemBuilder: (_, i) {
                final s = _signs[i];
                final sel = i == _signIndex;
                final accent = _elementAccent(s.element);
                return GestureDetector(
                  onTap: () => setState(() => _signIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? accent.withValues(alpha: 0.18)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? accent : AppColors.borderDark,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.symbol,
                            style: TextStyle(
                                fontSize: 24,
                                color: sel ? accent : Colors.white70)),
                        const SizedBox(height: 2),
                        Text(s.name,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // ── Content
          Expanded(
            child: _HoroscopeContent(
              sign: sign,
              period: _periods[_periodIndex],
              periodLabel: _periodLabels[_periodIndex],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AppBar with integrated period tabs ───────────────────────────────────

class _HoroscopeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HoroscopeAppBar({required this.sign, required this.periodTab});
  final _Sign sign;
  final TabController periodTab;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            title: Row(
              children: [
                Text(sign.symbol,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('Horoscope',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          TabBar(
            controller: periodTab,
            indicatorColor: AppColors.accent,
            indicatorWeight: 2.5,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: List.generate(_periods.length, (i) => Tab(
              icon: Icon(_periodIcons[i], size: 16),
              text: _periodLabels[i],
              iconMargin: const EdgeInsets.only(bottom: 2),
            )),
          ),
        ],
      ),
    );
  }
}

// ─── Content (data-driven) ────────────────────────────────────────────────

class _HoroscopeContent extends ConsumerWidget {
  const _HoroscopeContent({
    required this.sign,
    required this.period,
    required this.periodLabel,
  });

  final _Sign sign;
  final String period;
  final String periodLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(horoscopeProvider((sign.slug, period)));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _HoroscopeBody(
        sign: sign,
        periodLabel: periodLabel,
        data: null,
      ),
      data: (data) => _HoroscopeBody(
        sign: sign,
        periodLabel: periodLabel,
        data: data,
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────

class _HoroscopeBody extends StatelessWidget {
  const _HoroscopeBody({
    required this.sign,
    required this.periodLabel,
    required this.data,
  });

  final _Sign sign;
  final String periodLabel;
  final HoroscopeData? data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ── Hero card
        _HeroCard(sign: sign, periodLabel: periodLabel, data: data),
        const SizedBox(height: 16),

        // ── Fortune score
        if (data?.fortuneScore != null) ...[
          _FortuneScoreCard(score: data!.fortuneScore!, sign: sign),
          const SizedBox(height: 16),
        ],

        // ── Overview
        if (data?.summary != null) ...[
          _SectionCard(
            index: 0,
            icon: '🌟',
            title: 'Overview',
            content: data!.summary!,
            accentColor: AppColors.accent,
          ),
          const SizedBox(height: 10),
        ],

        // ── Love
        _SectionCard(
          index: 1,
          icon: '❤️',
          title: 'Love & Relationships',
          content: data?.love ??
              'Venus aligns with your sign, bringing harmony and fresh energy to relationships.',
          accentColor: const Color(0xFFEC407A),
        ),
        const SizedBox(height: 10),

        // ── Career
        _SectionCard(
          index: 2,
          icon: '💼',
          title: 'Career & Finance',
          content: data?.career ??
              'Mercury\'s position favours negotiations, strategic thinking, and financial planning.',
          accentColor: const Color(0xFFFFB300),
        ),
        const SizedBox(height: 10),

        // ── Health
        _SectionCard(
          index: 3,
          icon: '🌿',
          title: 'Health & Wellness',
          content: data?.health ??
              'Energy levels are high. An ideal time to begin new health routines or exercise regimens.',
          accentColor: const Color(0xFF66BB6A),
        ),

        if (data?.general != null) ...[
          const SizedBox(height: 10),
          _SectionCard(
            index: 4,
            icon: '✨',
            title: 'General',
            content: data!.general!,
            accentColor: AppColors.primary,
          ),
        ],

        // ── Lucky charms
        const SizedBox(height: 16),
        _LuckyCharmsCard(sign: sign, data: data),

        // ── Planetary note footer
        const SizedBox(height: 16),
        _PlanetaryFooter(sign: sign, tt: tt),
      ],
    );
  }
}

// ─── Hero card with constellation background ──────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.sign, required this.periodLabel, this.data});
  final _Sign sign;
  final String periodLabel;
  final HoroscopeData? data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final grad = _elementGradient(sign.element);
    final accent = _elementAccent(sign.element);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Gradient base
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Constellation dots (CustomPaint)
          Positioned.fill(
            child: CustomPaint(painter: _ConstellationPainter(sign.slug)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Big symbol with glow
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(sign.symbol,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sign.name,
                          style: tt.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(sign.dates,
                          style: tt.bodySmall?.copyWith(
                              color: Colors.white70)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Text(periodLabel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sign.element[0].toUpperCase() +
                                  sign.element.substring(1),
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }
}

// ─── Constellation background painter ────────────────────────────────────

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter(this.slug);
  final String slug;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(slug.hashCode);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);

    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.8 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // A few connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 5; i++) {
      final x1 = rng.nextDouble() * size.width;
      final y1 = rng.nextDouble() * size.height;
      final x2 = x1 + (rng.nextDouble() - 0.5) * 80;
      final y2 = y1 + (rng.nextDouble() - 0.5) * 60;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter old) => old.slug != slug;
}

// ─── Fortune score card ───────────────────────────────────────────────────

class _FortuneScoreCard extends StatelessWidget {
  const _FortuneScoreCard({required this.score, required this.sign});
  final int score;
  final _Sign sign;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = _elementAccent(sign.element);
    final clamped = score.clamp(1, 5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Text('Fortune', style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          ...List.generate(5, (i) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              i < clamped ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 22,
              color: i < clamped ? accent : AppColors.borderDark,
            ),
          )),
          const SizedBox(width: 8),
          Text('$clamped/5',
              style: tt.labelMedium?.copyWith(
                  color: accent, fontWeight: FontWeight.w700)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

// ─── Section card ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
  });

  final int index;
  final String icon;
  final String title;
  final String content;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left accent bar
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(title,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    Text(content,
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary, height: 1.6)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: -0.04);
  }
}

// ─── Lucky charms card ────────────────────────────────────────────────────

class _LuckyCharmsCard extends StatelessWidget {
  const _LuckyCharmsCard({required this.sign, required this.data});
  final _Sign sign;
  final HoroscopeData? data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = _elementAccent(sign.element);

    final items = <(String, String, String)>[
      ('🎨', 'Color', data?.luckyColor ?? '—'),
      ('🔢', 'Number', data?.luckyNumber ?? '—'),
      ('📅', 'Day', data?.luckyDay ?? '—'),
      if (data?.luckyGem != null) ('💎', 'Gem', data!.luckyGem!),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.10),
            AppColors.cardDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('⭐', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('Lucky Charms',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 14),
          Row(
            children: items.map((item) {
              final (icon, label, value) = item;
              return Expanded(
                child: Column(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(value,
                        style: tt.labelMedium?.copyWith(
                            color: accent, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(label,
                        style: tt.labelSmall?.copyWith(
                            color: AppColors.textSecondary, fontSize: 10),
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 320.ms);
  }
}

// ─── Planetary footer ─────────────────────────────────────────────────────

class _PlanetaryFooter extends StatelessWidget {
  const _PlanetaryFooter({required this.sign, required this.tt});
  final _Sign sign;
  final TextTheme tt;

  // Ruling planet per sign
  static const _rulers = {
    'aries': ('♂', 'Mars'),
    'taurus': ('♀', 'Venus'),
    'gemini': ('☿', 'Mercury'),
    'cancer': ('☽', 'Moon'),
    'leo': ('☉', 'Sun'),
    'virgo': ('☿', 'Mercury'),
    'libra': ('♀', 'Venus'),
    'scorpio': ('♇', 'Pluto'),
    'sagittarius': ('♃', 'Jupiter'),
    'capricorn': ('♄', 'Saturn'),
    'aquarius': ('♅', 'Uranus'),
    'pisces': ('♆', 'Neptune'),
  };

  @override
  Widget build(BuildContext context) {
    final ruler = _rulers[sign.slug] ?? ('☉', 'Sun');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Text(ruler.$1,
              style: const TextStyle(fontSize: 28, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ruling Planet: ${ruler.$2}',
                    style: tt.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${sign.name} is ruled by ${ruler.$2}, '
                  'which influences your personality and cosmic alignment.',
                  style: tt.labelSmall
                      ?.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
