class ReviewModel {
  ReviewModel({
    this.id,
    required this.username,
    required this.userId,
    required this.rating,
    required this.review,
    required this.astrologerId,
    required this.astromallProductId,
    required this.reply,
    required this.updatedAt,
    required this.profile,
    required this.isPublic,
  });
  dynamic id;
  dynamic userId;
  dynamic username;
  double rating;
  dynamic review;
  dynamic astrologerId;
  dynamic astromallProductId;
  dynamic reply;
  DateTime updatedAt;
  dynamic profile;
  dynamic isPublic;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json["id"],
    username: json["userName"] ?? "",
        userId: json["userId"] ?? "",
        rating: json["rating"] != null ? double.parse(json["rating"].toString()) : 0,
        review: json["review"] ?? "",
        astrologerId: json["astrologerId"] ?? "",
        astromallProductId: json["astromallProductId"] ?? 0,
        reply: json["reply"] ?? "",
        updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
        profile: json["profile"] ?? "",
        isPublic: json["isPublic"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "userId": userId,
        "rating": rating,
        "review": review,
        "astrologerId": astrologerId,
        "astromallProductId": astromallProductId,
        "reply": reply,
        "updated_at": updatedAt.toIso8601String(),
        "profile": profile,
        "isPublic": isPublic,
      };
}
