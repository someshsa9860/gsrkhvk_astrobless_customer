import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Slight delay so the splash animation plays before auth check resolves
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) ref.read(authNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0B1E), Color(0xFF1A1740), Color(0xFF0D0B1E)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Glowing orb top-right
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Glowing orb bottom-left
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo container
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 44),
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.6, 0.6),
                          duration: 600.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Text(
                    'Astrobless',
                    style: tt.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.3, delay: 300.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Your cosmic guide to clarity',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 56),

                  // Pulsing loader
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent.withValues(alpha: 0.8),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(delay: 700.ms)
                      .then()
                      .shimmer(
                          duration: 1200.ms,
                          color: AppColors.accent.withValues(alpha: 0.3)),
                ],
              ),
            ),
            // Version at bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                ),
              ).animate().fadeIn(delay: 800.ms),
            ),
          ],
        ),
      ),
    );
  }
}
