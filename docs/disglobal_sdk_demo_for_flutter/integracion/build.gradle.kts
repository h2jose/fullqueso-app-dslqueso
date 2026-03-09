plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fullqueso.dslqueso"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.fullqueso.dslqueso"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.22")
    implementation("androidx.multidex:multidex:2.0.1")

    // =========================================================================
    // AAR LOCALES - SDKs de DisGlobal/NexGO para POS
    // =========================================================================
    // IMPORTANTE: Estos archivos deben estar en android/app/libs/
    // - smartconnect_new_version.aar: SDK de SmartConnect para procesamiento de pagos
    // - nexgo-smartpos-sdk-v3.08.002_20240410.aar: SDK de NexGO para hardware (impresora, etc)
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))
    implementation(files("libs/nexgo-smartpos-sdk-v3.08.002_20240410.aar"))
    implementation(files("libs/smartconnect_new_version.aar"))

    // =========================================================================
    // DEPENDENCIAS ANDROIDX Y OTRAS
    // =========================================================================
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // GSON: Necesario para serializar/deserializar respuestas de transacciones
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("androidx.annotation:annotation:1.6.0")

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test:runner:1.5.2")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}

flutter {
    source = "../.."
}
