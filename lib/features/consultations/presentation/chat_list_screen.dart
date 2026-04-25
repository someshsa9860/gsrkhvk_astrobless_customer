import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../astrologers/data/astrologer_search_notifier.dart';
import '../../astrologers/domain/astrologer_models.dart';
import '../data/consultations_repository.dart';
import '../domain/consultation_models.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search astrologers…',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                prefixIcon: const Icon(Icons.search, color: AppColors.textDisabled, size: 20),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18,
                            color: AppColors.textSecondary),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
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
          : _ChatConsultationList(),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.astrologers),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text('New Chat',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
    );
  }
}

// ─── Chat consultation list ───────────────────────────────────────────────

class _ChatConsultationList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final async = ref.watch(consultationsByTypeProvider('chat'));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textDisabled, size: 40),
            const SizedBox(height: 12),
            Text('Could not load chats',
                style: tt.titleSmall
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.refresh(consultationsByTypeProvider('chat')),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) return _EmptyChat();

        final active = items
            .where((c) => c.status == 'active' || c.status == 'accepted')
            .toList();
        final past = items
            .where((c) =>
                c.status == 'ended' ||
                c.status == 'rejected' ||
                c.status == 'cancelled')
            .toList();

        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(consultationsByTypeProvider('chat').future),
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (active.isNotEmpty) ...[
                _ListHeader('Active', AppColors.accent),
                ...active.asMap().entries.map((e) =>
                    _ConsultationCard(c: e.value, index: e.key, isActive: true)),
                const Divider(color: AppColors.borderDark, height: 24, indent: 16, endIndent: 16),
              ],
              if (past.isNotEmpty) ...[
                _ListHeader('Recent', AppColors.textSecondary),
                ...past.asMap().entries.map((e) =>
                    _ConsultationCard(c: e.value, index: e.key, isActive: false)),
              ],
            ],
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
    final search = ref.watch(astrologerSearchProvider);

    if (search.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (search.items.isEmpty && !search.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text(
              search.query.isEmpty ? 'Search for an astrologer' : 'No astrologers found',
              style: tt.titleSmall?.copyWith(color: AppColors.textSecondary),
            ),
            if (search.query.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Try a different name or specialty',
                  style: tt.bodySmall?.copyWith(color: AppColors.textDisabled)),
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
          const Divider(height: 1, color: AppColors.borderDark, indent: 72),
      itemBuilder: (_, i) {
        if (i == search.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
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
    final price = mode == 'chat'
        ? astrologer.pricePerMinChat
        : astrologer.pricePerMinCall;

    return InkWell(
      onTap: () => context.push(AppRoutes.astrologerDetail(astrologer.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: astrologer.profileImageUrl != null
                      ? CachedNetworkImageProvider(astrologer.profileImageUrl!)
                      : null,
                  child: astrologer.profileImageUrl == null
                      ? const Icon(Icons.person,
                          color: AppColors.primary, size: 24)
                      : null,
                ),
                if (astrologer.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.bgDark, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(astrologer.displayName,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  if (astrologer.specialties.isNotEmpty)
                    Text(
                      astrologer.specialties.take(3).join(' · '),
                      style: tt.labelSmall
                          ?.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(astrologer.ratingAvg.toStringAsFixed(1),
                          style: tt.labelSmall
                              ?.copyWith(color: AppColors.accent)),
                      const SizedBox(width: 8),
                      Text(
                        '${formatCurrency(price)}/min',
                        style: tt.labelSmall?.copyWith(
                            color: AppColors.textDisabled, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _ActionButton(astrologer: astrologer, mode: mode),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 30 * index));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.astrologer, required this.mode});
  final Astrologer astrologer;
  final String mode;

  @override
  Widget build(BuildContext context) {
    if (astrologer.isBusy) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Busy',
            style: TextStyle(
                color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
      );
    }
    if (!astrologer.isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Offline',
            style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
    }
    final label = mode == 'chat' ? 'Chat' : 'Call';
    final icon = mode == 'chat'
        ? Icons.chat_bubble_outline
        : Icons.phone_outlined;
    return ElevatedButton.icon(
      onPressed: () {
        Get.snackbar(
          'Coming Soon',
          'Tap the profile to start a consultation',
          backgroundColor: AppColors.cardDark,
          colorText: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      },
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  const _ListHeader(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
    required this.c,
    required this.index,
    required this.isActive,
  });

  final Consultation c;
  final int index;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push(AppRoutes.consultationChat(c.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: c.astrologerImageUrl != null
                      ? CachedNetworkImageProvider(c.astrologerImageUrl!)
                      : null,
                  child: c.astrologerImageUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary, size: 26)
                      : null,
                ),
                if (isActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bgDark, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.astrologerName,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    isActive ? 'Session in progress' : timeAgo(c.createdAt),
                    style: tt.labelSmall?.copyWith(
                      color: isActive
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (c.totalCharged > 0 && !isActive)
              Text(
                formatCurrency(c.totalCharged),
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textDisabled,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Resume',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Chats Yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Search above to find an astrologer\nand start a chat consultation',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
