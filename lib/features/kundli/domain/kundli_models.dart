// Kundli domain models — covers all 8 report tabs:
// Basic, Charts, Planets, Dasha, Dosha, Ashtakvarga, KP, Report

// ── Profile ───────────────────────────────────────────────────────────────────

class KundliProfile {
  final String id;
  final String name;
  final String dateOfBirth;
  final String? timeOfBirth;
  final String placeOfBirth;
  final double lat;
  final double lng;
  final String timezoneOffset;
  final DateTime createdAt;

  const KundliProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.timeOfBirth,
    required this.placeOfBirth,
    required this.lat,
    required this.lng,
    this.timezoneOffset = '5.5',
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
        timezoneOffset: (j['timezoneOffset'] ?? '5.5').toString(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

// ── Planet ────────────────────────────────────────────────────────────────────

class PlanetData {
  final String name;
  final double fullDegree;
  final double normDegree;
  final double speed;
  final bool isRetro;
  final String sign;
  final String signLord;
  final String nakshatra;
  final String nakshatraLord;
  final int nakshatraPada;
  final int house;

  const PlanetData({
    required this.name,
    required this.fullDegree,
    required this.normDegree,
    required this.speed,
    required this.isRetro,
    required this.sign,
    required this.signLord,
    required this.nakshatra,
    required this.nakshatraLord,
    required this.nakshatraPada,
    required this.house,
  });

  factory PlanetData.fromJson(Map<String, dynamic> j) => PlanetData(
        name: j['name']?.toString() ?? '',
        fullDegree: _dbl(j['fullDegree']),
        normDegree: _dbl(j['normDegree']),
        speed: _dbl(j['speed']),
        isRetro: j['isRetro'] as bool? ?? j['retro'] as bool? ?? false,
        sign: j['sign']?.toString() ?? j['zodiac']?.toString() ?? '',
        signLord: j['signLord']?.toString() ?? j['zodiac_lord']?.toString() ?? '',
        nakshatra: j['nakshatra']?.toString() ?? '',
        nakshatraLord: j['nakshatraLord']?.toString() ?? j['nakshatra_lord']?.toString() ?? '',
        nakshatraPada: _int(j['nakshatraPada'] ?? j['nakshatra_pada']),
        house: _int(j['house']),
      );

  String get degreeStr {
    final d = normDegree.floor();
    final m = ((normDegree - d) * 60).floor();
    return "$d° $m'";
  }
}

// ── Ascendant ─────────────────────────────────────────────────────────────────

class AscendantData {
  final String sign;
  final String signLord;
  final double degree;
  final String nakshatra;
  final String nakshatraLord;
  final int nakshatraPada;

  const AscendantData({
    required this.sign,
    required this.signLord,
    required this.degree,
    required this.nakshatra,
    required this.nakshatraLord,
    required this.nakshatraPada,
  });

  factory AscendantData.fromJson(Map<String, dynamic> j) => AscendantData(
        sign: j['sign']?.toString() ?? j['ascendant']?.toString() ?? '',
        signLord: j['signLord']?.toString() ?? j['ascendant_lord']?.toString() ?? '',
        degree: _dbl(j['degree']),
        nakshatra: j['nakshatra']?.toString() ?? '',
        nakshatraLord: j['nakshatraLord']?.toString() ?? j['nakshatra_lord']?.toString() ?? '',
        nakshatraPada: _int(j['nakshatraPada'] ?? j['nakshatra_pada']),
      );
}

// ── Panchang ──────────────────────────────────────────────────────────────────

class PanchangData {
  final String tithi;
  final String karan;
  final String yog;
  final String nakshatra;
  final String vara;
  final String sunrise;
  final String sunset;
  final String ayanamsa;
  final String julian;

  const PanchangData({
    required this.tithi,
    required this.karan,
    required this.yog,
    required this.nakshatra,
    required this.vara,
    required this.sunrise,
    required this.sunset,
    required this.ayanamsa,
    required this.julian,
  });

  factory PanchangData.fromJson(Map<String, dynamic> j) {
    // Extended-kundli-details response has nested panchang_details or flat fields
    final pd = j['panchang_details'] as Map<String, dynamic>? ?? j;
    return PanchangData(
      tithi: pd['tithi']?.toString() ?? j['tithi']?.toString() ?? '',
      karan: pd['karan']?.toString() ?? j['karan']?.toString() ?? '',
      yog: pd['yog']?.toString() ?? j['yog']?.toString() ?? '',
      nakshatra: pd['nakshatra']?.toString() ?? j['nakshatra']?.toString() ?? '',
      vara: pd['vara']?.toString() ?? j['vara']?.toString() ?? pd['day']?.toString() ?? '',
      sunrise: pd['sunrise']?.toString() ?? j['sunrise']?.toString() ?? '',
      sunset: pd['sunset']?.toString() ?? j['sunset']?.toString() ?? '',
      ayanamsa: j['ayanamsa']?.toString() ?? '',
      julian: j['julian_day']?.toString() ?? j['julianDay']?.toString() ?? '',
    );
  }
}

// ── Avakhada ──────────────────────────────────────────────────────────────────

class AvakhadaData {
  final String varna;
  final String vashya;
  final String yoni;
  final String gan;
  final String nadi;
  final String sign;
  final String signLord;
  final String moonRashi;
  final String moonNakshatra;
  final String moonNakshatraLord;
  final String sunSign;
  final String lucky;

  const AvakhadaData({
    required this.varna,
    required this.vashya,
    required this.yoni,
    required this.gan,
    required this.nadi,
    required this.sign,
    required this.signLord,
    required this.moonRashi,
    required this.moonNakshatra,
    required this.moonNakshatraLord,
    required this.sunSign,
    required this.lucky,
  });

  factory AvakhadaData.fromJson(Map<String, dynamic> j) {
    final ad = j['avakhada_details'] as Map<String, dynamic>? ?? j;
    return AvakhadaData(
      varna: ad['varna']?.toString() ?? j['varna']?.toString() ?? '',
      vashya: ad['vashya']?.toString() ?? j['vashya']?.toString() ?? '',
      yoni: ad['yoni']?.toString() ?? j['yoni']?.toString() ?? '',
      gan: ad['gan']?.toString() ?? j['gan']?.toString() ?? ad['gana']?.toString() ?? '',
      nadi: ad['nadi']?.toString() ?? j['nadi']?.toString() ?? '',
      sign: ad['sign']?.toString() ?? j['sign']?.toString() ?? '',
      signLord: ad['sign_lord']?.toString() ?? j['signLord']?.toString() ?? '',
      moonRashi: ad['moon_rashi']?.toString() ?? j['moonRashi']?.toString() ?? '',
      moonNakshatra: ad['moon_nakshatra']?.toString() ?? j['moonNakshatra']?.toString() ?? '',
      moonNakshatraLord: ad['moon_nakshatra_lord']?.toString() ?? j['moonNakshatraLord']?.toString() ?? '',
      sunSign: ad['sun_sign']?.toString() ?? j['sunSign']?.toString() ?? '',
      lucky: ad['lucky']?.toString() ?? j['lucky']?.toString() ?? '',
    );
  }
}

// ── Dasha ─────────────────────────────────────────────────────────────────────

class AntarDasha {
  final String planet;
  final String startDate;
  final String endDate;

  const AntarDasha({
    required this.planet,
    required this.startDate,
    required this.endDate,
  });

  factory AntarDasha.fromJson(Map<String, dynamic> j) => AntarDasha(
        planet: j['planet']?.toString() ?? '',
        startDate: j['startDate']?.toString() ?? j['start_date']?.toString() ?? '',
        endDate: j['endDate']?.toString() ?? j['end_date']?.toString() ?? '',
      );
}

class MahaDasha {
  final String planet;
  final String startDate;
  final String endDate;
  final List<AntarDasha> antars;

  const MahaDasha({
    required this.planet,
    required this.startDate,
    required this.endDate,
    required this.antars,
  });

  factory MahaDasha.fromJson(Map<String, dynamic> j) => MahaDasha(
        planet: j['planet']?.toString() ?? '',
        startDate: j['startDate']?.toString() ?? j['start_date']?.toString() ?? '',
        endDate: j['endDate']?.toString() ?? j['end_date']?.toString() ?? '',
        antars: (j['antars'] as List<dynamic>? ?? [])
            .map((e) => AntarDasha.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get isCurrent {
    try {
      final now = DateTime.now();
      final start = DateTime.tryParse(startDate);
      final end = DateTime.tryParse(endDate);
      if (start == null || end == null) return false;
      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }
}

// ── Dosha ─────────────────────────────────────────────────────────────────────

class MangalDosha {
  final bool isManglik;
  final double manglikPct;
  final String description;
  final List<String> remedies;

  const MangalDosha({
    required this.isManglik,
    required this.manglikPct,
    required this.description,
    required this.remedies,
  });

  factory MangalDosha.fromJson(Map<String, dynamic> j) => MangalDosha(
        isManglik: j['isManglik'] as bool? ?? j['is_manglik'] as bool? ?? false,
        manglikPct: _dbl(j['manglikPct'] ?? j['manglik_pct']),
        description: j['description']?.toString() ?? j['bot_response']?.toString() ?? '',
        remedies: (j['remedies'] as List<dynamic>? ?? j['remedy'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class KaalSarpDosha {
  final bool isPresent;
  final String type;
  final String severity;
  final String description;

  const KaalSarpDosha({
    required this.isPresent,
    required this.type,
    required this.severity,
    required this.description,
  });

  factory KaalSarpDosha.fromJson(Map<String, dynamic> j) => KaalSarpDosha(
        isPresent: j['isPresent'] as bool? ?? j['is_dosha_present'] as bool? ?? false,
        type: j['type']?.toString() ?? j['dosha_type']?.toString() ?? '',
        severity: j['severity']?.toString() ?? j['dosha_direction']?.toString() ?? '',
        description: j['description']?.toString() ?? j['bot_response']?.toString() ?? '',
      );
}

class SadeSatiStatus {
  final bool isActive;
  final String description;
  final String phase;

  const SadeSatiStatus({
    required this.isActive,
    required this.description,
    required this.phase,
  });

  factory SadeSatiStatus.fromJson(Map<String, dynamic> j) => SadeSatiStatus(
        isActive: j['is_in_sade_sati'] as bool? ??
            j['isInSadeSati'] as bool? ??
            j['is_sade_sati'] as bool? ??
            false,
        description: j['bot_response']?.toString() ?? j['description']?.toString() ?? '',
        phase: j['phase']?.toString() ?? j['sade_sati_phase']?.toString() ?? '',
      );
}

class PitraDosha {
  final bool isPresent;
  final String description;

  const PitraDosha({required this.isPresent, required this.description});

  factory PitraDosha.fromJson(Map<String, dynamic> j) => PitraDosha(
        isPresent: j['is_pitra_dosha'] as bool? ??
            j['isPresent'] as bool? ??
            (j['bot_response']?.toString().isNotEmpty ?? false),
        description: j['bot_response']?.toString() ?? j['description']?.toString() ?? '',
      );
}

// ── Ashtakvarga ───────────────────────────────────────────────────────────────

class AshtakvargaData {
  final String planet;
  final Map<String, int> scores;
  final String? chartImageUrl;

  const AshtakvargaData({
    required this.planet,
    required this.scores,
    this.chartImageUrl,
  });

  factory AshtakvargaData.fromJson(Map<String, dynamic> j) {
    final rawScores = j['scores'] as Map<String, dynamic>? ?? {};
    final scores = rawScores.map((k, v) => MapEntry(k, (v as num).toInt()));
    return AshtakvargaData(
      planet: j['planet']?.toString() ?? 'Total',
      scores: scores,
      chartImageUrl: j['chartImage']?.toString(),
    );
  }

  int get totalBindus => scores.values.fold(0, (s, v) => s + v);
}

// ── Full report ───────────────────────────────────────────────────────────────

class KundliReport {
  final String profileId;
  final AscendantData? ascendant;
  final PanchangData? panchang;
  final AvakhadaData? avakhada;
  final List<PlanetData> planets;
  final List<MahaDasha> dasha;
  final Map<String, dynamic>? currentDasha;
  final MangalDosha? mangalDosha;
  final KaalSarpDosha? kaalSarpDosha;
  final SadeSatiStatus? sadeSatiStatus;
  final PitraDosha? pitraDosha;
  final String? generalPrediction;
  // Chart SVG URLs keyed by div name: { 'D1': url, 'D9': url, ... }
  final Map<String, String> chartSvgUrls;
  final bool cached;
  final DateTime computedAt;
  // Raw chartData for any fields not yet modelled
  final Map<String, dynamic> rawData;

  const KundliReport({
    required this.profileId,
    this.ascendant,
    this.panchang,
    this.avakhada,
    required this.planets,
    required this.dasha,
    this.currentDasha,
    this.mangalDosha,
    this.kaalSarpDosha,
    this.sadeSatiStatus,
    this.pitraDosha,
    this.generalPrediction,
    required this.chartSvgUrls,
    required this.cached,
    required this.computedAt,
    required this.rawData,
  });

  factory KundliReport.fromJson(Map<String, dynamic> j) {
    // Backend returns: { profile: { id, chartComputedAt, ... }, chartData: { ... }, cached }
    final profile = j['profile'] as Map<String, dynamic>? ?? {};
    final cd = j['chartData'] as Map<String, dynamic>? ?? {};
    final profileId = profile['id'] as String? ?? '';
    final computedAt = DateTime.tryParse(
            profile['chartComputedAt']?.toString() ?? '') ??
        DateTime.now();

    // Planets
    final planetsRaw = cd['planets'] as List<dynamic>? ?? [];
    final planets = planetsRaw
        .whereType<Map<String, dynamic>>()
        .map(PlanetData.fromJson)
        .toList();

    // Dasha
    final dashaRaw = cd['dasha'] as List<dynamic>? ?? [];
    final dasha = dashaRaw
        .whereType<Map<String, dynamic>>()
        .map(MahaDasha.fromJson)
        .toList();

    // Chart SVG URLs
    final svgUrlsRaw = cd['chartSvgUrls'] as Map<String, dynamic>? ?? {};
    final chartSvgUrls = <String, String>{};
    for (final e in svgUrlsRaw.entries) {
      if (e.value is String) chartSvgUrls[e.key] = e.value as String;
    }
    // Backward compat: top-level chartImageD1/D9
    final d1 = cd['chartImageD1']?.toString();
    final d9 = cd['chartImageD9']?.toString();
    if (d1 != null && d1.isNotEmpty) chartSvgUrls.putIfAbsent('D1', () => d1);
    if (d9 != null && d9.isNotEmpty) chartSvgUrls.putIfAbsent('D9', () => d9);

    // Optional sections
    final ascRaw = cd['ascendant'];
    final panchangRaw = cd['panchangDetails'];
    final avakhadaRaw = cd['avakhadaDetails'];
    final mangalRaw = cd['mangalDosha'];
    final kaalRaw = cd['kaalSarpDosha'];
    final sadeSatiRaw = cd['sadeSatiStatus'];
    final pitraRaw = cd['pitraDosha'];

    return KundliReport(
      profileId: profileId,
      ascendant: ascRaw is Map<String, dynamic>
          ? AscendantData.fromJson(ascRaw)
          : null,
      panchang: panchangRaw is Map<String, dynamic>
          ? PanchangData.fromJson(panchangRaw)
          : null,
      avakhada: avakhadaRaw is Map<String, dynamic>
          ? AvakhadaData.fromJson(avakhadaRaw)
          : null,
      planets: planets,
      dasha: dasha,
      currentDasha: cd['currentDasha'] is Map<String, dynamic>
          ? cd['currentDasha'] as Map<String, dynamic>
          : null,
      mangalDosha: mangalRaw is Map<String, dynamic>
          ? MangalDosha.fromJson(mangalRaw)
          : null,
      kaalSarpDosha: kaalRaw is Map<String, dynamic>
          ? KaalSarpDosha.fromJson(kaalRaw)
          : null,
      sadeSatiStatus: sadeSatiRaw is Map<String, dynamic>
          ? SadeSatiStatus.fromJson(sadeSatiRaw)
          : null,
      pitraDosha: pitraRaw is Map<String, dynamic>
          ? PitraDosha.fromJson(pitraRaw)
          : null,
      generalPrediction: cd['generalPrediction']?.toString(),
      chartSvgUrls: chartSvgUrls,
      cached: j['cached'] as bool? ?? false,
      computedAt: computedAt,
      rawData: cd,
    );
  }
}

// ── Kundli match ──────────────────────────────────────────────────────────────

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
        points: _dbl(j['points']),
        maxPoints: _int(j['maxPoints']),
        description: j['description']?.toString() ?? '',
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
        varna: KootaScore.fromJson(j['varna'] as Map<String, dynamic>? ?? {}),
        vashya: KootaScore.fromJson(j['vashya'] as Map<String, dynamic>? ?? {}),
        tara: KootaScore.fromJson(j['tara'] as Map<String, dynamic>? ?? {}),
        yoni: KootaScore.fromJson(j['yoni'] as Map<String, dynamic>? ?? {}),
        graha: KootaScore.fromJson(j['graha'] as Map<String, dynamic>? ?? {}),
        gana: KootaScore.fromJson(j['gana'] as Map<String, dynamic>? ?? {}),
        bhakoot: KootaScore.fromJson(j['bhakoot'] as Map<String, dynamic>? ?? {}),
        nadi: KootaScore.fromJson(j['nadi'] as Map<String, dynamic>? ?? {}),
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
    final match = j['match'] as Map<String, dynamic>? ?? j;
    final profileA = j['profileA'] as Map<String, dynamic>? ?? {};
    final profileB = j['profileB'] as Map<String, dynamic>? ?? {};
    final rawBreakdown = match['breakdown'];
    return KundliMatch(
      id: match['id']?.toString() ?? '',
      profileAId: match['profileAId']?.toString() ?? '',
      profileBId: match['profileBId']?.toString() ?? '',
      profileAName: (profileA['label'] ?? profileA['name'])?.toString() ?? 'Profile A',
      profileBName: (profileB['label'] ?? profileB['name'])?.toString() ?? 'Profile B',
      scorePoints: _int(match['scorePoints']),
      scoreLabel: match['scoreLabel']?.toString() ?? '',
      breakdown: rawBreakdown is Map<String, dynamic>
          ? KundliMatchBreakdown.fromJson(rawBreakdown)
          : KundliMatchBreakdown.fromJson({}),
      conclusion: j['conclusion']?.toString() ?? '',
      manglikBoy: j['manglikBoy'] as bool? ?? false,
      manglikGirl: j['manglikGirl'] as bool? ?? false,
      createdAt: DateTime.tryParse(match['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

double _dbl(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
int _int(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
