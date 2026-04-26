import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_controller.dart';

/// Shared OTP verification screen for both phone and email OTP flows.
///
/// [type] is either `'phone'` or `'email'`.
/// [identifier] is the phone number (E.164) or email address.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.identifier,
    required this.type,
  });

  final String identifier;

  /// `'phone'` or `'email'`
  final String type;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _pinCtrl = TextEditingController();
  final _pinFocusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _resendSeconds = 60;
  Timer? _timer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
    _startTimer();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _pinFocusNode.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _verify(String otp) async {
    if (otp.length < 6) return;
    setState(() => _hasError = false);

    final ctrl = ref.read(authControllerProvider.notifier);
    bool ok;
    if (widget.type == 'phone') {
      ok = await ctrl.verifyPhoneOtp(widget.identifier, otp);
    } else {
      ok = await ctrl.verifyEmailOtp(widget.identifier, otp);
    }

    if (!mounted) return;
    if (!ok) {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0);
      _pinCtrl.clear();
      _pinFocusNode.requestFocus();
    }
    // On success, router redirect fires automatically via authNotifier state change
  }

  Future<void> _resend() async {
    _pinCtrl.clear();
    setState(() => _hasError = false);

    final ctrl = ref.read(authControllerProvider.notifier);
    bool ok;
    if (widget.type == 'phone') {
      ok = await ctrl.sendPhoneOtp(widget.identifier.replaceFirst('+91', ''));
    } else {
      ok = await ctrl.sendEmailLoginOtp(widget.identifier);
    }
    if (ok && mounted) _startTimer();
  }

  String get _maskedIdentifier {
    if (widget.type == 'phone') {
      final digits = widget.identifier.replaceAll('+91', '');
      return '+91 ${digits.substring(0, 2)}*** ***${digits.substring(7)}';
    }
    final parts = widget.identifier.split('@');
    if (parts.length == 2) {
      final name = parts[0];
      final masked = name.length > 2
          ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
          : name;
      return '$masked@${parts[1]}';
    }
    return widget.identifier;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    final basePinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: tt.headlineSmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border, width: 1.5),
      ),
    );

    final focusedTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration!.copyWith(
        border: Border.all(color: c.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    final errorTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration!.copyWith(
        border: Border.all(color: c.error, width: 2),
        color: c.error.withValues(alpha: 0.08),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: c.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Text(
                widget.type == 'phone' ? 'Verify your\nnumber' : 'Enter\nOTP',
                style: tt.headlineMedium?.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  style: tt.bodyMedium?.copyWith(color: c.textSecondary),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: _maskedIdentifier,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 48),

              // Pin input with shake animation
              Center(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: Pinput(
                    controller: _pinCtrl,
                    focusNode: _pinFocusNode,
                    length: 6,
                    defaultPinTheme: _hasError ? errorTheme : basePinTheme,
                    focusedPinTheme: _hasError ? errorTheme : focusedTheme,
                    submittedPinTheme: _hasError
                        ? errorTheme
                        : basePinTheme.copyWith(
                            decoration: basePinTheme.decoration!.copyWith(
                              color: c.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                  color: c.primary.withValues(alpha: 0.5)),
                            ),
                          ),
                    onCompleted: _verify,
                    autofocus: true,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 2,
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    delay: 200.ms,
                  ),

              const SizedBox(height: 16),

              // Error text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasError
                    ? Center(
                        key: const ValueKey('error'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: c.error, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              ref.read(authControllerProvider).error ??
                                  'Incorrect code',
                              style: tt.bodySmall
                                  ?.copyWith(color: c.error),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-error')),
              ),

              const SizedBox(height: 32),

              // Verify button
              AppButton(
                label: 'Verify',
                onPressed: state.isLoading
                    ? null
                    : () => _verify(_pinCtrl.text),
                loading: state.isLoading,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Resend
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _resendSeconds > 0
                      ? RichText(
                          key: const ValueKey('countdown'),
                          text: TextSpan(
                            style: tt.bodyMedium
                                ?.copyWith(color: c.textSecondary),
                            children: [
                              const TextSpan(text: 'Resend code in '),
                              TextSpan(
                                text:
                                    '0:${_resendSeconds.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: c.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextButton(
                          key: const ValueKey('resend'),
                          onPressed: state.isLoading ? null : _resend,
                          style: TextButton.styleFrom(
                            foregroundColor: c.primary,
                          ),
                          child: const Text('Resend OTP'),
                        ),
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}
