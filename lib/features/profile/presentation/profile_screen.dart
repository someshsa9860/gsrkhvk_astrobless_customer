import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.push(AppRoutes.profileEdit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _ProfileBody(name: null, phone: null, email: null, imageUrl: null),
        data: (profile) => _ProfileBody(
          name: profile.name,
          phone: profile.phone,
          email: profile.email,
          imageUrl: profile.profileImageUrl,
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.name,
    required this.phone,
    required this.email,
    required this.imageUrl,
  });

  final String? name;
  final String? phone;
  final String? email;
  final String? imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceDark,
                backgroundImage: imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl!)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(name ?? 'My Account', style: tt.titleLarge),
              if (phone != null || email != null) ...[
                const SizedBox(height: 4),
                Text(
                  phone ?? email ?? '',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => context.push(AppRoutes.profileEdit),
                child: Text('Tap to edit profile',
                    style: tt.bodySmall?.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _Section(title: 'Account', items: [
          _MenuItem(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => context.push(AppRoutes.profileEdit),
          ),
          _MenuItem(
            icon: Icons.auto_stories_outlined,
            label: 'My Kundli Profiles',
            onTap: () => context.push(AppRoutes.kundliList),
          ),
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () => context.push(AppRoutes.wallet),
          ),
          _MenuItem(
            icon: Icons.history,
            label: 'Consultation History',
            onTap: () => context.go(AppRoutes.history),
          ),
        ]),
        const SizedBox(height: 16),
        _Section(title: 'Preferences', items: [
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => context.push(AppRoutes.notifications),
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
