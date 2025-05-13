plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.elifozcan.todoapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.elifozcan.todoapp"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = 15
        versionName = "1.3.1"
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:/Users/Ozcan/keystore.jks") // Keystore dosyasının tam yolu
            storePassword = "123456"  // Keystore şifreniz
            keyAlias = "upload"  // Anahtar alias'ınız
            keyPassword = "123456"  // Anahtar şifreniz
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."  // Flutter kaynak yolu
}
