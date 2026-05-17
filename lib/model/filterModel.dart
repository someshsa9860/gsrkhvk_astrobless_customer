class FilterModel {
  FilterModel({
    this.id,
    required this.name,
    this.isCheck,
  });

  dynamic id;
  dynamic name;
  bool? isCheck = false;

  factory FilterModel.fromJson(Map<String, dynamic> json) => FilterModel(
        id: json["id"],
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}