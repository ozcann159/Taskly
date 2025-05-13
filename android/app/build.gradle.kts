plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 🔹 Firebase plugin
}

android {
    namespace = "com.elifozcan.todoapp"
    compileSdk = flutter.compileSdkVersion  // Flutter'dan alınan compileSdkVersion kullanıldı
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
        targetSdk = flutter.targetSdkVersion // Flutter'dan alınan targetSdkVersion kullanıldı
        versionCode =  14// Versiyon kodu (flutter.versionCode yerine manuel belirlenmiş)
        versionName = "1.0.5" // Versiyon adı (flutter.versionName yerine manuel belirlenmiş)
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:/Users/Ozcan/keystore.jks") // Keystore dosyasının yolunu burada doğru yazın
            storePassword = "123456"  // Keystore şifrenizi buraya yazın
            keyAlias = "upload" // Anahtar alias'ınızı buraya yazın
            keyPassword = "123456"  // Key şifrenizi buraya yazın
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."  // Flutter kaynak yolu, proje dizinine göre doğru olduğunu kontrol edin
}
