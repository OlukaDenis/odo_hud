import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/isar_service.dart';
import '../../providers/permissions_provider.dart';
import '../widgets/oem_guide_modal.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    await IsarService.instance.setOnboardingCompleted(true);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(permissionStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.amoledBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with HUD style step counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SETUP WIZARD',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.electricGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'STEP ${_currentStep + 1} / 4',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.5,
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
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.electricGreen,
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
                    icon: Icons.gps_fixed,
                    title: 'Continuous GPS Tracking',
                    subtitle:
                        'OdoHUD calculates real-time speed, live heading, and precise odometer mileage. Background tracking ensures uninterrupted telemetry even if the screen turns off or another navigation app takes focus.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.locationWhenInUse
                          ? (d.locationAlways
                              ? 'Status: Background Granted'
                              : 'Status: Foreground Granted')
                          : 'Status: Not Granted',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.locationWhenInUse,
                      orElse: () => false,
                    ),
                    actionLabel: 'Authorize Location Access',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestLocation();
                    },
                  ),

                  // Step 2: Foreground Notification Service
                  _buildStepCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Live Telemetry Notification',
                    subtitle:
                        'To prevent the Android operating system from killing background GPS logging, OdoHUD displays a persistent, real-time notification with your current speed, trip mileage, and elapsed ride time.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.notification
                          ? 'Status: Authorized'
                          : 'Status: Not Authorized',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.notification,
                      orElse: () => false,
                    ),
                    actionLabel: 'Enable Service Notifications',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestNotification();
                    },
                  ),

                  // Step 3: Battery Saver Exemption
                  _buildStepCard(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Battery Saver Exemption',
                    subtitle:
                        'Aggressive OS power savers throttle GPS hardware during long rides. Whitelisting OdoHUD from battery restrictions guarantees 100% telemetry accuracy from start to finish.',
                    statusText: permissionAsync.maybeWhen(
                      data: (d) => d.batteryOptimizationIgnored
                          ? 'Status: Whitelisted (Unrestricted)'
                          : 'Status: Standard / Optimized',
                      orElse: () => 'Checking...',
                    ),
                    isGranted: permissionAsync.maybeWhen(
                      data: (d) => d.batteryOptimizationIgnored,
                      orElse: () => false,
                    ),
                    actionLabel: 'Request Battery Exemption',
                    onAction: () async {
                      await ref
                          .read(permissionStatusProvider.notifier)
                          .requestBatteryOptimization();
                    },
                  ),

                  // Step 4: OEM Auto-Start & Sleep Killers
                  _buildStepCard(
                    icon: Icons.phonelink_setup,
                    title: 'OEM Auto-Start & Lock',
                    subtitle:
                        'Devices from Xiaomi (MIUI/HyperOS), Samsung (One UI), Huawei, Oppo, and OnePlus employ proprietary task killers. Review device-specific instructions to protect your ride tracking.',
                    statusText: 'Review Brand Guide Recommended',
                    isGranted: true,
                    actionLabel: 'View Manufacturer Instructions',
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
                          side: const BorderSide(color: AppColors.defaultCardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                        backgroundColor: AppColors.electricGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentStep == 3 ? 'Launch Dashboard' : 'Continue',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
    required String title,
    required String subtitle,
    required String statusText,
    required bool isGranted,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGranted
                    ? AppColors.electricGreen.withValues(alpha: 0.15)
                    : AppColors.warningAmber.withValues(alpha: 0.15),
                border: Border.all(
                  color: isGranted ? AppColors.electricGreen : AppColors.warningAmber,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 44,
                color: isGranted ? AppColors.electricGreen : AppColors.warningAmber,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isGranted ? AppColors.electricGreen.withValues(alpha: 0.5) : AppColors.defaultCardBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGranted ? Icons.check_circle : Icons.info_outline,
                  size: 16,
                  color: isGranted ? AppColors.electricGreen : AppColors.warningAmber,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: GoogleFonts.jetBrainsMono(
                    color: isGranted ? AppColors.electricGreen : AppColors.warningAmber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranted ? const Color(0xFF1E1E1E) : AppColors.electricGreen,
              foregroundColor: isGranted ? Colors.white70 : Colors.black,
              side: isGranted
                  ? const BorderSide(color: AppColors.defaultCardBorder)
                  : BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(
              isGranted ? Icons.check : Icons.lock_open_rounded,
              color: isGranted ? AppColors.electricGreen : Colors.black,
            ),
            label: Text(
              isGranted ? 'Permission Granted (Tap to Re-check)' : actionLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isGranted ? Colors.white : Colors.black,
              ),
            ),
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
