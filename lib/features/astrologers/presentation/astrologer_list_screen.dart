import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/banner_carousel.dart';
import '../../home/data/home_repository.dart';
import '../data/astrologers_repository.dart';
import '../domain/astrologer_models.dart';

final _searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final _onlineFilterProvider = StateProvider.autoDispose<bool?>((ref) => null);
final _specialtyFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

final _filteredAstrologersProvider =
    FutureProvider.autoDispose<List<Astrologer>>((ref) {
  final query = ref.watch(_searchQueryProvider);
  final isOnline = ref.watch(_onlineFilterProvider);
  final specialty = ref.watch(_specialtyFilterProvider);
  return ref.watch(astrologersRepositoryProvider).fetchAstrologers(
        search: query.isEmpty ? null : query,
        isOnline: isOnline,
        specialty: specialty,
      );
});

class AstrologerListScreen extends ConsumerStatefulWidget {
  const AstrologerListScreen({super.key});

  @override
  ConsumerState<AstrologerListScreen> createState() =>
      _AstrologerListScreenState();
}

class _AstrologerListScreenState extends ConsumerState<AstrologerListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final astrologersAsync = ref.watch(_filteredAstrologersProvider);
    final isOnline = ref.watch(_onlineFilterProvider);
    final specialty = ref.watch(_specialtyFilterProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Astrologers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: tt.bodyMedium?.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, specialty...',
                hintStyle: tt.bodyMedium?.copyWith(
                    color: c.textSecondary.withValues(alpha: 0.5)),
                prefixIcon:
                    Icon(Icons.search, color: c.textSecondary, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: c.textSecondary, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(_searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: c.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.primary),
                ),
              ),
              onChanged: (v) =>
                  ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          BannerCarousel(bannersProvider: astrologerListBannersProvider),
          _FilterChips(isOnline: isOnline, specialty: specialty),
          Expanded(
            child: astrologersAsync.when(
              loading: () => const _AstrologerListSkeleton(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: c.error, size: 40),
                    const SizedBox(height: 12),
                    Text('Failed to load astrologers',
                        style: tt.bodyMedium),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(_filteredAstrologersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (astrologers) {
                if (astrologers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No astrologers found',
                            style: tt.titleMedium),
                        const SizedBox(height: 8),
                        Text('Try changing your filters',
                            style: tt.bodySmall
                                ?.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: astrologers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (ctx, i) =>
                      _AstrologerCard(astrologer: astrologers[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.isOnline, required this.specialty});
  final bool? isOnline;
  final String? specialty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _Chip(
            label: 'Online',
            selected: isOnline == true,
            onTap: () => ref.read(_onlineFilterProvider.notifier).state =
                isOnline == true ? null : true,
          ),
          const SizedBox(width: 8),
          for (final s in [
            'Vedic',
            'Tarot',
            'Numerology',
            'Vastu',
            'KP',
            'Palmistry'
          ]) ...[
            _Chip(
              label: s,
              selected: specialty == s,
              onTap: () =>
                  ref.read(_specialtyFilterProvider.notifier).state =
                      specialty == s ? null : s,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? c.accent : c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c.accent : c.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? c.bg : c.textSecondary,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _AstrologerCard extends StatelessWidget {
  const _AstrologerCard({required this.astrologer});
  final Astrologer astrologer;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: c.surface,
                  backgroundImage: astrologer.profileImageUrl != null
                      ? CachedNetworkImageProvider(
                          astrologer.profileImageUrl!)
                      : null,
                  child: astrologer.profileImageUrl == null
                      ? Icon(Icons.person, size: 28, color: c.textSecondary)
                      : null,
                ),
                if (astrologer.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: c.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(astrologer.displayName,
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ),
                      _RatingBadge(rating: astrologer.ratingAvg),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    astrologer.specialties.take(3).join(' • '),
                    style: tt.labelSmall
                        ?.copyWith(color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.translate,
                          size: 12,
                          color: c.textSecondary.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        astrologer.languages.take(2).join(', '),
                        style: tt.labelSmall?.copyWith(
                            color: c.textSecondary
                                .withValues(alpha: 0.6)),
                      ),
                      const Spacer(),
                      Text(
                        '${astrologer.experienceYears}yr exp',
                        style: tt.labelSmall?.copyWith(
                            color: c.textSecondary
                                .withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chat',
                              style: tt.labelSmall?.copyWith(
                                  color: c.textSecondary
                                      .withValues(alpha: 0.6),
                                  fontSize: 10)),
                          Text(
                            '₹${astrologer.pricePerMinChat.toStringAsFixed(0)}/min',
                            style: tt.labelMedium?.copyWith(
                                color: c.accent,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Call',
                              style: tt.labelSmall?.copyWith(
                                  color: c.textSecondary
                                      .withValues(alpha: 0.6),
                                  fontSize: 10)),
                          Text(
                            '₹${astrologer.pricePerMinCall.toStringAsFixed(0)}/min',
                            style: tt.labelMedium?.copyWith(
                                color: c.accent,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (astrologer.isBusy)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Busy',
                              style: tt.labelSmall
                                  ?.copyWith(color: c.error)),
                        )
                      else if (!astrologer.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Offline',
                              style: tt.labelSmall?.copyWith(
                                  color: c.textSecondary)),
                        )
                      else
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(
                                AppRoutes.astrologerDetail(astrologer.id)),
                            icon: const Icon(Icons.chat_bubble_outline,
                                size: 14),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
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
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: c.accent),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: c.accent, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AstrologerListSkeleton extends StatelessWidget {
  const _AstrologerListSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
