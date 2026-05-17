class ReportHistoryModel {
  ReportHistoryModel({required this.id, this.userId, this.astrologerId, this.firstName, this.lastName, this.gender, this.birthDate, this.birthTime, this.birthPlace, this.occupation, this.maritalStatus, this.astrologerName, this.contactNo, this.answerLanguage, this.profileImage, this.reportRate, this.comments, this.reportFile, this.reportType, required this.createdAt, this.isFileUpload, this.title});

  dynamic id;
  dynamic userId;
  dynamic firstName;
  dynamic lastName;
  dynamic gender;
  dynamic birthDate;
  dynamic birthTime;
  dynamic birthPlace;
  dynamic occupation;
  dynamic maritalStatus;
  dynamic answerLanguage;
  dynamic comments;
  dynamic contactNo;
  dynamic reportFile;
  dynamic reportType;
  dynamic astrologerId;
  dynamic astrologerName;
  dynamic title;
  dynamic profileImage;
  dynamic reportRate;
  DateTime? createdAt;
  bool? isFileUpload;

  factory ReportHistoryModel.fromJson(Map<String, dynamic> json) => ReportHistoryModel(
        id: json["id"],
        userId: json["userId"] ?? 0,
        firstName: json["firstName"] ?? "",
        astrologerId: json["astrologerId"] ?? 0,
        lastName: json["lastName"] ?? "",
        answerLanguage: json["answerLanguage"] ?? "",
        birthDate: json["birthDate"] ?? "",
        birthPlace: json["birthPlace"] ?? "",
        birthTime: json["birthTime"] ?? "",
        comments: json["comments"] ?? "",
        gender: json["gender"] ?? "",
        maritalStatus: json["maritalStatus"] ?? 0,
        astrologerName: json["astrologerName"] ?? "",
        contactNo: json["contactNo"] ?? "",
        profileImage: json["profileImage"] ?? "",
        occupation: json["occupation"] ?? "",
        reportFile: json["reportFile"] ?? "",
        reportType: json["reportType"] ?? "",
        title: json["title"] ?? "",
        reportRate: json["reportRate"] ?? 0,
        // createdAt: json["created_at"] ?? "",
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),

        isFileUpload: json['isFileUpload'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "astrologerId": astrologerId,
        "answerLanguage": answerLanguage,
        "birthDate": birthDate,
        "birthPlace": birthPlace,
        "birthTime": birthTime,
        "comments": comments,
        "gender": gender,
        "maritalStatus": maritalStatus,
        "occupation": occupation,
        "astrologerName": astrologerName,
        "contactNo": contactNo,
        "profileImage": profileImage,
        "reportRate": reportRate,
        "reportFile": reportFile,
        "reportType": reportType,
        "title": title,
        // "created_at": createdAt,
        "created_at": createdAt != null ? createdAt!.toIso8601String() : DateTime.now().toIso8601String(),

        "isFileUpload": isFileUpload ?? false,
      };
}
