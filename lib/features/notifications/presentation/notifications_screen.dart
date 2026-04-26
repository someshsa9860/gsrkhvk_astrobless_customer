import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final asyncNotifications = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: asyncNotifications.valueOrNull?.any((n) => !n.isRead) == true
                ? () => ref.read(notificationsNotifierProvider.notifier).markAllRead()
                : null,
            child: Text('Mark all read',
                style: tt.labelMedium?.copyWith(
                  color: asyncNotifications.valueOrNull?.any((n) => !n.isRead) == true
                      ? c.primary
                      : c.textSecondary.withValues(alpha: 0.4),
                )),
          ),
        ],
      ),
      body: asyncNotifications.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: c.primary),
        ),
        error: (_, __) => _EmptyState(message: 'Could not load notifications.\nPull to refresh.'),
        data: (notifications) {
          if (notifications.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsNotifierProvider.future),
            color: c.primary,
            backgroundColor: c.card,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: c.border, indent: 64),
              itemBuilder: (_, i) => _NotificationTile(
                notification: notifications[i],
                index: i,
                onTap: () {
                  final n = notifications[i];
                  if (!n.isRead) {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .markRead(n.id);
                  }
                  _navigateForNotification(context, n);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

void _navigateForNotification(BuildContext context, AppNotification notification) {
  switch (notification.type) {
    case 'consultation':
      final id = notification.data?['consultationId'] as String?;
      if (id != null) {
        context.push(AppRoutes.consultationChat(id));
      } else {
        context.push(AppRoutes.chat);
      }
    case 'wallet':
      context.push(AppRoutes.wallet);
    case 'kundli':
      context.push(AppRoutes.kundliList);
    case 'horoscope':
      context.push(AppRoutes.horoscope);
    case 'call':
      context.push(AppRoutes.call);
    default:
      break;
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.index,
    required this.onTap,
  });

  final AppNotification notification;
  final int index;
  final VoidCallback onTap;

  IconData _iconFor(String type) => switch (type) {
        'consultation' => Icons.chat_bubble_outline,
        'wallet' => Icons.account_balance_wallet_outlined,
        'kundli' => Icons.auto_stories_outlined,
        'horoscope' => Icons.star_outline,
        'call' => Icons.phone_outlined,
        _ => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? c.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: unread
                    ? c.primary.withValues(alpha: 0.15)
                    : c.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(notification.type),
                size: 18,
                color: unread ? c.primary : c.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight:
                                unread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body!,
                      style: tt.bodySmall?.copyWith(color: c.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(notification.createdAt),
                    style: tt.labelSmall?.copyWith(
                        color: c.textSecondary.withValues(alpha: 0.5),
                        fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Notifications', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            message ?? "You're all caught up!\nNew notifications will appear here.",
            style: tt.bodySmall?.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
