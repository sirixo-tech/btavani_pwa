part of '../../../main.dart';

class AuctionPage extends StatefulWidget {
  const AuctionPage({super.key});

  @override
  State<AuctionPage> createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  int _highestBid = 11501;
  String _highestBidder = 'I-1204';
  bool _isSubmitting = false;

  Future<void> _placeBid() async {
    final result = await showDialog<BidDetails>(
      context: context,
      builder: (context) => BidDialog(currentBid: _highestBid),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = EventApiService();
      await api.submitBid(
        amount: result.amount,
        bidderName: '', // Bidder name is not in the form, just flat number
        flatNumber: result.flatNumber,
        mobile: '',
      );
      if (!mounted) return;
      setState(() {
        _highestBid = result.amount;
        _highestBidder = result.flatNumber;
      });
      _snack(context, 'Bid submitted successfully');
    } catch (e) {
      if (!mounted) return;
      _snack(context, 'Failed to submit bid: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Laddoo Auction (Coming Soon)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_paper, _surfaceWarm],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _maroonDark.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LabelPill(label: 'LIVE AUCTION', color: _gold),
                ),
                const SizedBox(height: 18),
                const Text(
                  'LADDOO AUCTION',
                  style: TextStyle(
                    color: _maroonDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Current Highest Bid',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Rs ${_formatBid(_highestBid)}',
                  style: const TextStyle(
                    color: _maroon,
                    fontWeight: FontWeight.w900,
                    fontSize: 38,
                  ),
                ),
                Text(
                  'by $_highestBidder',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ends in',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const TimerRow(),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'PLACE YOUR BID',
                  isLoading: _isSubmitting,
                  onPressed: _placeBid,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: () {}, child: const Text('View All Bids')),
        ],
      ),
    );
  }

  String _formatBid(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class BidDetails {
  const BidDetails({required this.amount, required this.flatNumber});

  final int amount;
  final String flatNumber;
}

class BidDialog extends StatefulWidget {
  const BidDialog({required this.currentBid, super.key});

  final int currentBid;

  @override
  State<BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _flatController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  void _submitBid() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      BidDetails(
        amount: int.parse(_amountController.text.trim()),
        flatNumber: _flatController.text.trim().toUpperCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Place Your Bid',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: 'Bid Amount',
                prefixText: 'Rs ',
                hintText: '${widget.currentBid + 500}',
              ),
              validator: (value) {
                final amount = int.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= widget.currentBid) {
                  return 'Enter more than Rs ${widget.currentBid}.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _flatController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Flat Number',
                hintText: 'e.g. I-1204',
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Please enter your flat number.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _submitBid,
          style: ElevatedButton.styleFrom(
            backgroundColor: _maroon,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'SUBMIT BID',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class TimerRow extends StatelessWidget {
  const TimerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimeChunk(value: '02', label: 'HOURS'),
          Text(
            ' : ',
            style: TextStyle(
              color: _maroon,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          TimeChunk(value: '35', label: 'MINS'),
          Text(
            ' : ',
            style: TextStyle(
              color: _maroon,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          TimeChunk(value: '18', label: 'SECS'),
        ],
      ),
    );
  }
}

class TimeChunk extends StatelessWidget {
  const TimeChunk({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _paper,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: _maroon,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
