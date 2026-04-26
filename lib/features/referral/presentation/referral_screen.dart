import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_colors.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _referralCode = 'ASTRO2024';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Refer & Earn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary, c.primary.withValues(alpha: 0.7), c.accent.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Invite Friends, Earn ₹100',
                    style: tt.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Your friend gets ₹50 on signup.\nYou earn ₹100 when they complete their first consultation.',
                  style: tt.bodySmall?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Referral code
          Text('Your Referral Code', style: tt.titleSmall),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _referralCode,
                    style: tt.headlineSmall?.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: _referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Code copied to clipboard!'),
                      backgroundColor: c.success,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 14, color: c.primary),
                        const SizedBox(width: 4),
                        Text('Copy', style: tt.labelSmall?.copyWith(color: c.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Share sheet coming soon!'),
                  backgroundColor: c.card,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              icon: const Icon(Icons.share),
              label: const Text('Share with Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 28),

          // How it works
          Text('How it works', style: tt.titleSmall),
          const SizedBox(height: 12),

          ..._steps.asMap().entries.map((e) => _StepTile(
                step: e.key + 1,
                text: e.value,
                isLast: e.key == _steps.length - 1,
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + 60 * e.key))),

          const SizedBox(height: 24),

          // Earnings summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Earnings', style: tt.titleSmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _EarningStat(
                        label: 'Friends Invited', value: '0', color: c.primary),
                    _EarningStat(
                        label: 'Pending Reward', value: '₹0', color: c.accent),
                    _EarningStat(
                        label: 'Total Earned', value: '₹0', color: c.success),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  static const _steps = [
    'Share your referral code with friends',
    'Friend signs up using your code and gets ₹50 bonus',
    'Friend completes their first consultation',
    'You earn ₹100 credited to your wallet!',
  ];
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.text, required this.isLast});
  final int step;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$step',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 30, color: c.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(text, style: tt.bodySmall?.copyWith(color: c.textSecondary)),
          ),
        ),
      ],
    );
  }
}

class _EarningStat extends StatelessWidget {
  const _EarningStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: tt.titleLarge?.copyWith(
                  color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: context.colors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
