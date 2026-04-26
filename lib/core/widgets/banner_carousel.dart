import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme_colors.dart';
import '../../features/home/domain/home_models.dart';

/// A reusable banner carousel widget for any placement.
///
/// Pass a [FutureProvider<List<HomeBanner>>] via [bannersProvider] so each
/// screen can supply its own placement-scoped provider.
class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key, required this.bannersProvider});

  final FutureProvider<List<HomeBanner>> bannersProvider;

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bannersAsync = ref.watch(widget.bannersProvider);

    return bannersAsync.when(
      loading: () => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.card,
        child: Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: banners.length,
                itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 8),
              SmoothPageIndicator(
                controller: _pageCtrl,
                count: banners.length,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: c.accent,
                  dotColor: c.border,
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [c.primary, c.accent]),
      ),
      clipBehavior: Clip.antiAlias,
      child: banner.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: banner.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }
}
