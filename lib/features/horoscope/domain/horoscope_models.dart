class HoroscopeData {
  final String zodiacSign;
  final String period;
  final String? summary;
  final String? love;
  final String? career;
  final String? health;
  final String? general;
  final String? luckyColor;
  final String? luckyNumber;
  final String? luckyDay;
  final String? luckyGem;
  final int? fortuneScore; // 1–5

  const HoroscopeData({
    required this.zodiacSign,
    required this.period,
    this.summary,
    this.love,
    this.career,
    this.health,
    this.general,
    this.luckyColor,
    this.luckyNumber,
    this.luckyDay,
    this.luckyGem,
    this.fortuneScore,
  });

  factory HoroscopeData.fromJson(Map<String, dynamic> j) => HoroscopeData(
        zodiacSign: j['sign'] as String? ?? j['zodiacSign'] as String? ?? '',
        period: j['period'] as String? ?? 'daily',
        summary: j['content'] as String? ?? j['summary'] as String?,
        love: _section(j, 'love'),
        career: _section(j, 'career'),
        health: _section(j, 'health'),
        general: _section(j, 'general'),
        luckyColor: j['luckyColor'] as String?,
        luckyNumber: j['luckyNumber'] as String?,
        luckyDay: j['luckyDay'] as String?,
        luckyGem: j['luckyGem'] as String?,
        fortuneScore: j['fortuneScore'] as int? ?? j['score'] as int?,
      );

  static String? _section(Map<String, dynamic> j, String key) {
    final sections = j['sections'] as Map<String, dynamic>?;
    return sections?[key] as String? ?? j[key] as String?;
  }
}
