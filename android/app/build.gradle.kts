import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.muhamedxzidan.cpc_clean_user"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.muhamedxzidan.cpc_clean_user"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

buildTypes {
        release {
            // استخدام مفتاح الديباج مؤقتاً عشان يشتغل معاك APK حالياً
            signingConfig = signingConfigs.getByName("debug")
            
            // تعطيل ضغط الكود والمصادر لحل مشكلة الكراش
            isMinifyEnabled = false
            isShrinkResources = false
            
            isDebuggable = false
            isJniDebuggable = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_1_8)
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))

    // Add the dependency for the Firebase SDK for Google Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Required for Flutter Play Store split/deferred component classes during R8 shrink.
    implementation("com.google.android.play:core:1.10.3")
}

// Ensure flutter_jailbreak_detection receives the mandatory namespace without wrapping in afterEvaluate 
// to prevent project evaluation order conflicts.
rootProject.subprojects {
    val subproj = this
    if (subproj.name == "flutter_jailbreak_detection") {
        subproj.pluginManager.withPlugin("com.android.library") {
            subproj.extensions.findByType<com.android.build.gradle.LibraryExtension>()?.let { ext ->
                if (ext.namespace.isNullOrEmpty()) {
                    ext.namespace = "com.amolg.flutterjailbreakdetection"
                }
            }
        }
    }
}

// Proper Gradle task-hook syntax to capture ProGuard mapping.txt output and copy to symbols folder
// ensuring split-debug-info and ProGuard maps match locations.
tasks.whenTaskAdded {
    val task = this
    if (task.name == "assembleRelease" || task.name == "bundleRelease") {
        task.doLast {
            val appBuildDir = layout.buildDirectory.get().asFile
            val rootBuildDir = rootProject.layout.buildDirectory.get().asFile
            
            val mappingFile = file("$appBuildDir/outputs/mapping/release/mapping.txt")
            if (mappingFile.exists()) {
                val symbolsDir = file("$rootBuildDir/app/outputs/symbols")
                symbolsDir.mkdirs()
                mappingFile.copyTo(File(symbolsDir, "mapping.txt"), overwrite = true)
            }
        }
    }
}
