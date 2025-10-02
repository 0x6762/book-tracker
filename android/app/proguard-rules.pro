# Flutter Local Notifications & Gson ProGuard Rules

# Keep Flutter Local Notifications plugin and models
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep AndroidX notification classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat** { *; }
-keep class androidx.core.app.NotificationChannelCompat** { *; }
-keep class androidx.core.app.NotificationChannelGroupCompat** { *; }

# Keep WorkManager (if used transitively)
-keep class androidx.work.** { *; }

# Keep Google Play Services (safe default)
-keep class com.google.android.gms.** { *; }

# Keep exact alarm and wake lock classes
-keep class android.app.AlarmManager** { *; }
-keep class android.app.PendingIntent** { *; }
-keep class android.os.PowerManager** { *; }

# Gson: prevent stripping generic type info used by the plugin
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.google.gson.reflect.TypeToken { *; }

# Preserve generic signatures and annotations (required for Gson TypeToken)
-keepattributes Signature
-keepattributes *Annotation*

# General: keep Dex/Flutter generated classes under com.dexterous
-keep class com.dexterous.** { *; }

# Keep notification compat inner classes
-keep class * extends androidx.core.app.NotificationCompat$* { *; }
-keep class * extends androidx.core.app.NotificationCompat$Builder { *; }

