import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/theme_mode_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeAsync = ref.watch(appThemeColorsProvider);
    final themeMode = ref.watch(themeModeProvider);

    final colors = themeAsync.valueOrNull ?? AppThemeColors.defaults;

    return GetMaterialApp.router(
      title: 'Astrobless',
      theme: AppTheme.light(colors),
      darkTheme: AppTheme.dark(colors),
      themeMode: themeMode,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
    );
  }
}
