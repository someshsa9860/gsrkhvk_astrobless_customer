import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/wallet_repository.dart';

// ── Quick-add amount options ───────────────────────────────────────────────
const _kTopUpOptions = [
  (label: '₹100', amount: 100.0),
  (label: '₹200', amount: 200.0),
  (label: '₹500', amount: 500.0),
  (label: '₹1000', amount: 1000.0),
];

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  late Razorpay _razorpay;
  bool _topupInProgress = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startTopup(double amount) async {
    if (_topupInProgress) return;
    setState(() => _topupInProgress = true);

    try {
      final idempotencyKey = const Uuid().v4();
      final data = await ref.read(apiClientProvider).initiateTopup(
            amount: amount,
            providerKey: 'razorpay',
            idempotencyKey: idempotencyKey,
          );

      final payload = data['clientPayload'] as Map<String, dynamic>? ?? {};
      final options = {
        'key': payload['key'] ?? '',
        'amount': amount,
        'currency': 'INR',
        'name': 'Astrobless',
        'description': 'Wallet Top-up',
        'order_id': payload['orderId'] ?? payload['order_id'] ?? '',
        'prefill': payload['prefill'] ?? {},
        'theme': {'color': '#5C6BC0'},
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _topupInProgress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _topupInProgress = false);
    // Invalidate wallet cache so balance refreshes automatically
    ref.invalidate(walletProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Wallet updated.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _topupInProgress = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _topupInProgress = false);
  }

  void _showTopupSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TopupSheet(onSelect: _startTopup),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('My Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Balance card ─────────────────────────────────────────────────
          walletAsync.when(
            loading: () => Container(
              height: 160,
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
                    formatCurrencyExact(wallet.balance),
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
                      onPressed: _topupInProgress ? null : _showTopupSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3949AB),
                        disabledBackgroundColor: Colors.white54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _topupInProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF3949AB)),
                            )
                          : const Text('Add Money',
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

          // ── Transaction list ─────────────────────────────────────────────
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
                            color: (isCredit
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: isCredit
                                ? AppColors.success
                                : AppColors.error,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.type,
                                  style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600)),
                              if (tx.notes != null)
                                Text(tx.notes!,
                                    style: tt.labelSmall?.copyWith(
                                        color: AppColors.textSecondary)),
                              Text(formatDateTime(tx.createdAt),
                                  style: tt.labelSmall?.copyWith(
                                      color: AppColors.textDisabled)),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}${formatCurrency(tx.amount)}',
                          style: tt.titleSmall?.copyWith(
                            color: isCredit
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 40 * e.key));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopupSheet extends StatelessWidget {
  const _TopupSheet({required this.onSelect});
  final void Function(double amount) onSelect;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Money', style: tt.titleMedium),
          const SizedBox(height: 4),
          Text('Select an amount to add to your wallet',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: _kTopUpOptions.map((opt) {
              return OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSelect(opt.amount);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(opt.label,
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
