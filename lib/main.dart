import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'data/database/isar_service.dart';
import 'providers/theme_provider.dart';
import 'services/foreground_service.dart';
import 'services/permission_service.dart';
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
        fontFamily: theme.fontFamily,
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

class _AppRootRouterState extends State<AppRootRouter>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _showDashboard = false;
  int _initialOnboardingStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_showDashboard) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    try {
      final config = await IsarService.instance.getThemeConfig();
      final report = await PermissionService.instance.checkCurrentStatus();

      // Check if all permissions have been accepted
      final bool allPermissionsAccepted = report.areAllPermissionsAccepted;

      // Only bypass setup wizard if it was captured previously AND all permissions were fully accepted
      final bool canOpenDashboard =
          config.onboardingCompleted && allPermissionsAccepted;

      int targetStep = 0;
      if (!report.locationWhenInUse) {
        targetStep = 0;
      } else if (Platform.isAndroid && !report.notification) {
        targetStep = 1;
      } else if (Platform.isAndroid && !report.batteryOptimizationIgnored) {
        targetStep = 2;
      } else {
        targetStep = 3;
      }

      if (mounted) {
        setState(() {
          _showDashboard = canOpenDashboard;
          _initialOnboardingStep = targetStep;
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

    if (_showDashboard) {
      return const DashboardScreen();
    }

    return OnboardingScreen(
      initialStep: _initialOnboardingStep,
      onFinish: () {
        setState(() => _showDashboard = true);
      },
    );
  }
}
