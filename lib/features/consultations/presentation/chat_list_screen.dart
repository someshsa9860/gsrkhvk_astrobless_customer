import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../astrologers/data/astrologer_search_notifier.dart';
import '../../astrologers/data/astrologers_repository.dart';
import '../../astrologers/domain/astrologer_models.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isSearching) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(astrologerSearchProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _isSearching = value.isNotEmpty);
    ref.read(astrologerSearchProvider.notifier).search(value);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _isSearching = false);
    ref.read(astrologerSearchProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search astrologers…',
                hintStyle: TextStyle(color: c.textSecondary.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: c.textSecondary, size: 20),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.textSecondary),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: c.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.primary),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isSearching
          ? _AstrologerSearchResults(
              scrollCtrl: _scrollCtrl,
              mode: 'chat',
            )
          : _ApprovedAstrologerList(scrollCtrl: _scrollCtrl, mode: 'chat'),
    );
  }
}

// ─── Default view: approved astrologer list ──────────────────────────────

class _ApprovedAstrologerList extends ConsumerWidget {
  const _ApprovedAstrologerList({
    required this.scrollCtrl,
    required this.mode,
  });

  final ScrollController scrollCtrl;
  final String mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final async = ref.watch(astrologersProvider);

    return async.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: c.primary),
      ),
      error: (err, stack) {
        debugPrint('[ChatList] astrologersProvider error: $err');
        debugPrint('[ChatList] stack: $stack');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: c.textSecondary.withValues(alpha: 0.5), size: 40),
              const SizedBox(height: 12),
              Text('Could not load astrologers',
                  style: tt.titleSmall?.copyWith(color: c.textSecondary)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(err.toString(),
                    style: tt.bodySmall?.copyWith(color: c.error),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(astrologersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔭', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('No Astrologers Available', style: tt.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Check back soon',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(astrologersProvider),
          color: c.primary,
          backgroundColor: c.card,
          child: ListView.separated(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: c.border, indent: 72),
            itemBuilder: (_, i) => _AstrologerSearchTile(
              astrologer: items[i],
              index: i,
              mode: mode,
            ),
          ),
        );
      },
    );
  }
}

// ─── Astrologer search results (with lazy loading) ────────────────────────

class _AstrologerSearchResults extends ConsumerWidget {
  const _AstrologerSearchResults({
    required this.scrollCtrl,
    required this.mode, // 'chat' | 'voice'
  });

  final ScrollController scrollCtrl;
  final String mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final search = ref.watch(astrologerSearchProvider);

    if (search.isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }

    if (search.items.isEmpty && !search.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search, size: 48, color: c.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              search.query.isEmpty ? 'Search for an astrologer' : 'No astrologers found',
              style: tt.titleSmall?.copyWith(color: c.textSecondary),
            ),
            if (search.query.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Try a different name or specialty',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary.withValues(alpha: 0.5))),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: search.items.length + (search.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: c.border, indent: 72),
      itemBuilder: (_, i) {
        if (i == search.items.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
              ),
            ),
          );
        }
        return _AstrologerSearchTile(
          astrologer: search.items[i],
          index: i,
          mode: mode,
        );
      },
    );
  }
}

class _AstrologerSearchTile extends StatelessWidget {
  const _AstrologerSearchTile({
    required this.astrologer,
    required this.index,
    required this.mode,
  });

  final Astrologer astrologer;
  final int index;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final price = mode == 'chat'
        ? astrologer.pricePerMinChat
        : astrologer.pricePerMinCall;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: image strip ──────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 130,
                child: astrologer.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: astrologer.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _AvatarPlaceholder(c: c),
                      )
                    : _AvatarPlaceholder(c: c),
              ),
            ),
            // ── Right: details ─────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            astrologer.displayName,
                            style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (astrologer.isOnline)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (astrologer.specialties.isNotEmpty)
                      Text(
                        astrologer.specialties.take(3).join(' · '),
                        style: tt.labelSmall?.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: c.accent),
                        const SizedBox(width: 3),
                        Text(astrologer.ratingAvg.toStringAsFixed(1),
                            style: tt.labelSmall?.copyWith(
                                color: c.accent, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Text('(${astrologer.ratingCount})',
                            style: tt.labelSmall?.copyWith(
                                color: c.textSecondary.withValues(alpha: 0.6),
                                fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${astrologer.experienceYears} yrs exp  ·  ${astrologer.languages.take(2).join(', ')}',
                      style: tt.labelSmall?.copyWith(
                          color: c.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(0)}/min',
                              style: tt.labelMedium?.copyWith(
                                  color: c.accent,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _ActionButton(astrologer: astrologer, mode: mode),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.c});
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: c.primary.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.person, color: c.primary.withValues(alpha: 0.5), size: 40),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.astrologer, required this.mode});
  final Astrologer astrologer;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (astrologer.isBusy) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: c.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Busy',
            style: TextStyle(color: c.error, fontSize: 11, fontWeight: FontWeight.w600)),
      );
    }
    if (!astrologer.isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Offline',
            style: TextStyle(
                color: c.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
    }
    final label = mode == 'chat' ? 'Chat' : 'Call';
    final icon = mode == 'chat' ? Icons.chat_bubble_outline : Icons.phone_outlined;
    return ElevatedButton.icon(
      onPressed: () {
        Get.snackbar(
          'Coming Soon',
          'Tap the profile to start a consultation',
          backgroundColor: c.card,
          colorText: c.textPrimary,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      },
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
