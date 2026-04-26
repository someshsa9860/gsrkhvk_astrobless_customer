import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';
import 'kundli_chart_painter.dart';

class KundliReportScreen extends ConsumerStatefulWidget {
  const KundliReportScreen({super.key, required this.profileId});
  final String profileId;

  @override
  ConsumerState<KundliReportScreen> createState() => _KundliReportScreenState();
}

class _KundliReportScreenState extends ConsumerState<KundliReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs = ['Basic', 'Charts', 'Dasha', 'Dosha', 'Ashtakvarga', 'Report'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reportAsync = ref.watch(kundliReportProvider(widget.profileId));
    final profilesAsync = ref.watch(kundliProfilesProvider);

    final profileName = profilesAsync.valueOrNull
            ?.firstWhere(
              (p) => p.id == widget.profileId,
              orElse: () => KundliProfile(
                id: widget.profileId,
                name: 'Kundli',
                dateOfBirth: '',
                placeOfBirth: '',
                lat: 0,
                lng: 0,
                createdAt: DateTime.now(),
              ),
            )
            .name ??
        'Kundli Report';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(profileName),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: c.primary,
          labelColor: c.primary,
          unselectedLabelColor: c.textSecondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: reportAsync.when(
        loading: () => _LoadingView(c: c),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(kundliReportProvider(widget.profileId)),
        ),
        data: (report) => TabBarView(
          controller: _tab,
          children: [
            _BasicTab(report: report, profile: profilesAsync.valueOrNull
                ?.firstWhere((p) => p.id == widget.profileId,
                    orElse: () => KundliProfile(
                          id: widget.profileId,
                          name: '',
                          dateOfBirth: '',
                          placeOfBirth: '',
                          lat: 0,
                          lng: 0,
                          createdAt: DateTime.now(),
                        ))),
            _ChartsTab(report: report, profileId: widget.profileId),
            _DashaTab(report: report, profileId: widget.profileId),
            _DoshaTab(report: report),
            _AshtakvargaTab(profileId: widget.profileId),
            _ReportTab(report: report),
          ],
        ),
      ),
    );
  }
}

// ─── Loading / Error ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.c});
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          CircularProgressIndicator(color: c.primary),
          const SizedBox(height: 16),
          Text('Generating your birth chart…',
              style: TextStyle(color: c.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: c.error, size: 48),
          const SizedBox(height: 12),
          Text('Failed to load report', style: tt.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ─── Tab: Basic ──────────────────────────────────────────────────────────────

class _BasicTab extends StatelessWidget {
  const _BasicTab({required this.report, this.profile});
  final KundliReport report;
  final KundliProfile? profile;

  @override
  Widget build(BuildContext context) {
    final data = report.chartData;
    final ascRaw = data['ascendant'];
    final asc = ascRaw is Map ? Map<String, dynamic>.from(ascRaw) : null;
    final mangalRaw = data['mangalDosha'];
    final mangal = mangalRaw is Map ? Map<String, dynamic>.from(mangalRaw) : null;
    final panchangRaw = data['panchangDetails'];
    final panchang = panchangRaw is Map ? Map<String, dynamic>.from(panchangRaw) : null;
    final avakhadaRaw = data['avakhadaDetails'];
    final avakhada = avakhadaRaw is Map ? Map<String, dynamic>.from(avakhadaRaw) : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profile != null) ...[
          _KundliInfoTable(profile: profile!, asc: asc),
          const SizedBox(height: 20),
        ],
        if (panchang != null) ...[
          _SectionHeader('Panchang Details'),
          const SizedBox(height: 8),
          _PanchangCard(panchang: panchang),
          const SizedBox(height: 20),
        ],
        if (avakhada != null) ...[
          _SectionHeader('Avakhada Details'),
          const SizedBox(height: 8),
          _AvakhadaCard(avakhada: avakhada),
          const SizedBox(height: 20),
        ],
        if (asc != null) ...[
          _SectionHeader('Ascendant Details'),
          const SizedBox(height: 8),
          _InfoCard(rows: [
            _Row('Ascendant', asc['sign']?.toString() ?? '—'),
            _Row('Sign Lord', asc['signLord']?.toString() ?? '—'),
            _Row('Nakshatra', asc['nakshatra']?.toString() ?? '—'),
            _Row('Nakshatra Lord', asc['nakshatraLord']?.toString() ?? '—'),
            _Row('Pada', asc['nakshatraPada']?.toString() ?? '—'),
          ]),
          const SizedBox(height: 20),
        ],
        if (mangal != null) ...[
          _SectionHeader('Manglik Analysis'),
          const SizedBox(height: 8),
          _ManglikCard(mangal: mangal),
          const SizedBox(height: 20),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _KundliInfoTable extends StatelessWidget {
  const _KundliInfoTable({required this.profile, this.asc});
  final KundliProfile profile;
  final Map<String, dynamic>? asc;

  @override
  Widget build(BuildContext context) {
    final dob = profile.dateOfBirth.isNotEmpty ? _formatDate(profile.dateOfBirth) : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Basic Details'),
        const SizedBox(height: 8),
        _InfoCard(rows: [
          _Row('Name', profile.name.toUpperCase()),
          _Row('Date of Birth', dob),
          if (profile.timeOfBirth != null) _Row('Time of Birth', _to12Hour(profile.timeOfBirth!)),
          _Row('Place of Birth', profile.placeOfBirth),
          _Row('Latitude', profile.lat.toStringAsFixed(4)),
          _Row('Longitude', profile.lng.toStringAsFixed(4)),
          _Row('Timezone', 'GMT+5:30 (IST)'),
          if (asc != null) ...[
            _Row('Ascendant', asc!['sign']?.toString() ?? '—'),
            _Row('Nakshatra', asc!['nakshatra']?.toString() ?? '—'),
          ],
        ]),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _to12Hour(String hhmm) {
    try {
      final parts = hhmm.split(':');
      var h = int.parse(parts[0]);
      final m = parts[1];
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(2, '0')}:$m $period';
    } catch (_) {
      return hhmm;
    }
  }
}

class _ManglikCard extends StatelessWidget {
  const _ManglikCard({required this.mangal});
  final Map<String, dynamic> mangal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final isManglik = mangal['isManglik'] as bool? ?? false;
    final desc = mangal['description']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isManglik ? c.error.withAlpha(80) : c.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isManglik ? c.error : c.success,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isManglik ? 'Yes' : 'No',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manglik',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc,
                      style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanchangCard extends StatelessWidget {
  const _PanchangCard({required this.panchang});
  final Map<String, dynamic> panchang;

  @override
  Widget build(BuildContext context) {
    final rows = <_Row>[];
    // VedicAstro panchang-details field names
    final fields = <String, String>{
      'Tithi': _str(panchang, ['tithi', 'tithi_name']),
      'Karan': _str(panchang, ['karan', 'karana', 'karna']),
      'Yog': _str(panchang, ['yog', 'yoga', 'yog_name']),
      'Nakshatra': _str(panchang, ['nakshatra', 'nakshatra_name']),
      'Sunrise': _str(panchang, ['sunrise', 'sun_rise']),
      'Sunset': _str(panchang, ['sunset', 'sun_set']),
      'Day': _str(panchang, ['day', 'vaara', 'weekday']),
    };
    for (final e in fields.entries) {
      if (e.value.isNotEmpty) rows.add(_Row(e.key, e.value));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return _InfoCard(rows: rows);
  }

  static String _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return '';
  }
}

class _AvakhadaCard extends StatelessWidget {
  const _AvakhadaCard({required this.avakhada});
  final Map<String, dynamic> avakhada;

  @override
  Widget build(BuildContext context) {
    final rows = <_Row>[];
    final fields = <String, String>{
      'Varna': _str(avakhada, ['varna']),
      'Vashya': _str(avakhada, ['vashya']),
      'Yoni': _str(avakhada, ['yoni']),
      'Gan': _str(avakhada, ['gan', 'gana']),
      'Nadi': _str(avakhada, ['nadi']),
      'Sign': _str(avakhada, ['sign', 'zodiac']),
      'Sign Lord': _str(avakhada, ['sign_lord', 'signLord']),
      'Nakshatra': _str(avakhada, ['nakshatra', 'nakshatra_name']),
      'Nakshatra-Charan': _str(avakhada, ['nakshatra_pada', 'nakshatraPada', 'charan']),
    };
    for (final e in fields.entries) {
      if (e.value.isNotEmpty) rows.add(_Row(e.key, e.value));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return _InfoCard(rows: rows);
  }

  static String _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return '';
  }
}

// ─── Tab: Charts ─────────────────────────────────────────────────────────────

// Short → full planet name
const _planetFullNames = {
  'As': 'Asc', 'Asc': 'Asc',
  'Su': 'Sun', 'Mo': 'Moon', 'Ma': 'Mars', 'Me': 'Mer',
  'Ju': 'Jup', 'Ve': 'Ven', 'Sa': 'Sat',
  'Ra': 'Rahu', 'Ke': 'Ketu',
  'Ur': 'Ura', 'Ne': 'Nep', 'Pl': 'Plu',
};

String _expandPlanetName(String name) => _planetFullNames[name] ?? name;

// Chart sub-tab labels
const _chartSubTabs = ['Lagna', 'Navamsa', 'Transit', 'Divisional'];

// Understanding Your Kundli content (localized via ARB)
const _understandingCategories = ['General', 'Planetary', 'Yoga'];

const _understandingContent = {
  'General': [
    _KundliSection('Description',
        'The birth chart (Kundli) is a cosmic snapshot of the sky at the exact moment of your birth. '
        'It maps the positions of the Sun, Moon, and planets across the 12 houses of your life. '
        'Reading a Kundli reveals your innate nature, potential, strengths, and challenges.'),
    _KundliSection('Ascendant (Lagna)',
        'The Ascendant is the zodiac sign rising on the eastern horizon at your birth moment. '
        'It shapes your physical appearance, personality, and how others perceive you. '
        'Unlike the Sun sign, the Ascendant changes every 2 hours, making it uniquely yours.'),
    _KundliSection('Houses',
        'The 12 houses govern every area of life — from self (1st house) and finances (2nd) to '
        'relationships (7th), career (10th), and spirituality (12th). Planets placed in a house '
        'activate and color that life area with their energy.'),
  ],
  'Planetary': [
    _KundliSection('Sun (Surya)',
        'The Sun represents your soul, ego, and life purpose. A strong Sun gives confidence, '
        'leadership, and vitality. It rules the 5th sign Leo and the 5th house in the natural zodiac.'),
    _KundliSection('Moon (Chandra)',
        'The Moon governs your mind, emotions, and subconscious. It changes signs every 2.5 days, '
        'influencing daily moods. Your Moon sign is as important as your Sun sign in Vedic astrology.'),
    _KundliSection('Mars (Mangal)',
        'Mars rules energy, courage, ambition, and drive. A strong Mars gives determination; '
        'a weak or afflicted Mars can cause impulsiveness or conflict.'),
    _KundliSection('Mercury (Budh)',
        'Mercury governs intellect, communication, and analytical ability. It is the planet of '
        'learning, trade, and logical thinking.'),
    _KundliSection('Jupiter (Guru)',
        'Jupiter is the planet of wisdom, expansion, fortune, and dharma. It is the greatest '
        'benefic in Vedic astrology and blesses any house it occupies or aspects.'),
    _KundliSection('Venus (Shukra)',
        'Venus rules love, beauty, luxury, and relationships. It governs artistic talent, '
        'material comfort, and the quality of one\'s partnerships.'),
    _KundliSection('Saturn (Shani)',
        'Saturn is the planet of karma, discipline, and hard work. Its lessons are slow but '
        'lasting. A strong Saturn rewards perseverance; a weak one can bring delays and obstacles.'),
    _KundliSection('Rahu & Ketu',
        'Rahu (north node) and Ketu (south node) are shadow planets that represent your karmic '
        'axis — past-life gifts (Ketu) and the direction of soul growth in this life (Rahu).'),
  ],
  'Yoga': [
    _KundliSection('Raj Yoga',
        'Raj Yoga forms when the lords of a trine (1st, 5th, 9th) and a kendra (1st, 4th, 7th, 10th) '
        'house conjoin or exchange signs. It promises success, authority, and recognition.'),
    _KundliSection('Dhana Yoga',
        'Dhana Yoga indicates wealth accumulation. It forms through the connection of the lords '
        'of the 2nd, 5th, 9th, and 11th houses — the wealth-giving houses.'),
    _KundliSection('Gajakesari Yoga',
        'When Jupiter is in a kendra from the Moon (or vice versa), Gajakesari Yoga forms. '
        'It blesses the native with intelligence, fame, and a noble character.'),
    _KundliSection('Pancha Mahapurusha Yoga',
        'These five yogas form when Mars, Mercury, Jupiter, Venus, or Saturn occupy their own '
        'or exalted sign in a kendra house. Each yoga confers exceptional qualities related to that planet.'),
  ],
};

class _KundliSection {
  final String title;
  final String body;
  const _KundliSection(this.title, this.body);
}

class _ChartsTab extends ConsumerStatefulWidget {
  const _ChartsTab({required this.report, required this.profileId});
  final KundliReport report;
  final String profileId;

  @override
  ConsumerState<_ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends ConsumerState<_ChartsTab> {
  int _subTab = 0;       // 0=Lagna 1=Navamsa 2=Transit 3=Divisional
  int _styleIdx = 0;     // 0=North 1=South
  int _understandingCat = 0;

  List<Map<String, dynamic>> _planetsFromDivisional(Map<String, dynamic> data) {
    final planets = <Map<String, dynamic>>[];
    data.forEach((name, val) {
      if (val is Map) {
        final m = Map<String, dynamic>.from(val);
        final house = (m['house'] as num?)?.toInt() ?? 0;
        if (house > 0) {
          planets.add({
            'name': name,
            'sign': m['zodiac']?.toString() ?? '',
            'signLord': m['lord']?.toString() ?? '',
            'house': house,
            'normDegree': m['degree'] ?? 0,
            'isRetro': m['isRetro'] ?? false,
          });
        }
      }
    });
    return planets;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final data = widget.report.chartData;

    // Lagna planets from cached report
    final rawPlanets = data['planets'];
    final List<Map<String, dynamic>> lagnaPlanetMaps = rawPlanets is List
        ? rawPlanets
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .where((p) => (p['name']?.toString() ?? '').isNotEmpty &&
                          ((p['house'] as num?)?.toInt() ?? 0) > 0)
            .toList()
        : [];

    final ascRaw = data['ascendant'];
    final asc = ascRaw is Map ? Map<String, dynamic>.from(ascRaw) : null;
    final ascSign = asc?['sign']?.toString() ?? '';

    List<ChartPlanet> toChartPlanets(List<Map<String, dynamic>> maps) =>
        maps.map((p) => ChartPlanet(
          shortName: p['name']?.toString() ?? '',
          house: (p['house'] as num?)?.toInt() ?? 1,
          isRetro: p['isRetro'] as bool? ?? false,
        )).toList();

    // Navamsa (D9) from divisional API
    final navamsaAsync = _subTab == 1
        ? ref.watch(kundliDivisionalChartProvider((widget.profileId, 'D9')))
        : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _ChartSubTabBar(
          tabs: _chartSubTabs,
          selected: _subTab,
          onTap: (i) => setState(() => _subTab = i),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_subTab == 0) ...[
                // ── Lagna (D1) — from cached report ──
                _ChartStyleToggle(
                  styleIdx: _styleIdx,
                  onChanged: (i) => setState(() => _styleIdx = i),
                ),
                const SizedBox(height: 12),
                _ChartCanvas(
                  planets: toChartPlanets(lagnaPlanetMaps),
                  ascSign: ascSign,
                  styleIdx: _styleIdx,
                ),
                const SizedBox(height: 20),
                _SectionHeader('Planets'),
                const SizedBox(height: 8),
                if (lagnaPlanetMaps.isNotEmpty)
                  _PlanetsTable(planets: lagnaPlanetMaps, ascendant: asc)
                else
                  Text('No planetary data available.',
                      style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              ] else if (_subTab == 1) ...[
                // ── Navamsa (D9) — live from divisional API ──
                _ChartStyleToggle(
                  styleIdx: _styleIdx,
                  onChanged: (i) => setState(() => _styleIdx = i),
                ),
                const SizedBox(height: 12),
                if (navamsaAsync == null)
                  const SizedBox.shrink()
                else
                  navamsaAsync.when(
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(color: c.primary),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: c.error, size: 36),
                          const SizedBox(height: 8),
                          Text('Failed to load Navamsa chart',
                              style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(
                                kundliDivisionalChartProvider((widget.profileId, 'D9'))),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (divData) {
                      final rawDiv = divData['planets'];
                      final divPlanets = rawDiv is Map
                          ? _planetsFromDivisional(Map<String, dynamic>.from(rawDiv))
                          : _planetsFromDivisional(divData);
                      final divAscSign = divData['ascendant']?.toString() ?? ascSign;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ChartCanvas(
                            planets: toChartPlanets(divPlanets),
                            ascSign: divAscSign,
                            styleIdx: _styleIdx,
                          ),
                          const SizedBox(height: 20),
                          _SectionHeader('Navamsa Planets (D9)'),
                          const SizedBox(height: 8),
                          if (divPlanets.isNotEmpty)
                            _PlanetsTable(planets: divPlanets, ascendant: null)
                          else
                            Text('No Navamsa data available.',
                                style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                        ],
                      );
                    },
                  ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_top_rounded,
                          color: c.primary.withAlpha(120), size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _subTab == 2 ? 'Transit Chart' : 'Divisional Charts',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coming soon in the next update.',
                        style: tt.bodySmall?.copyWith(color: c.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              // ── Understanding Your Kundli ──
              const SizedBox(height: 24),
              Text('Understanding Your Kundli',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_understandingCategories.length, (i) {
                    final selected = _understandingCat == i;
                    return Padding(
                      padding: EdgeInsets.only(right: i < _understandingCategories.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _understandingCat = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? c.primary : Colors.transparent,
                            border: Border.all(color: selected ? c.primary : c.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _understandingCategories[i],
                            style: tt.labelMedium?.copyWith(
                              color: selected ? Colors.white : c.textSecondary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              ...(_understandingContent[_understandingCategories[_understandingCat]] ?? [])
                  .map((s) => _KundliInfoCard(section: s)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartCanvas extends StatelessWidget {
  const _ChartCanvas({
    required this.planets,
    required this.ascSign,
    required this.styleIdx,
  });
  final List<ChartPlanet> planets;
  final String ascSign;
  final int styleIdx;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        padding: const EdgeInsets.all(12),
        child: ascSign.isNotEmpty
            ? KundliChartWidget(
                planets: planets,
                ascSign: ascSign,
                style: styleIdx == 0 ? KundliChartStyle.north : KundliChartStyle.south,
                size: MediaQuery.of(context).size.width - 80,
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Chart data unavailable',
                    style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              ),
      ),
    );
  }
}

class _ChartSubTabBar extends StatelessWidget {
  const _ChartSubTabBar({
    required this.tabs,
    required this.selected,
    required this.onTap,
  });
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final sel = selected == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: sel ? c.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: tt.labelMedium?.copyWith(
                    color: sel ? c.primary : c.textSecondary,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ChartStyleToggle extends StatelessWidget {
  const _ChartStyleToggle({required this.styleIdx, required this.onChanged});
  final int styleIdx;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Style: ', style: tt.labelSmall?.copyWith(color: c.textSecondary)),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              _StyleBtn(label: 'North', selected: styleIdx == 0, onTap: () => onChanged(0)),
              _StyleBtn(label: 'South', selected: styleIdx == 1, onTap: () => onChanged(1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleBtn extends StatelessWidget {
  const _StyleBtn({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: selected ? Colors.white : c.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _KundliInfoCard extends StatelessWidget {
  const _KundliInfoCard({required this.section});
  final _KundliSection section;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: tt.bodySmall?.copyWith(
              color: c.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

class _PlanetsTable extends StatelessWidget {
  const _PlanetsTable({required this.planets, this.ascendant});
  final List<Map<String, dynamic>> planets;
  final Map<String, dynamic>? ascendant;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    // Build rows: ascendant first, then planets
    final rows = <Map<String, dynamic>>[];
    if (ascendant != null) {
      rows.add({
        'name': 'Ascendant',
        'sign': ascendant!['sign'] ?? '—',
        'signLord': ascendant!['signLord'] ?? '—',
        'normDegree': ascendant!['degree'] ?? 0,
        'house': 1,
        'nakshatra': ascendant!['nakshatra'] ?? '—',
        'isRetro': false,
      });
    }
    rows.addAll(planets);

    final headerStyle = tt.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: c.textPrimary,
    );

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          // fixed row width: 100+90+80+70+50 columns + 24px horizontal padding
          width: (MediaQuery.of(context).size.width - 32).clamp(414.0, double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Container(
                width: double.infinity,
                color: c.primary.withAlpha(25),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 100, child: Text('Planet', style: headerStyle)),
                    SizedBox(width: 90, child: Text('Sign', style: headerStyle)),
                    SizedBox(width: 80, child: Text('Sign Lord', style: headerStyle)),
                    SizedBox(width: 70, child: Text('Degree', style: headerStyle)),
                    SizedBox(width: 50, child: Text('House', style: headerStyle)),
                  ],
                ),
              ),
              // Data rows
              ...rows.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final isRetro = p['isRetro'] as bool? ?? false;
                final rawDeg = p['normDegree'] ?? p['degree'] ?? 0;
                final deg = (rawDeg as num).toDouble();
                final degStr = '${deg.toStringAsFixed(1)}°';
                final name = _expandPlanetName(p['name']?.toString() ?? '—');
                final isAsc = name == 'Ascendant';

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isAsc
                        ? c.accent.withAlpha(18)
                        : i.isEven
                            ? Colors.transparent
                            : c.surface.withAlpha(35),
                    border: Border(top: BorderSide(color: c.border, width: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Row(children: [
                          Text(
                            name,
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isAsc ? c.accent : c.textPrimary,
                            ),
                          ),
                          if (isRetro) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: c.error.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('R',
                                  style: TextStyle(
                                      color: c.error,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ]),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(p['sign']?.toString() ?? '—',
                            style: tt.bodySmall),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(p['signLord']?.toString() ?? '—',
                            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(degStr,
                            style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          p['house']?.toString() ?? '—',
                          style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab: Dasha ──────────────────────────────────────────────────────────────

String _fmtDashaDate(String raw) {
  if (raw.isEmpty) return '—';
  try {
    final d = DateTime.parse(raw);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  } catch (_) {
    return raw;
  }
}

// Returns true if the period [start, end] contains today
bool _isCurrentPeriod(String start, String end) {
  try {
    final now = DateTime.now();
    final s = DateTime.parse(start);
    final e = DateTime.parse(end);
    return now.isAfter(s) && now.isBefore(e);
  } catch (_) {
    return false;
  }
}

class _DashaTab extends ConsumerStatefulWidget {
  const _DashaTab({required this.profileId, required this.report});
  final String profileId;
  final KundliReport report;

  @override
  ConsumerState<_DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends ConsumerState<_DashaTab> {
  // Drill-down state: null = mahadasha list; set = viewing antars of that maha planet
  String? _selectedMaha;
  // Antar selection for sub-dasha drill-down
  String? _selectedAntar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final dashaAsync = ref.watch(kundliFullDashaProvider(widget.profileId));
    final currentDasha = widget.report.chartData['currentDasha'];
    final currentDashaMap = currentDasha is Map ? Map<String, dynamic>.from(currentDasha) : null;

    return dashaAsync.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: c.primary),
              const SizedBox(height: 12),
              Text('Loading dasha data…',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary)),
            ],
          ),
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: c.error, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load dasha', style: tt.bodySmall?.copyWith(color: c.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(kundliFullDashaProvider(widget.profileId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (dashaList) {
        final periods = dashaList
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        if (_selectedMaha != null) {
          final maha = periods.firstWhere(
            (p) => p['planet'] == _selectedMaha,
            orElse: () => {},
          );
          if (maha.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedMaha = null);
            });
            return const SizedBox.shrink();
          }

          final antars = (maha['antars'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ?? [];

          if (_selectedAntar != null) {
            return _SubDashaView(
              profileId: widget.profileId,
              md: _selectedMaha!,
              ad: _selectedAntar!,
              onBack: () => setState(() => _selectedAntar = null),
            );
          }

          return _AntarDashaView(
            maha: maha,
            antars: antars,
            onBack: () => setState(() => _selectedMaha = null),
            onSelectAntar: (planet) => setState(() => _selectedAntar = planet),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (currentDashaMap != null) ...[
              _SectionHeader('Current Dasha'),
              const SizedBox(height: 8),
              _CurrentDashaCard(dasha: currentDashaMap),
              const SizedBox(height: 20),
            ],
            _SectionHeader('Vimshottari Mahadasha'),
            const SizedBox(height: 4),
            Text('Tap a period to explore Antardasha',
                style: tt.bodySmall?.copyWith(color: c.textSecondary)),
            const SizedBox(height: 12),
            if (periods.isEmpty)
              Text('No dasha data available.',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary))
            else
              Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: c.primary.withAlpha(30),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('Planet', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                          Expanded(flex: 3, child: Text('Start', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                          Expanded(flex: 3, child: Text('End', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                          const SizedBox(width: 24),
                        ],
                      ),
                    ),
                    ...periods.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      final planet = p['planet']?.toString() ?? '—';
                      final start = _fmtDashaDate(p['startDate']?.toString() ?? '');
                      final end = _fmtDashaDate(p['endDate']?.toString() ?? '');
                      final isCurrent = _isCurrentPeriod(
                        p['startDate']?.toString() ?? '',
                        p['endDate']?.toString() ?? '',
                      );
                      return InkWell(
                        onTap: () => setState(() => _selectedMaha = planet),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? c.primary.withAlpha(20)
                                : i.isOdd
                                    ? c.surface.withAlpha(30)
                                    : Colors.transparent,
                            border: Border(top: BorderSide(color: c.border, width: 0.5)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Text(planet,
                                        style: tt.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isCurrent ? c.primary : c.textPrimary,
                                        )),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: c.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Now',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Expanded(flex: 3, child: Text(start, style: tt.bodySmall?.copyWith(fontSize: 11))),
                              Expanded(flex: 3, child: Text(end, style: tt.bodySmall?.copyWith(fontSize: 11))),
                              Icon(Icons.chevron_right_rounded, size: 18, color: c.textSecondary),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _AntarDashaView extends StatelessWidget {
  const _AntarDashaView({
    required this.maha,
    required this.antars,
    required this.onBack,
    required this.onSelectAntar,
  });
  final Map<String, dynamic> maha;
  final List<Map<String, dynamic>> antars;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectAntar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final mahaPlanet = maha['planet']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Back button + header
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 16, color: c.primary),
                  Text('Back', style: tt.bodySmall?.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader('$mahaPlanet Antardasha'),
        const SizedBox(height: 4),
        Text('${_fmtDashaDate(maha['startDate']?.toString() ?? '')} — ${_fmtDashaDate(maha['endDate']?.toString() ?? '')}',
            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 4),
        Text('Tap an Antardasha to see Pratyantar/Sookshma/Prana levels',
            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 12),
        if (antars.isEmpty)
          Text('No antardasha data available.',
              style: tt.bodySmall?.copyWith(color: c.textSecondary))
        else
          Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: c.primary.withAlpha(30),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('Antar Planet', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                      Expanded(flex: 4, child: Text('End Date', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                ...antars.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  final planet = a['planet']?.toString() ?? '—';
                  final endDate = _fmtDashaDate(a['endDate']?.toString() ?? '');
                  return InkWell(
                    onTap: () => onSelectAntar(planet),
                    child: Container(
                      decoration: BoxDecoration(
                        color: i.isOdd ? c.surface.withAlpha(30) : Colors.transparent,
                        border: Border(top: BorderSide(color: c.border, width: 0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3,
                              child: Text('$mahaPlanet / $planet',
                                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                          Expanded(flex: 4,
                              child: Text(endDate, style: tt.bodySmall?.copyWith(fontSize: 11))),
                          Icon(Icons.chevron_right_rounded, size: 18, color: c.textSecondary),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SubDashaView extends ConsumerWidget {
  const _SubDashaView({
    required this.profileId,
    required this.md,
    required this.ad,
    required this.onBack,
  });
  final String profileId;
  final String md;
  final String ad;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    // Use Sun as default pd/sd — the API returns prana levels regardless
    final subAsync = ref.watch(kundliSpecificSubDashaProvider((profileId, md, ad, md, md)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 16, color: c.primary),
                  Text('Back', style: tt.bodySmall?.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader('$md / $ad Sub-Dasha'),
        const SizedBox(height: 12),
        subAsync.when(
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: c.primary),
            ),
          ),
          error: (e, _) => Column(
            children: [
              Icon(Icons.error_outline, color: c.error, size: 36),
              const SizedBox(height: 8),
              Text('Failed to load sub-dasha data',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                    kundliSpecificSubDashaProvider((profileId, md, ad, md, md))),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (data) {
            final prana = (data['pranadasha'] as List?)
                ?.whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList() ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(rows: [
                  _Row('Mahadasha', data['mahadasha']?.toString() ?? '—'),
                  _Row('Antardasha', data['antardasha']?.toString() ?? '—'),
                  _Row('Paryantardasha', data['paryantardasha']?.toString() ?? '—'),
                  _Row('Shookshamadasha', data['shookshamadasha']?.toString() ?? '—'),
                ]),
                if (prana.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionHeader('Pranadasha'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: c.primary.withAlpha(30),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text('Planet', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                              Expanded(flex: 3, child: Text('Start', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                              Expanded(flex: 3, child: Text('End', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                        ...prana.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;
                          return Container(
                            decoration: BoxDecoration(
                              color: i.isOdd ? c.surface.withAlpha(30) : Colors.transparent,
                              border: Border(top: BorderSide(color: c.border, width: 0.5)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(flex: 2,
                                    child: Text(p['name']?.toString() ?? '—',
                                        style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                                Expanded(flex: 3,
                                    child: Text(_fmtDashaDate(p['start']?.toString() ?? ''),
                                        style: tt.bodySmall?.copyWith(fontSize: 10))),
                                Expanded(flex: 3,
                                    child: Text(_fmtDashaDate(p['end']?.toString() ?? ''),
                                        style: tt.bodySmall?.copyWith(fontSize: 10))),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CurrentDashaCard extends StatelessWidget {
  const _CurrentDashaCard({required this.dasha});
  final Map<String, dynamic> dasha;

  @override
  Widget build(BuildContext context) {
    final rows = <_Row>[];
    final fields = {
      'Mahadasha': dasha['maha_dasha'] ?? dasha['mahaDasha'],
      'Antardasha': dasha['antar_dasha'] ?? dasha['antarDasha'],
      'Pratyantar': dasha['pratyantar_dasha'] ?? dasha['pratyantarDasha'],
      'Start': dasha['start_date'] ?? dasha['startDate'],
      'End': dasha['end_date'] ?? dasha['endDate'],
    };
    for (final e in fields.entries) {
      if (e.value != null) rows.add(_Row(e.key, e.value.toString()));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return _InfoCard(rows: rows, highlight: true);
  }
}

// ─── Tab: Dosha ──────────────────────────────────────────────────────────────

class _DoshaTab extends StatelessWidget {
  const _DoshaTab({required this.report});
  final KundliReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final data = report.chartData;
    final mangalRaw2 = data['mangalDosha'];
    final mangal = mangalRaw2 is Map ? Map<String, dynamic>.from(mangalRaw2) : null;
    final kaalSarpRaw = data['kaalSarpDosha'];
    final kaalSarp = kaalSarpRaw is Map ? Map<String, dynamic>.from(kaalSarpRaw) : null;
    final sadeSatiRaw = data['sadeSatiStatus'];
    final sadeSati = sadeSatiRaw is Map ? Map<String, dynamic>.from(sadeSatiRaw) : null;
    final pitraRaw = data['pitraDosha'];
    final pitra = pitraRaw is Map ? Map<String, dynamic>.from(pitraRaw) : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (mangal != null) ...[
          _SectionHeader('Mangal Dosha'),
          const SizedBox(height: 8),
          _DoshaCard(
            name: 'Mangal Dosha',
            isPresent: mangal['isManglik'] as bool? ?? false,
            description: mangal['description']?.toString() ?? '',
            remedies: (mangal['remedies'] as List?)?.cast<String>() ?? [],
          ),
          const SizedBox(height: 16),
        ],
        if (kaalSarp != null) ...[
          _SectionHeader('Kaal Sarp Dosha'),
          const SizedBox(height: 8),
          _DoshaCard(
            name: 'Kaal Sarp Dosha',
            isPresent: kaalSarp['isPresent'] as bool? ?? false,
            description: kaalSarp['description']?.toString() ?? '',
            subtitle: kaalSarp['type']?.toString() ?? '',
          ),
          const SizedBox(height: 16),
        ],
        if (sadeSati != null) ...[
          _SectionHeader('Sade Sati'),
          const SizedBox(height: 8),
          _SadeSatiCard(sadeSati: sadeSati),
          const SizedBox(height: 16),
        ],
        if (pitra != null) ...[
          _SectionHeader('Pitra Dosha'),
          const SizedBox(height: 8),
          _PitraCard(pitra: pitra),
          const SizedBox(height: 16),
        ],
        if (mangal == null && kaalSarp == null && sadeSati == null && pitra == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No dosha data available.',
                  style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DoshaCard extends StatelessWidget {
  const _DoshaCard({
    required this.name,
    required this.isPresent,
    required this.description,
    this.subtitle,
    this.remedies = const [],
  });
  final String name;
  final bool isPresent;
  final String description;
  final String? subtitle;
  final List<String> remedies;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isPresent ? c.error.withAlpha(80) : c.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent ? c.error : c.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isPresent ? 'Present' : 'Not Present',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(subtitle!,
                    style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description,
                style: tt.bodySmall?.copyWith(color: c.textSecondary)),
          ],
          if (remedies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Remedies',
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...remedies.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style:
                              TextStyle(color: c.primary, fontSize: 14)),
                      Expanded(
                          child: Text(r,
                              style: tt.bodySmall
                                  ?.copyWith(color: c.textSecondary))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _SadeSatiCard extends StatelessWidget {
  const _SadeSatiCard({required this.sadeSati});
  final Map<String, dynamic> sadeSati;

  @override
  Widget build(BuildContext context) {
    final isActive = sadeSati['is_in_sade_sati'] as bool? ??
        sadeSati['isInSadeSati'] as bool? ?? false;
    final desc = sadeSati['bot_response']?.toString() ??
        sadeSati['description']?.toString() ?? '';
    return _DoshaCard(
        name: 'Sade Sati',
        isPresent: isActive,
        description: desc);
  }
}

class _PitraCard extends StatelessWidget {
  const _PitraCard({required this.pitra});
  final Map<String, dynamic> pitra;

  @override
  Widget build(BuildContext context) {
    final isPresent = pitra['is_pitra_dosha'] as bool? ??
        pitra['isPresent'] as bool? ?? false;
    final desc = pitra['bot_response']?.toString() ??
        pitra['description']?.toString() ?? '';
    return _DoshaCard(
        name: 'Pitra Dosha', isPresent: isPresent, description: desc);
  }
}

// ─── Tab: Ashtakvarga ────────────────────────────────────────────────────────

const _ashtakvargaPlanets = [
  'total', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
];

const _zodiacOrder = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
];

const _zodiacEmoji = {
  'aries': '♈', 'taurus': '♉', 'gemini': '♊', 'cancer': '♋',
  'leo': '♌', 'virgo': '♍', 'libra': '♎', 'scorpio': '♏',
  'sagittarius': '♐', 'capricorn': '♑', 'aquarius': '♒', 'pisces': '♓',
};

class _AshtakvargaTab extends ConsumerStatefulWidget {
  const _AshtakvargaTab({required this.profileId});
  final String profileId;

  @override
  ConsumerState<_AshtakvargaTab> createState() => _AshtakvargaTabState();
}

class _AshtakvargaTabState extends ConsumerState<_AshtakvargaTab> {
  String _planet = 'total';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final asyncData = ref.watch(kundliAshtakvargaProvider((widget.profileId, _planet)));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Planet selector
        _ChartSubTabBar(
          tabs: _ashtakvargaPlanets
              .map((p) => p == 'total' ? 'Total' : p)
              .toList(),
          selected: _ashtakvargaPlanets.indexOf(_planet),
          onTap: (i) => setState(() => _planet = _ashtakvargaPlanets[i]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: asyncData.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(color: c.primary),
              ),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: c.error, size: 40),
                  const SizedBox(height: 12),
                  Text('Failed to load Ashtakvarga',
                      style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(
                        kundliAshtakvargaProvider((widget.profileId, _planet))),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (data) {
              final scoresRaw = data['scores'];
              final scores = scoresRaw is Map
                  ? Map<String, dynamic>.from(scoresRaw)
                  : <String, dynamic>{};
              final chartImage = data['chartImage'] as String?;
              final planetLabel = data['planet']?.toString() ?? _planet;

              // Compute total bindus
              final total = scores.values
                  .fold<int>(0, (s, v) => s + ((v as num?)?.toInt() ?? 0));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chart image (SVG/base64) if available
                  if (chartImage != null && chartImage.isNotEmpty) ...[
                    _SectionHeader('Ashtakvarga Chart — $planetLabel'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: _ChartImageView(url: chartImage),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Bindus score bar chart
                  _SectionHeader('Bindus by Sign'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: _zodiacOrder.map((sign) {
                        final score =
                            (scores[sign] as num?)?.toInt() ??
                            (scores[sign.toLowerCase()] as num?)?.toInt() ??
                            0;
                        final capitalised =
                            sign[0].toUpperCase() + sign.substring(1);
                        final emoji = _zodiacEmoji[sign] ?? '';
                        const maxBindus = 8;
                        final fraction = (score / maxBindus).clamp(0.0, 1.0);
                        final barColor = score >= 5
                            ? c.success
                            : score >= 3
                                ? c.accent
                                : c.error;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '$emoji $capitalised',
                                  style: tt.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: fraction,
                                    minHeight: 10,
                                    backgroundColor: c.border.withAlpha(80),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(barColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 18,
                                child: Text(
                                  '$score',
                                  style: tt.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: barColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Summary row
                  Container(
                    decoration: BoxDecoration(
                      color: c.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.primary.withAlpha(60)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bindus',
                            style: tt.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text('$total / ${_zodiacOrder.length * 8}',
                            style: tt.titleSmall?.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _AshtakvargaLegend(),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChartImageView extends StatelessWidget {
  const _ChartImageView({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: c.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text('Chart unavailable',
                style: tt.labelSmall?.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(color: c.primary, strokeWidth: 2)),
        );
      },
    );
  }
}

class _AshtakvargaLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Understanding Ashtakvarga',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'Ashtakvarga assigns each planet a score (bindus) per zodiac sign. '
            'Each planet contributes points based on its position relative to '
            'other planets and the ascendant. Higher bindus in a sign indicate '
            'more favourable results when a planet transits that sign.',
            style: tt.bodySmall?.copyWith(color: c.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 12),
          _LegendRow(color: c.success, label: '5–8 bindus', desc: 'Favourable'),
          const SizedBox(height: 6),
          _LegendRow(color: c.accent, label: '3–4 bindus', desc: 'Neutral'),
          const SizedBox(height: 6),
          _LegendRow(color: c.error, label: '0–2 bindus', desc: 'Challenging'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.desc});
  final Color color;
  final String label;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text('— $desc',
            style: tt.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140))),
      ],
    );
  }
}

// ─── Tab: Report ─────────────────────────────────────────────────────────────

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.report});
  final KundliReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final data = report.chartData;
    final prediction = data['generalPrediction']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Birth Chart Summary'),
        const SizedBox(height: 8),
        _InfoCard(rows: [
          _Row('Computed At', formatDateTime(report.computedAt)),
          if ((data['ascendant'] as Map?)?.isNotEmpty == true)
            _Row('Ascendant', (data['ascendant'] as Map)['sign']?.toString() ?? '—'),
        ]),
        const SizedBox(height: 16),
        if (prediction.isNotEmpty) ...[
          _SectionHeader('General Prediction'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(prediction,
                style: tt.bodyMedium?.copyWith(
                    color: c.textSecondary, height: 1.6)),
          ),
          const SizedBox(height: 16),
        ],
        if (prediction.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Text('📊', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Full report analysis coming soon.',
                      style:
                          tt.bodyMedium?.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Text(text,
        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows, this.highlight = false});
  final List<_Row> rows;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final bg = highlight ? c.primary.withAlpha(20) : c.card;
    final border = highlight ? c.primary.withAlpha(80) : c.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Container(
            decoration: BoxDecoration(
              border: i > 0
                  ? Border(top: BorderSide(color: c.border, width: 0.5))
                  : null,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(row.label,
                      style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                ),
                Expanded(
                  child: Text(row.value,
                      style: tt.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
