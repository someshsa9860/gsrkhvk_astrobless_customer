class HelpAndSupportSubcatModel {
  HelpAndSupportSubcatModel({
    required this.id,
    required this.helpSupportId,
    required this.helpSupportQuationId,
    required this.title,
    required this.isChatWithus,
    required this.description,
  });

  dynamic id;
  dynamic helpSupportId;
  dynamic helpSupportQuationId;
  dynamic title;
  dynamic isChatWithus;
  dynamic description;

  factory HelpAndSupportSubcatModel.fromJson(Map<String, dynamic> json) => HelpAndSupportSubcatModel(
        id: json["id"],
        helpSupportId: json["helpSupportId"],
        helpSupportQuationId: json["helpSupportQuationId"],
        title: json["title"] ?? "",
        isChatWithus: json["isChatWithus"] ?? 0,
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "helpSupportId": helpSupportId,
        "helpSupportQuationId": helpSupportQuationId,
        "title": title,
        "isChatWithus": isChatWithus,
        "description": description,
      };
}
