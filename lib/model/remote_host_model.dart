class RemoteHostModel {
  RemoteHostModel({this.astroId, this.remoteId});

  dynamic astroId;
  dynamic remoteId;

  factory RemoteHostModel.fromJson(Map<String, dynamic> json) => RemoteHostModel(
        astroId: json['astroId'] ?? null,
        remoteId: json['hostId'] ?? null,
      );

  Map<String, dynamic> toJson() => {};
}
