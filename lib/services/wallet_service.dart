/// Wallet service - manages driver wallet balance and withdrawals
class WalletService {
  // Mock wallet balance (in Kyat)
  static double _balance = 157500; // Start with some balance for testing

  // Withdrawal history
  static List<WithdrawalEntry> _withdrawals = [];

  /// Get current wallet balance
  static double get balance => _balance;

  /// Get formatted balance
  static String get formattedBalance => 'Ks ${_balance.toStringAsFixed(0)}';

  /// Check if withdrawal amount is valid
  static String? validateWithdrawal({
    required double amount,
    required String kbzPhone,
  }) {
    // Check minimum withdrawal
    if (amount < 5000) {
      return 'Minimum withdrawal amount is Ks 5,000';
    }

    // Check sufficient balance
    if (amount > _balance) {
      return 'Insufficient balance. Available: Ks ${_balance.toStringAsFixed(0)}';
    }

    // Check KBZ Pay phone number
    if (kbzPhone.isEmpty) {
      return 'Please enter your KBZ Pay phone number';
    }

    if (!_isValidMyanmarPhone(kbzPhone)) {
      return 'Please enter a valid Myanmar phone number (e.g., 09XXXXXXXXX)';
    }

    return null; // No error
  }

  /// Process withdrawal to KBZ Pay
  static Future<WithdrawalResult> withdrawToKBZPay({
    required double amount,
    required String kbzPhone,
    required String driverName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Deduct from wallet
    _balance -= amount;

    // Record withdrawal
    final entry = WithdrawalEntry(
      id: 'WD${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      kbzPhone: kbzPhone,
      driverName: driverName,
      status: WithdrawalStatus.pending,
      requestedAt: DateTime.now(),
      completedAt: null,
    );

    _withdrawals.insert(0, entry);

    return WithdrawalResult(
      success: true,
      message:
          'Withdrawal request submitted successfully. Amount: Ks ${amount.toStringAsFixed(0)} will be transferred to $kbzPhone within 24 hours.',
      withdrawal: entry,
    );
  }

  /// Get withdrawal history
  static List<WithdrawalEntry> getWithdrawalHistory() {
    return _withdrawals;
  }

  /// Add earnings to wallet (called when ride is completed with online payment)
  static void addEarnings(double amount) {
    _balance += amount;
  }

  /// Validate Myanmar phone number
  static bool _isValidMyanmarPhone(String phone) {
    // Remove spaces and dashes
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it starts with 09 and has 9-11 digits
    return RegExp(r'^09\d{7,9}$').hasMatch(cleaned);
  }

  /// Get recent withdrawals (for display)
  static List<WithdrawalEntry> getRecentWithdrawals({int limit = 5}) {
    final sorted = [..._withdrawals];
    sorted.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return sorted.take(limit).toList();
  }
}

/// Withdrawal result
class WithdrawalResult {
  final bool success;
  final String message;
  final WithdrawalEntry? withdrawal;

  WithdrawalResult({
    required this.success,
    required this.message,
    this.withdrawal,
  });
}

/// Withdrawal entry model
class WithdrawalEntry {
  final String id;
  final double amount;
  final String kbzPhone;
  final String driverName;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  WithdrawalEntry({
    required this.id,
    required this.amount,
    required this.kbzPhone,
    required this.driverName,
    required this.status,
    required this.requestedAt,
    this.completedAt,
  });

  String get formattedStatus {
    switch (status) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.failed:
        return 'Failed';
    }
  }
}

/// Withdrawal status enum
enum WithdrawalStatus {
  pending,
  processing,
  completed,
  failed,
}
