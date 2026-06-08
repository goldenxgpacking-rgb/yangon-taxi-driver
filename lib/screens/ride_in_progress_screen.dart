import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'trip_completed_screen.dart';
import '../services/location_service.dart';
import '../widgets/driver_map_widget.dart';

class RideInProgressScreen extends StatefulWidget {
  final String passengerName;
  final String pickupAddress;
  final String destinationAddress;
  final double distance;
  final int duration;

  const RideInProgressScreen({
    super.key,
    required this.passengerName,
    required this.pickupAddress,
    required this.destinationAddress,
    this.distance = 5.2,
    this.duration = 18,
  });

  @override
  State<RideInProgressScreen> createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  bool _hasArrived = false;
  bool _tripStarted = false;
  LatLng? _driverPosition;
  double _heading = 0.0;
  double _currentSpeed = 0.0;
  double _remainingKm = 0.0;
  int _remainingMin = 0;
  StreamSubscription? _locationSub;

  // Mock coordinates for Yangon
  static const LatLng _pickupPos = LatLng(16.8661, 96.1951); // Sule area
  static const LatLng _destPos = LatLng(16.9080, 96.2010); // Airport area

  @override
  void initState() {
    super.initState();
    _driverPosition = _pickupPos;
    _remainingKm = widget.distance;
    _remainingMin = widget.duration;
    _startLocationTracking();
  }

  void _startLocationTracking() async {
    final locationService = LocationService();

    if (locationService.useRealGps) {
      // Real GPS - listen for updates, start from current position
      await locationService.startTracking();
      _locationSub = locationService.locationStream.listen((update) {
        if (mounted) {
          setState(() {
            _driverPosition = LatLng(update.lat, update.lng);
            _heading = update.heading;
            _currentSpeed = update.speed;
            _remainingKm = LocationService.calculateDistance(
              update.lat,
              update.lng,
              _destPos.latitude,
              _destPos.longitude,
            );
            _remainingMin = LocationService.estimateTravelTime(_remainingKm);
          });
        }
      });
    } else {
      // Mock mode - simulate route
      locationService.simulateRoute(
        pickupLat: _pickupPos.latitude,
        pickupLng: _pickupPos.longitude,
        destLat: _destPos.latitude,
        destLng: _destPos.longitude,
      );
      _locationSub = locationService.locationStream.listen((update) {
        if (mounted) {
          setState(() {
            _driverPosition = LatLng(update.lat, update.lng);
            _heading = update.heading;
            _currentSpeed = update.speed;
            _remainingKm = LocationService.calculateDistance(
              update.lat,
              update.lng,
              _destPos.latitude,
              _destPos.longitude,
            );
            _remainingMin = LocationService.estimateTravelTime(_remainingKm);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    LocationService().stopTracking();
    super.dispose();
  }

  void _openNavigation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Google Maps navigation...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markArrived() {
    setState(() {
      _hasArrived = true;
    });
    LocationService().stopTracking();
    _locationSub?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arrived at pickup location'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startTrip() {
    setState(() {
      _tripStarted = true;
    });
    _startLocationTracking();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip started! Drive safely.'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeTrip() {
    LocationService().stopTracking();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TripCompletedScreen(
          passengerName: widget.passengerName,
          destinationAddress: widget.destinationAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _tripStarted ? 'Trip In Progress' : (_hasArrived ? 'At Pickup' : 'Heading to Pickup'),
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Live Map
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DriverMapWidget(
                driverPosition: _driverPosition,
                pickupPosition: _pickupPos,
                destinationPosition: _destPos,
                heading: _heading,
                showRoute: true,
                zoom: 14.0,
              ),
            ),
          ),

          // Status bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  icon: Icons.speed,
                  label: 'Speed',
                  value: '${_currentSpeed.toStringAsFixed(0)} km/h',
                  color: Colors.blue,
                ),
                _buildStatusItem(
                  icon: Icons.straighten,
                  label: 'Remaining',
                  value: '${_remainingKm.toStringAsFixed(1)} km',
                  color: const Color(0xFFFFD700),
                ),
                _buildStatusItem(
                  icon: Icons.access_time,
                  label: 'ETA',
                  value: '$_remainingMin min',
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Trip info panel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Passenger info
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFFFD700),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.passengerName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Passenger',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling passenger...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFFFFD700)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/messages');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Route info
                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.my_location, color: Colors.green, size: 16),
                        Container(width: 2, height: 20, color: Colors.white24),
                        const Icon(Icons.location_on, color: Colors.red, size: 16),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pickupAddress,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.destinationAddress,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildActionButtons(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!_hasArrived) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _openNavigation,
              icon: const Icon(Icons.navigation),
              label: Text(
                'NAVIGATE',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _markArrived,
              icon: const Icon(Icons.flag),
              label: Text(
                'ARRIVED',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!_tripStarted) {
      return ElevatedButton.icon(
        onPressed: _startTrip,
        icon: const Icon(Icons.play_arrow),
        label: Text(
          'START TRIP',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _completeTrip,
      icon: const Icon(Icons.check_circle),
      label: Text(
        'COMPLETE TRIP',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
