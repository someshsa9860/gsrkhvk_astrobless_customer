import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class ConsultationCallScreen extends ConsumerStatefulWidget {
  const ConsultationCallScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  ConsumerState<ConsultationCallScreen> createState() =>
      _ConsultationCallScreenState();
}

class _ConsultationCallScreenState
    extends ConsumerState<ConsultationCallScreen> {
  RtcEngine? _engine;
  bool _remoteJoined = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _isEnding = false;
  bool _isEnded = false;
  bool _lowBalance = false;
  int _secondsElapsed = 0;
  Timer? _elapsed;
  StreamSubscription? _callEndedSub;
  StreamSubscription? _billingTickSub;
  StreamSubscription? _lowBalanceSub;
  BillingTick? _lastTick;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      if (mounted) {
        setState(() =>
            _error = 'Microphone permission is required for voice calls.');
      }
      return;
    }

    final socket = ref.read(socketServiceProvider);
    socket.joinConsultation(widget.consultationId);

    _callEndedSub = socket.onConsultationEnded
        .where((e) => e['consultationId'] == widget.consultationId)
        .listen((_) => _handleRemoteEnd());

    _billingTickSub = socket.onBillingTick
        .where((t) => t.consultationId == widget.consultationId)
        .listen((tick) {
      if (mounted) setState(() => _lastTick = tick);
    });

    _lowBalanceSub = socket.onLowBalance
        .where((e) => e['consultationId'] == widget.consultationId)
        .listen((_) {
      if (mounted) setState(() => _lowBalance = true);
    });

    _elapsed = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    await _startAgora();
  }

  Future<void> _startAgora() async {
    if (AppConfig.agoraAppId.isEmpty) {
      // No Agora configured — still show the UI but without media
      return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: AppConfig.agoraAppId));
      await _engine!.enableAudio();

      _engine!.registerEventHandler(RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          if (mounted) setState(() => _remoteJoined = true);
        },
        onUserOffline: (connection, uid, reason) {
          if (mounted) setState(() => _remoteJoined = false);
        },
        onError: (err, msg) {
          debugPrint('[Agora] error $err: $msg');
        },
      ));

      await _engine!.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.joinChannel(
        token: '',
        channelId: 'call_${widget.consultationId}',
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile:
              ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (_speakerOn) {
        await _engine!.setEnableSpeakerphone(true);
      }
    } catch (e) {
      debugPrint('[Agora] init error: $e');
    }
  }

  void _handleRemoteEnd() {
    if (_isEnded) return;
    if (mounted) setState(() => _isEnded = true);
    _cleanup();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.pop();
    });
  }

  Future<void> _endCall() async {
    if (_isEnding || _isEnded) return;
    setState(() => _isEnding = true);

    _cleanup();

    try {
      await ref
          .read(apiClientProvider)
          .endConsultation(widget.consultationId, reason: 'customerEnded');
    } catch (e) {
      debugPrint('[CallScreen] endConsultation error: $e');
    }

    if (mounted) {
      setState(() {
        _isEnded = true;
        _isEnding = false;
      });
      context.pop();
    }
  }

  void _cleanup() {
    _elapsed?.cancel();
    _callEndedSub?.cancel();
    _billingTickSub?.cancel();
    _lowBalanceSub?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    ref.read(socketServiceProvider).leaveConsultation(widget.consultationId);
  }

  void _toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
    setState(() {});
  }

  void _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine?.setEnableSpeakerphone(_speakerOn);
    setState(() {});
  }

  String _formatElapsed() {
    final m = _secondsElapsed ~/ 60;
    final s = _secondsElapsed % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    if (_error != null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_off_rounded, size: 64, color: c.error),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 60),

                // ── Avatar area ──────────────────────────────────────────
                Expanded(
                  child: _VoiceCallView(
                    remoteJoined: _remoteJoined,
                    elapsed: _formatElapsed(),
                    tt: tt,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Billing ticker ────────────────────────────────────────
                if (_lastTick != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _BillingBar(
                      tick: _lastTick!,
                      isLow: _lowBalance,
                      tt: tt,
                    ),
                  ),

                if (_lowBalance && _lastTick != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Text(
                          'Low balance — call may end soon',
                          style: tt.labelSmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Controls ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: _muted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        label: _muted ? 'Unmute' : 'Mute',
                        onTap: _toggleMute,
                        active: !_muted,
                      ),
                      _EndCallButton(
                          onTap: _isEnding ? () {} : _endCall),
                      _ControlButton(
                        icon: _speakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: 'Speaker',
                        onTap: _toggleSpeaker,
                        active: _speakerOn,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Top elapsed bar ───────────────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1740).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatElapsed(),
                          style: tt.labelMedium?.copyWith(
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _VoiceCallView extends StatelessWidget {
  const _VoiceCallView({
    required this.remoteJoined,
    required this.elapsed,
    required this.tt,
  });

  final bool remoteJoined;
  final String elapsed;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: const Icon(Icons.person_rounded,
              size: 56, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text(
          remoteJoined ? 'Connected' : 'Connecting...',
          style: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          elapsed,
          style:
              tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BillingBar extends StatelessWidget {
  const _BillingBar({
    required this.tick,
    required this.isLow,
    required this.tt,
  });

  final BillingTick tick;
  final bool isLow;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.error.withValues(alpha: 0.15)
            : const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(20),
        border: isLow
            ? Border.all(
                color: AppColors.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow
                ? Icons.warning_amber_rounded
                : Icons.timer_outlined,
            size: 14,
            color: isLow ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            isLow
                ? 'Low balance — add money to continue'
                : '${(tick.remainingSeconds ~/ 60)}m ${tick.remainingSeconds % 60}s left'
                    ' · ₹${tick.balance.toStringAsFixed(0)}',
            style: tt.labelMedium?.copyWith(
              color: isLow ? AppColors.error : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : const Color(0xFF1A1740),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? AppColors.primary
                    : const Color(0xFF2D2A5E),
              ),
            ),
            child: Icon(
              icon,
              color: active
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style:
                tt.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'End Call',
            style:
                tt.labelSmall?.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
