import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'ride_in_progress_screen.dart';
import '../services/notification_service.dart';

class OrderCenterScreen extends StatefulWidget {
  const OrderCenterScreen({super.key});

  @override
  State<OrderCenterScreen> createState() => _OrderCenterScreenState();
}

class _OrderCenterScreenState extends State<OrderCenterScreen> {
  List<RideOrder> _orders = [];
  bool _isLoading = true;
  RideOrder? _acceptedOrder;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  /// Load orders and show notification (must be called after first frame)
  void _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    OrderService.generateMockOrders();
    final pendingOrders = OrderService.getPendingOrders();
    final activeOrder = OrderService.getCurrentActiveOrder();

    // Show notification for new orders (simulate push)
    if (pendingOrders.isNotEmpty && mounted) {
      await NotificationService.showNewOrderNotification(
        orderId: pendingOrders.first.id,
        passengerName: pendingOrders.first.passengerName,
        pickupAddress: pendingOrders.first.pickupAddress,
      );
    }

    setState(() {
      _orders = pendingOrders;
      _acceptedOrder = activeOrder;
      _isLoading = false;
    });
  }

  void _acceptOrder(RideOrder order) {
    final accepted = OrderService.acceptOrder(order.id);
    if (accepted != null) {
      // Show system notification
      NotificationService.showOrderAcceptedNotification(
        orderId: accepted.id,
        passengerName: accepted.passengerName,
      );

      setState(() {
        _acceptedOrder = accepted;
        _orders = OrderService.getPendingOrders();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order accepted! Navigating to pickup...',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to ride in progress screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideInProgressScreen(
            passengerName: accepted.passengerName,
            pickupAddress: accepted.pickupAddress,
            destinationAddress: accepted.destinationAddress,
            distance: accepted.distance,
            duration: accepted.estimatedTime,
          ),
        ),
      ).then((_) => _loadOrders());
    }
  }

  void _rejectOrder(RideOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(
          'Reject Order?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Reject order from ${order.passengerName}?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              OrderService.rejectOrder(order.id);
              setState(() {
                _orders = OrderService.getPendingOrders();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order rejected',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.grey[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Reject',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final minutes = DateTime.now().difference(dateTime).inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return '${minutes}m ago';
    return '${minutes ~/ 60}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Order Center',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF2A2A3E),
              child: _orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_orders[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders available',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(RideOrder order) {
    final vehicleColor = _getVehicleColor(order.vehicleType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Vehicle type + Time ago
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: vehicleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.vehicleType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: vehicleColor,
                    ),
                  ),
                ),
                Text(
                  _formatTimeAgo(order.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Passenger info
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFFD700),
                  child: Icon(Icons.person, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.passengerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        order.passengerPhone,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Ks ${order.estimatedFare.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),

            // Pickup address
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.pickupAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Destination address
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.destinationAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Distance + Time info
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${order.distance} km',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${order.estimatedTime} min',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Accept / Reject buttons
            Row(
              children: [
                // Reject button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectOrder(order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
