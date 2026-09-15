package com.example.family_control

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "family_control/device_policy"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "lockApps" -> {
                    result.success(lockApps())
                }

                "unlockApps" -> {
                    result.success(unlockApps())
                }

                "isDeviceOwner" -> {
                    result.success(isDeviceOwner())
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getDevicePolicyManager(): DevicePolicyManager {
        return getSystemService(Context.DEVICE_POLICY_SERVICE)
                as DevicePolicyManager
    }

    private fun getAdminComponent(): ComponentName {
        return ComponentName(
            this,
            MyDeviceAdminReceiver::class.java
        )
    }
    /////////////////////////////the lock code part ////////////////////////////////
    private fun isDeviceOwner(): Boolean {
        return getDevicePolicyManager().isDeviceOwnerApp(packageName)
    }

    private fun lockApps(): Boolean {

        if (!isDeviceOwner()) {
            return false
        }

        val appsToBlock = arrayOf(
            "com.google.android.youtube",
            "com.facebook.katana",
            "com.instagram.android",
            "com.zhiliaoapp.musically"
        )

        return try {
            getDevicePolicyManager().setPackagesSuspended(
                getAdminComponent(),
                appsToBlock,
                true
            )
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun unlockApps(): Boolean {

        if (!isDeviceOwner()) {
            return false
        }

        val appsToBlock = arrayOf(
            "com.google.android.youtube",
            "com.facebook.katana",
            "com.instagram.android",
            "com.zhiliaoapp.musically"
        )

        return try {
            getDevicePolicyManager().setPackagesSuspended(
                getAdminComponent(),
                appsToBlock,
                false
            )
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}