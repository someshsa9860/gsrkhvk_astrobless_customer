import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._client);
  final ApiClient _client;

  Future<void> sendPhoneOtp(String phone) async {
    await _client.sendPhoneOtp(phone);
  }

  Future<LoginResult> verifyPhoneOtp(String phone, String otp) async {
    final data = await _client.verifyPhoneOtp(phone, otp);
    return LoginResult.fromJson(data);
  }

  Future<void> emailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    await _client.emailSignup(email: email, password: password, name: name);
  }

  /// Sends an email OTP for login (not signup). Used by the email-first login flow.
  Future<void> sendEmailOtp(String email) async {
    await _client.sendEmailLoginOtp(email);
  }

  Future<LoginResult> verifyEmailOtp(String email, String otp) async {
    final data = await _client.verifyEmailOtp(email, otp);
    return LoginResult.fromJson(data);
  }

  Future<LoginResult> emailLogin(String email, String password) async {
    final data = await _client.emailLogin(email, password);
    return LoginResult.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await _client.forgotPassword(email);
  }

  Future<LoginResult> googleLogin(String idToken) async {
    final data = await _client.googleLogin(idToken);
    return LoginResult.fromJson(data);
  }

  Future<LoginResult> appleLogin({
    required String identityToken,
    required String nonce,
    String? name,
  }) async {
    final data = await _client.appleLogin(
      identityToken: identityToken,
      nonce: nonce,
      name: name,
    );
    return LoginResult.fromJson(data);
  }

  Future<void> logout(String refreshToken) async {
    await _client.logout(refreshToken);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
