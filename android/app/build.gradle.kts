// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

plugins {
  id("com.android.application")
  id("kotlin-android")
  id("dev.flutter.flutter-gradle-plugin")
  id("com.google.gms.google-services")
}

// Carregamento condicional do key.properties
val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
val hasKeystore = keystoreFile.exists()

if (hasKeystore) {
  keystoreProperties.load(FileInputStream(keystoreFile))
}

android {
  namespace = "com.example.gestao_salao"
  compileSdk = flutter.compileSdkVersion

  defaultConfig {
    applicationId = "com.example.gestao_salao"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
  }

  kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
  }

  signingConfigs {
    create("release").apply {
      if (hasKeystore) {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
      }
    }
  }

  buildTypes {
    getByName("release") {
      // Só aplica assinatura se o arquivo existir
      if (hasKeystore) {
        signingConfig = signingConfigs.getByName("release")
      }
      isMinifyEnabled = false
      isShrinkResources = false
    }
  }
}

flutter {
  source = "../.."
}
