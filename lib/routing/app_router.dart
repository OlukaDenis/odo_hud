import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/database/isar_service.dart';
import '../services/permission_service.dart';
import '../data/models/trip_record.dart';
import '../ui/screens/dashboard_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/permissions_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/trip_detail_screen.dart';
import '../ui/screens/trip_history_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _AppSplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep = int.tryParse(stepParam ?? '0') ?? 0;
          return OnboardingScreen(
            initialStep: initialStep,
            onFinish: () {
              context.go('/dashboard');
            },
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const TripHistoryScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final trip = state.extra as TripRecord;
              return TripDetailScreen(trip: trip);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final isCompleted = await IsarService.instance.isOnboardingCompleted();
      final report = await PermissionService.instance.checkCurrentStatus();
      final currentLoc = state.matchedLocation;

      // 1. If onboarding has NOT been completed or essential Location is missing
      if (!isCompleted || !report.hasEssentialPermissions) {
        if (currentLoc != '/onboarding') {
          final step = !report.locationWhenInUse ? '0' : '1';
          return '/onboarding?step=$step';
        }
        return null;
      }

      // 2. If onboarding is completed and essential permissions exist, redirect root/onboarding to dashboard
      if (currentLoc == '/' || currentLoc == '/onboarding') {
        return '/dashboard';
      }

      return null;
    },
  );
});

class _AppSplashScreen extends StatelessWidget {
  const _AppSplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00FF66),
        ),
      ),
    );
  }
}
