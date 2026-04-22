import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

/// Repository for all authentication operations.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in [Endpoints.auth].
class AuthRepository {
  AuthRepository(this._client);
  final ApiClient _client;

  /// Sends a 6-digit SMS OTP to [phone].
  Future<void> sendPhoneOtp(String phone) async {
    await _client.sendPhoneOtp(phone);
  }

  /// Verifies [otp] for [phone] and returns access + refresh tokens.
  Future<LoginResult> verifyPhoneOtp(String phone, String otp) async {
    final data = await _client.verifyPhoneOtp(phone, otp);
    return LoginResult.fromJson(data);
  }

  /// Creates a new account with email + password and triggers email OTP.
  Future<void> emailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    await _client.emailSignup(email: email, password: password, name: name);
  }

  /// Verifies the email OTP sent during sign-up and returns tokens.
  Future<LoginResult> verifyEmailOtp(String email, String otp) async {
    final data = await _client.verifyEmailOtp(email, otp);
    return LoginResult.fromJson(data);
  }

  /// Authenticates with email + password.
  Future<LoginResult> emailLogin(String email, String password) async {
    final data = await _client.emailLogin(email, password);
    return LoginResult.fromJson(data);
  }

  /// Authenticates via Google ID token.
  Future<LoginResult> googleLogin(String idToken) async {
    final data = await _client.googleLogin(idToken);
    return LoginResult.fromJson(data);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
