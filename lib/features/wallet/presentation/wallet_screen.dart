import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/wallet_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('My Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          walletAsync.when(
            loading: () => Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (wallet) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text('Astrobless Wallet',
                          style: tt.labelMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatPaiseExact(wallet.balancePaise),
                    style: tt.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Available Balance',
                      style: tt.bodySmall?.copyWith(color: Colors.white60)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3949AB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Add Money',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
          ),
          const SizedBox(height: 24),
          Text('Transaction History', style: tt.titleSmall),
          const SizedBox(height: 12),
          txAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.accent),
            )),
            error: (_, __) => Text('Failed to load transactions',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            data: (txs) {
              if (txs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No transactions yet',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ),
                );
              }
              return Column(
                children: txs.asMap().entries.map((e) {
                  final tx = e.value;
                  final isCredit = tx.direction == 'CREDIT';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
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
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.type,
                                  style: tt.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              if (tx.notes != null)
                                Text(tx.notes!,
                                    style: tt.labelSmall?.copyWith(
                                        color: AppColors.textSecondary)),
                              Text(formatDateTime(tx.createdAt),
                                  style: tt.labelSmall
                                      ?.copyWith(color: AppColors.textDisabled)),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}${formatPaise(tx.amountPaise)}',
                          style: tt.titleSmall?.copyWith(
                            color: isCredit ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 40 * e.key));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
