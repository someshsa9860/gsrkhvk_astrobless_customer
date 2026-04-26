import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/banner_carousel.dart';
import '../../home/data/home_repository.dart';
import '../data/iap_service.dart';
import '../data/wallet_repository.dart';
import '../domain/iap_product.dart';

// ── Quick-add amount options (Razorpay / direct) ───────────────────────────
const _kTopUpOptions = [
  (label: '₹100', amountRupees: 100.0, amountPaise: 10000),
  (label: '₹200', amountRupees: 200.0, amountPaise: 20000),
  (label: '₹500', amountRupees: 500.0, amountPaise: 50000),
  (label: '₹1,000', amountRupees: 1000.0, amountPaise: 100000),
];

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  // ── Razorpay (Android direct / cross-platform fallback) ─────────────────
  late Razorpay _razorpay;
  bool _topupInProgress = false;

  // ── IAP (Google Play on Android, App Store on iOS) ──────────────────────
  List<ProductDetails> _iapProducts = [];
  bool _iapAvailable = false;
  bool _iapLoading = true;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _initIap();
  }

  Future<void> _initIap() async {
    final iapService = ref.read(iapServiceProvider);
    await iapService.initialize();

    final productIds = kDefaultIapProducts.map((p) => p.productId).toSet();
    final products = await iapService.fetchProducts(productIds);

    if (mounted) {
      setState(() {
        _iapAvailable = products != null;
        _iapProducts = products ?? [];
        _iapLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ── Razorpay flow ────────────────────────────────────────────────────────

  Future<void> _startRazorpayTopup(double amountRupees) async {
    if (_topupInProgress) return;
    setState(() => _topupInProgress = true);

    final primaryHex = context.colors.primary.toARGB32().toRadixString(16).substring(2).toUpperCase();

    try {
      final idempotencyKey = const Uuid().v4();
      final data = await ref.read(apiClientProvider).initiateTopup(
            amount: amountRupees,
            providerKey: 'razorpay',
            idempotencyKey: idempotencyKey,
          );

      final payload = data['clientPayload'] as Map<String, dynamic>? ?? {};
      final options = {
        'key': payload['key'] ?? '',
        'amount': amountRupees,
        'currency': 'INR',
        'name': 'Astrobless',
        'description': 'Wallet Top-up',
        'order_id': payload['orderId'] ?? payload['order_id'] ?? '',
        'prefill': payload['prefill'] ?? {},
        'theme': {'color': '#$primaryHex'},
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _topupInProgress = false);
      _showError('Failed to initiate payment: $e');
    }
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    setState(() => _topupInProgress = false);
    ref.invalidate(walletProvider);
    _showSuccess('Payment successful! Wallet updated.');
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    setState(() => _topupInProgress = false);
    _showError('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _topupInProgress = false);
  }

  // ── IAP flow (Google Play / App Store) ───────────────────────────────────

  Future<void> _startIapTopup(ProductDetails product, IapProduct catalogItem) async {
    if (_topupInProgress) return;
    setState(() => _topupInProgress = true);

    try {
      final iapService = ref.read(iapServiceProvider);
      await iapService.buyProduct(product, catalogItem);
      ref.invalidate(walletProvider);
      _showSuccess('Wallet topped up via ${Platform.isIOS ? 'App Store' : 'Google Play'}!');
    } catch (e) {
      _showError('Purchase failed: $e');
    } finally {
      if (mounted) setState(() => _topupInProgress = false);
    }
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────

  void _showTopupSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TopupSheet(
        onSelectRazorpay: _startRazorpayTopup,
        onSelectIap: _startIapTopup,
        iapProducts: _iapProducts,
        iapAvailable: _iapAvailable,
        iapLoading: _iapLoading,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.success),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.error),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('My Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Balance card ────────────────────────────────────────────���────
          walletAsync.when(
            loading: () => Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.bgDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (wallet) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
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
                      const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text('Astrobless Wallet',
                          style: tt.labelMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrencyExact(wallet.balance),
                    style: tt.headlineLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800),
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
                        foregroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: Colors.white54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _topupInProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primaryDark),
                            )
                          : const Text('Add Money',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
          ),

          const SizedBox(height: 16),
          BannerCarousel(bannersProvider: walletBannersProvider),
          Text('Transaction History', style: tt.titleSmall),
          const SizedBox(height: 12),

          // ── Transaction list ─────────────────────────────────────────────
          txAsync.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircularProgressIndicator(color: c.accent),
              ),
            ),
            error: (_, __) => Text('Failed to load transactions',
                style: tt.bodySmall?.copyWith(color: c.textSecondary)),
            data: (txs) {
              if (txs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No transactions yet',
                        style: tt.bodySmall?.copyWith(color: c.textSecondary)),
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
                      color: c.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isCredit ? c.success : c.error)
                                .withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: isCredit ? c.success : c.error,
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
                                    style: tt.labelSmall
                                        ?.copyWith(color: c.textSecondary)),
                              Text(formatDateTime(tx.createdAt),
                                  style: tt.labelSmall?.copyWith(
                                      color: c.textSecondary
                                          .withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}${formatCurrency(tx.amount)}',
                          style: tt.titleSmall?.copyWith(
                            color: isCredit ? c.success : c.error,
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

// ── Top-up bottom sheet ───────────────────────────────────��────────────────

class _TopupSheet extends StatelessWidget {
  const _TopupSheet({
    required this.onSelectRazorpay,
    required this.onSelectIap,
    required this.iapProducts,
    required this.iapAvailable,
    required this.iapLoading,
  });

  final void Function(double amountRupees) onSelectRazorpay;
  final void Function(ProductDetails product, IapProduct catalogItem) onSelectIap;
  final List<ProductDetails> iapProducts;
  final bool iapAvailable;
  final bool iapLoading;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    // On iOS: only show App Store IAP options.
    // On Android: show both Google Play IAP and Razorpay.
    final showIap = iapAvailable && iapProducts.isNotEmpty;
    final showRazorpay = Platform.isAndroid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Money', style: tt.titleMedium),
          const SizedBox(height: 4),
          Text(
            Platform.isIOS
                ? 'Purchases via App Store'
                : 'Pay via Google Play or Razorpay',
            style: tt.bodySmall?.copyWith(color: c.textSecondary),
          ),

          // ── IAP options ──────────────��──────────────────────────────────
          if (iapLoading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ] else if (showIap) ...[
            const SizedBox(height: 16),
            Text(
              Platform.isIOS ? 'App Store' : 'Google Play',
              style: tt.labelMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: kDefaultIapProducts.map((catalogItem) {
                final storeProduct = iapProducts.firstWhere(
                  (p) => p.id == catalogItem.productId,
                  orElse: () => iapProducts.first,
                );
                final priceLabel = storeProduct.price.isNotEmpty
                    ? storeProduct.price
                    : catalogItem.displayPrice;
                return OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelectIap(storeProduct, catalogItem);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textPrimary,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    Platform.isIOS ? Icons.apple : Icons.play_arrow,
                    size: 16,
                    color: c.textSecondary,
                  ),
                  label: Text(priceLabel,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                );
              }).toList(),
            ),
          ],

          // ── Razorpay options (Android only) ─────────────────────────────
          if (showRazorpay) ...[
            if (showIap) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: c.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or via Razorpay',
                        style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                  ),
                  Expanded(child: Divider(color: c.border)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: _kTopUpOptions.map((opt) {
                return OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelectRazorpay(opt.amountRupees);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textPrimary,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(opt.label,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                );
              }).toList(),
            ),
          ],

          // ── Fallback: no methods available ───────────────────────────────
          if (!showIap && !showRazorpay) ...[
            const SizedBox(height: 20),
            Center(
              child: Text('No payment methods available',
                  style: tt.bodySmall?.copyWith(color: c.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }
}
