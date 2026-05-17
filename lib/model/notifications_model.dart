class NotificationsModel {
  NotificationsModel({
    this.subscriptionid,
    this.id,
    this.userId,
    this.title,
    this.description,
    this.notificationId,
    this.createdAt,
    this.chatRequestId,
    this.callRequestId,
    this.isActive,
    this.isDelete,
    this.notificationType,
    // this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.astrologerName,
    this.astrologerId,
    this.astroprofileImage,
    this.fcmToken,
    this.chatId,
    this.callId,
    this.firebaseChatId,
    this.channelName,
    this.totalMin,
    this.callType,
    this.token,
    this.callDuration,
    this.chatDuration,
    this.callStatus,
    this.chatStatus,
    this.call_method,
    this.walletamount,
    this.charge,
    this.videoCallRate,
  });

  dynamic id;
  dynamic userId;
  dynamic title;
  dynamic description;
  dynamic notificationId;
  DateTime? createdAt;
  dynamic chatRequestId;
  dynamic callRequestId;
  dynamic isActive;
  dynamic isDelete;
  dynamic notificationType;
  //DateTime? createdAt;
  dynamic subscriptionid;
  DateTime? updatedAt;
  dynamic createdBy;
  dynamic modifiedBy;
  dynamic astrologerName;
  dynamic astrologerId;
  dynamic astroprofileImage;
  dynamic fcmToken;
  dynamic chatId;
  dynamic callId;
  dynamic firebaseChatId;
  dynamic channelName;
  dynamic totalMin;
  dynamic callType;
  dynamic token;
  dynamic callDuration;
  dynamic chatDuration;
  dynamic callStatus;
  dynamic chatStatus;
  dynamic call_method;
  dynamic walletamount;
  dynamic charge;
  dynamic videoCallRate;

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        id: json["id"],
        userId: json["userId"],
        title: json["title"],
        description: json["description"],
        notificationId: json["notificationId"],
        createdAt: DateTime.parse(json["created_at"]),
        subscriptionid: json["subscription_id"],
        //  notificationId: json["notificationId"],
        chatRequestId: json["chatRequestId"],
        callRequestId: json["callRequestId"],
        isActive: json["isActive"],
        isDelete: json["isDelete"],
        notificationType: json["notification_type"],
        //  createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        astrologerName: json["astrologerName"],
        astrologerId: json["astrologerId"],
        astroprofileImage: json["astroprofileImage"],
        fcmToken: json["fcmToken"],
        chatId: json["chatId"],
        callId: json["callId"],
        firebaseChatId: json["firebaseChatId"],
        channelName: json["channelName"],
        totalMin: json["totalMin"],
        callType: json["call_type"],
        token: json["token"],
        callDuration: json["call_duration"],
        chatDuration: json["chat_duration"],
        callStatus: json["callStatus"],
        chatStatus: json["chatStatus"],
        call_method: json["call_method"],
        walletamount: json["walletamount"],
        charge: json["charge"],
        videoCallRate: json["videoCallRate"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "title": title,
    "description": description,
    "notificationId": notificationId,
    "subscriptionid": subscriptionid,
    "created_at": createdAt!.toIso8601String(),
    "chatRequestId": chatRequestId,
    "callRequestId": callRequestId,
    "isActive": isActive,
    "isDelete": isDelete,
    "notification_type": notificationType,
    // "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "createdBy": createdBy,
    "modifiedBy": modifiedBy,
    "astrologerName": astrologerName,
    "astrologerId": astrologerId,
    "astroprofileImage": astroprofileImage,
    "fcmToken": fcmToken,
    "chatId": chatId,
    "callId": callId,
    "firebaseChatId": firebaseChatId,
    "channelName": channelName,
    "totalMin": totalMin,
    "call_type": callType,
    "token": token,
    "call_duration": callDuration,
    "chat_duration": chatDuration,
    "callStatus": callStatus,
    "chatStatus": chatStatus,
    "call_method": call_method,
    "walletamount": call_method,
    "charge": call_method,
    "videoCallRate": videoCallRate,
  };
}
