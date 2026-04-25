import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';

class ConsultationChatScreen extends ConsumerStatefulWidget {
  const ConsultationChatScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  ConsumerState<ConsultationChatScreen> createState() =>
      _ConsultationChatScreenState();
}

class _ConsultationChatScreenState
    extends ConsumerState<ConsultationChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  double _balance = 0;
  int _remainingSeconds = 0;
  bool _isEnded = false;
  String? _lastMessageId;

  late StreamSubscription<ChatMessage> _msgSub;
  late StreamSubscription<BillingTick> _billingSub;
  late StreamSubscription<Map<String, dynamic>> _endedSub;

  @override
  void initState() {
    super.initState();
    final socket = ref.read(socketServiceProvider);
    socket.joinConsultation(widget.consultationId);

    _msgSub = socket.onNewMessage.listen((msg) {
      if (msg.consultationId != widget.consultationId) return;
      if (!mounted) return;
      setState(() {
        _messages.add(msg);
        _lastMessageId = msg.id;
      });
      _scrollToBottom();
      if (_lastMessageId != null) {
        socket.sendReadReceipt(widget.consultationId, _lastMessageId!);
      }
    });

    _billingSub = socket.onBillingTick.listen((tick) {
      if (tick.consultationId != widget.consultationId) return;
      if (!mounted) return;
      setState(() {
        _balance = tick.balance;
        _remainingSeconds = tick.remainingSeconds;
      });
    });

    _endedSub = socket.onConsultationEnded.listen((data) {
      if (data['consultationId'] != widget.consultationId) return;
      if (!mounted) return;
      setState(() => _isEnded = true);
    });
  }

  @override
  void dispose() {
    ref.read(socketServiceProvider).leaveConsultation(widget.consultationId);
    _msgSub.cancel();
    _billingSub.cancel();
    _endedSub.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final body = _messageCtrl.text.trim();
    if (body.isEmpty || _isEnded) return;
    final clientMsgId = _uuid.v4();
    ref.read(socketServiceProvider).sendMessage(
          consultationId: widget.consultationId,
          body: body,
          clientMsgId: clientMsgId,
        );
    _messageCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {},
            tooltip: 'Switch to Call',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Billing ticker bar ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardDark,
            child: Row(
              children: [
                Icon(
                  _isEnded ? Icons.check_circle_outline : Icons.timer_outlined,
                  size: 16,
                  color: _isEnded ? AppColors.success : AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  _isEnded ? 'Session ended' : 'Session active',
                  style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (_remainingSeconds > 0)
                  Text(
                    '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} left',
                    style: tt.labelSmall?.copyWith(
                      color: _remainingSeconds < 120
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                if (_balance > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatCurrency(_balance),
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Messages list ──────────────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          _isEnded ? 'Consultation ended' : 'Connecting...',
                          style: tt.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consultation ID: ${widget.consultationId}',
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) =>
                        _ChatBubble(message: _messages[i]),
                  ),
          ),

          // ── Input bar ──────────────────────────────────────────────────
          if (!_isEnded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              decoration: const BoxDecoration(
                color: AppColors.cardDark,
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      style: tt.bodyMedium,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (v) {
                        if (v.isNotEmpty) {
                          ref
                              .read(socketServiceProvider)
                              .sendTypingStart(widget.consultationId);
                        } else {
                          ref
                              .read(socketServiceProvider)
                              .sendTypingStop(widget.consultationId);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: tt.bodyMedium
                            ?.copyWith(color: AppColors.textDisabled),
                        filled: true,
                        fillColor: AppColors.surfaceDark,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppColors.bgDark, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Text(
                'This consultation has ended.',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isCustomer = message.senderType == 'customer';

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCustomer ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isCustomer ? 16 : 4),
            bottomRight: Radius.circular(isCustomer ? 4 : 16),
          ),
        ),
        child: Text(
          message.body ?? '',
          style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
