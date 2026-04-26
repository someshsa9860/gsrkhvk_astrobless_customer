import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
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

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneOtp(_phoneCtrl.text.trim());
    if (!ok || !mounted) return;
    context.push(AppRoutes.authOtp, extra: {
      'phone': '+91${_phoneCtrl.text.trim()}',
      'type': 'phone',
    });
  }

  Future<void> _googleSignIn() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    // Navigation handled by auth state change via router redirect
  }

  Future<void> _appleSignIn() async {
    await ref.read(authControllerProvider.notifier).signInWithApple();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: context.colors.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final c = context.colors;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _showError(next.error!);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient — intentionally fixed dark purple for brand identity
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0B1E), Color(0xFF1A1740), Color(0xFF0D0B1E)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 28,
                vertical: size.height * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + brand
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [c.primary, c.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text('Astrobless',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          )),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                  SizedBox(height: size.height * 0.06),

                  Text('Welcome back',
                          style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ))
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your cosmic journey',
                    style: tt.bodyMedium
                        ?.copyWith(color: Colors.white60),
                  ).animate().fadeIn(delay: 150.ms),

                  SizedBox(height: size.height * 0.05),

                  // Phone field
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mobile Number',
                                style: tt.labelMedium?.copyWith(
                                    color: Colors.white60,
                                    letterSpacing: 0.3))
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: Validators.phone,
                          style: tt.bodyLarge
                              ?.copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '98765 43210',
                            hintStyle: const TextStyle(
                                color: Colors.white38, fontSize: 16),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: c.primary, width: 2),
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇮🇳',
                                      style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 6),
                                  Text('+91',
                                      style: tt.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.white24,
                                  ),
                                ],
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _sendOtp(),
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Continue with OTP',
                          onPressed: state.isLoading ? null : _sendOtp,
                          loading: state.isLoading,
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.white24, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with',
                            style: tt.labelSmall
                                ?.copyWith(color: Colors.white38)),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white24, height: 1)),
                    ],
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 20),

                  // Social buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          icon: _GoogleIcon(),
                          onPressed: state.isLoading ? null : _googleSignIn,
                        ),
                      ),
                      if (Platform.isIOS) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            icon: const Icon(Icons.apple,
                                color: Colors.white, size: 22),
                            onPressed: state.isLoading ? null : _appleSignIn,
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  // Email option
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.authEmail),
                      style: TextButton.styleFrom(
                        foregroundColor: c.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Use Email instead',
                              style: tt.bodyMedium
                                  ?.copyWith(color: c.primary)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                      style: tt.labelSmall
                          ?.copyWith(color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.white24, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -0.5, 1.6, true, paint);
    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        1.1, 1.1, true, paint);
    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        2.2, 1.1, true, paint);
    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        3.3, 1.1, true, paint);
    // Dark center to match auth screen background
    paint.color = const Color(0xFF0D0B1E);
    canvas.drawCircle(center, radius * 0.55, paint);
    // Blue right rectangle
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.2,
          radius * 0.95, radius * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
