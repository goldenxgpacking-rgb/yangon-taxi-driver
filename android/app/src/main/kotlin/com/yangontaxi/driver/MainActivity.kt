package com.yangontaxi.driver

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yangontaxi.driver/location"
    private lateinit var locationManager: LocationManager
    private var methodChannel: MethodChannel? = null
    private val executor = Executors.newSingleThreadExecutor()

    @SuppressLint("MissingPermission")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestLocationPermission" -> handleRequestPermission(result)
                "getLastKnownLocation" -> handleGetLastKnownLocation(result)
                "startLocationUpdates" -> handleStartLocationUpdates(result)
                "stopLocationUpdates" -> handleStopLocationUpdates(result)
                "isGpsEnabled" -> handleIsGpsEnabled(result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            locationManager.removeUpdates(locationListener)
        } catch (_: Exception) {}
    }

    private fun handleRequestPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED
            ) {
                result.success(true)
            } else {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION
                    ),
                    LOCATION_PERMISSION_REQUEST_CODE
                )
                result.success(false) // Will be handled in onRequestPermissionsResult
            }
        } else {
            result.success(true)
        }
    }

    @SuppressLint("MissingPermission")
    private fun handleGetLastKnownLocation(result: MethodChannel.Result) {
        val location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            ?: locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

        if (location != null) {
            result.success(mapOf(
                "latitude" to location.latitude,
                "longitude" to location.longitude,
                "speed" to location.speed,
                "bearing" to location.bearing,
                "accuracy" to location.accuracy,
                "timestamp" to location.time
            ))
        } else {
            result.success(null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun handleStartLocationUpdates(result: MethodChannel.Result) {
        try {
            // Try GPS first, fall back to network
            val hasGps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
            val hasNetwork = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)

            if (hasGps) {
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    2000L, // 2 seconds
                    5.0f,  // 5 meters
                    locationListener,
                    Looper.getMainLooper()
                )
            }

            if (hasNetwork && !hasGps) {
                locationManager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    2000L,
                    5.0f,
                    locationListener,
                    Looper.getMainLooper()
                )
            }

            result.success(null)
        } catch (e: Exception) {
            result.error("LOCATION_ERROR", e.message, null)
        }
    }

    private fun handleStopLocationUpdates(result: MethodChannel.Result) {
        try {
            locationManager.removeUpdates(locationListener)
            result.success(null)
        } catch (e: Exception) {
            result.error("LOCATION_ERROR", e.message, null)
        }
    }

    private fun handleIsGpsEnabled(result: MethodChannel.Result) {
        result.success(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
    }

    private val locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            val map = mapOf(
                "latitude" to location.latitude,
                "longitude" to location.longitude,
                "speed" to location.speed,
                "bearing" to location.bearing,
                "accuracy" to location.accuracy,
                "timestamp" to location.time
            )
            Handler(Looper.getMainLooper()).post {
                methodChannel?.invokeMethod("onLocationUpdate", map)
            }
        }

        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            methodChannel?.invokeMethod("onPermissionResult", granted)
        }
    }

    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1001
    }
}
