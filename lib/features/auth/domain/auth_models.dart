class CustomerProfile {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? profileImageUrl;
  final bool emailVerified;
  final String? gender;
  final String? dob;
  final String? createdAt;

  const CustomerProfile({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.profileImageUrl,
    this.emailVerified = false,
    this.gender,
    this.dob,
    this.createdAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        id: json['id'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        profileImageUrl: json['profileImageUrl'] as String? ?? json['profileImageKey'] as String?,
        emailVerified: json['emailVerified'] as bool? ?? false,
        gender: json['gender'] as String?,
        dob: json['dob'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'emailVerified': emailVerified,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (createdAt != null) 'createdAt': createdAt,
      };

  String get displayName => name ?? phone ?? email ?? 'Astrobless User';
}

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final CustomerProfile customer;
  final bool isNewUser;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.customer,
    this.isNewUser = false,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        customer: CustomerProfile.fromJson(
            json['customer'] as Map<String, dynamic>),
        isNewUser: json['isNewUser'] as bool? ?? false,
      );
}
