class WaitList {
  WaitList({
    required this.userName,
    required this.status,
    required this.userProfile,
    required this.requestType,
    required this.userFcmToken,
    required this.userId,
    required this.channel,
    required this.time,
    required this.id,
    this.isOnline = false,
  });

  dynamic userName;
  dynamic userProfile;
  dynamic requestType;
  dynamic channel;
  dynamic time;
  dynamic id;
  dynamic userId;
  dynamic userFcmToken;
  dynamic status;
  bool isOnline;

  factory WaitList.fromJson(Map<String, dynamic> json) => WaitList(
        userName: json["userName"] ?? "",
        userProfile: json['profile'] ?? "",
        requestType: json['requestType'] ?? "",
        channel: json['channel'] ?? "",
        time: json['time'] ?? "",
        id: json['id'] ?? null,
        userId: json['userId'] ?? 0,
        userFcmToken: json['userFcmToken'] ?? "",
        status: json['status'] ?? "Pending",
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "profile": userProfile,
        "requestType": requestType,
        "channel": channel,
        "time": time,
      };
}
