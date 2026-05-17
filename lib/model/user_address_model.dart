class UserAddressModel {
  UserAddressModel({
    this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.phoneNumber2,
    required this.flatNo,
    required this.locality,
    this.landmark,
    required this.city,
    this.state,
    required this.country,
    required this.pincode,
    this.countryCode,
    this.alternateCountryCode,
  });

  dynamic id;
  dynamic userId;
  dynamic name;
  dynamic phoneNumber;
  dynamic phoneNumber2;
  dynamic flatNo;
  dynamic locality;
  dynamic landmark;
  dynamic city;
  dynamic state;
  dynamic country;
  dynamic countryCode;
  dynamic alternateCountryCode;
  dynamic pincode;

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        id: json["id"],
        userId: json["userId"],
        name: json["name"] ?? "",
        phoneNumber: json["phoneNumber"],
        phoneNumber2: json["phoneNumber2"] ?? "",
        flatNo: json["flatNo"] ?? "",
        locality: json["locality"] ?? "",
        landmark: json["landmark"] ?? "",
        city: json["city"] ?? "",
        state: json["state"] ?? "",
        country: json["country"] ?? "",
        pincode: json["pincode"] ?? "",
        countryCode: json["countryCode"] ?? "IN",
        alternateCountryCode: json["alternateCountryCode"] ?? "IN",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "name": name,
        "phoneNumber": phoneNumber,
        "phoneNumber2": phoneNumber2,
        "flatNo": flatNo,
        "locality": locality,
        "landmark": landmark,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "countryCode": countryCode,
        "alternateCountryCode": alternateCountryCode,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
