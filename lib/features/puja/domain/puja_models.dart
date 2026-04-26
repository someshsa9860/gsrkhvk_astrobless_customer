class PujaBooking {
  final String id;
  final String bookingNumber;
  final String pujaTitle;
  final String? pujaImageUrl;
  final String devoteeName;
  final String status;
  final int amount;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final String? astrologerName;

  const PujaBooking({
    required this.id,
    required this.bookingNumber,
    required this.pujaTitle,
    this.pujaImageUrl,
    required this.devoteeName,
    required this.status,
    required this.amount,
    required this.scheduledAt,
    required this.createdAt,
    this.astrologerName,
  });

  factory PujaBooking.fromJson(Map<String, dynamic> j) {
    final template = j['pujaTemplate'] as Map<String, dynamic>?;
    final astrologer = j['astrologer'] as Map<String, dynamic>?;
    return PujaBooking(
      id: j['id'] as String,
      bookingNumber: j['bookingNumber'] as String? ?? j['id'] as String,
      pujaTitle: template?['title'] as String? ?? j['pujaTitle'] as String? ?? 'Puja',
      pujaImageUrl: template?['imageUrl'] as String? ?? j['pujaImageUrl'] as String?,
      devoteeName: j['devoteeName'] as String? ?? '',
      status: j['status'] as String? ?? 'pending',
      amount: (j['amount'] as num?)?.toInt() ?? 0,
      scheduledAt: DateTime.tryParse(j['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      astrologerName: astrologer?['displayName'] as String?,
    );
  }
}
