import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_app/core/network/api_client.dart';
import 'package:user_app/features/wallet/data/wallet_repository.dart';
import 'package:user_app/features/wallet/domain/wallet_models.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient client;
  late WalletRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = WalletRepository(client);
  });

  group('fetchWallet', () {
    test('returns a Wallet with correct paise values', () async {
      when(() => client.fetchWallet()).thenAnswer(
        (_) async => {'id': 'wallet-1', 'balancePaise': 75000, 'lockedPaise': 0},
      );

      final wallet = await repo.fetchWallet();

      expect(wallet, isA<Wallet>());
      expect(wallet.id, 'wallet-1');
      expect(wallet.balancePaise, 75000);
      expect(wallet.lockedPaise, 0);
    });

    test('propagates exceptions from client', () async {
      when(() => client.fetchWallet()).thenThrow(Exception('server error'));

      await expectLater(repo.fetchWallet(), throwsA(isA<Exception>()));
    });
  });

  group('fetchTransactions', () {
    test('returns mapped WalletTransaction list', () async {
      when(() => client.fetchWalletTransactions()).thenAnswer(
        (_) async => [
          {
            'id': 'txn-1',
            'type': 'TOPUP',
            'direction': 'CREDIT',
            'amountPaise': 10000,
            'balanceAfterPaise': 85000,
            'createdAt': '2026-04-01T10:00:00.000Z',
          },
          {
            'id': 'txn-2',
            'type': 'CONSULTATION_DEBIT',
            'direction': 'DEBIT',
            'amountPaise': 500,
            'balanceAfterPaise': 84500,
            'createdAt': '2026-04-02T11:00:00.000Z',
          },
        ],
      );

      final txns = await repo.fetchTransactions();

      expect(txns, hasLength(2));
      expect(txns.first.id, 'txn-1');
      expect(txns.first.direction, 'CREDIT');
      expect(txns.first.amountPaise, 10000);
      expect(txns.last.direction, 'DEBIT');
    });

    test('returns empty list when client returns empty', () async {
      when(() => client.fetchWalletTransactions()).thenAnswer((_) async => []);

      final txns = await repo.fetchTransactions();

      expect(txns, isEmpty);
    });

    test('amount values are ints (paise), not doubles', () async {
      when(() => client.fetchWalletTransactions()).thenAnswer(
        (_) async => [
          {
            'id': 'txn-3',
            'type': 'TOPUP',
            'direction': 'CREDIT',
            'amountPaise': 5000,
            'balanceAfterPaise': 5000,
            'createdAt': '2026-04-01T10:00:00.000Z',
          },
        ],
      );

      final txns = await repo.fetchTransactions();

      expect(txns.first.amountPaise, isA<int>());
      expect(txns.first.balanceAfterPaise, isA<int>());
    });
  });
}
