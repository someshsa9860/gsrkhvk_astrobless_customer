class AssistantModel {
  AssistantModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.createdAt,
    required this.updatedAt,
    required this.astrologerId,
    required this.customerId,
    this.profileImage,
    this.astrologerName,
    this.lastMessage,
    this.lastMessageTime,
    this.fcmToken,
  });

  dynamic id;
  dynamic senderId;
  dynamic receiverId;
  dynamic chatId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic astrologerId;
  dynamic customerId;
  dynamic profileImage;
  dynamic astrologerName;
  dynamic lastMessage;
  DateTime? lastMessageTime;
  dynamic fcmToken;

  factory AssistantModel.fromJson(Map<String, dynamic> json) => AssistantModel(
    id: json["id"],
    senderId: json["senderId"] ?? 0,
    receiverId: json["receiverId"] ?? 0,
    chatId: json["chatId"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    astrologerId: json["astrologerId"],
    customerId: json["customerId"],
    profileImage: json["profileImage"] ?? "",
    astrologerName: json["astrologerName"] ?? "",
    fcmToken: json["fcmToken"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "senderId": senderId,
    "receiverId": receiverId,
    "chatId": chatId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "astrologerId": astrologerId,
    "customerId": customerId,
    "profileImage": profileImage,
    "astrologerName": astrologerName,
    "fcmToken": fcmToken,
  };
}
