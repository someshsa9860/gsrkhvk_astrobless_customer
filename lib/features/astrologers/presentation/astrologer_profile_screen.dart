import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/astrologers_repository.dart';

class AstrologerProfileScreen extends ConsumerWidget {
  const AstrologerProfileScreen({super.key, required this.astrologerId});
  final String astrologerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final astrologerAsync = ref.watch(astrologerProvider(astrologerId));
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: astrologerAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: c.accent)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: c.error, size: 40),
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
              backgroundColor: c.bg,
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
                        color: c.surface,
                        child: Icon(Icons.person, size: 80, color: c.textSecondary),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            c.bg.withValues(alpha: 0.95),
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
                                      fontWeight: FontWeight.w800,
                                      color: c.textPrimary)),
                              const SizedBox(width: 8),
                              if (a.isOnline)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.success.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: c.success.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: c.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Online',
                                          style: tt.labelSmall
                                              ?.copyWith(color: c.success)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.specialties.join(' • '),
                            style: tt.bodySmall?.copyWith(color: c.textSecondary),
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
                          style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
                      const SizedBox(height: 20),
                    ],
                    Text('Languages', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: a.languages.map((l) => _Tag(label: l)).toList(),
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
                      chatPrice: a.pricePerMinChat,
                      callPrice: a.pricePerMinCall,
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            value: rating.toStringAsFixed(1),
            label: 'Rating',
            icon: Icons.star_rounded,
            iconColor: c.accent,
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
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    return Column(
      children: [
        Icon(icon, color: iconColor ?? c.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: tt.labelSmall?.copyWith(color: c.textSecondary)),
      ],
    );
  }
}

class _VertDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: context.colors.border);
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.isPrimary = false});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? c.primary.withValues(alpha: 0.15) : c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? c.primary.withValues(alpha: 0.4) : c.border,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isPrimary ? c.primary : c.textSecondary,
            ),
      ),
    );
  }
}

class _PriceAndCTA extends ConsumerStatefulWidget {
  const _PriceAndCTA({
    required this.chatPrice,
    required this.callPrice,
    required this.isOnline,
    required this.isBusy,
    required this.astrologerId,
  });
  final double chatPrice;
  final double callPrice;
  final bool isOnline;
  final bool isBusy;
  final String astrologerId;

  @override
  ConsumerState<_PriceAndCTA> createState() => _PriceAndCTAState();
}

class _PriceAndCTAState extends ConsumerState<_PriceAndCTA> {
  bool _chatLoading = false;
  bool _callLoading = false;

  Future<void> _startConsultation(String type) async {
    final isChat = type == 'chat';
    if (isChat) {
      setState(() => _chatLoading = true);
    } else {
      setState(() => _callLoading = true);
    }
    try {
      final data = await ref.read(apiClientProvider).requestConsultation(
            astrologerId: widget.astrologerId,
            type: type,
          );
      final consultationId = data['id'] as String;
      if (!mounted) return;
      if (isChat) {
        context.push(AppRoutes.consultationChat(consultationId));
      } else {
        context.push(AppRoutes.consultationCall(consultationId));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not start consultation: $e'),
        backgroundColor: context.colors.error,
      ));
    } finally {
      if (mounted) {
        setState(() {
          _chatLoading = false;
          _callLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final unavailable = !widget.isOnline || widget.isBusy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
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
                        style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                    Text(
                      '₹${widget.chatPrice.toStringAsFixed(2)}/min',
                      style: tt.titleMedium?.copyWith(
                          color: c.accent, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Call rate',
                        style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                    Text(
                      '₹${widget.callPrice.toStringAsFixed(2)}/min',
                      style: tt.titleMedium?.copyWith(
                          color: c.accent, fontWeight: FontWeight.w800),
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
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.isBusy ? 'Currently Busy' : 'Currently Offline',
                  style: tt.bodyMedium?.copyWith(color: c.textSecondary),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _chatLoading || _callLoading
                        ? null
                        : () => _startConsultation('chat'),
                    icon: _chatLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _chatLoading || _callLoading
                        ? null
                        : () => _startConsultation('voice'),
                    icon: _callLoading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: c.accent),
                          )
                        : const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: c.accent,
                      side: BorderSide(color: c.accent),
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
