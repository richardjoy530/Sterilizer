package com.ibis.sterilizer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


private const val REQUEST_ACCESS_FINE_LOCATION_PERMISSION = 200
private const val TAG = "FlutterActivity"

class MainActivity : FlutterActivity() {
    private val channel = "com.ibis.sterilizer/channel"
    private val permissions: Array<String> = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "permission" -> {
                    permissionHandler(result, call)
                }
                "register" -> {
                    register(result, call)
                }
                "connectHome" -> {
                    connectHome(result, call)
                }
                "ssid" -> {
                    getSSID(result, call)
                }
            }
        }
    }

    private fun register(result: MethodChannel.Result, call: MethodCall) {
        val ssid: String = call.argument("ssid")!!
        val pass: String = call.argument("password")!!
        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        if (Build.VERSION.SDK_INT < 29) {
            val addNetwork = wifiManager.addNetwork(createWifiConfig(ssid, pass))
            wifiManager.enableNetwork(addNetwork, true)
            result.success(true)
        } else {
            val wifiNetworkSpecifier = WifiNetworkSpecifier.Builder()
                    .setSsid(ssid)
                    .setWpa2Passphrase(pass)
                    .build()
            val networkRequest = NetworkRequest.Builder()
                    .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                    .setNetworkSpecifier(wifiNetworkSpecifier)
                    .build()
            val connectivityManager =
                    applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val networkCallback = ConnectivityManager.NetworkCallback()
            connectivityManager.requestNetwork(networkRequest, networkCallback)
            result.success(true)
        }
    }

    private fun getSSID(result: MethodChannel.Result, call: MethodCall) {
        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        result.success(wifiManager.connectionInfo.ssid)
    }

    private fun connectHome(result: MethodChannel.Result, call: MethodCall) {
        Log.d(TAG, "connectHome: In")
        val ssid: String = call.argument("ssid")!!
        val pass: String = call.argument("password")!!
        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        if (!wifiManager.isWifiEnabled) wifiManager.isWifiEnabled = true
//        if (Build.VERSION.SDK_INT < 29) {
//            Log.d(TAG, "connectHome: OLD")
//            val addNetwork: Int = wifiManager.addNetwork(createWifiConfig(ssid, pass))
//            wifiManager.enableNetwork(addNetwork, true)
//            wifiManager.reconnect()
//        } else {
//            Log.d(TAG, "connectHome: NEW")
//            wifiManager.removeNetworkSuggestions(
//                    listOf(WifiNetworkSuggestion.Builder()
//                            .setSsid(ssid)
//                            .build()))
//        }
        result.success(true)
    }

    private fun permissionHandler(result: MethodChannel.Result, call: MethodCall) {
        when (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
            PackageManager.PERMISSION_GRANTED -> result.success(true)
            PackageManager.PERMISSION_DENIED -> {
                ActivityCompat.requestPermissions(
                        this,
                        permissions,
                        REQUEST_ACCESS_FINE_LOCATION_PERMISSION
                )
                result.success(true)
            }
        }
    }

    private fun createWifiConfig(ssid: String, pass: String): WifiConfiguration? {
        val config = WifiConfiguration()
        config.SSID = "\"" + ssid + "\"";
        config.preSharedKey = "\"" + pass + "\""
        config.status = WifiConfiguration.Status.ENABLED
        return config
    }
}
