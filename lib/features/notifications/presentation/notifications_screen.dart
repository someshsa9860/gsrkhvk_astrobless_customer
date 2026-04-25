import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final asyncNotifications = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: asyncNotifications.valueOrNull?.any((n) => !n.isRead) == true
                ? () => ref.read(notificationsNotifierProvider.notifier).markAllRead()
                : null,
            child: Text('Mark all read',
                style: tt.labelMedium?.copyWith(
                  color: asyncNotifications.valueOrNull?.any((n) => !n.isRead) == true
                      ? AppColors.primary
                      : AppColors.textDisabled,
                )),
          ),
        ],
      ),
      body: asyncNotifications.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _EmptyState(message: 'Could not load notifications.\nPull to refresh.'),
        data: (notifications) {
          if (notifications.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsNotifierProvider.future),
            color: AppColors.primary,
            backgroundColor: AppColors.cardDark,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.borderDark, indent: 64),
              itemBuilder: (_, i) => _NotificationTile(
                notification: notifications[i],
                index: i,
                onTap: () {
                  if (!notifications[i].isRead) {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .markRead(notifications[i].id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
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
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? AppColors.primary.withValues(alpha: 0.06)
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
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(notification.type),
                size: 18,
                color: unread ? AppColors.primary : AppColors.textSecondary,
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
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body!,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(notification.createdAt),
                    style: tt.labelSmall
                        ?.copyWith(color: AppColors.textDisabled, fontSize: 10),
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
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
