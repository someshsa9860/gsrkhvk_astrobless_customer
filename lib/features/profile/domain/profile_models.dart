class CustomerProfileFull {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? profileImageUrl;
  final bool emailVerified;
  final String? gender;
  final String? dob;
  final String? birthPlace;

  const CustomerProfileFull({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.profileImageUrl,
    this.emailVerified = false,
    this.gender,
    this.dob,
    this.birthPlace,
  });

  factory CustomerProfileFull.fromJson(Map<String, dynamic> j) =>
      CustomerProfileFull(
        id: j['id'] as String,
        name: j['name'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        profileImageUrl: j['profileImageUrl'] as String?,
        emailVerified: j['emailVerified'] as bool? ?? false,
        gender: j['gender'] as String?,
        dob: j['dob'] as String?,
        birthPlace: j['birthPlace'] as String?,
      );

  CustomerProfileFull copyWith({
    String? name,
    String? email,
    String? gender,
    String? dob,
    String? birthPlace,
    String? profileImageUrl,
  }) =>
      CustomerProfileFull(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        emailVerified: emailVerified,
        gender: gender ?? this.gender,
        dob: dob ?? this.dob,
        birthPlace: birthPlace ?? this.birthPlace,
      );
}
