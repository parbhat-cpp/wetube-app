# Keep annotations
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Prevent obfuscation of Retrofit, Gson, and other common libraries
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
