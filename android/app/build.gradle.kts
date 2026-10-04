import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties").takeIf { it.exists() }
    ?: project.file("key.properties").takeIf { it.exists() }

if (keystorePropertiesFile != null) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.dennytech.odohud"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dennytech.odohud"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasProp = keystoreProperties.getProperty("keyAlias") ?: System.getenv("KEY_ALIAS")
            val keyPasswordProp = keystoreProperties.getProperty("keyPassword") ?: System.getenv("KEY_PASSWORD")
            val storePasswordProp = keystoreProperties.getProperty("storePassword") ?: System.getenv("STORE_PASSWORD")
            val storeFilePath = keystoreProperties.getProperty("storeFile") ?: System.getenv("KEYSTORE_PATH")

            if (!storeFilePath.isNullOrBlank()) {
                val rawFile = file(storeFilePath)
                storeFile = if (rawFile.isAbsolute) {
                    rawFile
                } else {
                    listOf(
                        project.file(storeFilePath),
                        rootProject.file(storeFilePath)
                    ).firstOrNull { it.exists() } ?: project.file(storeFilePath)
                }
            }

            keyAlias = keyAliasProp
            keyPassword = keyPasswordProp
            storePassword = storePasswordProp
        }
    }

    buildTypes {
        release {
            val releaseSigningConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseSigningConfig.storeFile?.exists() == true) {
                releaseSigningConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
