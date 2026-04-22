import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_app/core/network/api_client.dart';
import 'package:user_app/features/auth/data/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient client;
  late AuthRepository repo;

  final loginData = {
    'accessToken': 'access_abc',
    'refreshToken': 'refresh_xyz',
    'customer': {
      'id': 'cust-1',
      'name': 'Ravi Kumar',
      'phone': '+919999999999',
      'emailVerified': false,
    },
  };

  setUp(() {
    client = MockApiClient();
    repo = AuthRepository(client);
  });

  group('sendPhoneOtp', () {
    test('delegates to ApiClient and completes without error', () async {
      when(() => client.sendPhoneOtp(any())).thenAnswer((_) async {});

      await expectLater(repo.sendPhoneOtp('+919876543210'), completes);
      verify(() => client.sendPhoneOtp('+919876543210')).called(1);
    });

    test('propagates exception when client throws', () async {
      when(() => client.sendPhoneOtp(any())).thenThrow(Exception('network'));

      await expectLater(
        repo.sendPhoneOtp('+919000000000'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('verifyPhoneOtp', () {
    test('returns LoginResult with correct tokens', () async {
      when(() => client.verifyPhoneOtp(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.verifyPhoneOtp('+919999999999', '123456');

      expect(result.accessToken, 'access_abc');
      expect(result.refreshToken, 'refresh_xyz');
      expect(result.customer.id, 'cust-1');
      expect(result.customer.name, 'Ravi Kumar');
    });

    test('passes phone and otp to client', () async {
      when(() => client.verifyPhoneOtp(any(), any()))
          .thenAnswer((_) async => loginData);

      await repo.verifyPhoneOtp('+918888888888', '654321');

      verify(() => client.verifyPhoneOtp('+918888888888', '654321')).called(1);
    });
  });

  group('emailSignup', () {
    test('delegates all fields to client', () async {
      when(() => client.emailSignup(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async {});

      await repo.emailSignup(
        email: 'user@example.com',
        password: 'Secret123',
        name: 'Meena',
      );

      verify(() => client.emailSignup(
            email: 'user@example.com',
            password: 'Secret123',
            name: 'Meena',
          )).called(1);
    });
  });

  group('verifyEmailOtp', () {
    test('returns LoginResult from client data', () async {
      when(() => client.verifyEmailOtp(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.verifyEmailOtp('user@example.com', '789012');

      expect(result.accessToken, 'access_abc');
      expect(result.customer.id, 'cust-1');
    });
  });

  group('emailLogin', () {
    test('returns LoginResult from client data', () async {
      when(() => client.emailLogin(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.emailLogin('user@example.com', 'Secret123');

      expect(result.refreshToken, 'refresh_xyz');
      expect(result.customer.name, 'Ravi Kumar');
    });

    test('propagates exception on bad credentials', () async {
      when(() => client.emailLogin(any(), any())).thenThrow(Exception('401'));

      await expectLater(
        repo.emailLogin('bad@example.com', 'wrong'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('googleLogin', () {
    test('returns LoginResult from idToken', () async {
      when(() => client.googleLogin(any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.googleLogin('google_id_token_xyz');

      expect(result.accessToken, 'access_abc');
      verify(() => client.googleLogin('google_id_token_xyz')).called(1);
    });
  });
}
