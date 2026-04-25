import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_controller.dart';

/// Email authentication screen.
///
/// Tab 0 — Login: email → sends email OTP → navigates to OtpScreen.
/// Tab 1 — Register: name + email + password → backend sends email OTP → OtpScreen.
/// Forgot password link available on the login tab.
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // Login
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();

  // Register
  final _regFormKey = GlobalKey<FormState>();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  int _passwordStrength = 0; // 0–3

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _regPasswordCtrl.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final p = _regPasswordCtrl.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (mounted) setState(() => _passwordStrength = score);
  }

  // ─── Login: send OTP ─────────────────────────────────────────────────────

  Future<void> _loginSendOtp() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final email = _loginEmailCtrl.text.trim();
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendEmailLoginOtp(email);
    if (ok && mounted) {
      context.push(AppRoutes.authOtp, extra: {'phone': email, 'type': 'email'});
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────

  Future<void> _register() async {
    if (!_regFormKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).emailSignup(
          email: _regEmailCtrl.text.trim(),
          password: _regPasswordCtrl.text,
          name: _regNameCtrl.text.trim(),
        );
    if (ok && mounted) {
      context.push(AppRoutes.authOtp, extra: {
        'phone': _regEmailCtrl.text.trim(),
        'type': 'email',
      });
    }
  }

  // ─── Forgot password ─────────────────────────────────────────────────────

  Future<void> _forgotPassword() async {
    final email = _loginEmailCtrl.text.trim();
    if (email.isEmpty || Validators.email(email) != null) {
      _showSnack('Enter a valid email address first', isError: true);
      return;
    }
    final ok =
        await ref.read(authControllerProvider.notifier).forgotPassword(email);
    if (ok && mounted) {
      _showSnack('Reset code sent to $email');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    Get.showSnackbar(GetSnackBar(
      message: msg,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final tt = Theme.of(context).textTheme;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _showSnack(next.error!, isError: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Email Sign In',
            style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Register'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _LoginTab(
            formKey: _loginFormKey,
            emailCtrl: _loginEmailCtrl,
            isLoading: state.isLoading,
            onSubmit: _loginSendOtp,
            onForgotPassword: _forgotPassword,
          ).animate().fadeIn(),
          _RegisterTab(
            formKey: _regFormKey,
            nameCtrl: _regNameCtrl,
            emailCtrl: _regEmailCtrl,
            passwordCtrl: _regPasswordCtrl,
            isLoading: state.isLoading,
            obscurePassword: _obscurePassword,
            passwordStrength: _passwordStrength,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onSubmit: _register,
          ).animate().fadeIn(),
        ],
      ),
    );
  }
}

// ─── Login tab ────────────────────────────────────────────────────────────────

class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign in with email',
                style: tt.titleLarge?.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text("We'll send you a one-time code",
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            _FieldLabel('Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Send OTP',
              onPressed: isLoading ? null : onSubmit,
              loading: isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary),
                child: const Text('Forgot password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Register tab ─────────────────────────────────────────────────────────────

class _RegisterTab extends StatelessWidget {
  const _RegisterTab({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.obscurePassword,
    required this.passwordStrength,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final bool obscurePassword;
  final int passwordStrength;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create your account',
                style: tt.titleLarge?.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Join millions seeking cosmic guidance',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            _FieldLabel('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameCtrl,
              validator: (v) => Validators.required(v, 'Name'),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Rahul Kumar',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            _FieldLabel('Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            _FieldLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordCtrl,
              obscureText: obscurePassword,
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _PasswordStrengthBar(strength: passwordStrength),
            const SizedBox(height: 28),
            AppButton(
              label: 'Create Account',
              onPressed: isLoading ? null : onSubmit,
              loading: isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'By registering, you agree to our\nTerms of Service and Privacy Policy',
                style:
                    tt.labelSmall?.copyWith(color: AppColors.textDisabled),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});
  final int strength; // 0–3

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();

    final colors = [Colors.transparent, AppColors.error, AppColors.warning, AppColors.success];
    final labels = ['', 'Weak', 'Medium', 'Strong'];
    final color = colors[strength.clamp(0, 3)];
    final label = labels[strength.clamp(0, 3)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final filled = i < strength;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? color : AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color)),
      ],
    );
  }
}
