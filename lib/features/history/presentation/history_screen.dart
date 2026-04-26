import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../consultations/data/consultations_repository.dart';
import '../../consultations/domain/consultation_models.dart';
import '../../kundli/data/kundli_repository.dart';
import '../../kundli/domain/kundli_models.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/domain/wallet_models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.push(AppRoutes.wallet),
            tooltip: 'Wallet',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Consultations'),
            Tab(text: 'Kundli Reports'),
            Tab(text: 'Wallet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _ConsultationHistory(),
          _KundliReportHistory(),
          _WalletHistory(),
        ],
      ),
    );
  }
}

// ─── Consultation tab ──────────────────────────────────────────────────────

class _ConsultationHistory extends ConsumerWidget {
  const _ConsultationHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(consultationHistoryProvider);
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _EmptyState(
        emoji: '💬',
        title: 'Could not load consultations',
        subtitle: 'Pull down to retry',
        onAction: () => ref.refresh(consultationHistoryProvider),
        actionLabel: 'Retry',
      ),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            emoji: '💬',
            title: 'No Consultations Yet',
            subtitle: 'Your chat and call consultation\nhistory will appear here',
            onAction: () => context.push(AppRoutes.astrologers),
            actionLabel: 'Find Astrologers',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(consultationHistoryProvider.future),
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderDark, indent: 72),
            itemBuilder: (_, i) =>
                _ConsultationTile(consultation: items[i], index: i),
          ),
        );
      },
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  const _ConsultationTile({required this.consultation, required this.index});

  final Consultation consultation;
  final int index;

  IconData get _typeIcon => switch (consultation.type) {
        'voice' => Icons.phone_outlined,
        'video' => Icons.videocam_outlined,
        _ => Icons.chat_bubble_outline,
      };

  Color get _statusColor => switch (consultation.status) {
        'active' => AppColors.success,
        'ended' => AppColors.textSecondary,
        'requested' || 'accepted' => AppColors.accent,
        _ => AppColors.textDisabled,
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.push(AppRoutes.consultationChat(consultation.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage: consultation.astrologerImageUrl != null
                  ? NetworkImage(consultation.astrologerImageUrl!)
                  : null,
              child: consultation.astrologerImageUrl == null
                  ? Icon(_typeIcon, size: 22, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(consultation.astrologerName,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(_typeIcon,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        consultation.type[0].toUpperCase() +
                            consultation.type.substring(1),
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      if (consultation.durationSeconds > 0) ...[
                        const SizedBox(width: 8),
                        Text('·',
                            style: tt.labelSmall
                                ?.copyWith(color: AppColors.textDisabled)),
                        const SizedBox(width: 8),
                        Text(
                          formatDuration(consultation.durationSeconds),
                          style: tt.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo(consultation.createdAt),
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textDisabled, fontSize: 10),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (consultation.totalCharged > 0)
                  Text(
                    formatCurrency(consultation.totalCharged.toDouble()),
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    consultation.status[0].toUpperCase() +
                        consultation.status.substring(1),
                    style: tt.labelSmall?.copyWith(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }
}

// ─── Kundli tab ────────────────────────────────────────────────────────────

class _KundliReportHistory extends ConsumerWidget {
  const _KundliReportHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(kundliProfilesProvider);
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _EmptyState(
        emoji: '🔮',
        title: 'Could not load Kundli profiles',
        subtitle: 'Pull down to retry',
        onAction: () => ref.refresh(kundliProfilesProvider),
        actionLabel: 'Retry',
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return _EmptyState(
            emoji: '🔮',
            title: 'No Kundli Reports Yet',
            subtitle: 'Create a Kundli profile to generate\nyour personalized birth chart report',
            onAction: () => context.push(AppRoutes.kundliList),
            actionLabel: 'Create Kundli',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(kundliProfilesProvider.future),
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: profiles.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderDark, indent: 72),
            itemBuilder: (_, i) =>
                _KundliProfileTile(profile: profiles[i], index: i),
          ),
        );
      },
    );
  }
}

class _KundliProfileTile extends StatelessWidget {
  const _KundliProfileTile({required this.profile, required this.index});

  final KundliProfile profile;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.push(AppRoutes.kundliReport(profile.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_outlined,
                  size: 22, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    profile.dateOfBirth +
                        (profile.timeOfBirth != null
                            ? ' · ${profile.timeOfBirth}'
                            : ''),
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    profile.placeOfBirth,
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textDisabled, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }
}

// ─── Wallet tab ────────────────────────────────────────────────────────────

class _WalletHistory extends ConsumerWidget {
  const _WalletHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(walletTransactionsProvider);
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _EmptyState(
        emoji: '💳',
        title: 'Could not load transactions',
        subtitle: 'Pull down to retry',
        onAction: () => ref.refresh(walletTransactionsProvider),
        actionLabel: 'Retry',
      ),
      data: (txs) {
        if (txs.isEmpty) {
          return _EmptyState(
            emoji: '💳',
            title: 'No Transactions Yet',
            subtitle: 'Add money to your wallet to start\nconsulting with astrologers',
            onAction: () => context.push(AppRoutes.wallet),
            actionLabel: 'Add Money',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(walletTransactionsProvider.future),
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: txs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderDark, indent: 72),
            itemBuilder: (_, i) =>
                _TransactionTile(transaction: txs[i], index: i),
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.index});

  final WalletTransaction transaction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isCredit = transaction.direction == 'CREDIT';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _humanizeType(transaction.type),
                  style:
                      tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (transaction.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.notes!,
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  formatDateTime(transaction.createdAt),
                  style: tt.labelSmall
                      ?.copyWith(color: AppColors.textDisabled, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${formatCurrency(transaction.amount)}',
            style: tt.titleSmall?.copyWith(
              color: isCredit ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }

  String _humanizeType(String type) => switch (type) {
        'TOPUP' => 'Wallet Top-up',
        'CONSULTATION_DEBIT' => 'Consultation',
        'REFUND' => 'Refund',
        'BONUS' => 'Bonus Credit',
        'ADMIN_ADJUST' => 'Adjustment',
        _ => type,
      };
}

// ─── Shared empty state ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onAction,
    required this.actionLabel,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(title, style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style:
                  tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
