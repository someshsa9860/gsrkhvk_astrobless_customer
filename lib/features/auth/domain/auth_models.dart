class CustomerProfile {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? profileImageUrl;
  final bool emailVerified;

  const CustomerProfile({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.profileImageUrl,
    this.emailVerified = false,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        id: json['id'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        emailVerified: json['emailVerified'] as bool? ?? false,
      );
}

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final CustomerProfile customer;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.customer,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        customer: CustomerProfile.fromJson(json['customer'] as Map<String, dynamic>),
      );
}
