import '../models/order.dart';

/// Mock earnings service - simulates driver earnings history
class EarningsService {
  static List<EarningsEntry> _todayEntries = [];
  static List<EarningsEntry> _weekEntries = [];
  static List<EarningsEntry> _monthEntries = [];

  static void _generateMockData() {
    final now = DateTime.now();

    _todayEntries = [
      EarningsEntry(
        orderId: 'TR001',
        passengerName: 'Aung Aung',
        pickupAddress: 'Sule Pagoda, Yangon',
        destinationAddress: 'Yangon International Airport',
        vehicleType: 'CNG CAR',
        amount: 8500,
        distance: 8.5,
        duration: const Duration(minutes: 25),
        completedAt: now.subtract(const Duration(hours: 1)),
        paymentMethod: 'Cash',
      ),
      EarningsEntry(
        orderId: 'TR002',
        passengerName: 'Mya Mya',
        pickupAddress: 'Junction City Mall',
        destinationAddress: 'Inya Lake Park',
        vehicleType: 'OIL CAR',
        amount: 4200,
        distance: 4.0,
        duration: const Duration(minutes: 14),
        completedAt: now.subtract(const Duration(hours: 3)),
        paymentMethod: 'KBZ Pay',
      ),
      EarningsEntry(
        orderId: 'TR003',
        passengerName: 'Ko Htet',
        pickupAddress: 'Bogyoke Market',
        destinationAddress: 'Hlaing University',
        vehicleType: 'EV CAR',
        amount: 6100,
        distance: 5.8,
        duration: const Duration(minutes: 18),
        completedAt: now.subtract(const Duration(hours: 5)),
        paymentMethod: 'Cash',
      ),
    ];

    _weekEntries = [
      ..._todayEntries,
      EarningsEntry(
        orderId: 'TR004',
        passengerName: 'Su Su',
        pickupAddress: 'Central Railway Station',
        destinationAddress: 'Kandawgyi Lake',
        vehicleType: 'CNG CAR',
        amount: 3100,
        distance: 2.5,
        duration: const Duration(minutes: 10),
        completedAt: now.subtract(const Duration(days: 1)),
        paymentMethod: 'KBZ Pay',
      ),
      EarningsEntry(
        orderId: 'TR005',
        passengerName: 'Min Min',
        pickupAddress: 'Dagon Center 2',
        destinationAddress: 'Yangon Port',
        vehicleType: 'OIL CAR',
        amount: 7800,
        distance: 7.2,
        duration: const Duration(minutes: 22),
        completedAt: now.subtract(const Duration(days: 1, hours: 4)),
        paymentMethod: 'Cash',
      ),
      EarningsEntry(
        orderId: 'TR006',
        passengerName: 'Hla Hla',
        pickupAddress: 'Shwedagon Pagoda',
        destinationAddress: 'Myanmar Plaza',
        vehicleType: 'CNG CAR',
        amount: 2800,
        distance: 2.2,
        duration: const Duration(minutes: 8),
        completedAt: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Cash',
      ),
      EarningsEntry(
        orderId: 'TR007',
        passengerName: 'Tun Tun',
        pickupAddress: 'Insein Market',
        destinationAddress: 'Yangon University',
        vehicleType: 'EV CAR',
        amount: 5500,
        distance: 5.0,
        duration: const Duration(minutes: 16),
        completedAt: now.subtract(const Duration(days: 3)),
        paymentMethod: 'KBZ Pay',
      ),
    ];

    _monthEntries = [
      ..._weekEntries,
      for (int i = 4; i <= 28; i++)
        EarningsEntry(
          orderId: 'TR${(i + 7).toString().padLeft(3, '0')}',
          passengerName: _names[i % _names.length],
          pickupAddress: _pickups[i % _pickups.length],
          destinationAddress: _destinations[i % _destinations.length],
          vehicleType: _vehicleTypes[i % _vehicleTypes.length],
          amount: (3000 + (i * 217) % 7000).toDouble(),
          distance: (2.0 + (i * 0.3) % 8.0),
          duration: Duration(minutes: 10 + (i * 2) % 30),
          completedAt: now.subtract(Duration(days: i)),
          paymentMethod: i % 2 == 0 ? 'Cash' : 'KBZ Pay',
        ),
    ];
  }

  static final _names = [
    'Aung', 'Mya', 'Ko', 'Su', 'Min', 'Hla', 'Tun', 'Nyi', 'Kyi', ' Toe'
  ];
  static final _pickups = [
    'Sule Pagoda',
    'Junction City',
    'Bogyoke Market',
    'Railway Station',
    'Dagon Center',
    'Shwedagon Pagoda',
    'Insein Market',
    'Hledan Center',
    'Myanmar Plaza',
    'City Hall',
  ];
  static final _destinations = [
    'Airport',
    'Inya Lake',
    'University',
    'Kandawgyi',
    'Port',
    'Myanmar Plaza',
    'Yangon University',
    'Thuwunna',
    'Tamwe',
    'Kamayut',
  ];
  static final _vehicleTypes = [
    'CNG CAR',
    'OIL CAR',
    'EV CAR',
  ];

  static List<EarningsEntry> getTodayEarnings() {
    if (_todayEntries.isEmpty) _generateMockData();
    return _todayEntries;
  }

  static List<EarningsEntry> getWeekEarnings() {
    if (_weekEntries.isEmpty) _generateMockData();
    return _weekEntries;
  }

  static List<EarningsEntry> getMonthEarnings() {
    if (_monthEntries.isEmpty) _generateMockData();
    return _monthEntries;
  }

  static double getTodayTotal() {
    return getTodayEarnings().fold(0, (sum, e) => sum + e.amount);
  }

  static double getWeekTotal() {
    return getWeekEarnings().fold(0, (sum, e) => sum + e.amount);
  }

  static double getMonthTotal() {
    return getMonthEarnings().fold(0, (sum, e) => sum + e.amount);
  }

  /// Record completed ride earnings (called after a ride is completed)
  static void recordRide(RideOrder order) {
    final entry = EarningsEntry(
      orderId: order.id,
      passengerName: order.passengerName,
      pickupAddress: order.pickupAddress,
      destinationAddress: order.destinationAddress,
      vehicleType: order.vehicleType,
      amount: order.estimatedFare,
      distance: order.distance,
      duration: Duration(minutes: order.estimatedTime),
      completedAt: DateTime.now(),
      paymentMethod: 'Cash',
    );

    _todayEntries.insert(0, entry);
    _weekEntries.insert(0, entry);
    _monthEntries.insert(0, entry);
  }
}

class EarningsEntry {
  final String orderId;
  final String passengerName;
  final String pickupAddress;
  final String destinationAddress;
  final String vehicleType;
  final double amount;
  final double distance;
  final Duration duration;
  final DateTime completedAt;
  final String paymentMethod;

  EarningsEntry({
    required this.orderId,
    required this.passengerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.vehicleType,
    required this.amount,
    required this.distance,
    required this.duration,
    required this.completedAt,
    required this.paymentMethod,
  });
}
