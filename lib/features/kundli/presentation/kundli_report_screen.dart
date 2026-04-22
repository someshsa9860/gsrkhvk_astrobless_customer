import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';

class KundliReportScreen extends ConsumerWidget {
  const KundliReportScreen({super.key, required this.profileId});
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(kundliReportProvider(profileId));
    final profilesAsync = ref.watch(kundliProfilesProvider);
    final tt = Theme.of(context).textTheme;

    final profileName = profilesAsync.valueOrNull
            ?.firstWhere((p) => p.id == profileId,
                orElse: () => KundliProfile(
                      id: profileId,
                      name: 'Kundli',
                      dateOfBirth: '',
                      placeOfBirth: '',
                      lat: 0,
                      lng: 0,
                      createdAt: DateTime.now(),
                    ))
            .name ??
        'Kundli Report';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: Text(profileName)),
      body: reportAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔮', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 12),
              Text('Generating your birth chart...',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load report', style: tt.bodyMedium),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(kundliReportProvider(profileId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (report) => _ReportBody(report: report),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});
  final KundliReport report;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final data = report.chartData;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Birth Chart Overview',
          icon: '🪐',
          child: Column(
            children: [
              _InfoRow('Computed At', formatDateTime(report.computedAt), tt),
              if (data['ascendant'] != null)
                _InfoRow('Ascendant', data['ascendant'].toString(), tt),
              if (data['moonSign'] != null)
                _InfoRow('Moon Sign', data['moonSign'].toString(), tt),
              if (data['sunSign'] != null)
                _InfoRow('Sun Sign', data['sunSign'].toString(), tt),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (data['planets'] != null) ...[
          _SectionCard(
            title: 'Planetary Positions',
            icon: '⭐',
            child: _PlanetsTable(planets: data['planets'] as Map<String, dynamic>),
          ),
          const SizedBox(height: 12),
        ],
        if (data['dasha'] != null) ...[
          _SectionCard(
            title: 'Current Dasha',
            icon: '📅',
            child: _DashaInfo(dasha: data['dasha'] as Map<String, dynamic>),
          ),
          const SizedBox(height: 12),
        ],
        _SectionCard(
          title: 'Raw Chart Data',
          icon: '📊',
          child: Text(
            data.toString(),
            style: tt.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final String icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, this.tt);
  final String label;
  final String value;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlanetsTable extends StatelessWidget {
  const _PlanetsTable({required this.planets});
  final Map<String, dynamic> planets;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (planets.isEmpty) {
      return Text('No planetary data',
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary));
    }
    return Column(
      children: planets.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              Text(e.value.toString(),
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DashaInfo extends StatelessWidget {
  const _DashaInfo({required this.dasha});
  final Map<String, dynamic> dasha;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: dasha.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              Text(e.value.toString(),
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
