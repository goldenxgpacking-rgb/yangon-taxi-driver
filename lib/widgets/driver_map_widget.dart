import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable map widget using OpenStreetMap (free, no API key needed).
class DriverMapWidget extends StatefulWidget {
  final LatLng? driverPosition;
  final LatLng? pickupPosition;
  final LatLng? destinationPosition;
  final double? heading;
  final bool showRoute;
  final bool interactive;
  final double? zoom;

  const DriverMapWidget({
    super.key,
    this.driverPosition,
    this.pickupPosition,
    this.destinationPosition,
    this.heading,
    this.showRoute = false,
    this.interactive = true,
    this.zoom,
  });

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.driverPosition != null &&
        widget.driverPosition != oldWidget.driverPosition) {
      _mapController.move(widget.driverPosition!, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.driverPosition ??
        widget.pickupPosition ??
        const LatLng(16.8661, 96.1951); // Yangon center

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: widget.zoom ?? 14.0,
          interactionOptions: InteractionOptions(
            flags: widget.interactive
                ? InteractiveFlag.all
                : InteractiveFlag.none,
          ),
        ),
        children: [
          // OpenStreetMap tile layer
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.yangontaxi.driver',
            maxZoom: 19,
          ),

          // Route polyline (pickup → destination)
          if (widget.showRoute &&
              widget.pickupPosition != null &&
              widget.destinationPosition != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    widget.pickupPosition!,
                    widget.destinationPosition!,
                  ],
                  color: const Color(0xFFFFD700).withOpacity(0.8),
                  strokeWidth: 4.0,
                  pattern: const StrokePattern.dotted(),
                ),
              ],
            ),

          // Pickup marker (green)
          if (widget.pickupPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.pickupPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
              ],
            ),

          // Destination marker (red)
          if (widget.destinationPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.destinationPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ],
            ),

          // Driver marker (gold taxi icon)
          if (widget.driverPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.driverPosition!,
                  width: 44,
                  height: 44,
                  child: Transform.rotate(
                    angle: (widget.heading ?? 0) * 3.14159 / 180,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Map attribution (required by OSM)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white54,
              child: Text(
                '© OpenStreetMap',
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact map preview card for use in lists/cards.
class MapPreviewCard extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final VoidCallback? onTap;

  const MapPreviewCard({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yangontaxi.driver',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 32,
                        height: 32,
                        child: const Icon(
                          Icons.local_taxi,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onTap != null)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap to view',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
