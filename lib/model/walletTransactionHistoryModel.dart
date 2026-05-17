class WalletTransactionHistoryModel {
  WalletTransactionHistoryModel(
      {this.id,
      this.userId,
      this.orderId,
      this.isCredit = false,
      this.amount,
      this.transactionType,
      this.name,
      this.totalMin,
      this.createdAt,
      this.updatedAt});

  dynamic id;
  dynamic userId;
  dynamic orderId;
  double? amount;
  dynamic transactionType;
  dynamic name;
  dynamic totalMin;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isCredit;

  WalletTransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    userId = json["userId"] ?? 0;
    orderId = json["orderId"] ?? 0;
    amount =
        json["amount"] != null ? double.parse(json["amount"].toString()) : 0;
    name = json["name"] ?? "";
    totalMin = json["totalMin"] ?? "";
    transactionType = json["transactionType"] ?? "";
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString()).toLocal()
        : null;
    updatedAt = DateTime.parse(json["updated_at"]);
    isCredit = json['isCredit'] != null
        ? (json['isCredit']?.toString() == "1") || (json['isCredit'] == true)
            ? true
            : false
        : false;
  }
}
