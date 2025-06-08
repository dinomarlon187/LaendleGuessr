plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.laendle_guessr"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    defaultConfig {
        applicationId = "com.example.laendle_guessr"
        minSdk = 21 // oder verwende: flutter.minSdkVersion falls vorhanden
        targetSdk = 35 // oder: flutter.targetSdkVersion
        versionCode = 1 // oder: flutter.versionCode
        versionName = "1.0" // oder: flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
