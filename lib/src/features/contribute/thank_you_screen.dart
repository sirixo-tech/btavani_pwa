part of '../../../main.dart';

class ThankYouScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final VoidCallback onBackToHome;
  final VoidCallback onViewTracker;

  const ThankYouScreen({
    super.key,
    required this.paymentData,
    required this.onBackToHome,
    required this.onViewTracker,
  });

  @override
  Widget build(BuildContext context) {
    final amount = paymentData['amount'] ?? 0;
    final date = paymentData['createdAt'] != null
        ? DateFormat('dd MMM yyyy, h:mm a').format(DateTime.parse(paymentData['createdAt']))
        : DateFormat('dd MMM yyyy, h:mm a').format(DateTime.now());
    final receiptNumber = paymentData['receiptNumber'] ?? '-';
    final blockName = paymentData['blockName'] ?? '-';
    final status = paymentData['status'] == 'paid' ? 'Success' : 'Pending Verification';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: onBackToHome,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank You!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your contribution was successful.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRow('Amount', '₹${NumberFormat('#,##,###').format(amount)}'),
                    _buildRow('Date & Time', date),
                    _buildRow('Receipt No.', receiptNumber),
                    _buildRow('Block', blockName),
                    _buildRow('Status', status, isStatus: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your contribution helps make our Avani Ganesh Utsav 2026 a grand success!',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onBackToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E1119),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'BACK TO HOME',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onViewTracker,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8E1119),
                  side: const BorderSide(color: Color(0xFF8E1119), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'VIEW CONTRIBUTION TRACKER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: value == 'Success' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: value == 'Success' ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
