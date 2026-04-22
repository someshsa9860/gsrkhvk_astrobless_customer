import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/home_models.dart';

/// Repository for the home feed: banners, trending astrologers, stories,
/// and learning videos.
///
/// All requests go through [ApiClient.publicGet] (no auth required).
/// Path strings live in [Endpoints.public].
class HomeRepository {
  HomeRepository(this._client);
  final ApiClient _client;

  /// Fetches active promotional banners for the `home` placement.
  Future<List<HomeBanner>> fetchBanners() async {
    final list = await _client.fetchBanners(placement: 'home');
    return list.map((e) => HomeBanner.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches the top-10 trending astrologers.
  Future<List<TrendingAstrologer>> fetchTrendingAstrologers() async {
    final list = await _client.fetchTrendingAstrologers(limit: 10);
    return list
        .map((e) => TrendingAstrologer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the short-form stories feed.
  Future<List<Story>> fetchStories() async {
    final list = await _client.fetchStories(limit: 10);
    return list.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches the learning videos catalogue.
  Future<List<LearningVideo>> fetchLearningVideos() async {
    final list = await _client.fetchLearningVideos(limit: 8);
    return list.map((e) => LearningVideo.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(apiClientProvider));
});

final bannersProvider = FutureProvider<List<HomeBanner>>((ref) {
  return ref.read(homeRepositoryProvider).fetchBanners();
});

final trendingAstrologersProvider = FutureProvider<List<TrendingAstrologer>>((ref) {
  return ref.read(homeRepositoryProvider).fetchTrendingAstrologers();
});

final storiesProvider = FutureProvider<List<Story>>((ref) {
  return ref.read(homeRepositoryProvider).fetchStories();
});

final learningVideosProvider = FutureProvider<List<LearningVideo>>((ref) {
  return ref.read(homeRepositoryProvider).fetchLearningVideos();
});
