import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/astrologer_models.dart';

class AstrologerSearchState {
  const AstrologerSearchState({
    this.items = const [],
    this.query = '',
    this.page = 1,
    this.total = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
  });

  final List<Astrologer> items;
  final String query;
  final int page;
  final int total;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  AstrologerSearchState copyWith({
    List<Astrologer>? items,
    String? query,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
  }) =>
      AstrologerSearchState(
        items: items ?? this.items,
        query: query ?? this.query,
        page: page ?? this.page,
        total: total ?? this.total,
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
    if (!mounted || state.isLoading) return;

    state = state.copyWith(
      query: query,
      page: 1,
      items: [],
      total: 0,
      hasMore: false,
      isLoading: true,
    );

    try {
      final data = await _client.fetchAstrologers(
        search: query.trim().isEmpty ? null : query.trim(),
        page: 1,
        limit: _pageSize,
      );
      if (!mounted) return;
      final list = _parseList(data);
      final total = (data['total'] as num?)?.toInt() ?? list.length;
      state = state.copyWith(
        items: list,
        page: 2,
        total: total,
        hasMore: list.length < total,
        isLoading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (!mounted || !state.hasMore || state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final data = await _client.fetchAstrologers(
        search: state.query.trim().isEmpty ? null : state.query.trim(),
        page: state.page,
        limit: _pageSize,
      );
      if (!mounted) return;
      final newItems = _parseList(data);
      final allItems = [...state.items, ...newItems];
      final total = (data['total'] as num?)?.toInt() ?? state.total;
      state = state.copyWith(
        items: allItems,
        page: state.page + 1,
        total: total,
        hasMore: allItems.length < total,
        isLoadingMore: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  List<Astrologer> _parseList(Map<String, dynamic> data) {
    final list = data['items'] as List<dynamic>? ??
        data['astrologers'] as List<dynamic>? ??
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
