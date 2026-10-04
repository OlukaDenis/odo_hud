# OdoHUD 🏍️ 🚘

**OdoHUD** is a glanceable, resilient telemetry odometer and Head-Up Display (HUD) mobile application engineered for bikers and drivers. Designed for extreme readability under direct sunlight and night reflections, OdoHUD provides uninterrupted background GPS tracking with persistent foreground notifications, survives aggressive OEM battery-killing algorithms, and projects a horizontally inverted display onto vehicle windshields.

---

## ✨ Features

- **Responsive Dual-Mode Viewports:** Seamlessly transitions between **Landscape** (50/50 horizontal split for handlebar mounts) and **Portrait** (45/40/15 vertical hierarchy for dash mounts).
- **Matrix4 Windshield HUD Mirroring:** Flips the entire UI horizontally with a single tap using a 3D matrix transform (`scale(-1, 1, 1)`), projecting clear reflection displays onto windshields at night.
- **Jitter-Free Tabular Speedometer:** Renders digits using fixed-width monospaced tabular figures (`FontFeature.tabularFigures()`) to eliminate number vibration during rapid acceleration and deceleration.
- **Dynamic Speed Alerts:** Automatic color shifts based on customizable speed limits:
  - 🟢 **Normal Speed:** High-contrast electric green (`#00FF66`).
  - 🟡 **Warning Speed:** Amber warning alert (`#FFB800`) when approaching thresholds.
  - 🔴 **Critical Speed:** Danger red glow (`#FF3B30`) exceeding max safety limits.
- **Persistent Background Telemetry:** Employs an Android Foreground Service with live notification updates, ensuring GPS tracking never halts when the screen locks or when navigation apps (e.g., Google Maps) take focus.
- **Stationary GPS Noise Gate:** Suppresses GPS drift and spurious distance accumulation at stoplights by clamping speed to `0.0` when velocity $< 1.5\text{ km/h}$ ($0.42\text{ m/s}$) or GPS accuracy $> 20\text{ m}$.
- **Glove-Safe Haptic Hold-To-Reset:** Requires a continuous 1500 ms hold with progressive visual feedback and heavy haptic impact (`HapticFeedback.heavyImpact()`) to prevent accidental trip resets while wearing riding gloves or over road vibration.
- **4-Step Onboarding & OEM Exemption Wizard:** Guides users through background location, notification permissions, OS battery whitelist, and device-specific instructions (Xiaomi MIUI/HyperOS, Samsung OneUI, OnePlus/Oppo ColorOS, Huawei EMUI).
- **Live Theme & Typography Customizer:** Customize AMOLED Black, Deep Navy, and Charcoal backgrounds, warning sliders, and typography (`Bebas Neue`, `Orbitron`, `JetBrains Mono`, `Share Tech Mono`).
- **Instant Unit Conversion:** Toggle between Metric (`km/h`, `km`) and Imperial (`mph`, `miles`) on the fly.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Channel stable, Dart 3+)
- **State Management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Embedded Persistence:** [Isar Database](https://isar.dev) (`isar`, `xxf_isar_flutter_libs`)
- **Location & Sensors:**
  - `geolocator`: High-precision navigation-grade GPS stream
  - `flutter_foreground_task`: Persistent background service & live notification
  - `battery_plus`: Hardware battery level and status monitoring
  - `flutter_compass`: Real-time heading and cardinal direction fallback
  - `wakelock_plus`: Prevents display sleep during active journeys
  - `permission_handler`: Multi-stage runtime permission management (including battery optimization exemption)
- **Typography & Styling:** `google_fonts`, `flutter_colorpicker`

---

## 📁 Project Structure

```
odo_hud/
├── android/
│   └── app/src/main/AndroidManifest.xml      # Location, foreground service, wakelock manifests
├── ios/
│   └── Runner/Info.plist                     # Background location, processing, orientations
├── lib/
│   ├── main.dart                             # App initialization, ProviderScope, root router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart               # Default AMOLED color palette
│   │   │   └── app_constants.dart            # Noise gate thresholds, update intervals
│   │   ├── theme/
│   │   │   └── hud_theme.dart                # Dynamic styling mapped from ThemeConfigRecord
│   │   └── utils/
│   │       └── unit_converter.dart           # Metric/Imperial conversion & time formatting
│   ├── data/
│   │   ├── database/
│   │   │   └── isar_service.dart             # Isar singleton lifecycle & persistence handlers
│   │   └── models/
│   │       ├── telemetry_record.dart         # Isar schema for persistent odometer & trip stats
│   │       └── theme_config_record.dart      # Isar schema for colors, thresholds, and units
│   ├── models/
│   │   ├── telemetry_state.dart              # Immutable UI telemetry state
│   │   └── oem_brand.dart                    # OEM battery guide models (Xiaomi, Samsung, etc.)
│   ├── services/
│   │   ├── location_service.dart             # GPS stream wrapper & stationary noise gate
│   │   ├── foreground_service.dart           # FlutterForegroundTask notifications
│   │   ├── permission_service.dart           # Multi-permission coordinator
│   │   └── sensor_service.dart               # Compass & battery stream aggregators
│   ├── providers/
│   │   ├── telemetry_provider.dart           # Riverpod notifier driving live telemetry
│   │   ├── theme_provider.dart               # Theme and unit system notifier
│   │   └── permissions_provider.dart         # Onboarding status & permission notifier
│   └── ui/
│       ├── screens/
│       │   ├── dashboard_screen.dart         # Main HUD & Telemetry viewport
│       │   ├── onboarding_screen.dart        # 4-step permission & OEM exemption wizard
│       │   └── settings_screen.dart          # Live-preview theme & threshold customizer
│       └── widgets/
│           ├── top_status_bar.dart           # Clock, GPS locked pill, battery indicator
│           ├── speed_display.dart            # Tabular numeral with threshold transitions
│           ├── metric_card.dart              # Glanceable auxiliary tile
│           ├── auxiliary_grid.dart           # 2x2 responsive telemetry grid
│           ├── action_bar.dart               # Mirror toggle, settings, and guarded 1500ms reset
│           └── oem_guide_modal.dart          # OEM manufacturer auto-start instructions
└── test/
    ├── unit/
    │   ├── unit_converter_test.dart          # Metric/Imperial & formatting tests
    │   └── noise_gate_test.dart              # Noise gate parameters & color threshold tests
    └── widget/
        └── dashboard_layout_test.dart        # SpeedDisplay, TopStatusBar, Grid, ActionBar tests
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.16 or newer)
- Dart SDK (3.0 or newer)
- Android Studio / Xcode for device emulation or deployment

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/odo_hud.git
   cd odo_hud
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Isar schemas:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Quality Assurance

Run the automated test suite and static analyzer to ensure zero issues:

```bash
# Run static analysis
flutter analyze

# Run all unit and widget tests
flutter test
```

---

## 🔐 Android Release Signing & Keystore Configuration

To sign release builds for distribution (Google Play Store or manual APK deployment):

### 1. Create your `key.properties` file
A template is provided at [`android/key.properties.example`](file:///Volumes/Data/Projects/DenTech/odo_hud/android/key.properties.example). Copy it to `android/key.properties`:

```bash
cp android/key.properties.example android/key.properties
```

### 2. Configure Keystore Credentials
Edit `android/key.properties` with your actual keystore details:

```properties
storePassword=your_keystore_password
keyPassword=your_key_alias_password
keyAlias=your_key_alias
storeFile=upload-keystore.jks
```

> **Note on `storeFile` path:**
> - If you place your `.jks` or `.keystore` file in `android/app/` (e.g. `android/app/upload-keystore.jks`), simply specify `storeFile=upload-keystore.jks`.
> - If placed in `android/`, you can use `storeFile=upload-keystore.jks` or `storeFile=../upload-keystore.jks`.
> - Absolute paths (e.g., `/Users/username/keystores/upload-keystore.jks`) are also supported.

### 3. CI/CD Environment Variables (Optional)
If building via CI/CD pipelines (e.g., GitHub Actions, Bitrise), you can optionally pass credentials through environment variables instead of `key.properties`:
- `STORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `KEYSTORE_PATH`

### 4. Build Release Artifacts

```bash
# Build split or universal APK
flutter build apk --release

# Build Google Play App Bundle (AAB)
flutter build appbundle --release
```

> ⚠️ **Security Warning:**
> Never commit `key.properties` or any `*.jks` / `*.keystore` files to version control. Both are ignored in `.gitignore`.

---

## 📱 Platform Permissions

### Android (`AndroidManifest.xml`)
- `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION` (GPS fix)
- `ACCESS_BACKGROUND_LOCATION` (Background odometer tracking)
- `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_LOCATION` (Android 14+ ongoing notifications)
- `POST_NOTIFICATIONS` (Notification tray authorization)
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (Bypasses OS sleep throttling)
- `WAKE_LOCK` (Prevents screen auto-turnoff on dashboard mounts)

### iOS (`Info.plist`)
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `UIBackgroundModes`: `location`, `processing`

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
