import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/auth/domain/auth_models.dart';

void main() {
  group('CustomerProfile.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'cust-1',
        'name': 'Arjun Sharma',
        'phone': '+919876543210',
        'email': 'arjun@example.com',
        'profileImageUrl': 'https://cdn.example.com/arjun.jpg',
        'emailVerified': true,
      };
      final profile = CustomerProfile.fromJson(json);

      expect(profile.id, 'cust-1');
      expect(profile.name, 'Arjun Sharma');
      expect(profile.phone, '+919876543210');
      expect(profile.email, 'arjun@example.com');
      expect(profile.profileImageUrl, 'https://cdn.example.com/arjun.jpg');
      expect(profile.emailVerified, isTrue);
    });

    test('handles nullable fields being absent', () {
      final json = {'id': 'cust-2', 'emailVerified': false};
      final profile = CustomerProfile.fromJson(json);

      expect(profile.id, 'cust-2');
      expect(profile.name, isNull);
      expect(profile.phone, isNull);
      expect(profile.email, isNull);
      expect(profile.profileImageUrl, isNull);
      expect(profile.emailVerified, isFalse);
    });

    test('defaults emailVerified to false when missing', () {
      final profile = CustomerProfile.fromJson({'id': 'cust-3'});
      expect(profile.emailVerified, isFalse);
    });
  });

  group('LoginResult.fromJson', () {
    test('parses tokens and nested customer correctly', () {
      final json = {
        'accessToken': 'access_tok',
        'refreshToken': 'refresh_tok',
        'customer': {
          'id': 'cust-1',
          'name': 'Priya',
          'emailVerified': true,
        },
      };
      final result = LoginResult.fromJson(json);

      expect(result.accessToken, 'access_tok');
      expect(result.refreshToken, 'refresh_tok');
      expect(result.customer.id, 'cust-1');
      expect(result.customer.name, 'Priya');
      expect(result.customer.emailVerified, isTrue);
    });
  });
}
