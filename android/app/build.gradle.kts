// Arquivo: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Firebase
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
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
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))

    // Adicione Firebase conforme precisar:
    // implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}

// Necessário para o Firebase funcionar
apply(plugin = "com.google.gms.google-services")
