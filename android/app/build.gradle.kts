// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
  id("com.android.application")
  id("kotlin-android")
  id("dev.flutter.flutter-gradle-plugin")
  id("com.google.gms.google-services")
}

// CARREGA key.properties que está em android/key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
if (!keystorePropertiesFile.exists()) {
  throw GradleException("Arquivo key.properties não encontrado em ${keystorePropertiesFile.path}")
}
val keystoreProperties = Properties().apply {
  load(FileInputStream(keystorePropertiesFile))
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
      keyAlias     = keystoreProperties["keyAlias"]    as String
      keyPassword  = keystoreProperties["keyPassword"] as String
      // storeFile deve apontar para android/meu_keystore.jks
      storeFile    = rootProject.file(keystoreProperties["storeFile"] as String)
      storePassword= keystoreProperties["storePassword"] as String
    }
  }
  buildTypes {
    getByName("release") {
      signingConfig    = signingConfigs.getByName("release")
      isMinifyEnabled  = false
      isShrinkResources= false
    }
  }
}

flutter {
  source = "../.."
}
