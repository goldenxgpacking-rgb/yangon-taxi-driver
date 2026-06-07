enum OrderStatus {
  pending, // 等待司机接单
  accepted, // 已接单
  arrived, // 司机已到达上车点
  inProgress, // 行程中
  completed, // 已完成
  cancelled, // 已取消
}

class RideOrder {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final String vehicleType; // CNG CAR / OIL CAR / EV CAR / 私家车
  final double estimatedFare;
  final double distance; // km
  final int estimatedTime; // minutes
  final OrderStatus status;
  final DateTime createdAt;

  RideOrder({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicleType,
    required this.estimatedFare,
    required this.distance,
    required this.estimatedTime,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'vehicleType': vehicleType,
      'estimatedFare': estimatedFare,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RideOrder.fromMap(Map<String, dynamic> map) {
    return RideOrder(
      id: map['id'],
      passengerName: map['passengerName'],
      passengerPhone: map['passengerPhone'],
      pickupAddress: map['pickupAddress'],
      pickupLat: map['pickupLat'],
      pickupLng: map['pickupLng'],
      destinationAddress: map['destinationAddress'],
      destinationLat: map['destinationLat'],
      destinationLng: map['destinationLng'],
      vehicleType: map['vehicleType'],
      estimatedFare: map['estimatedFare'],
      distance: map['distance'],
      estimatedTime: map['estimatedTime'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
