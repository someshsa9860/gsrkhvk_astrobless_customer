class Wallet {
  final String id;
  final double balance;
  final double locked;

  const Wallet({required this.id, required this.balance, required this.locked});

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        id: j['id'] as String,
        balance: (j['balance'] as num?)?.toDouble() ?? 0.0,
        locked: (j['locked'] as num? ?? 0).toDouble(),
      );
}

class WalletTransaction {
  final String id;
  final String type;
  final String direction;
  final double amount;
  final double balanceAfter;
  final String? notes;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    this.notes,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: j['id'] as String,
        type: j['type'] as String,
        direction: j['direction'] as String,
        amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
        balanceAfter: (j['balanceAfter'] as num?)?.toDouble() ?? 0.0,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
