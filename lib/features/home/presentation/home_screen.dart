import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../astrologers/data/astrologers_repository.dart';
import '../../astrologers/domain/astrologer_models.dart';
import '../data/home_repository.dart';
import '../domain/home_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: _HomeAppBar(),
      body: RefreshIndicator(
        color: c.accent,
        backgroundColor: c.card,
        onRefresh: () async {
          ref.invalidate(bannersProvider);
          ref.invalidate(trendingAstrologersProvider);
          ref.invalidate(storiesProvider);
          ref.invalidate(learningVideosProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            _BannerSection(),
            SizedBox(height: 20),
            _FeatureGrid(),
            SizedBox(height: 20),
            _HoroscopeTeaserCard(),
            SizedBox(height: 20),
            _TrendingAstrologers(),
            _StoriesRow(),
            _LearningVideos(),
            SizedBox(height: 20),
            _AiChatCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final brightness = Theme.of(context).brightness;

    IconData modeIcon;
    if (themeMode == ThemeMode.system) {
      modeIcon = Icons.brightness_auto_outlined;
    } else if (themeMode == ThemeMode.dark) {
      modeIcon = Icons.dark_mode_outlined;
    } else {
      modeIcon = Icons.light_mode_outlined;
    }

    return AppBar(
      backgroundColor: c.bg,
      titleSpacing: 16,
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: c.accent, size: 22),
          const SizedBox(width: 8),
          Text(
            'Astrobless',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(modeIcon, color: c.textPrimary),
          tooltip: 'Toggle theme',
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggle(brightness);
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: c.textPrimary),
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: c.surface,
              child: Icon(Icons.person_outline, size: 18, color: c.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Banner Carousel ──────────────────────────────────────────────────────

class _BannerSection extends ConsumerStatefulWidget {
  const _BannerSection();

  @override
  ConsumerState<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<_BannerSection> {
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      loading: () => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.card,
        child: Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
        ),
      ),
      error: (_, __) => _FallbackBanner(),
      data: (banners) {
        if (banners.isEmpty) return _FallbackBanner();
        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: banners.length,
                itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 10),
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
              errorWidget: (_, __, ___) => _FallbackBannerContent(),
            )
          : _FallbackBannerContent(),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [c.primary, c.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _FallbackBannerContent(),
    );
  }
}

class _FallbackBannerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨ Your Stars Are Aligned',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Get your free Kundli reading today',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(20)),
            child: const Text('Get Started',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────

const _features = [
  (icon: '♈', label: 'Horoscope', route: AppRoutes.horoscope, color: AppColors.primary),
  (icon: '🔮', label: 'Kundli', route: AppRoutes.kundliList, color: AppColors.featureKundli),
  (icon: '💑', label: 'Matching', route: AppRoutes.kundliMatch, color: AppColors.featureMatching),
  (icon: '🌟', label: 'Talk Now', route: AppRoutes.astrologers, color: AppColors.featureTalkNow),
  (icon: '🪔', label: 'Puja', route: AppRoutes.puja, color: AppColors.featurePuja),
  (icon: '🛍️', label: 'AstroMall', route: AppRoutes.astromall, color: AppColors.featureAstroMall),
  (icon: '🔢', label: 'Numerology', route: AppRoutes.horoscope, color: AppColors.info),
  (icon: '🏠', label: 'Vastu', route: AppRoutes.horoscope, color: AppColors.success),
];

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _features.length,
            itemBuilder: (context, i) {
              final f = _features[i];
              return _FeatureItem(
                icon: f.icon,
                label: f.label,
                color: f.color,
                onTap: () => context.push(f.route),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.3);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.label, required this.color, required this.onTap});
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Trending Astrologers ─────────────────────────────────────────────────

class _TrendingAstrologers extends ConsumerWidget {
  const _TrendingAstrologers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingAstrologersProvider);
    final fallbackAsync = ref.watch(astrologersProvider);
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    // Resolve the list to show: trending if non-empty, else fallback astrologers
    final isLoading = trendingAsync.isLoading ||
        (trendingAsync.value?.isEmpty == true && fallbackAsync.isLoading);

    if (isLoading) {
      return _buildShimmer(context, c, tt);
    }

    final trendingList = trendingAsync.value ?? [];
    List<TrendingAstrologer> items;

    if (trendingList.isNotEmpty) {
      items = trendingList;
    } else {
      // Trending is empty or errored — convert Astrologer list to TrendingAstrologer
      final fallback = fallbackAsync.value ?? [];
      if (fallback.isEmpty) return const SizedBox.shrink();
      items = fallback
          .take(10)
          .map((a) => TrendingAstrologer(
                id: a.id,
                displayName: a.displayName,
                profileImageUrl: a.profileImageUrl,
                specialties: a.specialties,
                ratingAvg: a.ratingAvg,
                ratingCount: a.ratingCount,
                pricePerMinChat: a.pricePerMinChat,
                isOnline: a.isOnline,
              ))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trending Astrologers', style: tt.titleMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.astrologers),
                child: Text('See all', style: tt.labelMedium?.copyWith(color: c.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _AstrologerCard(astrologer: items[i]).animate().fadeIn(delay: Duration(milliseconds: 60 * i)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context, AppThemeColors c, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trending Astrologers', style: tt.titleMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.astrologers),
                child: Text('See all', style: tt.labelMedium?.copyWith(color: c.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: c.surface,
              highlightColor: c.card,
              child: Container(
                width: 150,
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _AstrologerCard extends StatelessWidget {
  const _AstrologerCard({required this.astrologer});
  final TrendingAstrologer astrologer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: astrologer.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: astrologer.profileImageUrl!,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _AvatarPlaceholder(),
                        )
                      : _AvatarPlaceholder(),
                ),
                if (astrologer.isOnline)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: c.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(astrologer.displayName,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            if (astrologer.specialties.isNotEmpty)
              Text(astrologer.specialties.take(2).join(' · '),
                  style: tt.labelSmall?.copyWith(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 13, color: c.accent),
                const SizedBox(width: 3),
                Text(astrologer.ratingAvg.toStringAsFixed(1),
                    style: tt.labelSmall?.copyWith(color: c.accent)),
                const Spacer(),
                Text('₹${astrologer.pricePerMinChat}/min',
                    style: tt.labelSmall?.copyWith(color: c.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Chat', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 80,
      color: c.surface,
      child: Center(child: Icon(Icons.person_outline, color: c.textSecondary, size: 32)),
    );
  }
}

// ─── Stories Row ──────────────────────────────────────────────────────────

class _StoriesRow extends ConsumerWidget {
  const _StoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(storiesProvider);
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return asyncData.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Daily Stories', style: tt.titleMedium),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: c.surface,
                highlightColor: c.card,
                child: Column(children: [
                  CircleAvatar(radius: 30, backgroundColor: c.surface),
                  const SizedBox(height: 4),
                  Container(width: 50, height: 10, color: c.surface),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stories) {
        if (stories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Daily Stories', style: tt.titleMedium),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: stories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) =>
                    _StoryBubble(story: stories[i]).animate().fadeIn(delay: Duration(milliseconds: 50 * i)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [c.accent, c.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: ClipOval(
            child: story.thumbnailUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: story.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: c.surface,
                      child: Icon(Icons.auto_stories, color: c.accent, size: 20),
                    ),
                  )
                : Container(
                    color: c.surface,
                    child: Icon(Icons.auto_stories, color: c.accent, size: 20),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(story.title,
              style: tt.labelSmall?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ─── Learning Videos ──────────────────────────────────────────────────────

class _LearningVideos extends ConsumerWidget {
  const _LearningVideos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(learningVideosProvider);
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return asyncData.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Learn Astrology', style: tt.titleMedium),
                TextButton(
                  onPressed: () {},
                  child: Text('See all', style: tt.labelMedium?.copyWith(color: c.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: c.surface,
                highlightColor: c.card,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (videos) {
        if (videos.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Learn Astrology', style: tt.titleMedium),
                  TextButton(
                    onPressed: () {},
                    child: Text('See all', style: tt.labelMedium?.copyWith(color: c.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _VideoCard(video: videos[i]).animate().fadeIn(delay: Duration(milliseconds: 60 * i)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final LearningVideo video;

  String _fmtDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                video.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: c.surface,
                          child: Icon(Icons.play_circle_outline, color: c.textSecondary, size: 40),
                        ),
                      )
                    : Container(
                        color: c.surface,
                        child: Icon(Icons.play_circle_outline, color: c.textSecondary, size: 40),
                      ),
                const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                if (video.durationSeconds > 0)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                      child: Text(_fmtDuration(video.durationSeconds),
                          style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(video.title,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── Horoscope Teaser Card ────────────────────────────────────────────────

const _zodiacSigns = [
  ('♈', 'aries'), ('♉', 'taurus'), ('♊', 'gemini'), ('♋', 'cancer'),
  ('♌', 'leo'),   ('♍', 'virgo'),  ('♎', 'libra'),  ('♏', 'scorpio'),
  ('♐', 'sagittarius'), ('♑', 'capricorn'), ('♒', 'aquarius'), ('♓', 'pisces'),
];

class _HoroscopeTeaserCard extends StatelessWidget {
  const _HoroscopeTeaserCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final isDark = c.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1040), const Color(0xFF2D1B69)]
                : [c.primary.withValues(alpha: 0.08), c.accent.withValues(alpha: 0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: Row(
                children: [
                  const Text('🔭', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Horoscope',
                            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text("Pick your sign to read today's cosmic forecast",
                            style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.horoscope),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('View All',
                          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _zodiacSigns.length,
                itemBuilder: (_, i) {
                  final (sym, _) = _zodiacSigns[i];
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.horoscope),
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.primary.withValues(alpha: 0.2)),
                      ),
                      child: Center(child: Text(sym, style: const TextStyle(fontSize: 20))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
    );
  }
}

// ─── AI Chat Card ─────────────────────────────────────────────────────────

class _AiChatCard extends StatelessWidget {
  const _AiChatCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.aiChat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.primary, c.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text('AI Astrologer',
                          style: tt.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(10)),
                        child: const Text('AI',
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Get instant answers about your horoscope, kundli & life questions',
                      style: tt.bodySmall?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text('Chat Now →',
                        style: TextStyle(color: c.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text('🔮', style: TextStyle(fontSize: 56)),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),
    );
  }
}
