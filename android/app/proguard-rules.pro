############################################
# Flutter
############################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

############################################
# Kotlin
############################################
-keep class kotlin.Metadata { *; }
-keepclassmembers class ** {
    @kotlin.Metadata *;
}

############################################
# AndroidX & Lifecycle
############################################
-keep class androidx.lifecycle.** { *; }
-keepclassmembers class androidx.lifecycle.** { *; }

############################################
# Gson / Moshi (jika pakai JSON)
############################################
-keep class com.google.gson.** { *; }
-keep class com.squareup.moshi.** { *; }

############################################
# Retrofit / OkHttp (jika ada)
############################################
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

############################################
# Jangan obfuscate model / data class
############################################
-keepclassmembers class * {
    <fields>;
}

############################################
# Remove logging (opsional)
############################################
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
