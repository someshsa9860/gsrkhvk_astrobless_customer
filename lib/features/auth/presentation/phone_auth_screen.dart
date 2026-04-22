import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_controller.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).sendPhoneOtp(_phoneCtrl.text.trim());
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      _showError(state.error.toString());
      return;
    }
    if (mounted) {
      context.push('/auth/otp', extra: {'phone': '+91${_phoneCtrl.text.trim()}'});
    }
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.auto_awesome, size: 48, color: AppColors.accent)
                  .animate().scale(duration: 400.ms),
              const SizedBox(height: 24),
              Text('Welcome to\nAstrobless', style: tt.headlineLarge)
                  .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Your cosmic guide to clarity',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              Text('Mobile Number',
                      style: tt.labelMedium?.copyWith(color: AppColors.textSecondary))
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 6),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: Validators.phone,
                  decoration: InputDecoration(
                    hintText: '9876543210',
                    prefixText: '+91  ',
                    prefixStyle:
                        tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
                    prefixIcon:
                        const Icon(Icons.phone_outlined, size: 18),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 24),
              AppButton(
                label: 'Send OTP',
                onPressed: _submit,
                loading: state.isLoading,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/auth/email'),
                  child: Text(
                    'Use Email instead',
                    style: tt.bodyMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: tt.labelSmall?.copyWith(color: AppColors.textDisabled),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
