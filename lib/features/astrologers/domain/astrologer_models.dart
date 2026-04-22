class Astrologer {
  final String id;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final List<String> specialties;
  final List<String> languages;
  final int experienceYears;
  final int pricePerMinChatPaise;
  final int pricePerMinCallPaise;
  final bool isOnline;
  final bool isBusy;
  final double ratingAvg;
  final int ratingCount;
  final int totalConsultations;

  const Astrologer({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    required this.specialties,
    required this.languages,
    required this.experienceYears,
    required this.pricePerMinChatPaise,
    required this.pricePerMinCallPaise,
    required this.isOnline,
    required this.isBusy,
    required this.ratingAvg,
    required this.ratingCount,
    required this.totalConsultations,
  });

  factory Astrologer.fromJson(Map<String, dynamic> j) => Astrologer(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        profileImageUrl: j['profileImageUrl'] as String?,
        bio: j['bio'] as String?,
        specialties: (j['specialties'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        languages: (j['languages'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        experienceYears: (j['experienceYears'] as int?) ?? 0,
        pricePerMinChatPaise: (j['pricePerMinChatPaise'] as int?) ?? 0,
        pricePerMinCallPaise: (j['pricePerMinCallPaise'] as int?) ?? 0,
        isOnline: (j['isOnline'] as bool?) ?? false,
        isBusy: (j['isBusy'] as bool?) ?? false,
        ratingAvg: (j['ratingAvg'] as num?)?.toDouble() ?? 0,
        ratingCount: (j['ratingCount'] as int?) ?? 0,
        totalConsultations: (j['totalConsultations'] as int?) ?? 0,
      );
}
