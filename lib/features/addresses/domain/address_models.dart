class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;

  factory CustomerAddress.fromJson(Map<String, dynamic> json) => CustomerAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        line1: json['line1'] as String,
        line2: json['line2'] as String?,
        city: json['city'] as String,
        state: json['state'] as String,
        pincode: json['pincode'] as String,
        country: json['country'] as String? ?? 'India',
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String get fullAddress {
    final parts = [line1, if (line2 != null && line2!.isNotEmpty) line2!, city, state, pincode];
    return parts.join(', ');
  }
}
