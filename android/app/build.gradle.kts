plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.roadsos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.roadsos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enables multidex — required by the large number of methods from
        // supabase_flutter, powersync, firebase, flutter_gemma, etc.
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // R8 full-mode: dead-code elimination + name obfuscation.
            // Reduces APK size significantly (Dart AOT + native libs both shrink).
            isMinifyEnabled = true

            // Remove unused resources (drawables, layouts, strings, etc.).
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // Signing with debug keys so `flutter build apk --release` works
            // in CI without a keystore secret.  Replace with a real signing
            // config before publishing to the Play Store.
            signingConfig = signingConfigs.getByName("debug")
        }

        debug {
            // Keep debug builds unminified so stack traces are readable.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Note: Splitting APKs by ABI can cause conflicts on certain environments
    // (e.g., with certain Gradle/NDK configurations). For testing, build a
    // universal APK by skipping per-ABI splits. If needed later, re-enable splits.

    lint {
        disable.add("MissingDimensionBaselineProguardFile")
        abortOnError = false
        checkDependencies = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.multidex:multidex:2.0.1")
}
