import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    // NOTE: kotlin-android plugin is NOT applied here — AGP 9+ uses built-in Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.ruzanov.puzzleforchild"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ruzanov.puzzleforchild"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["yandexMobileAdsAppId"] = "18531801"
    }



    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
            implementation("com.android.billingclient:billing:8.0.0")
            implementation("com.yandex.ads.mediation:mobileads-mytarget:5.27.2.1")
    }
}

// Миграция на built-in Kotlin (AGP 9+): вместо android.kotlinOptions {}
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
