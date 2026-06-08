import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';

/// Location service for tracking driver position.
/// Uses real GPS via MethodChannel on Android, falls back to mock on other platforms.
class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  static const _channel = MethodChannel('com.yangontaxi.driver/location');

  // Yangon center (default fallback)
  static const double yangonLat = 16.8661;
  static const double yangonLng = 96.1951;

  double _currentLat = yangonLat;
  double _currentLng = yangonLng;
  double _heading = 0.0;
  double _speed = 0.0; // m/s
  bool _isTracking = false;
  bool _useRealGps = false;
  Timer? _trackingTimer;
  StreamSubscription? _gpsSubscription;
  final StreamController<LocationUpdate> _locationController =
      StreamController<LocationUpdate>.broadcast();

  Stream<LocationUpdate> get locationStream => _locationController.stream;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  double get heading => _heading;
  double get speed => _speed;
  bool get isTracking => _isTracking;
  bool get useRealGps => _useRealGps;

  /// Initialize GPS. Returns true if real GPS is available.
  Future<bool> initialize() async {
    if (!Platform.isAndroid) return false;

    try {
      final hasPermission = await _channel.invokeMethod<bool>('requestLocationPermission');
      if (hasPermission != true) return false;

      // Test if we can get a location
      final location = await _channel.invokeMethod<Map>('getLastKnownLocation');
      if (location != null) {
        _currentLat = (location['latitude'] as num).toDouble();
        _currentLng = (location['longitude'] as num).toDouble();
        _useRealGps = true;
        return true;
      }
    } catch (e) {
      debugPrint('GPS init failed: $e');
    }
    return false;
  }

  /// Start tracking driver location
  Future<void> startTracking() async {
    if (_isTracking) return;
    _isTracking = true;

    if (_useRealGps && Platform.isAndroid) {
      _startRealGpsTracking();
    } else {
      _startMockTracking();
    }
  }

  void _startRealGpsTracking() {
    try {
      _channel.invokeMethod('startLocationUpdates').then((_) {
        // Listen for location updates from native
        _channel.setMethodCallHandler(_handleLocationUpdate);
      }).catchError((e) {
        debugPrint('Failed to start GPS updates: $e');
        _startMockTracking(); // Fallback
      });
    } catch (e) {
      _startMockTracking();
    }
  }

  Future<dynamic> _handleLocationUpdate(MethodCall call) async {
    if (call.method == 'onLocationUpdate') {
      final args = call.arguments as Map;
      _currentLat = (args['latitude'] as num).toDouble();
      _currentLng = (args['longitude'] as num).toDouble();
      _speed = (args['speed'] as num?)?.toDouble() ?? 0.0;
      if (args['bearing'] != null) {
        _heading = (args['bearing'] as num).toDouble();
      }

      _locationController.add(LocationUpdate(
        lat: _currentLat,
        lng: _currentLng,
        heading: _heading,
        speed: _speed,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _startMockTracking() {
    _speed = 6.94; // ~25 km/h in m/s
    _trackingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _updateMockLocation(),
    );
  }

  /// Stop tracking
  Future<void> stopTracking() async {
    _isTracking = false;
    _speed = 0.0;
    _trackingTimer?.cancel();
    _trackingTimer = null;

    if (_useRealGps && Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopLocationUpdates');
        _channel.setMethodCallHandler(null);
      } catch (e) {
        debugPrint('Failed to stop GPS: $e');
      }
    }
  }

  void _updateMockLocation() {
    final rng = Random();
    _heading = rng.nextDouble() * 360;
    final distance = (25.0 / 3600.0) * 2.0; // km per 2s at 25km/h
    final radHeading = _heading * pi / 180;
    _currentLat += (distance / 111.32) * cos(radHeading);
    _currentLng +=
        (distance / (111.32 * cos(_currentLat * pi / 180))) * sin(radHeading);
    _currentLat += (rng.nextDouble() - 0.5) * 0.0001;
    _currentLng += (rng.nextDouble() - 0.5) * 0.0001;

    _locationController.add(LocationUpdate(
      lat: _currentLat,
      lng: _currentLng,
      heading: _heading,
      speed: 6.94,
      timestamp: DateTime.now(),
    ));
  }

  /// Simulate a route from pickup to destination (for testing)
  void simulateRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
  }) {
    _currentLat = pickupLat;
    _currentLng = pickupLng;
    final dLat = destLat - pickupLat;
    final dLng = destLng - pickupLng;
    _heading = atan2(dLng, dLat) * 180 / pi;
    if (_heading < 0) _heading += 360;
    startTracking();
  }

  /// Calculate distance between two points in km (Haversine)
  static double calculateDistance(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Estimate travel time in minutes
  static int estimateTravelTime(double distanceKm, {double avgSpeedKmh = 25.0}) {
    return ((distanceKm / avgSpeedKmh) * 60).round();
  }

  static double _toRad(double deg) => deg * pi / 180;

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}

class LocationUpdate {
  final double lat;
  final double lng;
  final double heading;
  final double speed; // m/s
  final DateTime timestamp;

  LocationUpdate({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });
}
