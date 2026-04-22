import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surfaceDark,
                  child: const Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Text('My Account', style: tt.titleLarge),
                const SizedBox(height: 4),
                Text('Tap to edit profile',
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _Section(title: 'Account', items: [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.auto_stories_outlined,
              label: 'My Kundli Profiles',
              onTap: () => context.push('/kundli'),
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              onTap: () => context.push('/wallet'),
            ),
            _MenuItem(
              icon: Icons.history,
              label: 'Consultation History',
              onTap: () => context.go('/history'),
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Preferences', items: [
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => context.push('/notifications'),
            ),
            _MenuItem(
              icon: Icons.language_outlined,
              label: 'Language',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Support', items: [
            _MenuItem(icon: Icons.help_outline, label: 'Help & FAQ', onTap: () {}),
            _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
            _MenuItem(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
          ]),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Sign Out',
                  style: tt.bodyMedium?.copyWith(color: AppColors.error)),
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(height: 1, indent: 52, color: AppColors.borderDark),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 18),
      onTap: onTap,
      dense: true,
    );
  }
}
