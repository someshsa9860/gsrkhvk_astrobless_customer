import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);
  final ApiClient _client;

  Future<List<AppNotification>> fetchNotifications() async {
    final list = await _client.fetchNotifications();
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) => _client.markNotificationRead(id);

  Future<void> markAllRead() => _client.markAllNotificationsRead();
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.read(apiClientProvider));
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.read(notificationsRepositoryProvider).fetchNotifications();
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((n) => n.id == id ? n.copyWithRead() : n)
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    state = AsyncData(
      (state.valueOrNull ?? []).map((n) => n.copyWithRead()).toList(),
    );
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsNotifierProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
