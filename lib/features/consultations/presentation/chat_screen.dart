import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_theme_colors.dart';
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
  bool _isEnding = false;
  String? _lastMessageId;
  bool _lowBalanceDialogShown = false;

  late StreamSubscription<ChatMessage> _msgSub;
  late StreamSubscription<BillingTick> _billingSub;
  late StreamSubscription<Map<String, dynamic>> _endedSub;
  late StreamSubscription<Map<String, dynamic>> _lowBalanceSub;

  late Razorpay _razorpay;
  bool _topupInProgress = false;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onTopupSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onTopupError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});

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
      _showSessionEndedDialog(data['reason'] as String? ?? 'ended');
    });

    _lowBalanceSub = socket.onLowBalance.listen((data) {
      if (data['consultationId'] != widget.consultationId) return;
      if (!mounted || _lowBalanceDialogShown || _isEnded) return;
      _lowBalanceDialogShown = true;
      _showExtendTimeSheet();
    });
  }

  @override
  void dispose() {
    ref.read(socketServiceProvider).leaveConsultation(widget.consultationId);
    _msgSub.cancel();
    _billingSub.cancel();
    _endedSub.cancel();
    _lowBalanceSub.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _razorpay.clear();
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

  Future<void> _endSession() async {
    if (_isEnding || _isEnded) return;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('End Session?', style: tt.titleMedium?.copyWith(color: c.textPrimary)),
        content: Text(
          'You will be charged for time used so far.',
          style: tt.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: c.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isEnding = true);
    try {
      await ref.read(apiClientProvider).endConsultation(
            widget.consultationId,
            reason: 'customerEnded',
          );
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isEnded = true;
        _isEnding = false;
      });
    }
  }

  void _showSessionEndedDialog(String reason) {
    if (!mounted) return;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final reasonText = reason == 'lowBalance'
        ? 'Session ended due to insufficient balance.'
        : 'The session has ended.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.check_circle_outline, color: c.success),
          const SizedBox(width: 8),
          Text('Session Ended', style: tt.titleMedium?.copyWith(color: c.textPrimary)),
        ]),
        content: Text(reasonText, style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: c.primary),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExtendTimeSheet() {
    if (!mounted) return;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(Icons.account_balance_wallet_outlined, size: 40, color: c.error),
            const SizedBox(height: 12),
            Text(
              'Low Balance',
              style: tt.titleLarge?.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your wallet balance is running low. Top up to continue the session.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TopUpButton(
                    label: '₹100',
                    amount: 100,
                    onTap: () { Navigator.pop(context); _startTopup(100); },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopUpButton(
                    label: '₹200',
                    amount: 200,
                    onTap: () { Navigator.pop(context); _startTopup(200); },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopUpButton(
                    label: '₹500',
                    amount: 500,
                    onTap: () { Navigator.pop(context); _startTopup(500); },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _lowBalanceDialogShown = false;
              },
              child: Text('Dismiss', style: TextStyle(color: c.textSecondary)),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Reset so a subsequent lowBalance event can show the sheet again
      _lowBalanceDialogShown = false;
    });
  }

  Future<void> _startTopup(double amount) async {
    if (_topupInProgress) return;
    setState(() => _topupInProgress = true);

    final primaryHex = context.colors.primary.toARGB32().toRadixString(16).substring(2).toUpperCase();
    try {
      final idempotencyKey = _uuid.v4();
      final data = await ref.read(apiClientProvider).initiateTopup(
            amount: amount,
            providerKey: 'razorpay',
            idempotencyKey: idempotencyKey,
          );
      final payload = data['clientPayload'] as Map<String, dynamic>? ?? {};
      _razorpay.open({
        'key': payload['key'] ?? '',
        'amount': amount,
        'currency': 'INR',
        'name': 'Astrobless',
        'description': 'Wallet Top-up',
        'order_id': payload['orderId'] ?? payload['order_id'] ?? '',
        'prefill': payload['prefill'] ?? {},
        'theme': {'color': '#$primaryHex'},
      });
    } catch (e) {
      setState(() => _topupInProgress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: context.colors.error,
        ));
      }
    }
  }

  void _onTopupSuccess(PaymentSuccessResponse response) {
    setState(() => _topupInProgress = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Wallet topped up! Session continues.'),
        backgroundColor: context.colors.success,
      ));
    }
  }

  void _onTopupError(PaymentFailureResponse response) {
    setState(() => _topupInProgress = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: context.colors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final isLow = _remainingSeconds > 0 && _remainingSeconds < 120;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Chat Consultation'),
        actions: [
          if (!_isEnded)
            TextButton.icon(
              icon: Icon(Icons.call_end_rounded, color: c.error, size: 18),
              label: Text('End', style: TextStyle(color: c.error)),
              onPressed: _isEnding ? null : _endSession,
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Billing ticker bar ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: c.card,
            child: Row(
              children: [
                Icon(
                  _isEnded ? Icons.check_circle_outline : Icons.timer_outlined,
                  size: 16,
                  color: _isEnded ? c.success : (isLow ? c.error : c.accent),
                ),
                const SizedBox(width: 6),
                Text(
                  _isEnded ? 'Session ended' : 'Session active',
                  style: tt.labelSmall?.copyWith(color: c.textSecondary),
                ),
                const Spacer(),
                if (_remainingSeconds > 0)
                  Text(
                    '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')} left',
                    style: tt.labelSmall?.copyWith(
                      color: isLow ? c.error : c.textSecondary,
                      fontWeight: isLow ? FontWeight.w700 : null,
                    ),
                  ),
                if (_balance > 0) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isEnded ? null : _showExtendTimeSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLow
                            ? c.error.withValues(alpha: 0.15)
                            : c.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: isLow
                            ? Border.all(color: c.error.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Text(
                        formatCurrency(_balance),
                        style: tt.labelSmall?.copyWith(
                          color: isLow ? c.error : c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Low balance warning banner
          if (isLow && !_isEnded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: c.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: c.error),
                  const SizedBox(width: 6),
                  Text(
                    'Low balance — tap wallet to add money',
                    style: tt.labelSmall?.copyWith(color: c.error),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showExtendTimeSheet,
                    child: Text(
                      'Add Money',
                      style: tt.labelSmall?.copyWith(
                        color: c.error,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
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

          // ── Input bar or ended footer ──────────────────────────────────
          if (!_isEnded)
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
                        controller: _messageCtrl,
                        style: tt.bodyMedium?.copyWith(color: c.textPrimary),
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) => _sendMessage(),
                        onChanged: (v) {
                          if (v.isNotEmpty) {
                            ref.read(socketServiceProvider).sendTypingStart(widget.consultationId);
                          } else {
                            ref.read(socketServiceProvider).sendTypingStop(widget.consultationId);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: tt.bodyMedium?.copyWith(
                              color: c.textSecondary.withValues(alpha: 0.5)),
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
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [c.primary, c.primary.withValues(alpha: 0.7)]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  Text(
                    'This consultation has ended.',
                    textAlign: TextAlign.center,
                    style: tt.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.star_outline, color: Colors.white),
                      label: const Text('Rate this session',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopUpButton extends StatelessWidget {
  const _TopUpButton({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  final String label;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: c.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.primary.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

String _hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    final isMe = message.senderType == 'customer';

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
          color: isMe
              ? c.primary.withValues(alpha: 0.25)
              : c.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: Border.all(
            color: isMe
                ? c.primary.withValues(alpha: 0.4)
                : c.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body ?? '',
              style: tt.bodyMedium?.copyWith(color: c.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              _hhmm(message.createdAt),
              style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  color: c.textSecondary.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
