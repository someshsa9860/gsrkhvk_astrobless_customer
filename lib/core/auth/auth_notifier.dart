import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../realtime/socket_service.dart';
import 'token_storage.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(AuthState.unknown);

  final Ref _ref;

  Future<void> init() async {
    final hasTokens = await TokenStorage.hasTokens();
    if (hasTokens) {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken != null) {
        _ref.read(socketServiceProvider).connect(accessToken);
      }
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> setTokens(String access, String refresh) async {
    await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
    _ref.read(socketServiceProvider).connect(access);
    state = AuthState.authenticated;
  }

  Future<void> signOut() async {
    _ref.read(socketServiceProvider).disconnect();
    await TokenStorage.clearTokens();
    state = AuthState.unauthenticated;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
