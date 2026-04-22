class KundliProfile {
  final String id;
  final String name;
  final String dateOfBirth;
  final String? timeOfBirth;
  final String placeOfBirth;
  final double lat;
  final double lng;
  final DateTime createdAt;

  const KundliProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.timeOfBirth,
    required this.placeOfBirth,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  factory KundliProfile.fromJson(Map<String, dynamic> j) => KundliProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        dateOfBirth: j['dateOfBirth'] as String,
        timeOfBirth: j['timeOfBirth'] as String?,
        placeOfBirth: j['placeOfBirth'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class KundliReport {
  final String profileId;
  final Map<String, dynamic> chartData;
  final DateTime computedAt;

  const KundliReport({
    required this.profileId,
    required this.chartData,
    required this.computedAt,
  });

  factory KundliReport.fromJson(Map<String, dynamic> j) => KundliReport(
        profileId: j['profileId'] as String,
        chartData: j['chartData'] as Map<String, dynamic>? ?? {},
        computedAt: DateTime.parse(j['computedAt'] as String),
      );
}
