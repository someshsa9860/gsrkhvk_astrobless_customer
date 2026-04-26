import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../domain/iap_product.dart';

/// Result returned after a successful IAP top-up verification.
class IapTopupResult {
  const IapTopupResult({
    required this.storeTransactionId,
    required this.creditedAmountPaise,
    required this.walletTransactionId,
  });
  final String storeTransactionId;
  final int creditedAmountPaise;
  final String walletTransactionId;
}

class IapService {
  IapService(this._api);

  final ApiClient _api;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // Pending completers: keyed by productId → resolved when server confirms
  final _pending = <String, Completer<IapTopupResult>>{};

  bool _initialized = false;

  /// Initialize purchase listener. Call once after login.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object err) => debugPrint('[IapService] purchaseStream error: $err'),
    );
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _initialized = false;
  }

  /// Fetch available products from the store. Returns null if store is unavailable.
  Future<List<ProductDetails>?> fetchProducts(Set<String> productIds) async {
    final available = await _iap.isAvailable();
    if (!available) return null;

    final response = await _iap.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[IapService] Products not found in store: ${response.notFoundIDs}');
    }
    return response.productDetails;
  }

  /// Initiate a purchase and wait for server verification.
  /// Returns [IapTopupResult] on success or throws on failure.
  Future<IapTopupResult> buyProduct(
    ProductDetails product,
    IapProduct catalogItem,
  ) async {
    if (_pending.containsKey(product.id)) {
      throw Exception('A purchase for ${product.id} is already in progress.');
    }

    final completer = Completer<IapTopupResult>();
    _pending[product.id] = completer;

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
    } catch (e) {
      _pending.remove(product.id);
      rethrow;
    }

    // Wait for purchase stream to deliver and verify (with a timeout)
    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _pending.remove(product.id);
        throw TimeoutException('IAP verification timed out for ${product.id}');
      },
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        await _iap.completePurchase(purchase);
        final completer = _pending.remove(purchase.productID);
        completer?.completeError(
          purchase.error?.message ?? 'Purchase cancelled',
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          final result = await _verifyWithServer(purchase);
          // Acknowledge/consume only after server confirms
          await _iap.completePurchase(purchase);
          final completer = _pending.remove(purchase.productID);
          completer?.complete(result);
        } catch (e) {
          // Don't complete purchase — user can retry or contact support
          // The purchase is still pending on the store side
          debugPrint('[IapService] Server verification failed: $e');
          final completer = _pending.remove(purchase.productID);
          completer?.completeError(e);
        }
      }
    }
  }

  Future<IapTopupResult> _verifyWithServer(PurchaseDetails purchase) async {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final idempotencyKey = const Uuid().v4();

    // Find matching catalog item to get expected amount
    final catalogItem = kDefaultIapProducts.firstWhere(
      (p) => p.productId == purchase.productID,
      orElse: () => IapProduct(
        productId: purchase.productID,
        label: purchase.productID,
        amountPaise: 0,
        displayPrice: '?',
      ),
    );

    final String token;
    final String transactionId;

    if (Platform.isAndroid) {
      // purchaseToken = serverVerificationData on Android
      token = purchase.verificationData.serverVerificationData;
      transactionId = purchase.purchaseID ?? purchase.productID;
      // packageName resolved server-side from GOOGLE_PLAY_PACKAGE_NAME env var
    } else {
      // iOS: serverVerificationData = base64 receipt data
      token = purchase.verificationData.serverVerificationData;
      transactionId = purchase.purchaseID ?? purchase.productID;
    }

    final body = <String, dynamic>{
      'platform': platform,
      'productId': purchase.productID,
      'amount': catalogItem.amountPaise,
      'idempotencyKey': idempotencyKey,
      'token': token,
      'transactionId': transactionId,
    };

    final response = await _api.post(Endpoints.wallet.iapTopup, data: body);

    final data = response.data['data'] as Map<String, dynamic>;
    return IapTopupResult(
      storeTransactionId: data['storeTransactionId'] as String,
      creditedAmountPaise: data['creditedAmount'] as int,
      walletTransactionId: data['walletTransactionId'] as String,
    );
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final api = ref.watch(apiClientProvider);
  final service = IapService(api);
  ref.onDispose(service.dispose);
  return service;
});
