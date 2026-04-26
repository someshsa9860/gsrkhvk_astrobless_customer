import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../realtime/socket_service.dart';
import 'token_storage.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(AuthState.unknown);

  final Ref _ref;

  Future<void> init() async {
    try {
      debugPrint('[Auth] init started');
      final hasTokens = await TokenStorage.hasTokens();
      debugPrint('[Auth] hasTokens=$hasTokens');
      if (hasTokens) {
        final accessToken = await TokenStorage.getAccessToken();
        if (accessToken != null) {
          try {
            _ref.read(socketServiceProvider).connect(accessToken);
          } catch (e) {
            debugPrint('[Auth] socket connect error (ignored): $e');
          }
        }
        debugPrint('[Auth] → authenticated');
        state = AuthState.authenticated;
      } else {
        debugPrint('[Auth] → unauthenticated');
        state = AuthState.unauthenticated;
      }
    } catch (e, st) {
      debugPrint('[Auth] init error: $e\n$st');
      state = AuthState.unauthenticated;
    }
  }

  Future<void> setTokens(String access, String refresh, {String? customerId}) async {
    await TokenStorage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
      customerId: customerId,
    );
    try {
      _ref.read(socketServiceProvider).connect(access);
    } catch (_) {}
    if (customerId != null) {
      await _subscribeFcmTopic(customerId);
    }
    state = AuthState.authenticated;
  }

  Future<void> signOut() async {
    final customerId = await TokenStorage.getCustomerId();
    if (customerId != null) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(customerId);
        debugPrint('[FCM] unsubscribed from topic: $customerId');
      } catch (e) {
        debugPrint('[FCM] topic unsubscribe failed: $e');
      }
    }
    _ref.read(socketServiceProvider).disconnect();
    await TokenStorage.clearTokens();
    state = AuthState.unauthenticated;
  }

  Future<void> _subscribeFcmTopic(String customerId) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(customerId);
      debugPrint('[FCM] subscribed to topic: $customerId');
    } catch (e) {
      debugPrint('[FCM] topic subscribe failed: $e');
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
