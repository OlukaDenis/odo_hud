import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/database/isar_service.dart';
import '../../providers/permissions_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/oem_guide_modal.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinish;
  final int initialStep;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
    this.initialStep = 0,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 3);
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await IsarService.instance.setOnboardingCompleted(true);
    } catch (e) {
      debugPrint('Error marking onboarding complete: $e');
    }
    if (mounted) {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(permissionStatusProvider);
    final theme = ref.watch(hudThemeProvider);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: AppColors.amoledBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with clean indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.initialStep > 0
                            ? 'Permissions Setup'
                            : 'Welcome to OdoHUD',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Step ${_currentStep + 1} of 4',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: AppColors.charcoal,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor,
                  ),
                  minHeight: 4,
                ),
              ),
            ),

            // Wizard Step Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentStep = page),
                children: [
                  // Step 1: Location Tracking
                  _buildStepCard(
                    icon: Icons.location_on_rounded,
                    title: 'Speed & Distance',
                    subtitle: 'OdoHUD uses GPS to calculate your real-time speed, live heading, and trip mileage. Allow location access so tracking continues smoothly even when your phone is locked or running navigation.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.locationWhenInUse
                          ? (d.locationAlways
                                ? 'Location access: Always allowed'
                                : 'Location access: While in use')
                          : 'Location access needed',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.locationWhenInUse,
                      orElse: () => false,
                    ),
                    actionLabel: 'Allow Location Access',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestLocation();
                    },
                  ),

                  // Step 2: Foreground Notification Service
                  _buildStepCard(
                    icon: Icons.notifications_active_rounded,
                    imageAsset: 'assets/notification_icon.png',
                    title: 'Ride Notification',
                    subtitle: 'A quiet, persistent notification shows your live speed and trip time in the background so Android doesn\'t stop recording mid-ride.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.notification
                          ? 'Notifications enabled'
                          : 'Notification permission needed',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.notification,
                      orElse: () => false,
                    ),
                    actionLabel: 'Allow Notifications',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestNotification();
                    },
                  ),

                  // Step 3: Battery Saver Exemption
                  _buildStepCard(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Unrestricted Battery',
                    subtitle: 'Phone battery savers often pause GPS tracking when your screen is locked. Setting OdoHUD to unrestricted ensures your speed and mileage keep recording smoothly.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.batteryOptimizationIgnored
                          ? 'Battery: Unrestricted'
                          : 'Battery: Optimized (May pause GPS)',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.batteryOptimizationIgnored,
                      orElse: () => false,
                    ),
                    actionLabel: 'Set to Unrestricted',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestBatteryOptimization();
                    },
                  ),

                  // Step 4: Phone-specific tips
                  _buildStepCard(
                    icon: Icons.smartphone_rounded,
                    title: 'Phone Setup Tips',
                    subtitle: 'Devices from Samsung, Xiaomi, and OnePlus like to close background apps. Check these quick settings so your rides never get cut short.',
                    statusText: 'Tips available for your phone',
                    isGranted: true,
                    actionLabel: 'View Phone Tips',
                    onAction: () => OemGuideModal.show(context),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(
                            color: AppColors.defaultCardBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: (ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark)
                            ? Colors.white
                            : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              _currentStep == 3 ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    String? imageAsset,
    required String title,
    required String subtitle,
    required String statusText,
    required bool isGranted,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final primaryColor = ref.watch(hudThemeProvider).primaryColor;
    final isPrimaryDark = ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGranted
                    ? primaryColor.withValues(alpha: 0.15)
                    : AppColors.warningAmber.withValues(alpha: 0.15),
                border: Border.all(
                  color: isGranted
                      ? primaryColor
                      : AppColors.warningAmber,
                  width: 2,
                ),
              ),
              child: imageAsset != null
                  ? Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.contain,
                        color: isGranted
                            ? primaryColor
                            : AppColors.warningAmber,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 40,
                      color: isGranted
                          ? primaryColor
                          : AppColors.warningAmber,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isGranted
                    ? primaryColor.withValues(alpha: 0.4)
                    : AppColors.defaultCardBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGranted
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: isGranted
                      ? primaryColor
                      : AppColors.warningAmber,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isGranted
                          ? primaryColor
                          : AppColors.warningAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranted
                  ? const Color(0xFF1E1E1E)
                  : primaryColor,
              foregroundColor: isGranted
                  ? Colors.white70
                  : (isPrimaryDark ? Colors.white : Colors.black),
              side: isGranted
                  ? const BorderSide(color: AppColors.defaultCardBorder)
                  : BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              isGranted ? Icons.check : Icons.touch_app_rounded,
              size: 20,
              color: isGranted
                  ? primaryColor
                  : (isPrimaryDark ? Colors.white : Colors.black),
            ),
            label: Text(
              isGranted ? 'Permission Granted' : actionLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isGranted
                    ? Colors.white
                    : (isPrimaryDark ? Colors.white : Colors.black),
              ),
            ),
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
