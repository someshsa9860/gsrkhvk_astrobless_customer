class LanguageModel {
  LanguageModel({
    this.id,
    required this.languageName,
    this.isSelected,
  });
  dynamic id;
  dynamic languageName;
  bool? isSelected = true;

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        id: json["id"],
        languageName: json["languageName"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "languageName": languageName,
      };
}
