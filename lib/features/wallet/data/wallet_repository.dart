import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/wallet_models.dart';

/// Repository for wallet balance and transaction history.
///
/// All requests require a valid JWT and go through [ApiClient].
/// Path strings live in [Endpoints.wallet].
class WalletRepository {
  WalletRepository(this._client);
  final ApiClient _client;

  /// Fetches the current wallet balance and currency.
  Future<Wallet> fetchWallet() async {
    final data = await _client.fetchWallet();
    return Wallet.fromJson(data);
  }

  /// Fetches the full wallet transaction ledger (append-only).
  Future<List<WalletTransaction>> fetchTransactions() async {
    final list = await _client.fetchWalletTransactions();
    return list
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiClientProvider));
});

final walletProvider = FutureProvider<Wallet>((ref) {
  return ref.read(walletRepositoryProvider).fetchWallet();
});

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) {
  return ref.read(walletRepositoryProvider).fetchTransactions();
});
