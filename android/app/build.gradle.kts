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
<<<<<<< HEAD
=======
        isCoreLibraryDesugaringEnabled = true
>>>>>>> origin/main
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.roadsos"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
=======
        applicationId = "com.example.roadsos"
>>>>>>> origin/main
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
<<<<<<< HEAD
=======

        // Enables multidex — required by the large number of methods from
        // supabase_flutter, powersync, firebase, flutter_gemma, etc.
        multiDexEnabled = true
>>>>>>> origin/main
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
=======
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

    // Split APKs per ABI so each download is ~30-45 MB instead of ~90 MB.
    // Controlled by --split-per-abi in the Flutter CLI (see build_apk.yml).
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            isUniversalApk = false
        }
>>>>>>> origin/main
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
=======

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.multidex:multidex:2.0.1")
}
>>>>>>> origin/main
