package com.example.clevertap_push_demo

import android.app.Application
import com.clevertap.android.sdk.CleverTapAPI
import com.clevertap.android.sdk.ActivityLifecycleCallback

class MyApplication : Application() {
    override fun onCreate() {
        // Required for CleverTap to track activity lifecycle
        ActivityLifecycleCallback.register(this)
        super.onCreate()

        // Get CleverTap default instance
        val cleverTapDefaultInstance = CleverTapAPI.getDefaultInstance(applicationContext)
        cleverTapDefaultInstance?.enableDeviceNetworkInfoReporting(true)

        // Enable CleverTap debug logging
        CleverTapAPI.setDebugLevel(CleverTapAPI.LogLevel.DEBUG)
    }
}
