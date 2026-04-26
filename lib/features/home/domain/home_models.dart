class HomeBanner {
  final String id;
  final String? imageUrl;
  final String ctaType;
  final String ctaTarget;

  const HomeBanner({
    required this.id,
    this.imageUrl,
    required this.ctaType,
    required this.ctaTarget,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> j) => HomeBanner(
        id: j['id'] as String,
        imageUrl: j['imageUrl'] as String?,
        ctaType: j['ctaType'] as String? ?? 'none',
        ctaTarget: j['ctaTarget'] as String? ?? '',
      );
}

class TrendingAstrologer {
  final String id;
  final String displayName;
  final String? profileImageUrl;
  final List<String> specialties;
  final double ratingAvg;
  final int ratingCount;
  final double pricePerMinChat;
  final bool isOnline;

  const TrendingAstrologer({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
    required this.specialties,
    required this.ratingAvg,
    required this.ratingCount,
    required this.pricePerMinChat,
    required this.isOnline,
  });

  factory TrendingAstrologer.fromJson(Map<String, dynamic> j) =>
      TrendingAstrologer(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        profileImageUrl: j['profileImageUrl'] as String?,
        specialties: (j['specialties'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        ratingAvg: double.tryParse(j['ratingAvg']?.toString() ?? '0') ?? 0,
        ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
        pricePerMinChat: (j['pricePerMinChat'] as num?)?.toDouble() ?? 0,
        isOnline: (j['isOnline'] as bool?) ?? false,
      );
}

class Story {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String mediaUrl;
  final String type;

  const Story({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.mediaUrl,
    required this.type,
  });

  factory Story.fromJson(Map<String, dynamic> j) => Story(
        id: j['id'] as String,
        title: j['title'] as String,
        thumbnailUrl: j['thumbnailUrl'] as String? ?? '',
        mediaUrl: j['mediaUrl'] as String? ?? '',
        type: j['type'] as String? ?? 'image',
      );
}

class LearningVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final int durationSeconds;
  final String category;

  const LearningVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.durationSeconds,
    required this.category,
  });

  factory LearningVideo.fromJson(Map<String, dynamic> j) => LearningVideo(
        id: j['id'] as String,
        title: j['title'] as String,
        thumbnailUrl: j['thumbnailUrl'] as String? ?? '',
        videoUrl: j['videoUrl'] as String? ?? '',
        durationSeconds: (j['durationSeconds'] as int?) ?? 0,
        category: j['category'] as String? ?? 'astrology',
      );
}

class HomeData {
  final List<HomeBanner> banners;
  final List<TrendingAstrologer> trendingAstrologers;
  final List<Story> stories;
  final List<LearningVideo> learningVideos;

  const HomeData({
    required this.banners,
    required this.trendingAstrologers,
    required this.stories,
    required this.learningVideos,
  });
}
