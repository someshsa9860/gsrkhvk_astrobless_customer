import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/storage/storage_service.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

/// Holds the result of a completed login so screens can read the customer.
class AuthControllerState {
  final bool isLoading;
  final String? error;
  final CustomerProfile? customer;

  const AuthControllerState({
    this.isLoading = false,
    this.error,
    this.customer,
  });

  AuthControllerState copyWith({
    bool? isLoading,
    String? error,
    CustomerProfile? customer,
  }) =>
      AuthControllerState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        customer: customer ?? this.customer,
      );

  AuthControllerState loading() => copyWith(isLoading: true, error: null);
  AuthControllerState withError(String e) =>
      AuthControllerState(isLoading: false, error: e);
}

class AuthController extends StateNotifier<AuthControllerState> {
  AuthController(this._repo, this._ref) : super(const AuthControllerState());

  final AuthRepository _repo;
  final Ref _ref;

  // ─── Phone OTP ───────────────────────────────────────────────────────────

  Future<bool> sendPhoneOtp(String phone) async {
    state = state.loading();
    try {
      await _repo.sendPhoneOtp('+91$phone');
      state = const AuthControllerState();
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    state = state.loading();
    try {
      final result = await _repo.verifyPhoneOtp(phone, otp);
      await _onLoginSuccess(result);
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Email signup ─────────────────────────────────────────────────────────

  Future<bool> emailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.loading();
    try {
      await _repo.emailSignup(email: email, password: password, name: name);
      state = const AuthControllerState();
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Email login (sends OTP first) ───────────────────────────────────────

  Future<bool> sendEmailLoginOtp(String email) async {
    state = state.loading();
    try {
      await _repo.sendEmailOtp(email);
      state = const AuthControllerState();
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    state = state.loading();
    try {
      final result = await _repo.verifyEmailOtp(email, otp);
      await _onLoginSuccess(result);
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Email + password login ───────────────────────────────────────────────

  Future<bool> emailLogin(String email, String password) async {
    state = state.loading();
    try {
      final result = await _repo.emailLogin(email, password);
      await _onLoginSuccess(result);
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Forgot password ─────────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    state = state.loading();
    try {
      await _repo.forgotPassword(email);
      state = const AuthControllerState();
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Google ──────────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    state = state.loading();
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled
        state = const AuthControllerState();
        return false;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        state = state.withError('Google sign-in failed. Please try again.');
        return false;
      }
      final result = await _repo.googleLogin(idToken);
      await _onLoginSuccess(result);
      return true;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Apple ───────────────────────────────────────────────────────────────

  Future<bool> signInWithApple() async {
    state = state.loading();
    try {
      final nonce = _generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256ofString(nonce),
      );

      final name = [
        credential.givenName,
        credential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');

      final result = await _repo.appleLogin(
        identityToken: credential.identityToken!,
        nonce: nonce,
        name: name.isEmpty ? null : name,
      );
      await _onLoginSuccess(result);
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = const AuthControllerState();
        return false;
      }
      state = state.withError('Apple sign-in failed. Please try again.');
      return false;
    } catch (e) {
      state = state.withError(_friendlyError(e));
      return false;
    }
  }

  // ─── Sign out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _ref.read(authNotifierProvider.notifier).signOut();
    await StorageService.instance.clear();
    state = const AuthControllerState();
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _onLoginSuccess(LoginResult result) async {
    // Cache the profile locally for fast app start
    await StorageService.instance.setObject(
      'customer_profile',
      result.customer.toJson(),
      ttl: const Duration(days: 7),
    );
    await _ref.read(authNotifierProvider.notifier).setTokens(
          result.accessToken,
          result.refreshToken,
          customerId: result.customer.id,
        );
    state = AuthControllerState(customer: result.customer);
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('OTP_INVALID')) return 'Incorrect code. Please try again.';
    if (msg.contains('OTP_EXPIRED')) return 'Code expired. Request a new one.';
    if (msg.contains('OTP_ATTEMPTS_EXCEEDED')) {
      return 'Too many attempts. Request a new code.';
    }
    if (msg.contains('RATE_LIMIT')) return 'Too many requests. Try again later.';
    if (msg.contains('EMAIL_NOT_VERIFIED')) {
      return 'Email not verified. Please verify your email first.';
    }
    if (msg.contains('VALIDATION')) return 'Please check your input and try again.';
    if (msg.contains('SocketException') || msg.contains('NetworkException')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('Exception:')) return msg.replaceAll('Exception:', '').trim();
    return 'Something went wrong. Please try again.';
  }

  /// Generates a cryptographically random nonce for Apple Sign-In.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rng = Random.secure();
    return List.generate(length, (_) => charset[rng.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref);
});
