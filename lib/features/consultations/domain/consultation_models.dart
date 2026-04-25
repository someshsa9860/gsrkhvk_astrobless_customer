class Consultation {
  final String id;
  final String type;
  final String status;
  final String astrologerName;
  final String? astrologerImageUrl;
  final int durationSeconds;
  final double totalCharged;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? endReason;

  const Consultation({
    required this.id,
    required this.type,
    required this.status,
    required this.astrologerName,
    this.astrologerImageUrl,
    required this.durationSeconds,
    required this.totalCharged,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.endReason,
  });

  factory Consultation.fromJson(Map<String, dynamic> j) {
    final astrologer = j['astrologer'] as Map<String, dynamic>? ?? {};
    return Consultation(
      id: j['id'] as String,
      type: j['type'] as String? ?? 'chat',
      status: j['status'] as String? ?? 'ended',
      astrologerName: astrologer['displayName'] as String? ?? 'Astrologer',
      astrologerImageUrl: astrologer['profileImageUrl'] as String?,
      durationSeconds: (j['durationSeconds'] as num? ?? 0).toInt(),
      totalCharged: (j['totalCharged'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(j['createdAt'] as String),
      startedAt: j['startedAt'] != null
          ? DateTime.parse(j['startedAt'] as String)
          : null,
      endedAt: j['endedAt'] != null
          ? DateTime.parse(j['endedAt'] as String)
          : null,
      endReason: j['endReason'] as String?,
    );
  }
}
