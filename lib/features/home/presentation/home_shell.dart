import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_colors.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(shell: shell),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.shell});
  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Chat'),
    (icon: Icons.phone_outlined, activeIcon: Icons.phone, label: 'Call'),
    (icon: Icons.history, activeIcon: Icons.history, label: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = shell.currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => shell.goBranch(i,
                      initialLocation: i == shell.currentIndex),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.activeIcon : tab.icon,
                        color: selected
                            ? c.primary
                            : c.textSecondary.withValues(alpha: 0.5),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? c.primary
                              : c.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
