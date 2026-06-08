import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    setState(() {
      _errorMessage = null;
    });

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }

    final phone = _phoneController.text.trim();

    // Validate
    final error = WalletService.validateWithdrawal(
      amount: amount,
      kbzPhone: phone,
    );

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // Submit
    setState(() => _isLoading = true);

    final result = await WalletService.withdrawToKBZPay(
      amount: amount,
      kbzPhone: phone,
      driverName: 'Driver', // TODO: get from profile
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      _showSuccessDialog(result.message);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Request Submitted!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to wallet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletService.formattedBalance;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Withdraw to KBZ Pay',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Balance',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      balance,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              Text(
                'Withdrawal Amount (Ks)',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'e.g. 10000',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 20,
                  ),
                  prefixText: 'Ks ',
                  prefixStyle: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Minimum withdrawal: Ks 5,000',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),

              // KBZ Pay Phone
              Text(
                'KBZ Pay Phone Number',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. 09XXXXXXXXX',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Make sure the phone number is registered with KBZ Pay',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF1A1A2E),
                    disabledBackgroundColor:
                        const Color(0xFFFFD700).withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF1A1A2E)),
                          ),
                        )
                      : Text(
                          'Submit Withdrawal Request',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
