import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(authNotifierProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0B1E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Color(0xFFFFB300)),
            SizedBox(height: 16),
            Text(
              'Astrobless',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFFECEFF1),
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your cosmic guide',
              style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              color: Color(0xFFFFB300),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
