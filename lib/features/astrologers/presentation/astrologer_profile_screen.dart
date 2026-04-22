import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/astrologers_repository.dart';

class AstrologerProfileScreen extends ConsumerWidget {
  const AstrologerProfileScreen({super.key, required this.astrologerId});
  final String astrologerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final astrologerAsync = ref.watch(astrologerProvider(astrologerId));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: astrologerAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text('Failed to load profile', style: tt.bodyMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(astrologerProvider(astrologerId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (a) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.bgDark,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (a.profileImageUrl != null)
                      CachedNetworkImage(
                        imageUrl: a.profileImageUrl!,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.person,
                            size: 80, color: AppColors.textSecondary),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.bgDark.withValues(alpha: 0.9),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.displayName,
                                  style: tt.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(width: 8),
                              if (a.isOnline)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.success
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Online',
                                          style: tt.labelSmall?.copyWith(
                                              color: AppColors.success)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.specialties.join(' • '),
                            style: tt.bodySmall?.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(
                      rating: a.ratingAvg,
                      ratingCount: a.ratingCount,
                      consultations: a.totalConsultations,
                      experience: a.experienceYears,
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 20),
                    if (a.bio != null && a.bio!.isNotEmpty) ...[
                      Text('About', style: tt.titleSmall),
                      const SizedBox(height: 8),
                      Text(a.bio!,
                          style: tt.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                    ],
                    Text('Languages', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: a.languages
                          .map((l) => _Tag(label: l))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Specialties', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: a.specialties
                          .map((s) => _Tag(label: s, isPrimary: true))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    _PriceAndCTA(
                      chatPaise: a.pricePerMinChatPaise,
                      callPaise: a.pricePerMinCallPaise,
                      isOnline: a.isOnline,
                      isBusy: a.isBusy,
                      astrologerId: a.id,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.rating,
    required this.ratingCount,
    required this.consultations,
    required this.experience,
  });
  final double rating;
  final int ratingCount;
  final int consultations;
  final int experience;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            value: rating.toStringAsFixed(1),
            label: 'Rating',
            icon: Icons.star_rounded,
            iconColor: AppColors.accent,
          ),
          _VertDiv(),
          _Stat(
            value: _compact(ratingCount),
            label: 'Reviews',
            icon: Icons.rate_review_outlined,
          ),
          _VertDiv(),
          _Stat(
            value: _compact(consultations),
            label: 'Sessions',
            icon: Icons.chat_bubble_outline,
          ),
          _VertDiv(),
          _Stat(
            value: '${experience}yr',
            label: 'Exp',
            icon: Icons.workspace_premium_outlined,
          ),
        ],
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.value,
      required this.label,
      required this.icon,
      this.iconColor = AppColors.textSecondary});
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        Text(label,
            style:
                tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _VertDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40, width: 1, color: AppColors.borderDark);
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.isPrimary = false});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderDark,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _PriceAndCTA extends StatelessWidget {
  const _PriceAndCTA({
    required this.chatPaise,
    required this.callPaise,
    required this.isOnline,
    required this.isBusy,
    required this.astrologerId,
  });
  final int chatPaise;
  final int callPaise;
  final bool isOnline;
  final bool isBusy;
  final String astrologerId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final unavailable = !isOnline || isBusy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat rate',
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    Text(
                      '₹${(chatPaise / 100).toStringAsFixed(0)}/min',
                      style: tt.titleMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Call rate',
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    Text(
                      '₹${(callPaise / 100).toStringAsFixed(0)}/min',
                      style: tt.titleMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (unavailable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isBusy ? 'Currently Busy' : 'Currently Offline',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textDisabled),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context
                        .push('/consultation/chat/$astrologerId'),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
