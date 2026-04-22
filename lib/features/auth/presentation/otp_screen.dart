import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinCtrl = TextEditingController();
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _verify(String otp) async {
    if (otp.length < 6) return;
    await ref.read(authControllerProvider.notifier).verifyPhoneOtp(widget.phone, otp);
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      _showError(state.error.toString());
      _pinCtrl.clear();
    }
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).sendPhoneOtp(widget.phone);
    _startTimer();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg.replaceAll('Exception:', '').trim()),
      backgroundColor: AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final tt = Theme.of(context).textTheme;

    final pinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Enter OTP', style: tt.headlineSmall)
                  .animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Sent to ${widget.phone}',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  controller: _pinCtrl,
                  length: 6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: _verify,
                  autofocus: true,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              AppButton(
                label: 'Verify',
                onPressed: () => _verify(_pinCtrl.text),
                loading: state.isLoading,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                        style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend OTP'),
                      ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}
