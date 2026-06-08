import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_completed_screen.dart';

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

  void _openNavigation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening navigation...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markArrived() {
    setState(() {
      _hasArrived = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Arrived at pickup location'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startTrip() {
    setState(() {
      _tripStarted = true;
    });
  }

  void _completeTrip() {
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
          'Ride In Progress',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pickup & Destination
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.pickupAddress,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.destinationAddress,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.distance} km • ${widget.duration} min',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map Placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, color: Colors.white70, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Map View (Mock)',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (!_hasArrived)
              ElevatedButton(
                onPressed: _openNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'NAVIGATE TO PICKUP',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),

            if (!_hasArrived) const SizedBox(height: 12),

            if (!_hasArrived)
              ElevatedButton(
                onPressed: _markArrived,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ARRIVED',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),

            if (_hasArrived && !_tripStarted) const SizedBox(height: 12),

            if (_hasArrived && !_tripStarted)
              ElevatedButton(
                onPressed: _startTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'START TRIP',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),

            if (_tripStarted) const SizedBox(height: 12),

            if (_tripStarted)
              ElevatedButton(
                onPressed: _completeTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'COMPLETE',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
