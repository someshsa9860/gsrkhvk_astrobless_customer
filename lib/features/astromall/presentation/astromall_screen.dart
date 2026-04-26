import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_colors.dart';

class AstromallScreen extends StatelessWidget {
  const AstromallScreen({super.key});

  static const _categories = [
    (emoji: '💎', label: 'Gemstones'),
    (emoji: '📿', label: 'Rudraksha'),
    (emoji: '🪬', label: 'Yantras'),
    (emoji: '🕯️', label: 'Puja Kits'),
    (emoji: '📖', label: 'Books'),
    (emoji: '🧿', label: 'Bracelets'),
  ];

  static const _products = [
    (
      emoji: '💎',
      title: 'Blue Sapphire (Neelam)',
      subtitle: 'Saturn gemstone · Certified',
      price: '₹4,999',
      rating: '4.8',
    ),
    (
      emoji: '🔴',
      title: 'Ruby (Manik)',
      subtitle: 'Sun gemstone · Natural',
      price: '₹3,499',
      rating: '4.7',
    ),
    (
      emoji: '📿',
      title: '5 Mukhi Rudraksha',
      subtitle: 'Panchmukhi · Lab certified',
      price: '₹899',
      rating: '4.9',
    ),
    (
      emoji: '🪬',
      title: 'Sri Yantra',
      subtitle: 'Copper · Energised',
      price: '₹1,299',
      rating: '4.6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: Row(
          children: [
            const Text('🛍️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text('AstroMall'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: c.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category chips
          Text('Categories', style: tt.titleSmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border),
                        ),
                        child: Center(
                            child: Text(cat.emoji,
                                style: const TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(height: 4),
                      Text(cat.label,
                          style: tt.labelSmall?.copyWith(
                              color: c.textSecondary, fontSize: 10)),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 40 * i));
              },
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Products', style: tt.titleSmall),
              TextButton(
                onPressed: () {},
                child: Text('See all',
                    style: tt.labelMedium?.copyWith(color: c.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(_products.length, (i) {
            final p = _products[i];
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary)),
                        const SizedBox(height: 2),
                        Text(p.subtitle,
                            style: tt.labelSmall
                                ?.copyWith(color: c.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 13, color: c.accent),
                            const SizedBox(width: 2),
                            Text(p.rating,
                                style: tt.labelSmall
                                    ?.copyWith(color: c.accent)),
                            const Spacer(),
                            Text(p.price,
                                style: tt.titleSmall?.copyWith(
                                    color: c.primary,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${p.title} added to cart!'),
                          backgroundColor: c.success,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Icon(Icons.add_shopping_cart, size: 16),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(begin: 0.1);
          }),
        ],
      ),
    );
  }
}
