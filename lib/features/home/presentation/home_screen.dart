import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/home_repository.dart';
import '../domain/home_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: _HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.cardDark,
        onRefresh: () async {
          ref.invalidate(bannersProvider);
          ref.invalidate(trendingAstrologersProvider);
          ref.invalidate(storiesProvider);
          ref.invalidate(learningVideosProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _BannerSection(),
            const SizedBox(height: 20),
            const _FeatureGrid(),
            const SizedBox(height: 20),
            const _HoroscopeTeaserCard(),
            const SizedBox(height: 20),
            const _TrendingAstrologers(),
            const SizedBox(height: 20),
            const _StoriesRow(),
            const SizedBox(height: 20),
            const _LearningVideos(),
            const SizedBox(height: 20),
            const _AiChatCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgDark,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 22),
          const SizedBox(width: 8),
          Text(
            'Astrobless',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceDark,
              child: const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Banner Carousel ───────────────────────────────────────────────────────

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
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      loading: () => Shimmer.fromColors(
        baseColor: AppColors.surfaceDark,
        highlightColor: AppColors.cardDark,
        child: Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
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
                effect: const WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: AppColors.accent,
                  dotColor: AppColors.borderDark,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: banner.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorWidget: (_, __, ___) => _FallbackBannerContent(),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3949AB), Color(0xFF7B1FA2)],
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨ Your Stars Are Aligned',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Get your free Kundli reading today',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Get Started',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────

const _features = [
  (icon: '♈', label: 'Horoscope', route: '/horoscope', color: Color(0xFF5C6BC0)),
  (icon: '🔮', label: 'Kundli', route: '/kundli', color: Color(0xFF7B1FA2)),
  (icon: '💑', label: 'Matching', route: '/kundli', color: Color(0xFFE91E63)),
  (icon: '🌟', label: 'Talk Now', route: '/astrologers', color: Color(0xFFFF9800)),
  (icon: '📅', label: 'Panchang', route: '/horoscope', color: Color(0xFF009688)),
  (icon: '🃏', label: 'Tarot', route: '/horoscope', color: Color(0xFF673AB7)),
  (icon: '🔢', label: 'Numerology', route: '/horoscope', color: Color(0xFF2196F3)),
  (icon: '🏠', label: 'Vastu', route: '/horoscope', color: Color(0xFF4CAF50)),
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
  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
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
    final asyncData = ref.watch(trendingAstrologersProvider);
    final tt = Theme.of(context).textTheme;

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
                child: Text('See all',
                    style: tt.labelMedium?.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: asyncData.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surfaceDark,
                highlightColor: AppColors.cardDark,
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (astrologers) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: astrologers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _AstrologerCard(
                astrologer: astrologers[i],
              ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AstrologerCard extends StatelessWidget {
  const _AstrologerCard({required this.astrologer});
  final TrendingAstrologer astrologer;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
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
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardDark, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              astrologer.displayName,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            if (astrologer.specialties.isNotEmpty)
              Text(
                astrologer.specialties.take(2).join(' · '),
                style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 13, color: AppColors.accent),
                const SizedBox(width: 3),
                Text(
                  astrologer.ratingAvg.toStringAsFixed(1),
                  style: tt.labelSmall?.copyWith(color: AppColors.accent),
                ),
                const Spacer(),
                Text(
                  '${formatCurrency(astrologer.pricePerMinChat.toDouble())}/min',
                  style: tt.labelSmall?.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Chat', style: TextStyle(fontSize: 12)),
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
    return Container(
      height: 80,
      color: AppColors.surfaceDark,
      child: const Center(
        child: Icon(Icons.person_outline, color: AppColors.textDisabled, size: 32),
      ),
    );
  }
}

// ─── Stories Row ──────────────────────────────────────────────────────────

class _StoriesRow extends ConsumerWidget {
  const _StoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(storiesProvider);
    final tt = Theme.of(context).textTheme;

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
          child: asyncData.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surfaceDark,
                highlightColor: AppColors.cardDark,
                child: Column(children: [
                  CircleAvatar(radius: 30, backgroundColor: AppColors.surfaceDark),
                  const SizedBox(height: 4),
                  Container(width: 50, height: 10, color: AppColors.surfaceDark),
                ]),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (stories) {
              if (stories.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: stories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _StoryBubble(story: stories[i])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 50 * i)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.primary],
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
                      color: AppColors.surfaceDark,
                      child: const Icon(Icons.auto_stories, color: AppColors.accent, size: 20),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceDark,
                    child: const Icon(Icons.auto_stories, color: AppColors.accent, size: 20),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            story.title,
            style: tt.labelSmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Learning Videos ─────────────────────────────────────────────────────

class _LearningVideos extends ConsumerWidget {
  const _LearningVideos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(learningVideosProvider);
    final tt = Theme.of(context).textTheme;

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
                child: Text('See all',
                    style: tt.labelMedium?.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: asyncData.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surfaceDark,
                highlightColor: AppColors.cardDark,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (videos) {
              if (videos.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _VideoCard(video: videos[i])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 60 * i)),
              );
            },
          ),
        ),
      ],
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
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
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
                          color: AppColors.surfaceDark,
                          child: const Icon(Icons.play_circle_outline,
                              color: AppColors.textDisabled, size: 40),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.play_circle_outline,
                            color: AppColors.textDisabled, size: 40),
                      ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 20),
                  ),
                ),
                if (video.durationSeconds > 0)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _fmtDuration(video.durationSeconds),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              video.title,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1040), Color(0xFF2D1B69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF5C4BA0).withValues(alpha: 0.6)),
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
                            style: tt.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text('Pick your sign to read today\'s cosmic forecast',
                            style: tt.labelSmall
                                ?.copyWith(color: Colors.white60)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.horoscope),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('View All',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            // Sign grid — 2 rows of 6
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
                  final (sym, slug) = _zodiacSigns[i];
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.horoscope),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Center(
                        child: Text(sym,
                            style: const TextStyle(fontSize: 20)),
                      ),
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
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.aiChat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3949AB), Color(0xFF7B1FA2)],
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
                      Text(
                        'AI Astrologer',
                        style: tt.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('AI',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get instant answers about your horoscope, kundli & life questions',
                    style: tt.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Chat Now →',
                      style: TextStyle(
                        color: Color(0xFF3949AB),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
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
