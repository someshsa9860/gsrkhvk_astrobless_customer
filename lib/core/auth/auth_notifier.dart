import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_storage.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unknown);

  Future<void> init() async {
    final hasTokens = await TokenStorage.hasTokens();
    state = hasTokens ? AuthState.authenticated : AuthState.unauthenticated;
  }

  Future<void> setTokens(String access, String refresh) async {
    await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
    state = AuthState.authenticated;
  }

  Future<void> signOut() async {
    await TokenStorage.clearTokens();
    state = AuthState.unauthenticated;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
