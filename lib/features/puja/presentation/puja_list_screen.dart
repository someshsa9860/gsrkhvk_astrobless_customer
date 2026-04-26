import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/banner_carousel.dart';
import '../../home/data/home_repository.dart';

class PujaListScreen extends ConsumerWidget {
  const PujaListScreen({super.key});

  static const _pujas = [
    (emoji: '🪔', title: 'Satyanarayan Puja', subtitle: 'Prosperity & blessings', price: '₹1,100', tag: 'Popular'),
    (emoji: '🌺', title: 'Ganesh Puja', subtitle: 'Remove obstacles', price: '₹801', tag: 'New'),
    (emoji: '🔱', title: 'Rudrabhishek', subtitle: 'Shiva devotion & peace', price: '₹2,100', tag: null),
    (emoji: '🌟', title: 'Lakshmi Puja', subtitle: 'Wealth & prosperity', price: '₹1,501', tag: 'Popular'),
    (emoji: '☀️', title: 'Surya Puja', subtitle: 'Health & career boost', price: '₹501', tag: null),
    (emoji: '🌙', title: 'Chandra Puja', subtitle: 'Mental clarity & calm', price: '₹501', tag: null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Puja Bookings'),
      ),
      body: Column(
        children: [
          BannerCarousel(bannersProvider: pujaListBannersProvider),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary.withValues(alpha: 0.9), c.accent.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🙏', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Book a Sacred Puja',
                          style: tt.titleMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Performed by verified pandits & astrologers',
                          style: tt.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _pujas.length,
              itemBuilder: (_, i) {
                final p = _pujas[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text(p.emoji,
                                style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(p.title,
                                      style: tt.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: c.textPrimary)),
                                ),
                                if (p.tag != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: c.accent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(p.tag!,
                                        style: tt.labelSmall?.copyWith(
                                            color: c.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(p.subtitle,
                                style: tt.labelSmall
                                    ?.copyWith(color: c.textSecondary)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(p.price,
                                    style: tt.titleSmall?.copyWith(
                                        color: c.primary,
                                        fontWeight: FontWeight.w700)),
                                const Spacer(),
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('${p.title} booking — coming soon!'),
                                        backgroundColor: c.card,
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: c.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Book',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
