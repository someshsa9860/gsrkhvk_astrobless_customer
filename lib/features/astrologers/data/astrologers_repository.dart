import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/astrologer_models.dart';

/// Repository for astrologer discovery and profile retrieval.
///
/// All requests require a valid JWT and go through [ApiClient].
/// Path strings live in [Endpoints.astrologers].
class AstrologersRepository {
  AstrologersRepository(this._client);
  final ApiClient _client;

  /// Fetches a paginated list of astrologers with optional search and filters.
  ///
  /// [sort] defaults to `-ratingAvg` (highest-rated first).
  Future<List<Astrologer>> fetchAstrologers({
    String? search,
    String? specialty,
    String? language,
    double? minRating,
    int? maxPricePaise,
    bool? isOnline,
    String sort = '-ratingAvg',
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.fetchAstrologers(
      search: search,
      specialty: specialty,
      language: language,
      isOnline: isOnline,
      minRating: minRating,
      maxPricePaise: maxPricePaise,
      sort: sort,
      page: page,
      limit: limit,
    );
    final list = data['astrologers'] as List<dynamic>? ??
        data as List<dynamic>? ??
        <dynamic>[];
    return list.map((e) => Astrologer.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches the full profile for a single astrologer by [id].
  Future<Astrologer> fetchAstrologer(String id) async {
    final data = await _client.fetchAstrologer(id);
    return Astrologer.fromJson(
      (data['astrologer'] ?? data) as Map<String, dynamic>,
    );
  }
}

final astrologersRepositoryProvider = Provider<AstrologersRepository>(
  (ref) => AstrologersRepository(ref.watch(apiClientProvider)),
);

final astrologersProvider = FutureProvider.autoDispose<List<Astrologer>>((ref) {
  return ref.watch(astrologersRepositoryProvider).fetchAstrologers();
});

final astrologerProvider =
    FutureProvider.autoDispose.family<Astrologer, String>((ref, id) {
  return ref.watch(astrologersRepositoryProvider).fetchAstrologer(id);
});
