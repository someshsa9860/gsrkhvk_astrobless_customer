import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../data/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repo, this._ref) : super(const AsyncData(null));

  final AuthRepository _repo;
  final Ref _ref;

  Future<void> sendPhoneOtp(String phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.sendPhoneOtp('+91$phone'));
  }

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.verifyPhoneOtp(phone, otp);
      await _ref.read(authNotifierProvider.notifier).setTokens(
            result.accessToken,
            result.refreshToken,
          );
    });
  }

  Future<void> emailSignup(String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.emailSignup(email: email, password: password, name: name),
    );
  }

  Future<void> emailLogin(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.emailLogin(email, password);
      await _ref.read(authNotifierProvider.notifier).setTokens(
            result.accessToken,
            result.refreshToken,
          );
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref);
});
