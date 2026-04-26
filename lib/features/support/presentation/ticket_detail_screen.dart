import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/support_repository.dart';
import '../domain/support_models.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});
  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(ticketDetailProvider(widget.ticketId).notifier)
          .sendMessage(body);
      _replyCtrl.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: context.colors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _closeTicket(SupportTicket ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close ticket?'),
        content: const Text('Mark this ticket as closed. You won\'t be able to reply.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(ticketDetailProvider(widget.ticketId).notifier).close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ticket closed'),
        ));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final asyncTicket = ref.watch(ticketDetailProvider(widget.ticketId));

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: asyncTicket.when(
          data: (t) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.ticketNumber,
                  style: tt.labelSmall?.copyWith(
                      color: c.textSecondary, fontFamily: 'monospace')),
              Text(t.subject,
                  style: tt.titleSmall, overflow: TextOverflow.ellipsis),
            ],
          ),
          loading: () => const Text('Ticket'),
          error: (_, __) => const Text('Ticket'),
        ),
        actions: [
          asyncTicket.whenOrNull(
            data: (t) => t.isOpen
                ? TextButton(
                    onPressed: () => _closeTicket(t),
                    child: Text('Close',
                        style: TextStyle(color: c.error, fontWeight: FontWeight.w600)),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: asyncTicket.when(
        loading: () => Center(child: CircularProgressIndicator(color: c.primary)),
        error: (_, __) => Center(child: Text('Failed to load ticket', style: tt.bodyMedium)),
        data: (ticket) => Column(
          children: [
            // ── Ticket info banner ─────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(ticket.description,
                        style: tt.bodySmall?.copyWith(color: c.textSecondary),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusChip(status: ticket.status, c: c),
                      const SizedBox(height: 4),
                      Text(ticket.category,
                          style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Messages ───────────────────────────────────────────────
            Expanded(
              child: ticket.messages.isEmpty
                  ? Center(
                      child: Text('No replies yet.\nA support agent will respond soon.',
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: ticket.messages.length,
                      itemBuilder: (_, i) => _MessageBubble(
                        message: ticket.messages[i],
                        c: c,
                        tt: tt,
                      ),
                    ),
            ),

            // ── Reply bar ──────────────────────────────────────────────
            if (ticket.isOpen)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyCtrl,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: tt.bodyMedium?.copyWith(color: c.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Type a reply…',
                            hintStyle: tt.bodyMedium
                                ?.copyWith(color: c.textSecondary.withValues(alpha: 0.5)),
                            filled: true,
                            fillColor: c.card,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: c.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: c.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: c.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sending ? null : _send,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [c.primary, c.primary.withValues(alpha: 0.7)]),
                            shape: BoxShape.circle,
                          ),
                          child: _sending
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: c.surface,
                child: Center(
                  child: Text(
                    'This ticket is ${ticket.status}.',
                    style: tt.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.c,
    required this.tt,
  });

  final SupportMessage message;
  final AppThemeColors c;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromCustomer;
    final time = _hhmm(message.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? c.primary.withValues(alpha: 0.2) : c.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: Border.all(
            color: isMe ? c.primary.withValues(alpha: 0.3) : c.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Support Agent',
                    style: tt.labelSmall?.copyWith(
                        color: c.accent, fontWeight: FontWeight.w600)),
              ),
            Text(message.body,
                style: tt.bodySmall?.copyWith(color: c.textPrimary, height: 1.4)),
            const SizedBox(height: 4),
            Text(time,
                style: tt.labelSmall?.copyWith(
                    fontSize: 10,
                    color: c.textSecondary.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.c});
  final String status;
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'open' => c.primary,
      'inProgress' => c.accent,
      'waitingOnUser' => c.warning,
      'resolved' => c.success,
      _ => c.textSecondary,
    };
    final label = switch (status) {
      'inProgress' => 'In Progress',
      'waitingOnUser' => 'Waiting',
      String s => s[0].toUpperCase() + s.substring(1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
