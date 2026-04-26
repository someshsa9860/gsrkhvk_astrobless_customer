import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';

class KundliListScreen extends ConsumerWidget {
  const KundliListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(kundliProfilesProvider);
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('My Kundli Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            tooltip: 'Kundli Matching',
            onPressed: () => context.push(AppRoutes.kundliMatch),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.kundliAdd).then(
                  (_) => ref.invalidate(kundliProfilesProvider),
                ),
          ),
        ],
      ),
      body: profilesAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: c.accent)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load profiles', style: tt.bodyMedium),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(kundliProfilesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text('No Kundli Profiles Yet', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Add your birth details to generate\na personalized birth chart',
                    style: tt.bodySmall?.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.kundliAdd).then(
                          (_) => ref.invalidate(kundliProfilesProvider),
                        ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Kundli'),
                  ),
                ],
              ).animate().fadeIn(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _KundliCard(
              profile: profiles[i],
              onDeleted: () => ref.invalidate(kundliProfilesProvider),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.kundliAdd).then(
              (_) => ref.invalidate(kundliProfilesProvider),
            ),
        backgroundColor: c.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _KundliCard extends ConsumerWidget {
  const _KundliCard({required this.profile, required this.onDeleted});
  final KundliProfile profile;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return InkWell(
      onTap: () => context.push(AppRoutes.kundliReport(profile.id)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🔮', style: TextStyle(fontSize: 22))),
          ),
          title: Text(profile.name, style: tt.titleSmall),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                profile.dateOfBirth +
                    (profile.timeOfBirth != null
                        ? ' • ${profile.timeOfBirth}'
                        : ''),
                style: tt.labelSmall?.copyWith(color: c.textSecondary),
              ),
              Text(
                profile.placeOfBirth,
                style: tt.labelSmall?.copyWith(color: c.textSecondary.withValues(alpha: 0.6)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: c.primary, size: 20),
                onPressed: () => context.push(
                  AppRoutes.kundliEdit(profile.id),
                  extra: profile,
                ).then((_) => ref.invalidate(kundliProfilesProvider)),
                tooltip: 'Edit Profile',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: c.error, size: 20),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: c.card,
                      title: const Text('Delete Profile'),
                      content: Text(
                          'Remove "${profile.name}" from your kundli profiles?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete',
                                style: TextStyle(color: c.error))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(kundliRepositoryProvider)
                        .deleteProfile(profile.id);
                    onDeleted();
                  }
                },
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
