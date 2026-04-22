import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_colors.dart';
import 'core/theme/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeAsync = ref.watch(appThemeColorsProvider);

    // Use fetched colors if available; fall back to defaults during load/error.
    final colors = themeAsync.valueOrNull ?? AppThemeColors.defaults;

    return MaterialApp.router(
      title: 'Astrobless',
      theme: AppTheme.dark(colors),
      darkTheme: AppTheme.dark(colors),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
