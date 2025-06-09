// android/app/build.gradle.kts
import java.io.FileInputStream
import java.util.Properties

plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
  id("com.google.gms.google-services")
  id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
  if (keystorePropertiesFile.exists()) {
    load(FileInputStream(keystorePropertiesFile))
  }
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
    create("release") {
      keyAlias = keystoreProperties["keyAlias"] as String?
      keyPassword = keystoreProperties["keyPassword"] as String?
      keystoreProperties["storeFile"]?.let { sf ->
        storeFile = file(sf as String)
      }
      storePassword = keystoreProperties["storePassword"] as String?
    }
  }

  buildTypes {
    getByName("release") {
      signingConfig = signingConfigs.getByName("release")
      // Se você usar ProGuard/R8, habilite e configure abaixo:
      // isMinifyEnabled = true
      // proguardFiles(
      //     getDefaultProguardFile("proguard-android-optimize.txt"),
      //     "proguard-rules.pro"
      // )
    }
  }
}

flutter {
  source = "../.."
}
