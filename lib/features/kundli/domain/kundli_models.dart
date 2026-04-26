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
        name: (j['label'] ?? j['name']) as String,
        dateOfBirth: (j['birthDate'] ?? j['dateOfBirth']) as String,
        timeOfBirth: (j['birthTime'] ?? j['timeOfBirth']) as String?,
        placeOfBirth: (j['birthPlace'] ?? j['placeOfBirth']) as String,
        lat: double.parse((j['birthLat'] ?? j['lat']).toString()),
        lng: double.parse((j['birthLng'] ?? j['lng']).toString()),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class KootaScore {
  final double points;
  final int maxPoints;
  final String description;

  const KootaScore({
    required this.points,
    required this.maxPoints,
    required this.description,
  });

  factory KootaScore.fromJson(Map<String, dynamic> j) => KootaScore(
        points: double.tryParse(j['points']?.toString() ?? '0') ?? 0,
        maxPoints: (j['maxPoints'] as num?)?.toInt() ?? 0,
        description: j['description'] as String? ?? '',
      );
}

class KundliMatchBreakdown {
  final KootaScore varna;
  final KootaScore vashya;
  final KootaScore tara;
  final KootaScore yoni;
  final KootaScore graha;
  final KootaScore gana;
  final KootaScore bhakoot;
  final KootaScore nadi;

  const KundliMatchBreakdown({
    required this.varna,
    required this.vashya,
    required this.tara,
    required this.yoni,
    required this.graha,
    required this.gana,
    required this.bhakoot,
    required this.nadi,
  });

  factory KundliMatchBreakdown.fromJson(Map<String, dynamic> j) => KundliMatchBreakdown(
        varna:   KootaScore.fromJson(j['varna']   as Map<String, dynamic>? ?? {}),
        vashya:  KootaScore.fromJson(j['vashya']  as Map<String, dynamic>? ?? {}),
        tara:    KootaScore.fromJson(j['tara']     as Map<String, dynamic>? ?? {}),
        yoni:    KootaScore.fromJson(j['yoni']     as Map<String, dynamic>? ?? {}),
        graha:   KootaScore.fromJson(j['graha']    as Map<String, dynamic>? ?? {}),
        gana:    KootaScore.fromJson(j['gana']     as Map<String, dynamic>? ?? {}),
        bhakoot: KootaScore.fromJson(j['bhakoot']  as Map<String, dynamic>? ?? {}),
        nadi:    KootaScore.fromJson(j['nadi']     as Map<String, dynamic>? ?? {}),
      );
}

class KundliMatch {
  final String id;
  final String profileAId;
  final String profileBId;
  final String profileAName;
  final String profileBName;
  final int scorePoints;
  final String scoreLabel;
  final KundliMatchBreakdown breakdown;
  final String conclusion;
  final bool manglikBoy;
  final bool manglikGirl;
  final DateTime createdAt;

  const KundliMatch({
    required this.id,
    required this.profileAId,
    required this.profileBId,
    required this.profileAName,
    required this.profileBName,
    required this.scorePoints,
    required this.scoreLabel,
    required this.breakdown,
    required this.conclusion,
    required this.manglikBoy,
    required this.manglikGirl,
    required this.createdAt,
  });

  factory KundliMatch.fromJson(Map<String, dynamic> j) {
    // When created fresh: { match: {...}, profileA: {...}, profileB: {...}, conclusion, manglikBoy, manglikGirl }
    // When listed: match fields are top-level with profileA/profileB nested
    final match    = j['match'] as Map<String, dynamic>? ?? j;
    final profileA = j['profileA'] as Map<String, dynamic>? ?? {};
    final profileB = j['profileB'] as Map<String, dynamic>? ?? {};

    final rawBreakdown = match['breakdown'];
    final breakdown = rawBreakdown is Map<String, dynamic>
        ? KundliMatchBreakdown.fromJson(rawBreakdown)
        : KundliMatchBreakdown.fromJson({});

    return KundliMatch(
      id:           match['id'] as String? ?? '',
      profileAId:   match['profileAId'] as String? ?? '',
      profileBId:   match['profileBId'] as String? ?? '',
      profileAName: (profileA['label'] ?? profileA['name']) as String? ?? 'Profile A',
      profileBName: (profileB['label'] ?? profileB['name']) as String? ?? 'Profile B',
      scorePoints:  (match['scorePoints'] as num?)?.toInt() ?? 0,
      scoreLabel:   match['scoreLabel'] as String? ?? '',
      breakdown:    breakdown,
      conclusion:   j['conclusion'] as String? ?? '',
      manglikBoy:   j['manglikBoy'] as bool? ?? false,
      manglikGirl:  j['manglikGirl'] as bool? ?? false,
      createdAt:    DateTime.tryParse(match['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
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

  factory KundliReport.fromJson(Map<String, dynamic> j) {
    // Backend returns { profile: { id, chartData: {...}, chartComputedAt }, cached }
    // chartData lives inside profile, not at the top level
    final profile = j['profile'] as Map<String, dynamic>?;
    final profileId = profile?['id'] as String? ?? j['profileId'] as String? ?? '';
    final computedAtRaw = profile?['chartComputedAt'] as String? ?? j['computedAt'] as String?;
    final rawChartData = profile?['chartData'] ?? j['chartData'];
    final chartData = rawChartData is Map
        ? Map<String, dynamic>.from(rawChartData)
        : <String, dynamic>{};
    return KundliReport(
      profileId: profileId,
      chartData: chartData,
      computedAt: computedAtRaw != null ? DateTime.parse(computedAtRaw) : DateTime.now(),
    );
  }
}
