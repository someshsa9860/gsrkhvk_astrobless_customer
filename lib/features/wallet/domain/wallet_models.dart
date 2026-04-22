class Wallet {
  final String id;
  final int balancePaise;
  final int lockedPaise;

  const Wallet({required this.id, required this.balancePaise, required this.lockedPaise});

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        id: j['id'] as String,
        balancePaise: (j['balancePaise'] as num).toInt(),
        lockedPaise: (j['lockedPaise'] as num? ?? 0).toInt(),
      );
}

class WalletTransaction {
  final String id;
  final String type;
  final String direction;
  final int amountPaise;
  final int balanceAfterPaise;
  final String? notes;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amountPaise,
    required this.balanceAfterPaise,
    this.notes,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: j['id'] as String,
        type: j['type'] as String,
        direction: j['direction'] as String,
        amountPaise: (j['amountPaise'] as num).toInt(),
        balanceAfterPaise: (j['balanceAfterPaise'] as num).toInt(),
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
