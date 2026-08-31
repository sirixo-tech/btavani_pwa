part of '../../../main.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({this.onBackToHome, super.key});

  final VoidCallback? onBackToHome;

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  static const int minimumContributionAmount = 2000;
  static const int maximumContributionAmount = 99000;

  int selectedAmount = 0;

  final List<String> amounts = const [
    '2,001',
    '5,001',
    '10,001',
    '25,001',
    '50,001',
    'Other',
  ];

  // Your Razorpay Payment Page
  static final Uri razorpayPaymentUrl = Uri.parse(
    'https://pages.razorpay.com/BTAVANIganeshchanda',
  );

  bool _openingPayment = false;

  Future<void> _proceedToPay() async {
    if (_openingPayment) return;

    setState(() {
      _openingPayment = true;
    });

    try {
      final selected = amounts[selectedAmount];

      // If "Other" is selected, ask the user for the amount.
      if (selected == 'Other') {
        final amount = await _showCustomAmountDialog();

        if (!mounted) return;

        if (amount == null || amount.trim().isEmpty) {
          return;
        }

        final parsed = double.tryParse(amount.replaceAll(',', '').trim());

        if (parsed == null ||
            parsed < minimumContributionAmount ||
            parsed > maximumContributionAmount) {
          _showSnack('Please enter an amount from Rs 2,000 to Rs 99,000.');
          return;
        }

        await _openRazorpayPage(amount: parsed.toStringAsFixed(0));

        return;
      }

      final amount = selected.replaceAll(',', '');

      await _openRazorpayPage(amount: amount);
    } catch (error) {
      debugPrint('Payment error: $error');

      if (mounted) {
        _showSnack('Unable to open payment page. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingPayment = false;
        });
      }
    }
  }

  Uri _paymentUrlWithAmount(String amount) {
    return razorpayPaymentUrl.replace(
      queryParameters: {
        ...razorpayPaymentUrl.queryParameters,
        'amount': amount,
      },
    );
  }

  Future<void> _openRazorpayPage({required String amount}) async {
    final shouldContinue = await _showPaymentConfirmation(amount);

    if (!shouldContinue || !mounted) {
      return;
    }

    final paymentUrl = _paymentUrlWithAmount(amount);
    final canOpen = await canLaunchUrl(paymentUrl);

    if (!canOpen) {
      if (mounted) {
        _showSnack('Could not open Razorpay payment page.');
      }
      return;
    }

    await launchUrl(paymentUrl, mode: LaunchMode.externalApplication);
  }

  Future<bool> _showPaymentConfirmation(String amount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Contribution',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You are about to contribute',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '₹$amount',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: _maroon,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The selected amount will be opened on Razorpay to complete the payment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<String?> _showCustomAmountDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Enter Amount',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTopBar(
              title: 'Contribute',
              compact: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    return;
                  }

                  widget.onBackToHome?.call();
                },
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              trailing: IconButton(
                tooltip: 'History',
                onPressed: () {},
                icon: const Icon(Icons.history),
              ),
            ),

            const SizedBox(height: 8),

            const FestivalArtCard(),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: panelDecoration(
                color: _paper.withValues(alpha: 0.94),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Avani Ganesh Utsav 2026',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your contribution makes this celebration special',
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Choose an amount',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.55,
              ),
              itemCount: amounts.length,
              itemBuilder: (context, index) {
                final selected = selectedAmount == index;

                final label = amounts[index] == 'Other'
                    ? 'Other'
                    : 'Rs ${amounts[index]}';

                return AmountButton(
                  label: label,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      selectedAmount = index;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_goldLight.withValues(alpha: 0.62), _surfaceWarm],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: _gold.withValues(alpha: 0.22)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Every contribution, big or small,\n'
                'makes a big difference.\n'
                'Thank you!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            const SizedBox(height: 18),

            // PAYMENT BUTTON
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _openingPayment ? null : _proceedToPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maroon,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _maroon.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _openingPayment
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'PROCEED TO PAY',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Secure payment powered by Razorpay',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 10),

            const PaymentBadges(),
          ],
        ),
      ),
    );
  }
}

class FestivalArtCard extends StatelessWidget {
  const FestivalArtCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 126,
        decoration: BoxDecoration(
          color: _surfaceWarm,
          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.16),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/ganesha_contribute.jpg',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              CustomPaint(painter: FestivalArtPainter()),
        ),
      ),
    );
  }
}

class FestivalArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final maroonPaint = Paint()..color = _maroon;

    final goldPaint = Paint()..color = _gold;

    final leafPaint = Paint()..color = _leaf;

    for (final x in [size.width * 0.12, size.width * 0.88]) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * 0.72),
        Paint()
          ..color = const Color(0xFFB77518)
          ..strokeWidth = 2,
      );

      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(Offset(x, 18 + i * 18), 4, goldPaint);
      }

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, size.height * 0.82),
          width: 22,
          height: 9,
        ),
        goldPaint,
      );

      canvas.drawPath(
        Path()
          ..moveTo(x, size.height * 0.58)
          ..lineTo(x - 7, size.height * 0.72)
          ..lineTo(x + 7, size.height * 0.72)
          ..close(),
        maroonPaint,
      );
    }

    final center = Offset(size.width / 2, size.height * 0.55);

    canvas.drawCircle(center, 34, Paint()..color = const Color(0xFFFFDB7B));

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 5),
        width: 44,
        height: 56,
      ),
      goldPaint,
    );

    canvas.drawCircle(center + const Offset(0, -30), 17, maroonPaint);

    canvas.drawCircle(
      center + const Offset(0, -15),
      25,
      Paint()..color = const Color(0xFFFFBE55),
    );

    canvas.drawCircle(center + const Offset(-9, -18), 2.4, maroonPaint);

    canvas.drawCircle(center + const Offset(9, -18), 2.4, maroonPaint);

    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - 10)
        ..quadraticBezierTo(
          center.dx + 20,
          center.dy + 4,
          center.dx + 10,
          center.dy + 22,
        ),
      Paint()
        ..color = maroonPaint.color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(-31, -10),
        width: 22,
        height: 42,
      ),
      goldPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(31, -10),
        width: 22,
        height: 42,
      ),
      goldPaint,
    );

    canvas.drawCircle(center + const Offset(-34, -16), 7, leafPaint);

    canvas.drawCircle(center + const Offset(34, -16), 7, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class AmountButton extends StatelessWidget {
  const AmountButton({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [_maroon, _maroonDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : _paper,
            border: Border.all(
              color: selected ? _maroon : _line.withValues(alpha: 0.9),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _maroon.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentBadges extends StatelessWidget {
  const PaymentBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: PaymentLogoBadge(
            label: 'Google Pay',
            assetPath: 'assets/images/payment/google_pay.png',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: PaymentLogoBadge(
            label: 'PhonePe',
            assetPath: 'assets/images/payment/phonepe.png',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: PaymentLogoBadge(
            label: 'Paytm',
            assetPath: 'assets/images/payment/paytm.jpg',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: PaymentLogoBadge(
            label: 'BHIM',
            assetPath: 'assets/images/payment/bhim.png',
          ),
        ),
      ],
    );
  }
}

class PaymentLogoBadge extends StatelessWidget {
  const PaymentLogoBadge({
    required this.label,
    required this.assetPath,
    super.key,
  });

  final String label;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        alignment: Alignment.center,
        decoration: panelDecoration(radius: 14, elevated: false),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: _maroonDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
