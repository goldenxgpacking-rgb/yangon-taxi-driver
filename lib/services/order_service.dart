import 'dart:math';
import '../models/order.dart';

/// Mock order service - simulates nearby passenger ride requests
class OrderService {
  static final Random _random = Random();
  static List<RideOrder> _mockOrders = [];

  /// Initialize with mock nearby orders (called when driver goes online)
  static void generateMockOrders() {
    _mockOrders = [
      RideOrder(
        id: 'ORD001',
        passengerName: 'Aung Aung',
        passengerPhone: '09-123456789',
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
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      RideOrder(
        id: 'ORD002',
        passengerName: 'Mya Mya',
        passengerPhone: '09-234567890',
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
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RideOrder(
        id: 'ORD003',
        passengerName: 'Ko Htet',
        passengerPhone: '09-345678901',
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
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      RideOrder(
        id: 'ORD004',
        passengerName: 'Su Su',
        passengerPhone: '09-456789012',
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
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      RideOrder(
        id: 'ORD005',
        passengerName: 'Min Min',
        passengerPhone: '09-567890123',
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
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ];
  }

  /// Get all pending orders (nearby passenger requests)
  static List<RideOrder> getPendingOrders() {
    if (_mockOrders.isEmpty) {
      generateMockOrders();
    }
    return _mockOrders
        .where((order) => order.status == OrderStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Accept an order
  static RideOrder? acceptOrder(String orderId) {
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;

    _mockOrders[index] = RideOrder(
      id: _mockOrders[index].id,
      passengerName: _mockOrders[index].passengerName,
      passengerPhone: _mockOrders[index].passengerPhone,
      pickupAddress: _mockOrders[index].pickupAddress,
      pickupLat: _mockOrders[index].pickupLat,
      pickupLng: _mockOrders[index].pickupLng,
      destinationAddress: _mockOrders[index].destinationAddress,
      destinationLat: _mockOrders[index].destinationLat,
      destinationLng: _mockOrders[index].destinationLng,
      vehicleType: _mockOrders[index].vehicleType,
      estimatedFare: _mockOrders[index].estimatedFare,
      distance: _mockOrders[index].distance,
      estimatedTime: _mockOrders[index].estimatedTime,
      status: OrderStatus.accepted,
      createdAt: _mockOrders[index].createdAt,
    );

    return _mockOrders[index];
  }

  /// Reject an order (mark as cancelled)
  static bool rejectOrder(String orderId) {
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    _mockOrders.removeAt(index);
    return true;
  }

  /// Get current active order (accepted, not completed)
  static RideOrder? getCurrentActiveOrder() {
    try {
      return _mockOrders.firstWhere(
        (o) => o.status == OrderStatus.accepted ||
            o.status == OrderStatus.arrived ||
            o.status == OrderStatus.inProgress,
      );
    } catch (_) {
      return null;
    }
  }

  /// Update order status
  static RideOrder? updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) {
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;

    _mockOrders[index] = RideOrder(
      id: _mockOrders[index].id,
      passengerName: _mockOrders[index].passengerName,
      passengerPhone: _mockOrders[index].passengerPhone,
      pickupAddress: _mockOrders[index].pickupAddress,
      pickupLat: _mockOrders[index].pickupLat,
      pickupLng: _mockOrders[index].pickupLng,
      destinationAddress: _mockOrders[index].destinationAddress,
      destinationLat: _mockOrders[index].destinationLat,
      destinationLng: _mockOrders[index].destinationLng,
      vehicleType: _mockOrders[index].vehicleType,
      estimatedFare: _mockOrders[index].estimatedFare,
      distance: _mockOrders[index].distance,
      estimatedTime: _mockOrders[index].estimatedTime,
      status: newStatus,
      createdAt: _mockOrders[index].createdAt,
    );

    return _mockOrders[index];
  }

  /// Get completed orders for history
  static List<RideOrder> getCompletedOrders() {
    return _mockOrders
        .where((o) => o.status == OrderStatus.completed)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
