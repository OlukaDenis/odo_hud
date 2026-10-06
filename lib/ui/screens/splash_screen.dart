import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/database/isar_service.dart';
import '../../providers/theme_provider.dart';
import '../../services/permission_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final TickerFuture _animationFuture;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _animationFuture = _controller.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    final onboardingFuture = IsarService.instance.isOnboardingCompleted();
    final permissionFuture = PermissionService.instance.checkCurrentStatus();

    // Ensure the animation and progress bar complete fully to 100%
    try {
      await _animationFuture.orCancel;
    } catch (_) {}

    final results = await Future.wait([
      onboardingFuture,
      permissionFuture,
    ]);

    // Brief moment so the user sees the completed progress bar
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final isCompleted = results[0] as bool;
    final report = results[1] as PermissionStatusReport;

    if (!isCompleted || !report.hasEssentialPermissions) {
      final step = !report.locationWhenInUse ? '0' : '1';
      context.go('/onboarding?step=$step');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hudThemeProvider);
    final primaryColor = theme.primaryColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.amoledBlack,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.amoledBlack,
        body: SafeArea(
          child: Stack(
            children: [
              // Perfectly centered logo
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom loader with 2-second progress bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 130,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: _controller.value,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                  minHeight: 2.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'INITIALIZING TELEMETRY...',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.6,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
