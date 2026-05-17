// To parse this JSON data, do
//
//     final liveAstrologerModel = liveAstrologerModelFromJson(jsonString);

import 'dart:convert';

LiveAstrologerModel liveAstrologerModelFromJson(dynamic str) =>
    LiveAstrologerModel.fromJson(json.decode(str));

dynamic liveAstrologerModelToJson(LiveAstrologerModel data) =>
    json.encode(data.toJson());

class LiveAstrologerModel {
  dynamic message;
  dynamic status;
  List<RecordList>? recordList;
  dynamic callMethod;

  LiveAstrologerModel({
    this.message,
    this.status,
    this.recordList,
    this.callMethod,
  });

  factory LiveAstrologerModel.fromJson(Map<String, dynamic> json) =>
      LiveAstrologerModel(
        message: json["message"],
        status: json["status"],
        recordList: json["recordList"] == null
            ? []
            : List<RecordList>.from(
                json["recordList"]!.map((x) => RecordList.fromJson(x))),
        callMethod: json["call_method"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "recordList": recordList == null
            ? []
            : List<dynamic>.from(recordList!.map((x) => x.toJson())),
        "call_method": callMethod,
      };
}

class RecordList {
  dynamic id;
  dynamic userId;
  dynamic name;
  dynamic slug;
  dynamic email;
  dynamic countryCode;
  dynamic contactNo;
  dynamic whatsappNo;
  dynamic aadharNo;
  dynamic gstNo;
  dynamic pancardNo;
  dynamic gender;
  DateTime? birthDate;
  dynamic primarySkill;
  dynamic allSkill;
  dynamic languageKnown;
  dynamic profileImage;
  dynamic charge;
  dynamic chargeUsd;
  dynamic videoCallRateUsd;
  dynamic reportRateUsd;
  dynamic experienceInYears;
  dynamic dailyContribution;
  dynamic hearAboutAstroguru;
  dynamic isWorkingOnAnotherPlatform;
  dynamic whyOnBoard;
  dynamic interviewSuitableTime;
  dynamic currentCity;
  dynamic mainSourceOfBusiness;
  dynamic highestQualification;
  dynamic degree;
  dynamic college;
  dynamic learnAstrology;
  dynamic astrologerCategoryId;
  dynamic instaProfileLink;
  dynamic facebookProfileLink;
  dynamic linkedInProfileLink;
  dynamic youtubeChannelLink;
  dynamic websiteProfileLink;
  dynamic isAnyBodyRefer;
  dynamic minimumEarning;
  dynamic maximumEarning;
  dynamic loginBio;
  dynamic noofforeignCountriesTravel;
  dynamic currentlyworkingfulltimejob;
  dynamic goodQuality;
  dynamic biggestChallenge;
  dynamic whatwillDo;
  dynamic isVerified;
  dynamic totalOrder;
  dynamic country;
  dynamic isActive;
  dynamic isDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic createdBy;
  dynamic modifiedBy;
  dynamic nameofplateform;
  dynamic monthlyEarning;
  dynamic referedPerson;
  dynamic chatStatus;
  dynamic chatWaitTime;
  dynamic callStatus;
  dynamic callWaitTime;
  dynamic videoCallRate;
  dynamic callSections;
  dynamic chatSections;
  dynamic liveSections;
  dynamic reportRate;
  dynamic deletedAt;
  dynamic aadharCard;
  dynamic panCard;
  dynamic certificate;
  dynamic ifscCode;
  dynamic bankName;
  dynamic bankBranch;
  dynamic accountType;
  dynamic accountNumber;
  dynamic accountHolderName;
  dynamic upi;
  dynamic emergencyVideoChage;
  dynamic emergencyAudioCharge;
  dynamic emergencyChatCharge;
  dynamic emergencyCallStatus;
  dynamic emergencyChatStatus;
  dynamic chat_discounted_rate;
  dynamic audio_discounted_rate;
  dynamic video_discounted_rate;
  dynamic isDiscountedPrice;
  dynamic astrologerId;
  dynamic channelName;
  dynamic token;
  dynamic liveChatToken;
  bool? isFollow;

  RecordList({
    this.id,
    this.userId,
    this.name,
    this.slug,
    this.email,
    this.countryCode,
    this.contactNo,
    this.whatsappNo,
    this.aadharNo,
    this.gstNo,
    this.pancardNo,
    this.gender,
    this.birthDate,
    this.primarySkill,
    this.allSkill,
    this.languageKnown,
    this.profileImage,
    this.charge,
    this.chargeUsd,
    this.videoCallRateUsd,
    this.reportRateUsd,
    this.experienceInYears,
    this.dailyContribution,
    this.hearAboutAstroguru,
    this.isWorkingOnAnotherPlatform,
    this.whyOnBoard,
    this.interviewSuitableTime,
    this.currentCity,
    this.mainSourceOfBusiness,
    this.highestQualification,
    this.degree,
    this.college,
    this.learnAstrology,
    this.astrologerCategoryId,
    this.instaProfileLink,
    this.facebookProfileLink,
    this.linkedInProfileLink,
    this.youtubeChannelLink,
    this.websiteProfileLink,
    this.isAnyBodyRefer,
    this.minimumEarning,
    this.maximumEarning,
    this.loginBio,
    this.noofforeignCountriesTravel,
    this.currentlyworkingfulltimejob,
    this.goodQuality,
    this.biggestChallenge,
    this.whatwillDo,
    this.isVerified,
    this.totalOrder,
    this.country,
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.nameofplateform,
    this.monthlyEarning,
    this.referedPerson,
    this.chatStatus,
    this.chatWaitTime,
    this.callStatus,
    this.callWaitTime,
    this.videoCallRate,
    this.callSections,
    this.chatSections,
    this.liveSections,
    this.reportRate,
    this.deletedAt,
    this.aadharCard,
    this.panCard,
    this.certificate,
    this.ifscCode,
    this.bankName,
    this.bankBranch,
    this.accountType,
    this.accountNumber,
    this.accountHolderName,
    this.upi,
    this.emergencyVideoChage,
    this.emergencyAudioCharge,
    this.emergencyChatCharge,
    this.emergencyCallStatus,
    this.emergencyChatStatus,
    this.chat_discounted_rate,
    this.audio_discounted_rate,
    this.video_discounted_rate,
    this.isDiscountedPrice,
    this.astrologerId,
    this.channelName,
    this.token,
    this.liveChatToken,
    this.isFollow,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        id: json["id"],
        userId: json["userId"],
        name: json["name"],
        slug: json["slug"],
        email: json["email"],
        countryCode: json["countryCode"],
        contactNo: json["contactNo"],
        whatsappNo: json["whatsappNo"],
        aadharNo: json["aadharNo"],
        gstNo: json["gstNo"],
        pancardNo: json["pancardNo"],
        gender: json["gender"],
        birthDate: json["birthDate"] == null
            ? null
            : DateTime.parse(json["birthDate"]),
        primarySkill: json["primarySkill"],
        allSkill: json["allSkill"],
        languageKnown: json["languageKnown"],
        profileImage: json["profileImage"],
        charge: json["charge"],
        chargeUsd: json["charge_usd"],
        videoCallRateUsd: json["videoCallRate_usd"],
        reportRateUsd: json["reportRate_usd"],
        experienceInYears: json["experienceInYears"],
        dailyContribution: json["dailyContribution"],
        hearAboutAstroguru: json["hearAboutAstroguru"],
        isWorkingOnAnotherPlatform: json["isWorkingOnAnotherPlatform"],
        whyOnBoard: json["whyOnBoard"],
        interviewSuitableTime: json["interviewSuitableTime"],
        currentCity: json["currentCity"],
        mainSourceOfBusiness: json["mainSourceOfBusiness"],
        highestQualification: json["highestQualification"],
        degree: json["degree"],
        college: json["college"],
        learnAstrology: json["learnAstrology"],
        astrologerCategoryId: json["astrologerCategoryId"],
        instaProfileLink: json["instaProfileLink"],
        facebookProfileLink: json["facebookProfileLink"],
        linkedInProfileLink: json["linkedInProfileLink"],
        youtubeChannelLink: json["youtubeChannelLink"],
        websiteProfileLink: json["websiteProfileLink"],
        isAnyBodyRefer: json["isAnyBodyRefer"],
        minimumEarning: json["minimumEarning"],
        maximumEarning: json["maximumEarning"],
        loginBio: json["loginBio"],
        noofforeignCountriesTravel: json["NoofforeignCountriesTravel"],
        currentlyworkingfulltimejob: json["currentlyworkingfulltimejob"],
        goodQuality: json["goodQuality"],
        biggestChallenge: json["biggestChallenge"],
        whatwillDo: json["whatwillDo"],
        isVerified: json["isVerified"],
        totalOrder: json["totalOrder"],
        country: json["country"],
        isActive: json["isActive"],
        isDelete: json["isDelete"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        nameofplateform: json["nameofplateform"],
        monthlyEarning: json["monthlyEarning"],
        referedPerson: json["referedPerson"],
        chatStatus: json["chatStatus"],
        chatWaitTime: json["chatWaitTime"],
        callStatus: json["callStatus"],
        callWaitTime: json["callWaitTime"],
        videoCallRate: json["videoCallRate"],
        callSections: json["call_sections"],
        chatSections: json["chat_sections"],
        liveSections: json["live_sections"],
        reportRate: json["reportRate"],
        deletedAt: json["deleted_at"],
        aadharCard: json["aadhar_card"],
        panCard: json["pan_card"],
        certificate: json["certificate"],
        ifscCode: json["ifscCode"],
        bankName: json["bankName"],
        bankBranch: json["bankBranch"],
        accountType: json["accountType"],
        accountNumber: json["accountNumber"],
        accountHolderName: json["accountHolderName"],
        upi: json["upi"],
        emergencyVideoChage: json["emergency_video_chage"],
        emergencyAudioCharge: json["emergency_audio_charge"],
        emergencyChatCharge: json["emergency_chat_charge"],
        emergencyCallStatus: json["emergencyCallStatus"],
        emergencyChatStatus: json["emergencyChatStatus"],
        chat_discounted_rate: json["chat_discounted_rate"],
        audio_discounted_rate: json["audio_discounted_rate"],
        video_discounted_rate: json["video_discounted_rate"],
        isDiscountedPrice: json["isDiscountedPrice"],
        astrologerId: json["astrologerId"],
        channelName: json["channelName"],
        token: json["token"],
        liveChatToken: json["liveChatToken"],
        isFollow: json["isFollow"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "name": name,
        "slug": slug,
        "email": email,
        "countryCode": countryCode,
        "contactNo": contactNo,
        "whatsappNo": whatsappNo,
        "aadharNo": aadharNo,
        "gstNo": gstNo,
        "pancardNo": pancardNo,
        "gender": gender,
        "birthDate": birthDate?.toIso8601String(),
        "primarySkill": primarySkill,
        "allSkill": allSkill,
        "languageKnown": languageKnown,
        "profileImage": profileImage,
        "charge": charge,
        "charge_usd": chargeUsd,
        "videoCallRate_usd": videoCallRateUsd,
        "reportRate_usd": reportRateUsd,
        "experienceInYears": experienceInYears,
        "dailyContribution": dailyContribution,
        "hearAboutAstroguru": hearAboutAstroguru,
        "isWorkingOnAnotherPlatform": isWorkingOnAnotherPlatform,
        "whyOnBoard": whyOnBoard,
        "interviewSuitableTime": interviewSuitableTime,
        "currentCity": currentCity,
        "mainSourceOfBusiness": mainSourceOfBusiness,
        "highestQualification": highestQualification,
        "degree": degree,
        "college": college,
        "learnAstrology": learnAstrology,
        "astrologerCategoryId": astrologerCategoryId,
        "instaProfileLink": instaProfileLink,
        "facebookProfileLink": facebookProfileLink,
        "linkedInProfileLink": linkedInProfileLink,
        "youtubeChannelLink": youtubeChannelLink,
        "websiteProfileLink": websiteProfileLink,
        "isAnyBodyRefer": isAnyBodyRefer,
        "minimumEarning": minimumEarning,
        "maximumEarning": maximumEarning,
        "loginBio": loginBio,
        "NoofforeignCountriesTravel": noofforeignCountriesTravel,
        "currentlyworkingfulltimejob": currentlyworkingfulltimejob,
        "goodQuality": goodQuality,
        "biggestChallenge": biggestChallenge,
        "whatwillDo": whatwillDo,
        "isVerified": isVerified,
        "totalOrder": totalOrder,
        "country": country,
        "isActive": isActive,
        "isDelete": isDelete,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "nameofplateform": nameofplateform,
        "monthlyEarning": monthlyEarning,
        "referedPerson": referedPerson,
        "chatStatus": chatStatus,
        "chatWaitTime": chatWaitTime,
        "callStatus": callStatus,
        "callWaitTime": callWaitTime,
        "videoCallRate": videoCallRate,
        "call_sections": callSections,
        "chat_sections": chatSections,
        "live_sections": liveSections,
        "reportRate": reportRate,
        "deleted_at": deletedAt,
        "aadhar_card": aadharCard,
        "pan_card": panCard,
        "certificate": certificate,
        "ifscCode": ifscCode,
        "bankName": bankName,
        "bankBranch": bankBranch,
        "accountType": accountType,
        "accountNumber": accountNumber,
        "accountHolderName": accountHolderName,
        "upi": upi,
        "emergency_video_chage": emergencyVideoChage,
        "emergency_audio_charge": emergencyAudioCharge,
        "emergency_chat_charge": emergencyChatCharge,
        "emergencyCallStatus": emergencyCallStatus,
        "emergencyChatStatus": emergencyChatStatus,
        "chat_discounted_rate": chat_discounted_rate,
        "audio_discounted_rate": audio_discounted_rate,
        "video_discounted_rate": video_discounted_rate,
        "isDiscountedPrice": isDiscountedPrice,
        "astrologerId": astrologerId,
        "channelName": channelName,
        "token": token,
        "liveChatToken": liveChatToken,
        "isFollow": isFollow,
      };
}
