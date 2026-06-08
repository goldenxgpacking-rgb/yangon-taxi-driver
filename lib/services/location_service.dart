import 'dart:async';
import 'dart:math';

/// Location service for tracking driver position.
/// Uses mock data for demo; replace with geolocator for production.
class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  // Yangon center
  static const double yangonLat = 16.8661;
  static const double yangonLng = 96.1951;

  double _currentLat = yangonLat;
  double _currentLng = yangonLng;
  double _heading = 0.0;
  double _speed = 0.0; // km/h
  bool _isTracking = false;
  Timer? _trackingTimer;
  final StreamController<LocationUpdate> _locationController =
      StreamController<LocationUpdate>.broadcast();

  Stream<LocationUpdate> get locationStream => _locationController.stream;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  double get heading => _heading;
  double get speed => _speed;
  bool get isTracking => _isTracking;

  /// Start tracking driver location
  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _speed = 25.0; // average driving speed in Yangon

    _trackingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _updateLocation(),
    );
  }

  /// Stop tracking
  void stopTracking() {
    _isTracking = false;
    _speed = 0.0;
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  void _updateLocation() {
    // Simulate movement along a route
    final rng = Random();
    _heading = (rng.nextDouble() * 360);

    // Move approximately 25km/h = ~14m per 2 seconds
    final distance = (25.0 / 3600.0) * 2.0; // km
    final radHeading = _heading * pi / 180;
    _currentLat += (distance / 111.32) * cos(radHeading);
    _currentLng +=
        (distance / (111.32 * cos(_currentLat * pi / 180))) * sin(radHeading);

    // Add slight randomness
    _currentLat += (rng.nextDouble() - 0.5) * 0.0001;
    _currentLng += (rng.nextDouble() - 0.5) * 0.0001;

    _locationController.add(LocationUpdate(
      lat: _currentLat,
      lng: _currentLng,
      heading: _heading,
      speed: _speed,
      timestamp: DateTime.now(),
    ));
  }

  /// Simulate a route from pickup to destination
  void simulateRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
  }) {
    _currentLat = pickupLat;
    _currentLng = pickupLng;

    // Calculate heading toward destination
    final dLat = destLat - pickupLat;
    final dLng = destLng - pickupLng;
    _heading = atan2(dLng, dLat) * 180 / pi;
    if (_heading < 0) _heading += 360;

    startTracking();
  }

  /// Calculate distance between two points in km
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // km
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
  final double speed;
  final DateTime timestamp;

  LocationUpdate({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });
}
