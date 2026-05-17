// To parse this JSON data, do
//
//     final chartDetailModel = chartDetailModelFromJson(jsonString);

import 'dart:convert';

ChartDetailModel chartDetailModelFromJson(dynamic str) =>
    ChartDetailModel.fromJson(json.decode(str));

dynamic chartDetailModelToJson(ChartDetailModel data) =>
    json.encode(data.toJson());

class ChartDetailModel {
  dynamic message;
  RecordList? recordList;
  dynamic chartDetails;
  dynamic status;

  ChartDetailModel({
    this.message,
    this.recordList,
    this.chartDetails,
    this.status,
  });

  factory ChartDetailModel.fromJson(Map<String, dynamic> json) =>
      ChartDetailModel(
        message: json["message"],
        recordList: json["recordList"] == null
            ? null
            : RecordList.fromJson(json["recordList"]),
        chartDetails: json["chartDetails"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList?.toJson(),
        "chartDetails": chartDetails,
        "status": status,
      };
}

class RecordList {
  dynamic id;
  dynamic name;
  dynamic gender;
  DateTime? birthDate;
  dynamic birthTime;
  dynamic birthPlace;
  dynamic isActive;
  dynamic isDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic createdBy;
  dynamic modifiedBy;
  double? latitude;
  double? longitude;
  dynamic timezone;
  dynamic isForTrackPlanet;
  dynamic pdfType;
  dynamic matchType;
  dynamic forMatch;
  dynamic pdfLink;

  RecordList({
    this.id,
    this.name,
    this.gender,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.latitude,
    this.longitude,
    this.timezone,
    this.isForTrackPlanet,
    this.pdfType,
    this.matchType,
    this.forMatch,
    this.pdfLink,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        id: json["id"],
        name: json["name"],
        gender: json["gender"],
        birthDate: json["birthDate"] == null
            ? null
            : DateTime.parse(json["birthDate"]),
        birthTime: json["birthTime"],
        birthPlace: json["birthPlace"],
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
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        timezone: json["timezone"],
        isForTrackPlanet: json["isForTrackPlanet"],
        pdfType: json["pdf_type"],
        matchType: json["match_type"],
        forMatch: json["forMatch"],
        pdfLink: json["pdf_link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "gender": gender,
        "birthDate": birthDate?.toIso8601String(),
        "birthTime": birthTime,
        "birthPlace": birthPlace,
        "isActive": isActive,
        "isDelete": isDelete,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "isForTrackPlanet": isForTrackPlanet,
        "pdf_type": pdfType,
        "match_type": matchType,
        "forMatch": forMatch,
        "pdf_link": pdfLink,
      };
}
