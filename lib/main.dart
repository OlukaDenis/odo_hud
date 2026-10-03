import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'data/database/isar_service.dart';
import 'providers/theme_provider.dart';
import 'services/foreground_service.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/onboarding_screen.dart';

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

    return MaterialApp(
      title: 'OdoHUD',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: theme.backgroundColor,
        colorScheme: ColorScheme.dark(
          surface: theme.cardBackgroundColor,
          primary: theme.speedNormal,
          secondary: theme.speedWarning,
          error: theme.speedCritical,
        ),
      ),
      home: const AppRootRouter(),
    );
  }
}

class AppRootRouter extends StatefulWidget {
  const AppRootRouter({super.key});

  @override
  State<AppRootRouter> createState() => _AppRootRouterState();
}

class _AppRootRouterState extends State<AppRootRouter> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final config = await IsarService.instance.getThemeConfig();
      if (mounted) {
        setState(() {
          _onboardingCompleted = config.onboardingCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.amoledBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.electricGreen),
        ),
      );
    }

    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onFinish: () {
          setState(() => _onboardingCompleted = true);
        },
      );
    }

    return const DashboardScreen();
  }
}
