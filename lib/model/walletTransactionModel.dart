class WalletTransaction {
  WalletTransaction({this.id, required this.name, required this.value});
  dynamic id;
  dynamic name;
  dynamic value;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        id: json["id"],
        name: json["name"] ?? "",
        value: json["value"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
      };
}
