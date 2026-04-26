import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/support_repository.dart';
import '../domain/support_models.dart';
import 'new_ticket_screen.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final asyncTickets = ref.watch(ticketsNotifierProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Help & Support'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewTicketScreen()),
          );
          if (created == true) {
            ref.read(ticketsNotifierProvider.notifier).refresh();
          }
        },
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ticketsNotifierProvider.notifier).refresh(),
        color: c.primary,
        backgroundColor: c.card,
        child: asyncTickets.when(
          loading: () => ListView(
            children: List.generate(4, (i) => _TicketSkeleton(c: c)),
          ),
          error: (_, __) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: c.error),
                const SizedBox(height: 12),
                Text('Could not load tickets', style: tt.bodyLarge),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.refresh(ticketsNotifierProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (tickets) {
            if (tickets.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🛎️', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 20),
                      Text('No support tickets yet',
                          style: tt.titleMedium?.copyWith(color: c.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "New Ticket" to get help from our team.\nAvg response time: under 2 hours.',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TicketCard(
                ticket: tickets[i],
                index: i,
                onTap: () => context.push(AppRoutes.supportTicketDetail(tickets[i].id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.index,
    required this.onTap,
  });

  final SupportTicket ticket;
  final int index;
  final VoidCallback onTap;

  Color _statusColor(String status, AppThemeColors c) => switch (status) {
        'open' => c.primary,
        'inProgress' => c.accent,
        'waitingOnUser' => c.warning,
        'resolved' => c.success,
        _ => c.textSecondary,
      };

  Color _priorityColor(String priority, AppThemeColors c) => switch (priority) {
        'urgent' => c.error,
        'high' => c.warning,
        _ => c.accent,
      };

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final statusColor = _statusColor(ticket.status, c);
    final priorityColor = _priorityColor(ticket.priority, c);

    final statusLabel = switch (ticket.status) {
      'inProgress' => 'In Progress',
      'waitingOnUser' => 'Waiting',
      String s => s[0].toUpperCase() + s.substring(1),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(ticket.ticketNumber,
                    style: tt.labelSmall?.copyWith(color: c.textSecondary, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(ticket.priority,
                    style: tt.labelSmall?.copyWith(color: priorityColor)),
                const Spacer(),
                Text(_formatDate(ticket.createdAt),
                    style: tt.labelSmall?.copyWith(color: c.textSecondary)),
              ],
            ),
            if (ticket.messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: c.surface, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  ticket.messages.last.body,
                  style: tt.labelSmall?.copyWith(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 60)).fadeIn().slideY(begin: 0.08),
    );
  }
}

class _TicketSkeleton extends StatelessWidget {
  const _TicketSkeleton({required this.c});
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 14, width: 220,
              decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 8),
          Container(height: 10, width: 120,
              decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(6))),
        ]),
      );
}
