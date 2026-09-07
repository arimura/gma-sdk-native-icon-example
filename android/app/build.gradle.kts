plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "jp.fluct.example.gmanativeicon"
    compileSdk = 35

    defaultConfig {
        applicationId = "jp.fluct.example.gmanativeicon"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.constraintlayout:constraintlayout:2.2.0")

    // Google Mobile Ads SDK
    implementation("com.google.android.gms:play-services-ads:23.1.0")

    // FluctSDK adapter for Google Mobile Ads SDK
    implementation("jp.fluct.mediation.gma:gma-mediation:9.16.0")
}
