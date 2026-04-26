import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';

// ── Select-profiles screen (entry point) ─────────────────────────────────────

class KundliMatchScreen extends ConsumerStatefulWidget {
  const KundliMatchScreen({super.key});

  @override
  ConsumerState<KundliMatchScreen> createState() => _KundliMatchScreenState();
}

class _KundliMatchScreenState extends ConsumerState<KundliMatchScreen> {
  KundliProfile? _profileA;
  KundliProfile? _profileB;
  bool _loading = false;

  Future<void> _compute() async {
    if (_profileA == null || _profileB == null) return;
    if (_profileA!.id == _profileB!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select two different profiles.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final match = await ref.read(kundliRepositoryProvider).matchKundli(
            profileAId: _profileA!.id,
            profileBId: _profileB!.id,
          );
      ref.invalidate(kundliMatchesProvider);
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => KundliMatchResultScreen(match: match),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Match failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(kundliProfilesProvider);
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('Kundli Matching')),
      body: profilesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: c.accent)),
        error: (e, _) => Center(child: Text('Failed to load profiles')),
        data: (profiles) {
          if (profiles.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('💑', style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text('Need at least 2 profiles',
                        style: tt.titleMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least two Kundli profiles to check compatibility.',
                      style: tt.bodySmall?.copyWith(color: c.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select two profiles to check Ashtakoot compatibility.',
                    style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 24),
                _ProfilePicker(
                  label: 'Boy / Person A',
                  emoji: '👦',
                  selected: _profileA,
                  profiles: profiles,
                  onSelected: (p) => setState(() => _profileA = p),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('↕️', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ProfilePicker(
                  label: 'Girl / Person B',
                  emoji: '👧',
                  selected: _profileB,
                  profiles: profiles,
                  onSelected: (p) => setState(() => _profileB = p),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: (_profileA != null && _profileB != null && !_loading)
                      ? _compute
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Check Compatibility',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 32),
                _MatchHistorySection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.profiles,
    required this.onSelected,
  });

  final String label;
  final String emoji;
  final KundliProfile? selected;
  final List<KundliProfile> profiles;
  final ValueChanged<KundliProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected != null ? c.primary : c.border,
          width: selected != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '$emoji  $label',
              style: tt.labelSmall?.copyWith(color: c.textSecondary),
            ),
          ),
          if (selected != null)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('🔮', style: TextStyle(fontSize: 18))),
              ),
              title: Text(selected!.name, style: tt.titleSmall),
              subtitle: Text(
                selected!.dateOfBirth +
                    (selected!.timeOfBirth != null
                        ? ' • ${selected!.timeOfBirth}'
                        : ''),
                style: tt.labelSmall?.copyWith(color: c.textSecondary),
              ),
              trailing: Icon(Icons.swap_horiz_rounded, color: c.primary),
              onTap: () => _showPicker(context),
            )
          else
            ListTile(
              leading: Icon(Icons.person_add_outlined, color: c.primary),
              title: Text('Select profile', style: tt.bodyMedium),
              trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
              onTap: () => _showPicker(context),
            ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<KundliProfile>(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProfilePickerSheet(
        profiles: profiles,
        onSelected: (p) {
          Navigator.pop(context);
          onSelected(p);
        },
      ),
    );
  }
}

class _ProfilePickerSheet extends StatelessWidget {
  const _ProfilePickerSheet(
      {required this.profiles, required this.onSelected});
  final List<KundliProfile> profiles;
  final ValueChanged<KundliProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: c.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Select a profile', style: tt.titleSmall),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: profiles.length,
          itemBuilder: (_, i) {
            final p = profiles[i];
            return ListTile(
              leading: const Text('🔮', style: TextStyle(fontSize: 22)),
              title: Text(p.name),
              subtitle: Text(
                p.dateOfBirth +
                    (p.timeOfBirth != null ? ' • ${p.timeOfBirth}' : ''),
                style: tt.labelSmall?.copyWith(color: c.textSecondary),
              ),
              onTap: () => onSelected(p),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MatchHistorySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(kundliMatchesProvider);
    final tt = Theme.of(context).textTheme;

    return matchesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (matches) {
        if (matches.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previous Matches', style: tt.titleSmall),
            const SizedBox(height: 12),
            ...matches.take(5).map((m) => _MatchHistoryCard(match: m)),
          ],
        );
      },
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({required this.match});
  final KundliMatch match;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final color = _scoreColor(match.scoreLabel, c);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => KundliMatchResultScreen(match: match)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.profileAName} ↔ ${match.profileBName}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${match.scorePoints}/36 · ${match.scoreLabel}',
                    style:
                        tt.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${match.scorePoints}',
                  style: tt.titleSmall?.copyWith(
                      color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(String label, AppThemeColors c) {
    switch (label) {
      case 'Excellent':
        return c.success;
      case 'Good':
        return c.accent;
      case 'Average':
        return const Color(0xFFFF9800);
      default:
        return c.error;
    }
  }
}

// ── Result screen ─────────────────────────────────────────────────────────────

class KundliMatchResultScreen extends StatelessWidget {
  const KundliMatchResultScreen({super.key, required this.match});
  final KundliMatch match;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final scoreColor = _scoreColor(match.scoreLabel, c);
    final pct = match.scorePoints / 36;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Compatibility Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withValues(alpha: 0.2),
                    scoreColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '${match.profileAName} ↔ ${match.profileBName}',
                    style: tt.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 10,
                          backgroundColor: c.border,
                          valueColor: AlwaysStoppedAnimation(scoreColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${match.scorePoints}',
                            style: tt.displaySmall?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('/ 36',
                              style: tt.bodySmall
                                  ?.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ],
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      match.scoreLabel,
                      style: tt.labelLarge?.copyWith(
                          color: scoreColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (match.conclusion.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      match.conclusion,
                      style: tt.bodySmall?.copyWith(color: c.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Manglik status
            if (match.manglikBoy || match.manglikGirl)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: const Color(0xFFFF9800), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        [
                          if (match.manglikBoy) '${match.profileAName} is Manglik',
                          if (match.manglikGirl)
                            '${match.profileBName} is Manglik',
                        ].join(' · '),
                        style: tt.bodySmall
                            ?.copyWith(color: const Color(0xFFFF9800)),
                      ),
                    ),
                  ],
                ),
              ),

            // Breakdown
            Text('Ashtakoot Breakdown', style: tt.titleSmall),
            const SizedBox(height: 12),
            ..._kootaRows(match.breakdown, tt, c)
                .asMap()
                .entries
                .map((e) => e.value
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 60 * e.key))),
          ],
        ),
      ),
    );
  }

  List<Widget> _kootaRows(
      KundliMatchBreakdown b, TextTheme tt, AppThemeColors c) {
    final rows = [
      ('Varna', b.varna),
      ('Vashya', b.vashya),
      ('Tara', b.tara),
      ('Yoni', b.yoni),
      ('Graha Maitri', b.graha),
      ('Gana', b.gana),
      ('Bhakoot', b.bhakoot),
      ('Nadi', b.nadi),
    ];
    return rows.map((r) => _KootaRow(name: r.$1, score: r.$2)).toList();
  }

  Color _scoreColor(String label, AppThemeColors c) {
    switch (label) {
      case 'Excellent':
        return c.success;
      case 'Good':
        return c.accent;
      case 'Average':
        return const Color(0xFFFF9800);
      default:
        return c.error;
    }
  }
}

class _KootaRow extends StatelessWidget {
  const _KootaRow({required this.name, required this.score});
  final String name;
  final KootaScore score;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final pct = score.maxPoints > 0 ? score.points / score.maxPoints : 0.0;
    final barColor = pct >= 0.75
        ? c.success
        : pct >= 0.5
            ? c.accent
            : pct >= 0.25
                ? const Color(0xFFFF9800)
                : c.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              Text(
                '${score.points.toStringAsFixed(score.points % 1 == 0 ? 0 : 1)} / ${score.maxPoints}',
                style: tt.labelSmall?.copyWith(
                    color: barColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              minHeight: 6,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (score.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              score.description,
              style: tt.labelSmall?.copyWith(color: c.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
