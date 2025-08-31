package com.example.clevertap_push_demo

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import com.clevertap.android.sdk.CleverTapAPI

class MainActivity : FlutterActivity() {

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Forward notification click payload to CleverTap
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            CleverTapAPI.getDefaultInstance(applicationContext)
                ?.pushNotificationClickedEvent(intent.extras)
        }
    }
}
