import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/database/isar_service.dart';
import '../../services/permission_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

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

    _controller.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Ensure the splash screen is displayed for at least 2 seconds
    final timerFuture = Future.delayed(const Duration(seconds: 2));
    final onboardingFuture = IsarService.instance.isOnboardingCompleted();
    final permissionFuture = PermissionService.instance.checkCurrentStatus();

    final results = await Future.wait([
      timerFuture,
      onboardingFuture,
      permissionFuture,
    ]);

    if (!mounted) return;

    final isCompleted = results[1] as bool;
    final report = results[2] as PermissionStatusReport;

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
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated Logo & App Title
              AnimatedBuilder(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Logo with neon glow
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricGreen.withValues(alpha: 0.30),
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.cyanAccent.withValues(alpha: 0.15),
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
                    const SizedBox(height: 24),

                    // App Title
                    Text(
                      'ODOHUD',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle / Tagline
                    Text(
                      'HIGH-FREQUENCY TELEMETRY HUD',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: AppColors.electricGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Loader with 2-second Progress Bar
              AnimatedBuilder(
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
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.electricGreen,
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

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
