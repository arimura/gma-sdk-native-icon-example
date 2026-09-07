plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.gmanativeiconexample"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.gmanativeiconexample"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
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
    // Google Mobile Ads SDK
    implementation("com.google.android.gms:play-services-ads:24.4.0")

    // FluctSDK Google Mobile Ads向けメディエーションアダプター
    implementation("jp.fluct.mediation.gma:gma-mediation:9.16.0")
}
