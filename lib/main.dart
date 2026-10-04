import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'providers/theme_provider.dart';
import 'routing/app_router.dart';
import 'services/foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure system navigation bar and status bar match AMOLED dark styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.amoledBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize background foreground task manager
  await ForegroundServiceManager.instance.init();

  runApp(
    const ProviderScope(
      child: OdoHudApp(),
    ),
  );
}

class OdoHudApp extends ConsumerWidget {
  const OdoHudApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'OdoHUD',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: theme.backgroundColor,
        fontFamily: theme.fontFamily,
        colorScheme: ColorScheme.dark(
          surface: theme.cardBackgroundColor,
          primary: theme.speedNormal,
          secondary: theme.speedWarning,
          error: theme.speedCritical,
        ),
      ),
      routerConfig: router,
    );
  }
}
