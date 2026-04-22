import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/wallet/domain/wallet_models.dart';

void main() {
  group('Wallet.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'wallet-1',
        'balancePaise': 50000,
        'lockedPaise': 5000,
      };
      final wallet = Wallet.fromJson(json);

      expect(wallet.id, 'wallet-1');
      expect(wallet.balancePaise, 50000);
      expect(wallet.lockedPaise, 5000);
    });

    test('defaults lockedPaise to 0 when absent', () {
      final wallet = Wallet.fromJson({'id': 'w-2', 'balancePaise': 10000});
      expect(wallet.lockedPaise, 0);
    });

    test('converts numeric balancePaise to int', () {
      final wallet = Wallet.fromJson({
        'id': 'w-3',
        'balancePaise': 25000.0,
        'lockedPaise': 0,
      });
      expect(wallet.balancePaise, isA<int>());
      expect(wallet.balancePaise, 25000);
    });

    test('balance is stored as paise — no float conversion', () {
      final wallet = Wallet.fromJson({
        'id': 'w-4',
        'balancePaise': 100,
        'lockedPaise': 0,
      });
      expect(wallet.balancePaise, 100);
    });
  });

  group('WalletTransaction.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'txn-1',
        'type': 'TOPUP',
        'direction': 'CREDIT',
        'amountPaise': 10000,
        'balanceAfterPaise': 60000,
        'notes': 'Razorpay top-up',
        'createdAt': '2026-04-01T10:00:00.000Z',
      };
      final txn = WalletTransaction.fromJson(json);

      expect(txn.id, 'txn-1');
      expect(txn.type, 'TOPUP');
      expect(txn.direction, 'CREDIT');
      expect(txn.amountPaise, 10000);
      expect(txn.balanceAfterPaise, 60000);
      expect(txn.notes, 'Razorpay top-up');
      expect(txn.createdAt, DateTime.utc(2026, 4, 1, 10, 0, 0));
    });

    test('handles null notes', () {
      final json = {
        'id': 'txn-2',
        'type': 'CONSULTATION_DEBIT',
        'direction': 'DEBIT',
        'amountPaise': 500,
        'balanceAfterPaise': 49500,
        'createdAt': '2026-04-02T12:00:00.000Z',
      };
      final txn = WalletTransaction.fromJson(json);

      expect(txn.notes, isNull);
      expect(txn.amountPaise, 500);
    });

    test('parses DEBIT direction correctly', () {
      final json = {
        'id': 'txn-3',
        'type': 'CONSULTATION_DEBIT',
        'direction': 'DEBIT',
        'amountPaise': 300,
        'balanceAfterPaise': 49700,
        'createdAt': '2026-04-03T08:00:00.000Z',
      };
      final txn = WalletTransaction.fromJson(json);
      expect(txn.direction, 'DEBIT');
    });
  });
}
