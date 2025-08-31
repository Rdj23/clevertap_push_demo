package com.example.clevertap_push_demo

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)

        // Handle notification clicks on Android 12+ explicitly
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            CleverTapAPI.getDefaultInstance(applicationContext)
                ?.pushNotificationClickedEvent(intent?.extras)
        }
    }
}
