import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/astrologer_models.dart';

class AstrologerSearchState {
  const AstrologerSearchState({
    this.items = const [],
    this.query = '',
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
  });

  final List<Astrologer> items;
  final String query;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  AstrologerSearchState copyWith({
    List<Astrologer>? items,
    String? query,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
  }) =>
      AstrologerSearchState(
        items: items ?? this.items,
        query: query ?? this.query,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class AstrologerSearchNotifier extends StateNotifier<AstrologerSearchState> {
  AstrologerSearchNotifier(this._client) : super(const AstrologerSearchState());

  final ApiClient _client;

  static const _pageSize = 15;

  Future<void> search(String query) async {
    if (state.isLoading) return;

    state = state.copyWith(
      query: query,
      page: 1,
      items: [],
      hasMore: true,
      isLoading: true,
    );

    try {
      final data = await _client.fetchAstrologers(
        search: query.trim().isEmpty ? null : query.trim(),
        page: 1,
        limit: _pageSize,
      );
      final list = _parseList(data);
      state = state.copyWith(
        items: list,
        page: 2,
        hasMore: list.length >= _pageSize,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final data = await _client.fetchAstrologers(
        search: state.query.trim().isEmpty ? null : state.query.trim(),
        page: state.page,
        limit: _pageSize,
      );
      final newItems = _parseList(data);
      state = state.copyWith(
        items: [...state.items, ...newItems],
        page: state.page + 1,
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  List<Astrologer> _parseList(Map<String, dynamic> data) {
    final list = data['astrologers'] as List<dynamic>? ??
        data['items'] as List<dynamic>? ??
        <dynamic>[];
    return list
        .map((e) => Astrologer.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Used by the Chat tab screen.
final astrologerSearchProvider = StateNotifierProvider.autoDispose<
    AstrologerSearchNotifier, AstrologerSearchState>((ref) {
  return AstrologerSearchNotifier(ref.read(apiClientProvider));
});

/// Used by the Call tab screen — independent state so the two tabs don't share results.
final callAstrologerSearchProvider = StateNotifierProvider.autoDispose<
    AstrologerSearchNotifier, AstrologerSearchState>((ref) {
  return AstrologerSearchNotifier(ref.read(apiClientProvider));
});
