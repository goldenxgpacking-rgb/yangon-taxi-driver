import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<RideOrder> _completedOrders = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Make sure mock data is generated
    OrderService.generateMockOrders();
    final completed = OrderService.getCompletedOrders();

    // Add some mock completed trips if empty
    if (completed.isEmpty) {
      _addMockCompletedTrips();
    }

    setState(() {
      _completedOrders = OrderService.getCompletedOrders();
      _isLoading = false;
    });
  }

  void _addMockCompletedTrips() {
    final now = DateTime.now();
    final mockCompleted = [
      RideOrder(
        id: 'CMP001',
        passengerName: 'Aung Aung',
        passengerPhone: '09-111111111',
        pickupAddress: 'Sule Pagoda, Yangon',
        pickupLat: 16.8723,
        pickupLng: 96.1790,
        destinationAddress: 'Yangon International Airport',
        destinationLat: 16.9075,
        destinationLng: 96.1336,
        vehicleType: 'CNG CAR',
        estimatedFare: 8500,
        distance: 8.5,
        estimatedTime: 25,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      RideOrder(
        id: 'CMP002',
        passengerName: 'Mya Mya',
        passengerPhone: '09-222222222',
        pickupAddress: 'Junction City Mall, Yangon',
        pickupLat: 16.8615,
        pickupLng: 96.1824,
        destinationAddress: 'Inya Lake Park',
        destinationLat: 16.8661,
        destinationLng: 96.1951,
        vehicleType: 'OIL CAR',
        estimatedFare: 4500,
        distance: 4.2,
        estimatedTime: 15,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      RideOrder(
        id: 'CMP003',
        passengerName: 'Ko Htet',
        passengerPhone: '09-333333333',
        pickupAddress: 'Bogyoke Aung San Market',
        pickupLat: 16.8667,
        pickupLng: 96.1887,
        destinationAddress: 'Hlaing University',
        destinationLat: 16.8500,
        destinationLng: 96.1167,
        vehicleType: 'EV CAR',
        estimatedFare: 6200,
        distance: 6.0,
        estimatedTime: 20,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      RideOrder(
        id: 'CMP004',
        passengerName: 'Su Su',
        passengerPhone: '09-444444444',
        pickupAddress: 'Yangon Central Railway Station',
        pickupLat: 16.8708,
        pickupLng: 96.1714,
        destinationAddress: 'Kandawgyi Lake',
        destinationLat: 16.8667,
        destinationLng: 96.2000,
        vehicleType: 'CNG CAR',
        estimatedFare: 3200,
        distance: 2.8,
        estimatedTime: 10,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      RideOrder(
        id: 'CMP005',
        passengerName: 'Min Min',
        passengerPhone: '09-555555555',
        pickupAddress: 'Dagon Center 2',
        pickupLat: 16.8417,
        pickupLng: 96.1767,
        destinationAddress: 'Yangon Port',
        destinationLat: 16.7833,
        destinationLng: 96.1667,
        vehicleType: 'OIL CAR',
        estimatedFare: 7800,
        distance: 7.5,
        estimatedTime: 22,
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
    ];

    for (final order in mockCompleted) {
      // Use private _mockOrders directly via service
      // We'll add them through a helper
    }
  }

  List<RideOrder> get _filteredOrders {
    if (_filterStatus == 'All') return _completedOrders;
    return _completedOrders.where((o) {
      if (_filterStatus == 'CNG CAR') return o.vehicleType == 'CNG CAR';
      if (_filterStatus == 'OIL CAR') return o.vehicleType == 'OIL CAR';
      if (_filterStatus == 'EV CAR') return o.vehicleType == 'EV CAR';
      return true;
    }).toList();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM d, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trip History',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : Column(
              children: [
                // Filter chips
                _buildFilterChips(),
                const SizedBox(height: 8),
                // Trip count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredOrders.length} trips',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: Ks ${_getTotalEarnings().toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Trip list
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildTripCard(_filteredOrders[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'CNG CAR',
      'OIL CAR',
      'EV CAR',
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == filter;
          return FilterChip(
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _filterStatus = filter;
              });
            },
            backgroundColor: const Color(0xFF2A2A3E),
            selectedColor: const Color(0xFFFFD700).withOpacity(0.2),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.white24,
            ),
            label: Text(
              filter,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : Colors.white54,
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 70,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'No trip history',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed trips will appear here',
            style: GoogleFonts.poppins(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(RideOrder order) {
    final vehicleColor = _getVehicleColor(order.vehicleType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => _showTripDetail(order),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: vehicle type + time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: vehicleColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.vehicleType,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: vehicleColor,
                      ),
                    ),
                  ),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 14),

              // Passenger info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFFD700),
                    child: Icon(Icons.person, color: Colors.black, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.passengerName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          order.passengerPhone,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Ks ${order.estimatedFare.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Route
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 10),
                      Container(
                        width: 2,
                        height: 24,
                        color: Colors.white24,
                      ),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 10),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.pickupAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          order.destinationAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Distance + time
              Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    '${order.distance} km',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    '${order.estimatedTime} min',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripDetail(RideOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A3E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trip Details',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Passenger', order.passengerName),
            _buildDetailRow('Phone', order.passengerPhone),
            _buildDetailRow('Pickup', order.pickupAddress),
            _buildDetailRow('Destination', order.destinationAddress),
            _buildDetailRow('Vehicle', order.vehicleType),
            _buildDetailRow('Distance', '${order.distance} km'),
            _buildDetailRow('Est. Time', '${order.estimatedTime} min'),
            _buildDetailRow('Fare', 'Ks ${order.estimatedFare.toStringAsFixed(0)}'),
            _buildDetailRow('Date', _formatDateTime(order.createdAt)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getTotalEarnings() {
    return _filteredOrders.fold(
      0,
      (sum, o) => sum + o.estimatedFare,
    );
  }

  Color _getVehicleColor(String vehicleType) {
    switch (vehicleType) {
      case 'CNG CAR':
        return Colors.green;
      case 'OIL CAR':
        return Colors.orange;
      case 'EV CAR':
        return Colors.blue;
      case '私家车':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
