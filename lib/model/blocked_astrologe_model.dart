class BlockedAstrologerModel {
  BlockedAstrologerModel({
    this.id,
    this.astrologerId,
    this.userId,
    this.reason,
    this.languageKnown,
    this.astrologerCategoryId,
    this.allSkill,
    this.primarySkill,
    this.profile,
    this.astrologerName,
    this.experienceInYears,
  });

  dynamic id;
  dynamic astrologerId;
  dynamic userId;
  dynamic reason;
  dynamic languageKnown;
  dynamic astrologerCategoryId;
  dynamic allSkill;
  dynamic primarySkill;
  dynamic profile;
  dynamic astrologerName;
  dynamic experienceInYears;

  factory BlockedAstrologerModel.fromJson(Map<String, dynamic> json) => BlockedAstrologerModel(
        id: json["id"],
        astrologerId: json["astrologerId"],
        userId: json["userId"],
        reason: json["reason"],
        languageKnown: json["languageKnown"],
        astrologerCategoryId: json["astrologerCategoryId"],
        allSkill: json["allSkill"],
        primarySkill: json["primarySkill"],
        profile: json["profile"],
        astrologerName: json["astrologerName"],
        experienceInYears: json["experienceInYears"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "astrologerId": astrologerId,
        "userId": userId,
        "reason": reason,
        "languageKnown": languageKnown,
        "astrologerCategoryId": astrologerCategoryId,
        "allSkill": allSkill,
        "primarySkill": primarySkill,
        "profile": profile,
        "astrologerName": astrologerName,
        "experienceInYears": experienceInYears,
      };
}
