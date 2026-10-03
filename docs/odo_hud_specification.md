# Product Requirements Document & AI Agent Implementation Spec: OdoHUD (Flutter + Riverpod + Isar)

## 1. Project Overview & Tech Stack

Build a glanceable, resilient telemetry odometer and Head-Up Display (HUD) mobile application for bikers and drivers. The app must run uninterrupted in both landscape and portrait orientations, provide foreground service tracking with persistent notifications, survive OS-level aggressive task-killing (OEM auto-start/battery optimizations), and include an onboarding permission wizard.

* **Framework:** Flutter (Channel stable, Dart 3+)
* **State Management:** `flutter_riverpod` + `riverpod_annotation` (Notifier/AsyncNotifier code-gen pattern)
* **Local Persistence:** `isar` + `isar_flutter_libs` + `path_provider` (High-speed embedded DB)
* **Hardware, Sensors & System:**
  * `geolocator` (High-precision GPS stream)
  * `flutter_foreground_task` (Foreground notification service & persistent background execution)
  * `permission_handler` (Multi-permission requesting and status polling)
  * `disable_battery_optimization` (Request exemption from battery saver throttling)
  * `wakelock_plus` (Screen keep-awake during active rides)
  * `flutter_compass` / `sensors_plus` (Orientation / Compass heading)
  * `battery_plus` (Device battery level & state)
  * `google_fonts` (Monospaced and digital display typography)
  * `flutter_colorpicker` (In-app theme personalization)

---

## 2. Platform Permissions & Native Manifests

### 2.1. Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Location Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Foreground Service & Notification Permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Battery & System Keep-Alive Permissions -->
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:label="OdoHUD"
        android:keepScreenOn="true"
        android:icon="@mipmap/ic_launcher">

        <!-- Foreground Service Definition for Ongoing Trip Notification -->
        <service
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="location"
            android:exported="false" />

        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 2.2. iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>OdoHUD requires your location to calculate real-time speed, trip distance, and heading.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>OdoHUD tracks continuous trip mileage and odometer stats even when the screen is locked or the app is in the background.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>processing</string>
</array>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

---

## 3. Isar Persistence Schemas (`/lib/data/models/`)

### 3.1. Telemetry State Record (`telemetry_record.dart`)

```dart
import 'package:isar/isar.dart';

part 'telemetry_record.g.dart';

@collection
class TelemetryRecord {
  Id id = 1; // Single-row singleton for persistent totals

  double lifetimeOdometerMeters = 0.0;
  double activeTripMeters = 0.0;
  int activeTripMovingSeconds = 0;
  double maxSpeedKmh = 0.0;
  DateTime lastSavedTimestamp = DateTime.now();
}
```

### 3.2. Custom Theme Record (`theme_config_record.dart`)

```dart
import 'package:isar/isar.dart';

part 'theme_config_record.g.dart';

@collection
class ThemeConfigRecord {
  Id id = 1; // Single-row singleton

  int backgroundColorValue = 0xFF000000; // Pure AMOLED Black
  int speedColorNormal = 0xFF00FF66;    // Electric Green
  int speedColorWarning = 0xFFFFB800;   // Amber
  int speedColorCritical = 0xFFFF3B30;  // Danger Red
  double warningThresholdKmh = 100.0;
  double criticalThresholdKmh = 130.0;

  int cardBackgroundColor = 0xFF121212;
  int cardBorderColor = 0xFF222222;
  int cardLabelColor = 0xFF888888;
  int cardValueColor = 0xFFFFFFFF;

  String speedFontFamily = 'Bebas Neue';
  String telemetryFontFamily = 'JetBrains Mono';
  bool isMetric = true; // true = km/h, false = mph
  bool onboardingCompleted = false;
}
```

---

## 4. State Management & Foreground Service

### 4.1. Telemetry State Model (`/lib/models/telemetry_state.dart`)

```dart
class TelemetryState {
  final double currentSpeedKmh;
  final double currentSpeedMph;
  final double tripDistanceKm;
  final double tripDistanceMiles;
  final double odometerKm;
  final int movingTimeSeconds;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final double headingDegrees;
  final String cardinalDirection;
  final double gpsAccuracyMeters;
  final bool isGpsLocked;
  final bool isHudMirrored;
  final int batteryPercent;

  const TelemetryState({
    this.currentSpeedKmh = 0.0,
    this.currentSpeedMph = 0.0,
    this.tripDistanceKm = 0.0,
    this.tripDistanceMiles = 0.0,
    this.odometerKm = 0.0,
    this.movingTimeSeconds = 0,
    this.averageSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.headingDegrees = 0.0,
    this.cardinalDirection = 'N',
    this.gpsAccuracyMeters = 999.0,
    this.isGpsLocked = false,
    this.isHudMirrored = false,
    this.batteryPercent = 100,
  });
}
```

### 4.2. Foreground Notification Service (`/lib/services/foreground_service.dart`)

* Initializes with `FlutterForegroundTask.init`.
* Runs a persistent notification displaying real-time live telemetry:
  * Title: `OdoHUD Active Ride`
  * Text: `Speed: 48 km/h | Trip: 12.4 km | Time: 00:18:42`
* Ensures Android OS does not kill GPS tracking when the screen turns off or another application (e.g., Google Maps) takes the foreground.

---

## 5. UI Architecture: Responsive Dual-Mode Layout

Support continuous transition between Landscape and Portrait using `OrientationBuilder` and `LayoutBuilder`.

### 5.1. Landscape Layout (Handlebar / Dashboard Mount Mode)
```text
+-------------------------------------------------------------------+
| 10:42 PM   [ GPS: LOCKED (±3m) ]                   [ BATTERY 88% ]|  <- Top Bar
+---------------------------------+---------------------------------+
|                                 |   TRIP DISTANCE   | MOVING TIME |
|              104                |      34.8 KM      |  00:42:15   |  <- 2x2 Auxiliary
|             KM / H              +-------------------+-------------+     Grid on Right
|                                 |     AVG SPEED     |   HEADING   |
|                                 |      52 KM/H      |   NW 315°   |
+---------------------------------+-------------------+-------------+
| [ HUD MIRROR ]            [ SETTINGS ]           [ RESET (HOLD) ] |  <- Bottom Bar
+-------------------------------------------------------------------+
```

### 5.2. Portrait Layout (Vertical Mount Mode)
```text
+-------------------------------------------------------------+
| 10:42 PM         [ GPS LOCKED (±3m) ]         [ BATTERY 88%]|  <- Top Bar
+-------------------------------------------------------------+
|                                                             |
|                            104                              |  <- Speed Numeral
|                           KM / H                            |     (45% height)
|                                                             |
+------------------------------+------------------------------+
|        TRIP DISTANCE         |         MOVING TIME          |  <- 2x2 Grid
|           34.8 KM            |           00:42:15           |     underneath
+------------------------------+------------------------------+
|          AVG SPEED           |           HEADING            |
|           52 KM/H            |           NW 315°            |
+------------------------------+------------------------------+
| [ HUD MIRROR ]         [ SETTINGS ]          [ RESET (HOLD)]|  <- Bottom Bar
+-------------------------------------------------------------+
```

### 5.3. HUD Matrix4 Mirror Transform
The entire root view (in both orientations) is wrapped in a `Transform`:
```dart
Transform(
  alignment: Alignment.center,
  transform: isHudMirrored 
      ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)) 
      : Matrix4.identity(),
  child: DashboardContent(),
);
```

---

## 6. Three-Phase Step-by-Step Implementation Roadmap

```text
+-------------------------------------------------------------------+
|                             PHASE 1                               |
|        Hardware, Permissions Wizard & Persistence Core            |
|  - 4-step onboarding wizard for permissions & battery exemptions  |
|  - Android OEM auto-start instructions modal                      |
|  - Isar schemas & singleton repository setup                      |
|  - Foreground notification service & background location pipeline |
|  - GPS noise gating (<1.5 km/h) & 5-second persistence loop       |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                             PHASE 2                               |
|         Adaptive Dual-Orientation Dashboard & HUD Engine          |
|  - OrientationBuilder for seamless Landscape & Portrait layouts   |
|  - Tabular/Monospaced speed numeral with dynamic color thresholds  |
|  - Matrix4 horizontal HUD mirror flip                             |
|  - 1500ms haptic long-press action safeguards (gloves/vibration)  |
|  - Wakelock & battery status integration                          |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                             PHASE 3                               |
|            Customization Engine & Production Hardening            |
|  - Live-preview theme customizer (colors, fonts, limits)          |
|  - Metric/Imperial unit conversion (km/h vs mph, km vs miles)     |
|  - GPS drop/tunnel dead-reckoning safeguard                       |
|  - 2 Hz throttled UI rendering for thermal and battery efficiency |
+-------------------------------------------------------------------+
```

### Phase 1: Hardware, Permissions Wizard & Persistence Core

* **Step 1.1 — Dependencies & Android/iOS Manifests:**
  * Add all dependencies in `pubspec.yaml` (`flutter_riverpod`, `riverpod_annotation`, `isar`, `isar_flutter_libs`, `path_provider`, `geolocator`, `flutter_foreground_task`, `permission_handler`, `disable_battery_optimization`, `wakelock_plus`, `flutter_compass`, `battery_plus`, `google_fonts`, `flutter_colorpicker`).
  * Configure Android `AndroidManifest.xml` and iOS `Info.plist` with all background location, foreground service, and battery optimization permissions.

* **Step 1.2 — Onboarding Permission Wizard (`/lib/screens/onboarding_screen.dart`):**
  * Present a 4-step guided setup flow before reaching the dashboard:
    1. **Location Tracking:** Request `Permission.locationWhenInUse`, followed immediately by `Permission.locationAlways` for background logging.
    2. **Notification Authorization:** Request `Permission.notification` for the foreground telemetry service.
    3. **Battery Saver Whitelist:** Call `DisableBatteryOptimization.showDisableBatteryOptimizationSettings()` to exempt OdoHUD from OS sleep kills.
    4. **OEM Auto-Start Helper:** Provide a visual prompt detailing how users on OEM skins (Xiaomi/MIUI, Samsung/OneUI, Huawei, Oppo/Vivo) must allow "Auto-start" and set background battery to "No restrictions".
  * Store `onboardingCompleted = true` in `ThemeConfigRecord` upon completion to bypass the wizard on subsequent launches.

* **Step 1.3 — Persistence & Isar Models:**
  * Generate Isar schemas (`telemetry_record.g.dart`, `theme_config_record.g.dart`).
  * Initialize `IsarService` on startup.

* **Step 1.4 — Foreground Service & Telemetry Pipeline:**
  * Configure `flutter_foreground_task` to run a sticky foreground notification updating with live speed, trip distance, and moving time.
  * Implement `TelemetryNotifier` consuming `Geolocator.getPositionStream(locationSettings: AndroidSettings(intervalDuration: Duration(seconds: 1), distanceFilter: 1))`.
  * **Stationary Noise Gate:** Clamp speed to `0.0` if raw reading $< 0.42\text{ m/s}$ ($< 1.5\text{ km/h}$) or GPS accuracy $> 20\text{ m}$.
  * Trigger automated database writes to Isar every 5 seconds while active.

---

### Phase 2: Adaptive Dual-Orientation Dashboard & HUD Engine

* **Step 2.1 — Adaptive Layout Engine:**
  * Build a layout with `OrientationBuilder`:
    * **Landscape:** 50/50 horizontal split (Left: Speed numeral; Right: 2x2 auxiliary metric grid).
    * **Portrait:** Vertical stack (Top 45%: Speed numeral; Lower 40%: 2x2 auxiliary metric grid; Bottom 15%: Action bar).
  * Enable `WakelockPlus.enable()` when the dashboard view mounts.

* **Step 2.2 — High-Readability Speedometer:**
  * Implement numeric display using tabular digits (`fontFeatures: [FontFeature.tabularFigures()]`) to eliminate jitter.
  * Integrate dynamic threshold transitions:
    * Normal: default theme color.
    * Warning: triggers when speed $\ge \text{warningThresholdKmh}$ (e.g., 100 km/h).
    * Critical: triggers when speed $\ge \text{criticalThresholdKmh}$ (e.g., 130 km/h).

* **Step 2.3 — Auxiliary Data Tiles & Top Bar:**
  * Top bar: digital clock (12h/24h), GPS status pill (Green = Locked, Amber = Searching), and device battery level (`battery_plus`).
  * Auxiliary cards: Trip Distance, Moving Time, Average Speed, Heading (Compass degrees + Cardinal symbol `N`, `NE`, `SW`).

* **Step 2.4 — HUD Mode & Touch Ergonomics:**
  * Implement the horizontal flip toggle via `Transform(Matrix4.identity()..scale(-1.0, 1.0, 1.0))`.
  * Protect dangerous actions (Trip Reset, End Session) with a 1500 ms `LongPressGestureDetector` + `HapticFeedback.heavyImpact()` to prevent accidental taps while wearing gloves.

---

### Phase 3: Customization Engine & Production Hardening

* **Step 3.1 — In-App Theme & Font Customizer (`/lib/screens/settings_screen.dart`):**
  * Color picker selectors for:
    * Background color (AMOLED Black `#000000`, Deep Navy `#050B14`, Charcoal `#121212`).
    * Speed numeral colors (Normal, Warning, Critical).
    * Metric tile background, border, and text colors.
  * Typography selector via `google_fonts` (`Bebas Neue`, `Orbitron`, `JetBrains Mono`, `Share Tech Mono`).
  * Sliders for custom warning and critical speed limits.

* **Step 3.2 — Units & Conversion:**
  * Metric/Imperial toggle in settings:
    * Speed: $\text{km/h} \leftrightarrow \text{mph}$
    * Distance: $\text{km} \leftrightarrow \text{miles}$
    * Altitude: $\text{meters} \leftrightarrow \text{feet}$

* **Step 3.3 — Edge-Case Safeguards & Performance:**
  * **Tunnel & Signal Outage:** Detect when GPS timestamps lag $> 3\text{ seconds}$; display an amber "SIGNAL LOST" badge while maintaining the last valid odometer reading.
  * **Thermal & Battery Optimization:** Limit UI repaints to a maximum of 2 Hz (every 500 ms) when stationary.
  * **Clean Teardown:** Ensure foreground notifications, location subscriptions, and wakelocks properly release when the user explicitly terminates a ride.