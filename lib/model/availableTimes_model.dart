class AvailableTimes {
  AvailableTimes({this.fromTime, this.toTime});

  dynamic fromTime;
  dynamic toTime;
  factory AvailableTimes.fromJson(Map<String, dynamic> json) => AvailableTimes(
        fromTime: json["fromTime"],
        toTime: json['toTime'],
      );

  Map<String, dynamic> toJson() => {
        "fromTime": fromTime,
        "toTime": toTime,
      };
}
