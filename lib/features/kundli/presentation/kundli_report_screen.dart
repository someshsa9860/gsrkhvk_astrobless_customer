import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  static const _tabs = ['Basic', 'Charts', 'Planets', 'Dasha', 'Dosha', 'Ashtakvarga', 'KP', 'Report'];

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
        data: (report) {
          final profile = profilesAsync.valueOrNull?.firstWhere(
            (p) => p.id == widget.profileId,
            orElse: () => KundliProfile(
              id: widget.profileId,
              name: '',
              dateOfBirth: '',
              placeOfBirth: '',
              lat: 0,
              lng: 0,
              createdAt: DateTime.now(),
            ),
          );
          return TabBarView(
            controller: _tab,
            children: [
              _BasicTab(report: report, profile: profile),
              _ChartsTab(report: report, profileId: widget.profileId),
              _PlanetsTab(report: report),
              _DashaTab(report: report, profileId: widget.profileId),
              _DoshaTab(report: report),
              _AshtakvargaTab(profileId: widget.profileId),
              _KpTab(report: report),
              _ReportTab(report: report),
            ],
          );
        },
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: c.error, size: 48),
          const SizedBox(height: 12),
          Text('Failed to load report',
              style: Theme.of(context).textTheme.bodyMedium),
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
    final asc = report.ascendant;
    final panchang = report.panchang;
    final avakhada = report.avakhada;
    final mangal = report.mangalDosha;

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
          _InfoCard(rows: [
            _Row('Tithi', panchang.tithi),
            _Row('Karan', panchang.karan),
            _Row('Yog', panchang.yog),
            _Row('Nakshatra', panchang.nakshatra),
            _Row('Day', panchang.vara),
            _Row('Sunrise', panchang.sunrise),
            _Row('Sunset', panchang.sunset),
            if (panchang.ayanamsa.isNotEmpty) _Row('Ayanamsa', panchang.ayanamsa),
            if (panchang.julian.isNotEmpty) _Row('Julian Day', panchang.julian),
          ].where((r) => r.value.isNotEmpty).toList()),
          const SizedBox(height: 20),
        ],
        if (avakhada != null) ...[
          _SectionHeader('Avakhada Details'),
          const SizedBox(height: 8),
          _InfoCard(rows: [
            _Row('Varna', avakhada.varna),
            _Row('Vashya', avakhada.vashya),
            _Row('Yoni', avakhada.yoni),
            _Row('Gan', avakhada.gan),
            _Row('Nadi', avakhada.nadi),
            _Row('Moon Sign', avakhada.moonRashi),
            _Row('Moon Nakshatra', avakhada.moonNakshatra),
            _Row('Moon Nak. Lord', avakhada.moonNakshatraLord),
            _Row('Sun Sign', avakhada.sunSign),
            _Row('Lucky', avakhada.lucky),
          ].where((r) => r.value.isNotEmpty).toList()),
          const SizedBox(height: 20),
        ],
        if (asc != null) ...[
          _SectionHeader('Ascendant Details'),
          const SizedBox(height: 8),
          _InfoCard(rows: [
            _Row('Ascendant', asc.sign),
            _Row('Sign Lord', asc.signLord),
            _Row('Degree', "${asc.degree.toStringAsFixed(2)}°"),
            _Row('Nakshatra', asc.nakshatra),
            _Row('Nakshatra Lord', asc.nakshatraLord),
            _Row('Pada', asc.nakshatraPada.toString()),
          ].where((r) => r.value.isNotEmpty && r.value != '0').toList()),
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
  final AscendantData? asc;

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
            _Row('Ascendant', asc!.sign),
            _Row('Nakshatra', asc!.nakshatra),
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
  final MangalDosha mangal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mangal.isManglik ? c.error.withAlpha(80) : c.border),
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
                  color: mangal.isManglik ? c.error : c.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mangal.isManglik ? 'Manglik' : 'Non-Manglik',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (mangal.manglikPct > 0) ...[
                const SizedBox(width: 8),
                Text('${mangal.manglikPct.toStringAsFixed(0)}%',
                    style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              ],
            ],
          ),
          if (mangal.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(mangal.description,
                style: tt.bodySmall?.copyWith(color: c.textSecondary, height: 1.5)),
          ],
          if (mangal.remedies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Remedies', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...mangal.remedies.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: c.primary, fontSize: 14)),
                      Expanded(child: Text(r, style: tt.bodySmall?.copyWith(color: c.textSecondary))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Tab: Charts ─────────────────────────────────────────────────────────────

// Divisional chart options shown in the selector
const _divisionalCharts = [
  ('D1', 'Lagna'),
  ('D2', 'Hora'),
  ('D3', 'Drekkana'),
  ('D4', 'Chaturthamsa'),
  ('D7', 'Saptamsa'),
  ('D9', 'Navamsa'),
  ('D10', 'Dashamsa'),
  ('D12', 'Dwadasamsa'),
  ('D16', 'Shodasamsa'),
  ('D20', 'Vimshamsa'),
  ('D24', 'Chaturvimshamsa'),
  ('D27', 'Bhamsa'),
  ('D30', 'Trimshamsa'),
  ('D40', 'Khavedamsa'),
  ('D45', 'Akshavedamsa'),
  ('D60', 'Shashtiamsa'),
];

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
  int _styleIdx = 0;
  int _understandingCat = 0;
  // Which divisional chart is selected (index into _divisionalCharts)
  int _divIdx = 0;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final report = widget.report;

    final (divKey, divLabel) = _divisionalCharts[_divIdx];
    final cachedSvgUrl = report.chartSvgUrls[divKey];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Divisional chart selector
        _HorizontalChipBar(
          chips: _divisionalCharts.map((e) => e.$1).toList(),
          selected: _divIdx,
          onTap: (i) => setState(() => _divIdx = i),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart label + style toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$divKey — $divLabel',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (cachedSvgUrl == null)
                    _ChartStyleToggle(
                      styleIdx: _styleIdx,
                      onChanged: (i) => setState(() => _styleIdx = i),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Chart display: SVG from storage if available, else painter
              if (cachedSvgUrl != null)
                _SvgChartCard(url: cachedSvgUrl, label: divLabel)
              else
                _LiveDivisionalChart(
                  report: report,
                  profileId: widget.profileId,
                  div: divKey,
                  styleIdx: _styleIdx,
                  onStyleChanged: (i) => setState(() => _styleIdx = i),
                  ref: ref,
                ),

              // Understanding Your Kundli
              const SizedBox(height: 28),
              Text('Understanding Your Kundli',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _HorizontalChipBar(
                chips: _understandingCategories,
                selected: _understandingCat,
                onTap: (i) => setState(() => _understandingCat = i),
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

class _SvgChartCard extends StatelessWidget {
  const _SvgChartCard({required this.url, required this.label});
  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final isSvg = url.toLowerCase().endsWith('.svg') || url.contains('/svg');

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(12),
      child: isSvg
          ? SvgPicture.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              placeholderBuilder: (_) => SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator(color: c.primary, strokeWidth: 2)),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              width: double.infinity,
              placeholder: (_, __) => SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator(color: c.primary, strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => _ChartUnavailable(label: label, c: c, tt: tt),
            ),
    );
  }
}

class _ChartUnavailable extends StatelessWidget {
  const _ChartUnavailable({required this.label, required this.c, required this.tt});
  final String label;
  final AppThemeColors c;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.broken_image_outlined, color: c.textSecondary, size: 32),
          const SizedBox(height: 8),
          Text('$label chart unavailable', style: tt.labelSmall?.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}

class _LiveDivisionalChart extends ConsumerWidget {
  const _LiveDivisionalChart({
    required this.report,
    required this.profileId,
    required this.div,
    required this.styleIdx,
    required this.onStyleChanged,
    required this.ref,
  });
  final KundliReport report;
  final String profileId;
  final String div;
  final int styleIdx;
  final ValueChanged<int> onStyleChanged;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final c = context.colors;
    final asc = report.ascendant;

    // D1 uses cached report planets
    if (div == 'D1') {
      final planets = report.planets
          .where((p) => p.house > 0)
          .map((p) => ChartPlanet(
                shortName: p.name.length > 2 ? p.name.substring(0, 2) : p.name,
                house: p.house,
                isRetro: p.isRetro,
              ))
          .toList();
      return _ChartCanvas(
        planets: planets,
        ascSign: asc?.sign ?? '',
        styleIdx: styleIdx,
      );
    }

    // Other divisional charts — fetch live
    final divAsync = widgetRef.watch(kundliDivisionalChartProvider((profileId, div)));
    return divAsync.when(
      loading: () => SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(color: c.primary)),
      ),
      error: (e, _) => _DivChartError(
        onRetry: () => widgetRef.invalidate(kundliDivisionalChartProvider((profileId, div))),
      ),
      data: (data) {
        final planetsRaw = data['planets'];
        final List<Map<String, dynamic>> planetMaps;
        if (planetsRaw is List) {
          planetMaps = planetsRaw.whereType<Map<dynamic, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (planetsRaw is Map) {
          planetMaps = [];
          planetsRaw.forEach((name, val) {
            if (val is Map) {
              final m = Map<String, dynamic>.from(val);
              final house = (m['house'] as num?)?.toInt() ?? 0;
              if (house > 0) planetMaps.add({'name': name, 'house': house, 'isRetro': m['isRetro'] ?? false, ...m});
            }
          });
        } else {
          planetMaps = [];
        }

        final divAscSign = data['ascendant']?.toString() ?? asc?.sign ?? '';
        final chartPlanets = planetMaps
            .map((p) => ChartPlanet(
                  shortName: (p['name']?.toString() ?? '').length > 2
                      ? p['name'].toString().substring(0, 2)
                      : p['name']?.toString() ?? '',
                  house: (p['house'] as num?)?.toInt() ?? 1,
                  isRetro: p['isRetro'] as bool? ?? false,
                ))
            .toList();

        return _ChartCanvas(
          planets: chartPlanets,
          ascSign: divAscSign,
          styleIdx: styleIdx,
        );
      },
    );
  }
}

class _DivChartError extends StatelessWidget {
  const _DivChartError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: c.error, size: 36),
          const SizedBox(height: 8),
          Text('Failed to load chart',
              style: tt.bodySmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
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
    return Container(
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
    );
  }
}

class _HorizontalChipBar extends StatelessWidget {
  const _HorizontalChipBar({
    required this.chips,
    required this.selected,
    required this.onTap,
  });
  final List<String> chips;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: List.generate(chips.length, (i) {
            final sel = selected == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? c.primary : Colors.transparent,
                  border: Border.all(color: sel ? c.primary : c.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chips[i],
                  style: tt.labelSmall?.copyWith(
                    color: sel ? Colors.white : c.textSecondary,
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
      mainAxisSize: MainAxisSize.min,
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
            style: tt.bodySmall?.copyWith(color: c.textSecondary, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Planets ─────────────────────────────────────────────────────────────

class _PlanetsTab extends StatelessWidget {
  const _PlanetsTab({required this.report});
  final KundliReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final planets = report.planets;
    final asc = report.ascendant;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Planetary Positions'),
        const SizedBox(height: 4),
        Text('Birth chart planetary placement with nakshatra details.',
            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 12),

        if (asc != null) ...[
          // Ascendant row card
          _InfoCard(rows: [
            _Row('Ascendant', asc.sign),
            _Row('Degree', "${asc.degree.toStringAsFixed(2)}°"),
            _Row('Nakshatra', '${asc.nakshatra} (${asc.nakshatraLord}) — Pada ${asc.nakshatraPada}'),
          ]),
          const SizedBox(height: 16),
        ],

        // Full planets table
        if (planets.isNotEmpty)
          _FullPlanetsTable(planets: planets)
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text('No planetary data available.',
                  style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _FullPlanetsTable extends StatelessWidget {
  const _FullPlanetsTable({required this.planets});
  final List<PlanetData> planets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final headerStyle = tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                color: c.primary.withAlpha(25),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 88, child: Text('Planet', style: headerStyle)),
                    SizedBox(width: 80, child: Text('Sign', style: headerStyle)),
                    SizedBox(width: 60, child: Text('Degree', style: headerStyle)),
                    SizedBox(width: 44, child: Text('House', style: headerStyle)),
                    SizedBox(width: 100, child: Text('Nakshatra', style: headerStyle)),
                    SizedBox(width: 80, child: Text('Nak. Lord', style: headerStyle)),
                    SizedBox(width: 40, child: Text('Pada', style: headerStyle)),
                  ],
                ),
              ),
              // Rows
              ...planets.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.transparent : c.surface.withAlpha(30),
                    border: Border(top: BorderSide(color: c.border, width: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Row(
                          children: [
                            Text(p.name,
                                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            if (p.isRetro) ...[
                              const SizedBox(width: 4),
                              _RetroTag(c: c),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 80, child: Text(p.sign, style: tt.bodySmall)),
                      SizedBox(
                        width: 60,
                        child: Text(p.degreeStr,
                            style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(p.house.toString(),
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(width: 100, child: Text(p.nakshatra, style: tt.bodySmall)),
                      SizedBox(
                        width: 80,
                        child: Text(p.nakshatraLord,
                            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(p.nakshatraPada.toString(),
                            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
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

class _RetroTag extends StatelessWidget {
  const _RetroTag({required this.c});
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: c.error.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('R', style: TextStyle(color: c.error, fontSize: 9, fontWeight: FontWeight.w700)),
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

class _DashaTab extends ConsumerStatefulWidget {
  const _DashaTab({required this.profileId, required this.report});
  final String profileId;
  final KundliReport report;

  @override
  ConsumerState<_DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends ConsumerState<_DashaTab> {
  String? _selectedMaha;
  String? _selectedAntar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final dashaAsync = ref.watch(kundliFullDashaProvider(widget.profileId));
    final currentDasha = widget.report.currentDasha;

    // If dasha already available in report, prefer it
    final builtInDasha = widget.report.dasha;

    return dashaAsync.when(
      loading: () => builtInDasha.isNotEmpty
          ? _DashaList(
              periods: builtInDasha,
              currentDasha: currentDasha,
              selectedMaha: _selectedMaha,
              selectedAntar: _selectedAntar,
              profileId: widget.profileId,
              onSelectMaha: (p) => setState(() { _selectedMaha = p; _selectedAntar = null; }),
              onSelectAntar: (p) => setState(() => _selectedAntar = p),
              onBackMaha: () => setState(() => _selectedMaha = null),
              onBackAntar: () => setState(() => _selectedAntar = null),
            )
          : Center(
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
      data: (rawList) {
        final periods = rawList.isNotEmpty
            ? rawList
                .whereType<Map>()
                .map((e) => MahaDasha.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : builtInDasha;

        return _DashaList(
          periods: periods,
          currentDasha: currentDasha,
          selectedMaha: _selectedMaha,
          selectedAntar: _selectedAntar,
          profileId: widget.profileId,
          onSelectMaha: (p) => setState(() { _selectedMaha = p; _selectedAntar = null; }),
          onSelectAntar: (p) => setState(() => _selectedAntar = p),
          onBackMaha: () => setState(() => _selectedMaha = null),
          onBackAntar: () => setState(() => _selectedAntar = null),
        );
      },
    );
  }
}

class _DashaList extends ConsumerWidget {
  const _DashaList({
    required this.periods,
    required this.currentDasha,
    required this.selectedMaha,
    required this.selectedAntar,
    required this.profileId,
    required this.onSelectMaha,
    required this.onSelectAntar,
    required this.onBackMaha,
    required this.onBackAntar,
  });

  final List<MahaDasha> periods;
  final Map<String, dynamic>? currentDasha;
  final String? selectedMaha;
  final String? selectedAntar;
  final String profileId;
  final ValueChanged<String> onSelectMaha;
  final ValueChanged<String> onSelectAntar;
  final VoidCallback onBackMaha;
  final VoidCallback onBackAntar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    if (selectedMaha != null) {
      final maha = periods.firstWhere(
        (p) => p.planet == selectedMaha,
        orElse: () => MahaDasha(planet: '', startDate: '', endDate: '', antars: []),
      );
      if (maha.planet.isEmpty) return const SizedBox.shrink();

      if (selectedAntar != null) {
        return _SubDashaView(
          profileId: profileId,
          md: selectedMaha!,
          ad: selectedAntar!,
          onBack: onBackAntar,
        );
      }

      return _AntarDashaView(
        maha: maha,
        onBack: onBackMaha,
        onSelectAntar: onSelectAntar,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (currentDasha != null) ...[
          _SectionHeader('Current Dasha'),
          const SizedBox(height: 8),
          _CurrentDashaCard(dasha: currentDasha!),
          const SizedBox(height: 20),
        ],
        _SectionHeader('Vimshottari Mahadasha'),
        const SizedBox(height: 4),
        Text('Tap a period to explore Antardasha',
            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 12),
        if (periods.isEmpty)
          Text('No dasha data available.', style: tt.bodySmall?.copyWith(color: c.textSecondary))
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
                  final isCurrent = p.isCurrent;
                  return InkWell(
                    onTap: () => onSelectMaha(p.planet),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? c.primary.withAlpha(20)
                            : i.isOdd ? c.surface.withAlpha(30) : Colors.transparent,
                        border: Border(top: BorderSide(color: c.border, width: 0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(children: [
                              Text(p.planet,
                                  style: tt.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent ? c.primary : c.textPrimary,
                                  )),
                              if (isCurrent) ...[
                                const SizedBox(width: 6),
                                _NowBadge(c: c),
                              ],
                            ]),
                          ),
                          Expanded(flex: 3,
                              child: Text(_fmtDashaDate(p.startDate),
                                  style: tt.bodySmall?.copyWith(fontSize: 11))),
                          Expanded(flex: 3,
                              child: Text(_fmtDashaDate(p.endDate),
                                  style: tt.bodySmall?.copyWith(fontSize: 11))),
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

class _NowBadge extends StatelessWidget {
  const _NowBadge({required this.c});
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
      child: const Text('Now',
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}

class _AntarDashaView extends StatelessWidget {
  const _AntarDashaView({
    required this.maha,
    required this.onBack,
    required this.onSelectAntar,
  });
  final MahaDasha maha;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectAntar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final antars = maha.antars;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BackButton(onTap: onBack),
        const SizedBox(height: 16),
        _SectionHeader('${maha.planet} Antardasha'),
        const SizedBox(height: 4),
        Text('${_fmtDashaDate(maha.startDate)} — ${_fmtDashaDate(maha.endDate)}',
            style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 4),
        Text('Tap an Antardasha to see Pratyantar levels',
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
                  return InkWell(
                    onTap: () => onSelectAntar(a.planet),
                    child: Container(
                      decoration: BoxDecoration(
                        color: i.isOdd ? c.surface.withAlpha(30) : Colors.transparent,
                        border: Border(top: BorderSide(color: c.border, width: 0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3,
                              child: Text('${maha.planet} / ${a.planet}',
                                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                          Expanded(flex: 4,
                              child: Text(_fmtDashaDate(a.endDate),
                                  style: tt.bodySmall?.copyWith(fontSize: 11))),
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
    final subAsync = ref.watch(kundliSpecificSubDashaProvider((profileId, md, ad, md, md)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BackButton(onTap: onBack),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: c.error, size: 36),
              const SizedBox(height: 8),
              Text('Failed to load sub-dasha',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(kundliSpecificSubDashaProvider((profileId, md, ad, md, md))),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (data) {
            final prana = (data['pranadasha'] as List?)
                    ?.whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList() ??
                [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(rows: [
                  _Row('Mahadasha', data['mahadasha']?.toString() ?? '—'),
                  _Row('Antardasha', data['antardasha']?.toString() ?? '—'),
                  _Row('Paryantardasha', data['paryantardasha']?.toString() ?? '—'),
                  _Row('Shookshamadasha', data['shookshamadasha']?.toString() ?? '—'),
                ].where((r) => r.value != '—').toList()),
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
      if (e.value != null && e.value.toString().isNotEmpty) {
        rows.add(_Row(e.key, e.value.toString()));
      }
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
    final mangal = report.mangalDosha;
    final kaalSarp = report.kaalSarpDosha;
    final sadeSati = report.sadeSatiStatus;
    final pitra = report.pitraDosha;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (mangal != null) ...[
          _SectionHeader('Mangal Dosha'),
          const SizedBox(height: 8),
          _DoshaCard(
            name: 'Mangal Dosha',
            isPresent: mangal.isManglik,
            description: mangal.description,
            remedies: mangal.remedies,
          ),
          const SizedBox(height: 16),
        ],
        if (kaalSarp != null) ...[
          _SectionHeader('Kaal Sarp Dosha'),
          const SizedBox(height: 8),
          _DoshaCard(
            name: 'Kaal Sarp Dosha',
            isPresent: kaalSarp.isPresent,
            description: kaalSarp.description,
            subtitle: kaalSarp.type.isNotEmpty
                ? '${kaalSarp.type}${kaalSarp.severity.isNotEmpty ? ' — ${kaalSarp.severity}' : ''}'
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (sadeSati != null) ...[
          _SectionHeader('Sade Sati'),
          const SizedBox(height: 8),
          _DoshaCard(
            name: 'Sade Sati',
            isPresent: sadeSati.isActive,
            description: sadeSati.description,
            subtitle: sadeSati.phase.isNotEmpty ? 'Phase: ${sadeSati.phase}' : null,
          ),
          const SizedBox(height: 16),
        ],
        if (pitra != null) ...[
          _SectionHeader('Pitra Dosha'),
          const SizedBox(height: 8),
          _DoshaCard(name: 'Pitra Dosha', isPresent: pitra.isPresent, description: pitra.description),
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
        border: Border.all(color: isPresent ? c.error.withAlpha(80) : c.border),
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
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(child: Text(subtitle!, style: tt.bodySmall?.copyWith(color: c.textSecondary))),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description, style: tt.bodySmall?.copyWith(color: c.textSecondary, height: 1.5)),
          ],
          if (remedies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Remedies', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...remedies.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: c.primary, fontSize: 14)),
                      Expanded(child: Text(r, style: tt.bodySmall?.copyWith(color: c.textSecondary))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
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
        _HorizontalChipBar(
          chips: _ashtakvargaPlanets.map((p) => p == 'total' ? 'Total' : p).toList(),
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
                    onPressed: () =>
                        ref.invalidate(kundliAshtakvargaProvider((widget.profileId, _planet))),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (data) {
              final avData = AshtakvargaData.fromJson(data);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SVG chart if available (cached from backend)
                  if (avData.chartImageUrl != null && avData.chartImageUrl!.isNotEmpty) ...[
                    _SectionHeader('Ashtakvarga Chart — ${avData.planet}'),
                    const SizedBox(height: 10),
                    _SvgChartCard(url: avData.chartImageUrl!, label: '${avData.planet} Ashtakvarga'),
                    const SizedBox(height: 20),
                  ],

                  // Bindus bar chart
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
                            avData.scores[sign] ?? avData.scores[sign.toLowerCase()] ?? 0;
                        final label = sign[0].toUpperCase() + sign.substring(1);
                        const maxBindus = 8;
                        final fraction = (score / maxBindus).clamp(0.0, 1.0);
                        final barColor = score >= 5 ? c.success : score >= 3 ? c.accent : c.error;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '${_zodiacEmoji[sign] ?? ''} $label',
                                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: fraction,
                                    minHeight: 10,
                                    backgroundColor: c.border.withAlpha(80),
                                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
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

                  // Total summary
                  Container(
                    decoration: BoxDecoration(
                      color: c.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.primary.withAlpha(60)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bindus',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${avData.totalBindus} / ${_zodiacOrder.length * 8}',
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
            'Higher bindus in a sign indicate more favourable results when a '
            'planet transits that sign.',
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text('— $desc',
            style: tt.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140))),
      ],
    );
  }
}

// ─── Tab: KP (Krishnamurti Paddhati) ─────────────────────────────────────────

class _KpTab extends ConsumerStatefulWidget {
  const _KpTab({required this.report});
  final KundliReport report;

  @override
  ConsumerState<_KpTab> createState() => _KpTabState();
}

class _KpTabState extends ConsumerState<_KpTab> {
  // KP sub-sections
  int _kpSub = 0;
  static const _kpSubTabs = ['KP Chart', 'Sub Lords', 'House Cusps'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final report = widget.report;

    // Use cached D1 SVG if available; otherwise show the chart painter
    final kpChartUrl = report.chartSvgUrls['D1'];
    final rawKp = report.rawData['kpPlanets'];
    final kpPlanets = rawKp is List
        ? rawKp.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
    final rawCusps = report.rawData['kpHouseCusps'];
    final cusps = rawCusps is List
        ? rawCusps.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HorizontalChipBar(
          chips: _kpSubTabs,
          selected: _kpSub,
          onTap: (i) => setState(() => _kpSub = i),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_kpSub == 0) ...[
                _SectionHeader('KP Lagna Chart'),
                const SizedBox(height: 4),
                Text(
                  'Krishnamurti Paddhati uses the same chart as Lagna (D1) but '
                  'interprets it through sub-lords and stellar positions.',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 12),
                if (kpChartUrl != null)
                  _SvgChartCard(url: kpChartUrl, label: 'KP Chart')
                else ...[
                  // Fall back to the painter with D1 planets
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: report.ascendant != null
                        ? KundliChartWidget(
                            planets: report.planets
                                .where((p) => p.house > 0)
                                .map((p) => ChartPlanet(
                                      shortName: p.name.length > 2 ? p.name.substring(0, 2) : p.name,
                                      house: p.house,
                                      isRetro: p.isRetro,
                                    ))
                                .toList(),
                            ascSign: report.ascendant!.sign,
                            style: KundliChartStyle.south,
                            size: MediaQuery.of(context).size.width - 80,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text('KP chart unavailable',
                                style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                          ),
                  ),
                ],
                const SizedBox(height: 20),
                _KpInfoCard(),
              ] else if (_kpSub == 1) ...[
                _SectionHeader('Sub Lords'),
                const SizedBox(height: 4),
                Text(
                  'In KP astrology, each planet is placed in a star lord\'s sub-division. '
                  'The sub-lord reveals specific results the planet will deliver.',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 12),
                if (kpPlanets.isNotEmpty)
                  _KpSubLordsTable(planets: kpPlanets)
                else
                  _KpFallbackTable(planets: report.planets),
              ] else ...[
                _SectionHeader('House Cusps'),
                const SizedBox(height: 4),
                Text(
                  'KP uses Placidus house cusps. Each house cusp falls in a specific star '
                  'sub-lord which determines the signification of that house.',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 12),
                if (cusps.isNotEmpty)
                  _KpCuspsTable(cusps: cusps)
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'KP house cusps data not available.\nThis section requires a KP-specific API call.',
                        style: tt.bodySmall?.copyWith(color: c.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpInfoCard extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About KP Astrology', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Krishnamurti Paddhati (KP) is a highly accurate system of stellar astrology '
            'developed by K.S. Krishnamurti. It uses Placidus house system, 249 sub-divisions '
            'of the zodiac based on Vimshottari dasha proportions, and focuses on the sub-lord '
            'of the house cusp to determine precise event timing.',
            style: tt.bodySmall?.copyWith(color: c.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _KpSubLordsTable extends StatelessWidget {
  const _KpSubLordsTable({required this.planets});
  final List<Map<String, dynamic>> planets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final header = tt.labelSmall?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: c.primary.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(width: 80, child: Text('Planet', style: header)),
                  SizedBox(width: 80, child: Text('Sign', style: header)),
                  SizedBox(width: 80, child: Text('Star Lord', style: header)),
                  SizedBox(width: 80, child: Text('Sub Lord', style: header)),
                  SizedBox(width: 60, child: Text('Sub-Sub', style: header)),
                ],
              ),
            ),
            ...planets.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Container(
                decoration: BoxDecoration(
                  color: i.isEven ? Colors.transparent : c.surface.withAlpha(30),
                  border: Border(top: BorderSide(color: c.border, width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(p['name']?.toString() ?? '—', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                    SizedBox(width: 80, child: Text(p['sign']?.toString() ?? '—', style: tt.bodySmall)),
                    SizedBox(width: 80, child: Text(p['starLord']?.toString() ?? p['nakshatraLord']?.toString() ?? '—', style: tt.bodySmall)),
                    SizedBox(width: 80, child: Text(p['subLord']?.toString() ?? '—', style: tt.bodySmall)),
                    SizedBox(width: 60, child: Text(p['subSubLord']?.toString() ?? '—', style: tt.bodySmall?.copyWith(color: c.textSecondary))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KpFallbackTable extends StatelessWidget {
  const _KpFallbackTable({required this.planets});
  final List<PlanetData> planets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final header = tt.labelSmall?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: c.primary.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(width: 88, child: Text('Planet', style: header)),
                  SizedBox(width: 80, child: Text('Sign', style: header)),
                  SizedBox(width: 60, child: Text('Degree', style: header)),
                  SizedBox(width: 100, child: Text('Star Lord', style: header)),
                  SizedBox(width: 40, child: Text('Pada', style: header)),
                ],
              ),
            ),
            ...planets.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Container(
                decoration: BoxDecoration(
                  color: i.isEven ? Colors.transparent : c.surface.withAlpha(30),
                  border: Border(top: BorderSide(color: c.border, width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 88,
                      child: Row(children: [
                        Text(p.name, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (p.isRetro) ...[const SizedBox(width: 4), _RetroTag(c: c)],
                      ]),
                    ),
                    SizedBox(width: 80, child: Text(p.sign, style: tt.bodySmall)),
                    SizedBox(width: 60, child: Text(p.degreeStr, style: tt.labelSmall?.copyWith(color: c.textSecondary))),
                    SizedBox(width: 100, child: Text(p.nakshatraLord, style: tt.bodySmall)),
                    SizedBox(width: 40, child: Text(p.nakshatraPada.toString(), style: tt.bodySmall?.copyWith(color: c.textSecondary))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KpCuspsTable extends StatelessWidget {
  const _KpCuspsTable({required this.cusps});
  final List<Map<String, dynamic>> cusps;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final header = tt.labelSmall?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: c.primary.withAlpha(25),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 60, child: Text('House', style: header)),
                Expanded(child: Text('Sign', style: header)),
                Expanded(child: Text('Star Lord', style: header)),
                Expanded(child: Text('Sub Lord', style: header)),
              ],
            ),
          ),
          ...cusps.asMap().entries.map((entry) {
            final i = entry.key;
            final cusp = entry.value;
            return Container(
              decoration: BoxDecoration(
                color: i.isEven ? Colors.transparent : c.surface.withAlpha(30),
                border: Border(top: BorderSide(color: c.border, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(cusp['house']?.toString() ?? '${i + 1}', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
                  Expanded(child: Text(cusp['sign']?.toString() ?? '—', style: tt.bodySmall)),
                  Expanded(child: Text(cusp['starLord']?.toString() ?? cusp['nakshatraLord']?.toString() ?? '—', style: tt.bodySmall)),
                  Expanded(child: Text(cusp['subLord']?.toString() ?? '—', style: tt.bodySmall)),
                ],
              ),
            );
          }),
        ],
      ),
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
    final prediction = report.generalPrediction ?? '';
    final asc = report.ascendant;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Birth Chart Summary'),
        const SizedBox(height: 8),
        _InfoCard(rows: [
          _Row('Computed At', formatDateTime(report.computedAt)),
          _Row('Cache', report.cached ? 'Cached result' : 'Freshly computed'),
          if (asc != null) ...[
            _Row('Ascendant', asc.sign),
            _Row('Asc. Degree', "${asc.degree.toStringAsFixed(2)}°"),
            _Row('Asc. Nakshatra', '${asc.nakshatra} (${asc.nakshatraLord})'),
          ],
          if (report.planets.isNotEmpty)
            _Row('Planets', '${report.planets.length} positioned'),
          if (report.dasha.isNotEmpty)
            _Row('Dasha periods', '${report.dasha.length} mahadasha periods'),
        ]),
        const SizedBox(height: 20),
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
                style: tt.bodyMedium?.copyWith(color: c.textSecondary, height: 1.6)),
          ),
          const SizedBox(height: 16),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Full report analysis coming soon.',
                      style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ),

        // Chart SVG URLs summary
        if (report.chartSvgUrls.isNotEmpty) ...[
          _SectionHeader('Saved Charts'),
          const SizedBox(height: 8),
          _InfoCard(rows: report.chartSvgUrls.entries
              .map((e) => _Row(e.key, 'Saved ✓'))
              .toList()),
          const SizedBox(height: 16),
        ],

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
    return Text(text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
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

    if (rows.isEmpty) return const SizedBox.shrink();

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
              border: i > 0 ? Border(top: BorderSide(color: c.border, width: 0.5)) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(row.label, style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                ),
                Expanded(
                  child: Text(row.value,
                      style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_rounded, size: 16, color: c.primary),
          Text('Back', style: tt.bodySmall?.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
