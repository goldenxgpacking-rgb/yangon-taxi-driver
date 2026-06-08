import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/earnings_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'My Earnings',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EarningsList(
            earnings: EarningsService.getTodayEarnings(),
            periodLabel: "Today's Summary",
          ),
          _EarningsList(
            earnings: EarningsService.getWeekEarnings(),
            periodLabel: 'This Week Summary',
          ),
          _EarningsList(
            earnings: EarningsService.getMonthEarnings(),
            periodLabel: 'This Month Summary',
          ),
        ],
      ),
    );
  }
}

class _EarningsList extends StatelessWidget {
  final List<EarningsEntry> earnings;
  final String periodLabel;

  const _EarningsList({
    required this.earnings,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final total = earnings.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final completedTrips = earnings.length;
    final avgRating = 4.8; // Mock

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD700).withOpacity(0.3),
                const Color(0xFFFFD700).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              Text(
                periodLabel,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ks ${total.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Trips',
                    value: '$completedTrips',
                    color: Colors.green,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                  ),
                  _buildStatItem(
                    icon: Icons.star,
                    label: 'Rating',
                    value: avgRating.toStringAsFixed(1),
                    color: Colors.orange,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                  ),
                  _buildStatItem(
                    icon: Icons.route,
                    label: 'Distance',
                    value:
                        '${earnings.fold<double>(0, (s, e) => s + e.distance).toStringAsFixed(1)} km',
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Trip history header
        Text(
          'Trip History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        if (earnings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No completed trips yet',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...earnings.map((e) => _buildTripCard(e)),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(EarningsService.EarningsEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Vehicle icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getVehicleColor(entry.vehicleType).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_taxi,
              color: _getVehicleColor(entry.vehicleType),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Trip details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.pickupAddress.split(',').first,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      entry.vehicleType,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.distance.toStringAsFixed(1)} km',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.duration.inMinutes} min',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ks ${entry.amount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatTime(entry.completedAt),
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getVehicleColor(String type) {
    switch (type) {
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

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
