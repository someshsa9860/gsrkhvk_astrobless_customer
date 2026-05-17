class AmountModel {
  AmountModel({
    this.id,
    this.amount,
    this.cashback,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  dynamic amount;
  dynamic cashback;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory AmountModel.fromJson(Map<String, dynamic> json) => AmountModel(
        id: json["id"],
        amount: json["amount"],
        cashback: json["cashback"],
        createdAt: DateTime.parse(
            json["created_at"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json["updated_at"] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "cashback": cashback,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
